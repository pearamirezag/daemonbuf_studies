(
SynthDef("Moonshine", {
	// let's build a raw sound:
	var pulse = Pulse.ar(freq: 300);
	var saw = Saw.ar(freq: 300);
	var sub = Pulse.ar(freq: 300/2);
	var noise = WhiteNoise.ar(mul: 0.1);
	var mix = Mix.ar([pulse,saw,sub,noise]);

	// and generate an envelope:
	var envelope = Env.perc(attackTime: 0.3, releaseTime: 2).kr(doneAction: 2);

	// put the raw sound through a resonant filter
	//  and modulate the filter with the envelope
	var filter = MoogFF.ar(in: mix, freq: 6000 * envelope, gain: 3);

	// our filtered signal is then multiplied by our envelope, panned to center:
	var signal = Pan2.ar(filter*envelope,0);

	// let's send our signal to the output:
	Out.ar(0,signal);

	}).add;
)

x = Synth(\Moonshine);