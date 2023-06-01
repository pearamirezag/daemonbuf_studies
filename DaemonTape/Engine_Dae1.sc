Engine_Dae1 : CroneEngine {

  var <params;
	var synth;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
		SynthDef(\Dae1, {
			arg rate = 1, recLoop = 1, outBus = 0, start = 0, selRate = 0.5, in_db = -6.0;
			var snd, ptr, in, rec, frames, buf;

			buf = Buffer.alloc(context.server, context.server.sampleRate* 2, 1);

			in = Mix.ar(SoundIn.ar([0,1],1)) * in_db.dbamp;

			frames = BufFrames.kr(buf.bufnum);

			ptr = Phasor.ar(start, BufRateScale.kr(buf.bufnum) * rate, 0, frames);

			SendReply.kr(Impulse.kr(1),'/ptrVal',values:ptr, replyID:99);
			//ptr.range(0,1).scope;

			rec = BufWr.ar(in,buf.bufnum,ptr,recLoop);

			//SendReply.kr(Impulse.kr(10),'/ptrVal',values: Amplitude.kr(rec), replyID: 66);

			snd = BufRd.ar(1, buf.bufnum, SelectX.ar(LFNoise0.kr(selRate),[ptr,(-1*ptr)]));

			// LocalOut.ar();
			//b.plot;
			Out.ar(outBus, snd.tanh);
		}).add;


    context.server.sync;

		synth = Synth(\Dae1, [\outBus, context.out_b.index], target: context.xg);

		/*params = Dictionary.newFrom([
			\rate, 1,
			\recLoop, 1,
			\outBus, 0,
			\selRate, 0.5
		]);*/

		this.addCommand("rate", "i", {|msg|
			synth.set(\rate, msg[1]);
		});

		this.addCommand("recLoop", "i", {|msg|
			synth.set(\recLoop, msg[1]);
		});

		this.addCommand("selRate", "i", {|msg|
			synth.set(\selRate, msg[1]);
		});

		this.addCommand("in_db", "i", {|msg|
			synth.set(\in_db, msg[1]);
		});




  free {
			synth.free;

  }}
}