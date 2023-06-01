Engine_DaemonBuf1 : CroneEngine {

	// ** add your variables here **

	var <params, <synth;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	// This is called when the engine is actually loaded by a script.
	// You can assume it will be called in a Routine,
	//  and you can use .sync and .wait methods.
	alloc { // allocate memory to the following:

		// ** add your SynthDefs here **

		var winenv, winenv2, winenv3, winenv4;

		// Buffer stuff and preparation
		/////////////////////////////////////////
		b = Buffer.alloc(context.server, context.server.sampleRate*4 , 1);

		/////////////////////////////////////////
		//Initialize grain windows

		winenv = Env([0, 1, 0], [0.001, 0.05], [1, -8]);
		z = Buffer.sendCollection(context.server, winenv.discretize, 1);

		winenv2 = Env([0, 1, 0], [0.3, 0.05], [1, -8]);
		y = Buffer.sendCollection(context.server, winenv2.discretize, 1);

		winenv3 = Env([0, 1, 0.9, 0.8, 0], [0.00001, 0.002, 0.05, 0.01], [1,-1,]);
		w = Buffer.sendCollection(context.server,winenv3.discretize,1);

		winenv4 = Env([0, 1, 0], [0.3, 0.05, 0.5], [1, -8]);
		v = Buffer.sendCollection(context.server,winenv4.discretize,1);
		// if you need your SynthDef to be available before commands are sent,
		//  sync with the server by ** uncommenting the following line **:
		Server.default.sync;

		SynthDef(\DaemonBuf, {
			// define three variables that will contain the three part of my synthDef ( recording and different playbacks )
			arg decimator = 0, frames = 0, brick = 1.5, startPos = 0;
			var grainz, play, recz, mix, direct,recIn, local, rTrigz, gTrig, ptrRec, ptrPlay, max1, grainz_PV;

			direct = In.ar(\inBus.ar(0),1);

			frames = b.numFrames;

			local = LocalIn.ar(2);

			recIn = (direct*\inLvl.kr(1)) + (local*\overdubLvl.kr(0.3)); // receive the audio from the mix

			rTrigz = Trig1.ar(Dust.kr(\burstRate.kr(1)-0.2));
			gTrig = Trig1.ar(Dust.kr(\grainRate.kr(5)-0.2));

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

			grainz = GrainBuf.ar(
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
			grainz_PV = Pan2.ar(IFFT(grainz_PV),TRand.kr(-1,1,gTrig));



			grainz = ((brick<1)*grainz) + ((brick>1)*grainz_PV);

			mix=(grainz*\grainLvl.kr(0)) + (play*\playLvl.kr(0)) + (direct*\directLvl.ar(0));

			// effects

			mix =  ((decimator<1)*mix)+((decimator>1)*Decimator.ar(mix, TChoose.kr(rTrigz, [44100,8000, 16000, 12000, 6000, 35000,2]).lag(0), decimator));

			mix = LeakDC.ar(mix);

			LocalOut.ar(mix);

			Out.ar(\outBus.kr(0), mix.tanh);
		}).add;

		context.server.sync;

		synth = Synth.new(\DaemonBuf, [
			\inBus, context.in_b[0].index;
			\outBus, context.out_b.index],
		target:context.xg);

		*new {
			// when this class is initialized...
			^super.new.init; // ...run the 'init' below.
		}

		init {
			params = Dictionary.newFrom([
				\startPos, 0,
				\brick, 1.5,
				\decimator, 24,
				\inBus, 0,
				\inLvl, 0.8,
				\overdubLvl, 0.6,
				\burstRate, 5,
				\grainRate, 10,
				\trigRec, 1,
				\rateRec, 1,
				\rateRecLag, 1,
				\trigPlay, 1,
				\ratePlay, 1,
				\ratePlayLag, 4,
				\recLvl, 0.9,
				\recLoop, 1,
				\playLoop, 1,
				\durGrain, 0.2,
				\grainLvl, 0.6,
				\playLvl, 0.5,
				\directLvl, 0,
				\outBus, 0
			]);
		}

		// ** add your commands here **

		params.keysDo({ arg key;
			this.addCommand(key, "f", { arg msg;
				params[key] = msg[1];
			});
		});

		/*	this.addCommand("hz", "f", { arg msg;
		Synth.new("DaemonBuf", [\trigRec, msg[1]] ++ params.getPairs)
		});*/

	}

	free {
		synth.free
	}

}

