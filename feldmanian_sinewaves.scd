/*
* feldmanian_sinewaves
*
*
*
* Diego Villaseñor
*
*
* Volos-Athens, Greece, June 2017
*
* v.1.1.1
*/



//controles
~active_synths.postln;
~play_synth.(~ss);
~stop_synth.(~active_synths);
~dont_continue.();


(//paso 3. iniciar reproducción
~automatic_playing.(4);
)


(//paso 2. generar los sonidos
~ss = ~feldmanian_sinewaves.(
	12.54,
	[
		[9,10],
		[11,12],
		[13,14],
		[15,16],
		[17,19],
		[21, 23],
		[29, 31],
		[33, 37],
		[41, 43],
		[47, 49]
	]
);
)


/*paso 0. iniciar servidor*/
s.boot;

(//paso 1. precargar todo lo necesario

//~active_synths :: [ Synth [Synth, Synth] ]
~active_synths = List[];
//~ss :: [ Synth [Synth, Synth] ]
~ss = List[];

~feldmanian_sinewaves = {|fundamental, harmonic_pair_list|

	//harm_pair  :: Number -> [Int, Int] -> [Number, Number]
	var harm_pair = { |fundamental, pair| pair.collect({|int| int * fundamental})};

	//freq_pair_list :: HarmPairs [[harm1, harm2]] -> FreqPairs[[freq1, freq2]]
	var make_freq_pairs = _.collect(harm_pair.(fundamental, _));

	//freq_pair_list :: FreqPairs [[freq1, freq2]]
	var freq_pair_list = make_freq_pairs.(harmonic_pair_list);

	//make_synth_pair :: [freq1, freq2] -> [Synth, Synth]
	var make_synth_pair = {
		|freq_pair|
		{
			[SinOsc.ar(
				freq_pair[0],
				LFNoise2.kr(0.001, 10)*0.00001,
				LFNoise2.kr(0.5, 100)*0.01
			),
			SinOsc.ar(
				freq_pair[1],
				LFNoise2.kr(0.001, 10)*0.00001,
				LFNoise2.kr(0.8, 100)*0.01
			)]
		}
	};

	//[FSinewaves [Synth, Synth]]
	freq_pair_list.collect(make_synth_pair);
};


//activación y desactivación de los sintes

~play_synth = {
	|ss|
	var len, selected, playing;
	len = ss.size;
	selected = ss[len.rand];
	playing = selected.play(fadeTime:6);
	~active_synths.add(playing);
	~active_synths.size.postln;
};

~stop_synth = {
	|active_ss|
	var len, stopped;

	len = active_ss.size;
	if(len > 0, {
		"borrando".postln;
		stopped = active_ss.removeAt(len.rand);
		stopped.release;
	}, {});
	~active_synths.size.postln;
};


//manejo del tiempo
~continue = true;

//continuar o no la reproducción automática
~do_continue = {~continue = true};
~dont_continue = {~continue = false};

~automatic_playing = {
	|time|
	if(~continue == true,
		{
			SystemClock.sched(rrand(4.0,120), {
				if(~active_synths.size > 1, {
					~stop_synth.(~active_synths);
				}, {})

			});
			SystemClock.sched(time, {
				~play_synth.(~ss);
				~automatic_playing.(rrand(4.0,60));
			});
		},
		{
			"recursive calls are disabled".postln
		}
	)
};



)