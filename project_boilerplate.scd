s.quit;

// **********************************************************************
// 1. SERVER CONFIG - any server setup key to this piece
// **********************************************************************

~isHome = true;

s = Server.local;
if(~isHome, { // home vars
	s.options.outDevice_('Built-in Output');
	s.options.inDevice_('Built-in Microph');
	s.options.numOutputBusChannels_(4); 
	s.options.numInputBusChannels_(2); 
	s.options.sampleRate_(44100);
	~projectPath = "/Users/Pete/Documents/my-coding/supercollider/projects/project_loopers"; // home
	
}, { // studio vars
	s.options.device = "DN32-USB"; 
	s.options.numOutputBusChannels_(8); 
	s.options.numInputBusChannels_(8);
	s.options.sampleRate_(48000);
	~projectPath = "/Users/petethomas/code/project_loopers";
});

s.options.memSize_(2.pow(20)); // roughly 1 gig of realtime memory
s.newBusAllocators;
ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

// **********************************************************************
// 2. INIT GLOBAL VARIABLES
// **********************************************************************
// outs
~out = 0;
~tapBus1 = 2;
~synthsPath = ~projectPath++"/synths";
~midiPath = ~projectPath++"/midi";
~guiPath = ~projectPath++"/gui";

// **********************************************************************
// 3. DEFINE PIECE SPECIFIC FUNCTIONS
// **********************************************************************
~makeBuffers = {
	// ~looperBuf1 = Buffer.alloc(s, 44100 * 20, 1); // a 20 second 1 channel Buffer
	// ~looperBuf1MaxDelay = ~looperBuf1.numFrames / ~looperBuf1.sampleRate;
};

~makeBusses = {
	~busses = Dictionary.new;
	~busses.add(\reverb -> Bus.audio(s, 2));
	// add more busses as you need them
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

~makeNodes = {
	// ~mainGroup = Group.new;
	// ~reverbGroup = Group.after(~mainGroup);

	// define more fx nodes as you need them
};
~makeGui = {
	// MIDIIn.connectAll
	g = Dictionary.new;
	g.add(\looperGui -> (~guiPath++"/looper_gui.scd").load);
	g.add(\looperGui2 -> (~guiPath++"/looper_gui2.scd").load);
	
};
~makeMidi = {
	MIDIIn.connectAll;
	e = Dictionary.new;
	e.add(\controls -> (~midiPath++"/controls.scd").load);
};

// **********************************************************************
// 4. REGISTER FUNCTIONS WITH ABSTRACT SERVER ACTION
// **********************************************************************
ServerBoot.add(~makeBuffers); // make ~buffers
ServerBoot.add(~makeBusses); // make ~busses
ServerQuit.add(~cleanup); // clean up when quit the server

// **********************************************************************
// 5. BOOT SERVER
// **********************************************************************
s.waitForBoot({
	s.sync; // ensure actions have completed before moving on (synchronous)
	// 5a. REGISTER SYNTHDEFS
	(~synthsPath++"/tapDelay.scd").load;
	(~synthsPath++"/looper.scd").load;
	s.sync;
	// load state
	(~projectPath++"/data.scd").load;
	// 5b. CREATE NODES AND EVENTS
	ServerTree.add(~makeNodes); // delay these until you've created your nodes
	ServerTree.add(~makeGui); 
	// TODO: add controls back in
	// ServerTree.add(~makeMidi); 
	s.freeAll;
	s.sync;
	s.plotTree;
	// s.meter;
	// 5c. NOW READY TO BEGIN PERFORMANCE
	"Done".postln;
});

// **********************************************************************
// 6. PERFORMANCE
// **********************************************************************
// args in, out
// g[\looperGui2].value(0, 0);