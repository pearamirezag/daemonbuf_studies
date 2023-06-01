Server.default.options.outDevice_("HUAWEI FreeBuds Pro");
Server.default.options.inDevice_("Macbook Pro Speakers");
Server.default.options.outDevice_("Fireface UCX (23925971)");
Server.default.options.inDevice_("Fireface UCX (23925971)");
Server.default.options.inDevice_("Macbook Pro Microphone");
Server.default.options.inDevice_("BlackHole 2ch");
Server.default.options.numOutputBusChannels = 6;
Server.default.options.numInputBusChannels = 6;
Server.default.options.outDevice;

Server.default.options.inDevice
s.reboot;


(
{
	arg hola=0;
	var	sig = SinOsc.ar(440+100.rand)*EnvGen.kr(Env.perc,Impulse.kr(10.rand/10))*(hola<1);
	Out.ar(0,sig);
}.play;
)

~inBus = Array.fill(6, {arg i; Bus.audio(s,1)});
~outBus = Array.fill(6, {arg i; Bus.audio(s,1)});

// Maybe each route also neets to be an synthdefinition




s.newBusAllocators;

Bus.browse
Server.freeAll

(
SynthDef(\matrixmix, {
	SoundIn.ar([0,1,2,3,4,5]);


	grid=
	// en un array bidimensional la X es el input y el Y es el output
	//grid[0] es el x -- es decir el input
	//grid[1] es el Y -- es decir el output
	//grid[2} es el z -- sería si está abierto o cerrada la conexión
	Out.ar(grid[1],In.ar(~inBus[grid[0]],1);); // [0,1]
	Out.ar(grid[4],In.ar(~inBus[grid[0]],1);); // [0,4]



	Out.ar([0,1,2,3,4,5],sig) //this is where it writes to the outboard gear
}).add;

)


// First I need to create the busses in which the sounds need to travel into
// then what could i do to indicate that when I press a button, a channel is connected to another??
// maybe throu osc or midi messages... how can I plug busses to other busses



// Array.fill(6, {arg i; Bus.audio(s,1)});