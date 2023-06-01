///////  Preparing and Testing the sound....

// Change input devices
Server.default.options.outDevice_("HUAWEI FreeBuds Pro");
Server.default.options.outDevice_("MacBook Pro Speakers");
Server.default.options.inDevice_("MacBook Pro Microphone");
Server.default.options.inDevice_("BlackHole 2ch");


{arg hola=0;SinOsc.ar()*EnvGen.kr(Env.perc,doneAction:2)*(hola<1)}.play;

{(SinOsc.ar()*LFPulse.kr(1,width: 0.1))}.play;

//// Initialize the demo Sounds

~file = "/Users/airpc/zuri_left.wav"
~testfile = Buffer.read(s,~file);

~testfile.allocReadChannel(~file, channels: 0);

/*~testfile.play;*/
~testfile.plot;

/*Buffer.freeAll;*/
~input01 = Bus.audio(s,1);



({PlayBuf.ar(1,~testfile.bufnum,startPos: 1.0.rand *~testfile.numFrames,loop: 1);
}.play(s,~input01);
~input01.scope;
)

x = Synth(\bufferMangz,[\inBus,~input01],  addAction: 'addToTail');

x.set(\recLoop, 1, \recTrig,1);
x.set(\loopzLoop, 1, \loopzTrig,1);
x.set(\loopzTrig,1);
x.set(\loopzLoop,0);
x.set(\inBus,~input01);
x.set(\directLvl,0);
x.set(\grainLvl,0.4);
x.set(\loop,1);
x.set(\preLevel,0.4);
x.set(\rate, 1);
x.set(\rateLag,1);
x.set(\decimator,22);
x.set(\overdubLvl,0.8);

b.plot;





(
// Buffer stuff and preparation
b.free;
/////////////////////////////////////////
b = Buffer.alloc(s, s.sampleRate*2 , 1);

SynthDef(\bufferMangz, {
	// define three variables that will contain the three part of my synthDef ( recording and different playbacks )
	arg decimator = 0;
	var grainz, loopz, recz, mix, direct,recIn, local,rTrigz;

	direct = In.ar(\inBus.ar(~input01),1);
	local = LocalIn.ar(2);
	recIn = direct + (local*\overdubLvl.kr(0)); // receive the audio from the mix

	rTrigz = Dust.kr(\burstRate.kr(1));

	recz = RecordBuf.ar(
		inputArray: recIn.sum, //audioIn
		bufnum: b.bufnum,
		recLevel: \recLevel.kr(1),
		preLevel: \preLevel.kr(0),
		run: \recRun.kr(1),
		loop: \recLoop.kr(0),
		trigger: \recTrig.kr(0)
	);

	loopz = PlayBuf.ar(
	1,
		bufnum: b.bufnum,
		rate:\rate.kr(1).lag(\rateLag.kr(1)),
		trigger: \loopzTrig.kr(1),
		startPos: 0,
		loop: \loopzLoop.kr(0)
);

	grainz = Pan2.ar(GrainBuf.ar(
		numChannels: 1,
		trigger: Dust.ar(\dustRate.kr(5)),
		dur: 0.2,
		sndbuf: b,
		rate: LFNoise1.kr(15),),
	LFNoise0.kr(10)
	);

	mix = (grainz*\grainLvl.kr(0.3)) + (loopz*\grainLvl.kr(0.3)) + (direct*\directLvl.ar(0.3));

	// effects

	mix =  ((decimator<1)*mix)+((decimator>1)*Decimator.ar(mix, TChoose.kr(rTrigz, [44100,8000, 16000, 12000, 6000, 35000]).lag(1), decimator)); //Bitcrusher TODO: add Demand to random the rates...
	mix = LeakDC.ar(mix);

	LocalOut.ar(mix + ((SinOsc.ar()*LFPulse.kr(3,width: 0.1))) );

	Out.ar(0, mix);
}).add;
)

///////////////////



b.numFrames-b.numFrames.rand

(

var winenv, winenv2, winenv3, winenv4 ;
// Buffer stuff and preparation
b.free;
/////////////////////////////////////////
b = Buffer.alloc(s, s.sampleRate*2 , 1);

/////////////////////////////////////////
//Initialize grain windows

winenv = Env([0, 1, 0], [0.001, 0.05], [1, -8]);
z = Buffer.sendCollection(s, winenv.discretize, 1);

winenv2 = Env([0, 1, 0], [0.3, 0.05], [1, -8]);
y = Buffer.sendCollection(s, winenv2.discretize, 1);

winenv3 = Env([0, 1, 0.9, 0.8, 0], [0.00001, 0.002, 0.05, 0.01], [1,-1,]);
w = Buffer.sendCollection(s,winenv3.discretize,1);

winenv4 = Env([0, 1, 0], [0.3, 0.05, 0.5], [1, -8]);
v = Buffer.sendCollection(s,winenv4.discretize,1);




SynthDef(\bufPointMang, {
	// define three variables that will contain the three part of my synthDef ( recording and different playbacks )
	arg decimator = 0, frames = 0;
	var grainz, play, recz, mix, direct,recIn, local, rTrigz, gTrig, ptrRec, ptrPlay, max1, grainz_PV;

	direct = In.ar(\inBus.ar(~input01),1);

	frames = b.numFrames;

	local = LocalIn.ar(2);

	recIn = (direct) + (local*\overdubLvl.kr(0.3)); // receive the audio from the mix

	rTrigz = Trig1.ar(Dust.kr(\burstRate.kr(1)));
	gTrig = Trig1.ar(Dust.kr(\grainRate.kr(5)));


	ptrRec = Phasor.ar(
		trig: \trigRec.tr(1),
		rate: BufRateScale.kr(b.bufnum)*\rateRec.kr(0.5).lag(\rateRecLag.kr(0)),
		start: 0,
		end: frames,
		resetPos: \start.kr(0) / frames);

	ptrPlay = Phasor.ar(
		trig: \trigPlay.tr(1),
		rate: BufRateScale.kr(b.bufnum)*\ratePlay.kr(0.5).lag(\ratePlayLag.kr(0)),
		start: 0,
		end: frames,
		resetPos: \start.kr(0) / frames);

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
		loop: \loopzLoop.kr(0)
	);

	grainz = GrainBuf.ar(
		numChannels: 1,
		trigger: gTrig,
		dur: 0.2,
		sndbuf: b,
		rate: TChoose.kr(gTrig, [2,4,1.3333,0.25,0.5, 1])*TChoose.kr(gTrig,[1, 1, 1, 0, -1, -1]),
		envbufnum: TChoose.kr(gTrig, [z,y,w,v])
	);

	// PhaseVocoder Brickwall filter
	grainz_PV = FFT(LocalBuf(2048), grainz);
	grainz_PV = PV_BrickWall(grainz_PV, LFNoise0.kr(10));
	grainz_PV = Pan2.ar(IFFT(grainz_PV),TRand.kr(-1,1,gTrig));

	grainz = (brick<1)*grainz + (grainz_PV * )

	mix=(grainz*\grainLvl.kr(0)) + (play*\loopLvl.kr(0)) + (direct*\directLvl.ar(0));

	// effects

	mix =  ((decimator<1)*mix)+((decimator>1)*Decimator.ar(mix, TChoose.kr(rTrigz, [44100,8000, 16000, 12000, 6000, 35000,2]).lag(0), decimator));
	mix = LeakDC.ar(mix);

	LocalOut.ar(mix);

	Out.ar(0, mix);
}).add;
)

Counter


({PlayBuf.ar(1,~testfile.bufnum,startPos: 1.0.rand *~testfile.numFrames,loop: 1);
}.play(s,~input01);
~input01.scope;
)

x=Synth(\bufPointMang,[\inBus,~input01],  addAction: 'addToTail');


x.set(\loopzLoop, 1);
x.set(\recLoop, 1);
x.set(\trigPlay,1);
x.set(\trigRec,1)
x.set(\start, 0.3);
x.set(\loopzTrig,1);
x.set(\loopzLoop,0);
x.set(\loopLvl,0.2);
x.set(\inBus,~input01);
x.set(\directLvl,0);
x.set(\recLvl,0);
x.set(\rateRec,0.7);
x.set(\ratePlay,-0.13333);
x.set(\ratePlayLag,4);
x.set(\grainLvl,0.7);
x.set(\loop,1);
x.set(\preLevel,0.6);
x.set(\rate, 0.2);
x.set(\rateLag,4);
x.set(\decimator,10);
x.set(\grainRate, 20);
x.set(\overdubLvl,0.7);

b.plot;


b.numFrames;




(
// register to receive this message
o = OSCFunc({ arg msg;

	 //msg.postln; // The msg contains several information about the trigger sent in the SynthDef

	//I found that to get distinct messages each of them has to be separated by control structures

	if(msg[2]==69,{
	NetAddr("127.0.0.1",7771).sendMsg("ptr1",1,  msg[3]);
	},{});

	if(msg[2]==69,{
	NetAddr("127.0.0.1",7771).sendMsg("ptr2",1,  msg[4]);
	},{});

		// NetAddr("127.0.0.1",7771).sendMsg("aves",msg[2], msg[3]);
		// NetAddr("127.0.0.1",7771).sendMsg("trus",msg[2], msg[3]);
	// msg.postln;
},'/ptrs', s.addr);   /// In this line is where we set that we are receiving from the SendTrig.kr in the UGen

)

o.free




NetAddr("127.0.0.1",7771).sendMsg("ptr",1, 1);






Env([0, 1, 0], [0.3, 0.05, 0.5], [1, -8]).plot
