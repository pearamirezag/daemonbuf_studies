(
Server.default = Server.local;

~m = MonomeGrid.new(0);

s.waitForBoot({
	arg togs;
	var draw;

	~m.connect(0);

	/*~m.rot(1);*/

	~togs = Array.fill(36, {0});


	// togs.postln;

	~m.key({
		arg x,y,z;
		draw.play();
		//x.postln;
		// ~togs[y*16+x].postln;
		~togs[y*1].postln;
//		~m.led(x,y,~togs[y*16+x]*15);
//		[x,y,z].postln;
	});


	draw = {
		for(10,15) {
			arg i;
			for(2,7){
				arg j;
				~m.led(i,j,4);
			};
		}
	};
	draw.play();
});
)
