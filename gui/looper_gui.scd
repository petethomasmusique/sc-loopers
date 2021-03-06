(
	{|in1, in2, out, tapBus|

	    var synth, win, buttons, labels, firstTime=true, startTime=0, loopTime, cols=2, rows=2, size=80, fadeFunc, isMute=false, buffer;
	    // manually fade on certain actions to avoid pops
	    s.meter;
	    fadeFunc = {|from, to, dur, syn, param|
	    	var fade;
			{fade = Env([from,to],[dur]).asStream;
    		1000.do({
    			syn.set(param, fade.next);
    			(dur/1000).wait;
    		})}.fork;
	    };
	    
	    // synth
	    synth = Synth(\looper, 
	    	[\buffer, Buffer.alloc(s, s.options.sampleRate * 20, 1), \inBus, in1, \inBus2, in2, \outBus, out, \tapBus, tapBus, \loopTime, 19.9];
	    );
	    // GUI window
	    win = Window(\looper, Rect(0, 0, 165, 165), false);

	    // create buttons
	    buttons = 0!(cols*rows);
	    buttons = buttons
	    	.collect({|item, i| Button(win, Rect((i % cols) * size  + 5, trunc(i/cols) * size + 5, size-5, size-5))});


	    // rec button
		buttons[0]
			.states_([
				["O", Color.grey(0.2), Color.new(136/255, 80/255, 83/255)],
				["O", Color.grey(0.2), Color.new(254/255, 95/255, 85/255)],
		    ])
			.action_({ |bu|
				if(bu.value == 0, {
			        fadeFunc.value(1,0,0.05, synth, \record); // fade out to avoid pops
			        if(firstTime) {
			            loopTime = thisThread.clock.beats - startTime; 
			            synth.set(\loopTime, loopTime);
			            firstTime = false;
			        };
		        });
				if(bu.value == 1, {
		            if(firstTime) { startTime = thisThread.clock.beats };
		            fadeFunc.value(0,1,0.05, synth, \record); // fade in to avoid pops
		        });
			});

		// erase button
		buttons[1]
			.states_([
		        ["x", Color.grey(0.2), Color.new(198/255, 236/255, 174/255)],
		    ])
		    .action_({ arg bu;
		    	Task({
			        buttons[0].value = 0;
			        buttons[2].value = 0;
			        buttons[3].value = 0;
			        if(isMute == false, {fadeFunc.value(1.0,0.0,0.05, synth, \outMul)}); // fade out to avoid pops
			        buffer.free;
			        0.1.wait;
			        synth.set(\buffer, Buffer.alloc(s, s.options.sampleRate * 20, 1), \record, 0, \loopTime, 19.9);
			        fadeFunc.value(0.0,1.0,0.05, synth, \outMul); // fade in to avoid pops
			        firstTime = true;
		    	}).start(AppClock);
		    });

	    // play/pause button
		buttons[2]
			.states_([
		        ["||", Color.grey(0.2), Color.new(148/255, 201/255, 169/255)],
		        [">", Color.grey(0.2), Color.new(148/255, 201/255, 169/255, 0.5)],
		    ])
		    .action_({ arg bu;
		    	if(bu.value == 0, {
		    		fadeFunc.value(0,1,0.001,synth,\outMul);
		    		isMute = false;
		    	});
		    	if(bu.value == 1, { 
		    		fadeFunc.value(1,0,0.001,synth,\outMul);
		    		isMute = true; 
		    	});
		    });

	    // oct button
		buttons[3]
			.states_([
		        ["-", Color.grey(0.2), Color.new(119/255, 125/255, 167/255)],
		        ["+", Color.grey(0.2), Color.new(119/255, 125/255, 167/255, 0.5)],
		    ])
		    .action_({ arg bu;
		    	// TODO
		    });


	    win.onClose_({synth.free;}).front;
	}
)
