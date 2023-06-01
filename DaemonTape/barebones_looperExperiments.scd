///////  Preparing and Testing the sound....

// Change input devices
Server.default.options.outDevice_("HUAWEI FreeBuds Pro");
Server.default.options.outDevice_("MacBook Pro Speakers");
Server.default.options.inDevice_("MacBook Pro Microphone");
Server.default.options.inDevice_("BlackHole 2ch");


{arg hola=0;SinOsc.ar()*EnvGen.kr(Env.perc,doneAction:2)*(hola<1)}.play;

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

x.set(\recLoop, 1);
x.set(\loopzLoop, 1, \loopzTrig,1);
x.set(\loopzTrig,1);
x.set(\loopzLoop,0);
x.set(\inBus,~input01);
x.set(\directLvl,0);
x.set(\grainLvl,1.5);
x.set(\loop,1);
x.set(\preLevel,0.5);
x.set(\rate,-1);
x.set(\decimator,13);
x.set(\overdubLvl,1);

b.plot


(
// Buffer stuff and preparation
b.free;
/////////////////////////////////////////
b = Buffer.alloc(s, s.sampleRate*8 , 1);

SynthDef(\bufferMangz, {
	// define three variables that will contain the three part of my synthDef ( recording and different playbacks )
	arg decimator = 0;
	var grainz, loopz, recz, mix, direct,recIn;

	direct = In.ar(\inBus.ar(~input01),1);
	recIn = direct + (LocalIn.ar(1)*\overdubLvl.kr(0)); // receive the audio from the mix


	recz = RecordBuf.ar(
		inputArray: recIn, //audioIn
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
		rate:\rate.kr(1).lag(\rateLag.kr(0)),
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

	mix =  ((decimator<1)*mix)+((decimator>1)*Decimator.ar(mix, 25000, decimator)); //Bitcrusher TODO: add Demand to random the rates...
	LocalOut.ar(mix);

	Out.ar(0, mix);
}).add;
)


