// SC class exercise 1: first adaptation
// a class does all the heavy lifting
// it defines our SynthDefs, handles variables, etc.

Moonshine {

	// we want 'params' to be accessible any time we instantiate this class,
	// so we'll prepend it with '<', which turns 'params' into a 'getter' method
	// see 'Getters and Setters' at https://doc.sccode.org/Guides/WritingClasses.html for more info
	var <params;

	// in SuperCollider, asterisks denote functions which are specific to the class.
	// '*initClass' is called when the class is initialized: https://doc.sccode.org/Classes/Class.html#*initClass
	*initClass {
		StartUp.add {
			var s = Server.default;
			// we need to make sure the server is running before asking it to do anything
			s.waitForBoot {
				// this is just our SynthDef from 'rude mechanicals':

				 // allocate memory to the following:

		// ** add your SynthDefs here **

				var winenv, winenv2, winenv3, winenv4;

				// Buffer stuff and preparation
				/////////////////////////////////////////
				b = Buffer.alloc(context.server, context.server.sampleRate*4 , 1);

				/////////////////////////////////////////
				//Initialize grain windows
				/*
				winenv = Env([0, 1, 0], [0.001, 0.05], [1, -8]);
				z = Buffer.sendCollection(context.server, winenv.discretize, 1);

				winenv2 = Env([0, 1, 0], [0.3, 0.05], [1, -8]);
				y = Buffer.sendCollection(context.server, winenv2.discretize, 1);

				winenv3 = Env([0, 1, 0.9, 0.8, 0], [0.00001, 0.002, 0.05, 0.01], [1,-1,]);
				w = Buffer.sendCollection(context.server,winenv3.discretize,1);

				winenv4 = Env([0, 1, 0], [0.3, 0.05, 0.5], [1, -8]);
				v = Buffer.sendCollection(context.server,winenv4.discretize,1);*/

				// if you need your SynthDef to be available before commands are sent,
				//  sync with the server by ** uncommenting the following line **:



				SynthDef(\DaemonBuf, {
					// define three variables that will contain the three part of my synthDef ( recording and different playbacks )
					arg decimator = 0, frames = 0, brick = 1.5, startPos = 0;
					var grainz, play, recz, mix, direct,recIn, local, rTrigz, gTrig, ptrRec, ptrPlay, max1, grainz_PV;

					direct = In.ar(\inBus.ar(0),1);

					frames = b.numFrames;

					local = LocalIn.ar(2);

					recIn = (direct*\inLvl.kr(1)) + (local*\overdubLvl.kr(0.3)); // receive the audio from the mix

					/*	rTrigz = Trig1.ar(Dust.kr(\burstRate.kr(1)-0.2));
					gTrig = Trig1.ar(Dust.kr(\grainRate.kr(5)-0.2));*/

					//TODO: How to modify the playback position


					ptrRec = Phasor.ar(
						trig: \trigRec.tr(1),
						rate: BufRateScale.kr(b.bufnum)*\rateRec.kr(0.5).lag(\rateRecLag.kr(0)),
						start: 0,
						end: frames,
						resetPos: startPos / frames);

					ptrPlay = Phasor.ar(
						trig: \trigPlay.tr(1),
						rate: BufRateScale.kr(b.bufnum)*\ratePlay.kr(0.5).lag(\ratePlayLag.kr(0)),
						start: 0,
						end: frames,
						resetPos: startPos / frames);

					SendReply.kr(Impulse.kr(18), '/ptrs', [ptrRec/frames, ptrPlay/frames], 69);

					recz = BufWr.ar(
						inputArray: recIn.sum * \recLvl.kr(1), //audioIn
						bufnum: b.bufnum,
						phase: ptrRec,
						loop: \recLoop.kr(1)
					);
					0.0;

					play = BufRd.ar(
						numChannels: 1,
						bufnum: b.bufnum,
						phase: ptrPlay,
						loop: \playLoop.kr(0)
					);

					/*	grainz = GrainBuf.ar(
					numChannels: 1,
					trigger: gTrig,
					dur: \durGrain.kr(0.2),
					sndbuf: b,
					rate: TChoose.kr(gTrig, [2,4,1.3333,0.25,0.5, 1])*TChoose.kr(gTrig,[1, 1, 1, 0, -1, -1]),
					envbufnum: TChoose.kr(gTrig, [z,y,w,v])
					);

					// PhaseVocoder Brickwall filter
					grainz_PV = FFT(LocalBuf(2048), grainz);
					grainz_PV = PV_BrickWall(grainz_PV, TRand.kr(-1,1,gTrig));
					grainz_PV = Pan2.ar(IFFT(grainz_PV),TRand.kr(-1,1,gTrig));*/



					// grainz = ((brick<1)*grainz) + ((brick>1)*grainz_PV);

					mix=(grainz*\grainLvl.kr(0)) + (play*\playLvl.kr(0)) + (direct*\directLvl.ar(0));

					// effects

					mix =  ((decimator<1)*mix)+((decimator>1)*Decimator.ar(mix, TChoose.kr(rTrigz, [44100,8000, 16000, 12000, 6000, 35000,2]).lag(0), decimator));

					mix = LeakDC.ar(mix);

					LocalOut.ar(mix);

					Out.ar(\outBus.kr(0), mix.tanh);
				}).add;

			} // s.waitForBoot
		} // StartUp
	} // *initClass

	*new { // when this class is initialized...
		^super.new.init; // ...run the 'init' below.
	}

	init {
		// build a list of our sound-shaping parameters, with default values
		// (see https://doc.sccode.org/Classes/Dictionary.html for more about Dictionaries):
		params = Dictionary.newFrom([
			\sub_div, 2,
			\noise_level, 0.1,
			\cutoff, 8000,
			\resonance, 3,
			\attack, 0,
			\release, 0.4,
			\amp, 0.5,
			\pan, 0;
		]);
	}

	// these methods will populate in SuperCollider when we instantiate the class
	//   'trigger' to play a note with the current 'params' settings:
	trigger { arg freq;
		Synth.new("Moonshine", [\freq, freq] ++ params.getPairs);
		// '++ params.getPairs' iterates through all the 'params' above,
		//   and sends them as [key, value] pairs
	}
	//   'setParam' to set one of our 'params' to a new value:
	setParam { arg paramKey, paramValue;
		params[paramKey] = paramValue;
	}

}

