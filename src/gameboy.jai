#load "interruptService.jai";
#load "cartridge.jai";
#load "mmu.jai";
#load "cpu.jai";
#load "gpu.jai";
#load "timer.jai";
#load "joypad.jai";
#load "serialDataTransfer.jai";
#load "audio.jai";

EmulationModeSetting :: enum {
    Detect;
    ForceGameBoy;
    ForceGameBoyColor;
};

GameBoy :: struct {
    cartridge : Cartridge;
    mmu : MMU;
    cpu : CPU;
    intService : InterruptServiceRoutine;
    gpu : GPU;
    timer : Timer;
    joypad : Joypad;
    serial : SerialDataTransfer;
    audio : Audio;

    frameFinished : bool;
    sampleGenerated : bool;

    syncWithAudio := true;

	IsCGB : bool;

	isPaused : bool;
	stepsToEmulate : u8;
    
    skipBios : bool;
};

Init :: (using gameBoy: *GameBoy, RomPath: string) {
    Init(*cartridge, RomPath);
    mmu.cpu = *cpu;
    mmu.cartridge = *cartridge;
    mmu.intService = *intService;
    mmu.gpu = *gpu;
    mmu.timer = *timer;
    mmu.joypad = *joypad;
    mmu.serial = *serial;
    mmu.audio = *audio;
    
    Init(*cpu, *mmu, *intService);
    Init(*gpu, *mmu, *intService);
    timer.intService = *intService;
    joypad.intService = *intService;
    serial.intService = *intService;

	// TODO load settings from a settings file
	emulationModeSetting := EmulationModeSetting.Detect;
    startLogging := false;

    skipBios = true;
	syncWithAudio = true;
    isPaused = false;

	if emulationModeSetting == {
	case .Detect;
		IsCGB = IsGBCCartridge(*cartridge);
	case .ForceGameBoy;
		IsCGB = false;
	case .ForceGameBoyColor;
		IsCGB = true;
	}

	gpu.isCGB = IsCGB;
    
    if skipBios
        LoadState(gameBoy);
	else
		LoadBootRom(*mmu, IsCGB);

    if startLogging
        ToggleLogging(gameBoy);
}

ToggleLogging :: (using gameBoy: *GameBoy) {
    cpu.doLogs = !cpu.doLogs;
    gpu.doLogs = !gpu.doLogs;
    gpu.dma.doLogs = !gpu.dma.doLogs;
    cartridge.mbc.doLogs = !cartridge.mbc.doLogs;
    joypad.doLogs = !joypad.doLogs;
    intService.doLogs = !intService.doLogs;
}

Reset :: (using gameBoy: *GameBoy) {
    cpu.pc = 0;
    Write(*mmu, 0xFF50, 0);
    // TODO reset all components
}

MainLoop :: (using gameBoy: *GameBoy) {
    if isPaused
        return;

	// boot rom finished, entry point of game code
    //if cpu.pc == 0x100 && !skipBios
	//	SaveState(gameBoy);

    if cpu.pc == 0x00e0
		a := 1;//ToggleLogging(gameBoy);

    lastOpCycles := Step(*cpu);
    frameFinished = Step(*gpu, lastOpCycles * 4, IsDoubleSpeedEnabled(*cpu));
    Step(*timer, lastOpCycles * 4);
    sampleGenerated = Step(*audio, lastOpCycles, IsDoubleSpeedEnabled(*cpu));
    Step(*serial, lastOpCycles * 4, IsDoubleSpeedEnabled(*cpu));

	if stepsToEmulate > 0 {
		stepsToEmulate -= 1;
		if stepsToEmulate == 0
			isPaused = true;
	}
}

LoadState :: (using gameBoy: *GameBoy) {
    bootStateFileName : string;
    if IsCGB 
        bootStateFileName = "../Files/CGBBootState.bin";
    else
        bootStateFileName = "../Files/DMGBootState.bin";

    fileContent, success := read_entire_file(bootStateFileName);
    if success {
        backup := fileContent;
        defer free(backup);

	    Load(*cpu, *fileContent);
        Load(*mmu, *fileContent);
        Load(*gpu, *fileContent);
        Load(*intService, *fileContent);
        // TODO Load audio, timer, joystick, serial
    }
}

SaveState :: (using gameBoy: *GameBoy) {
    bootStateFileName : string;
    if IsCGB 
        bootStateFileName = "../Files/CGBBootState.bin";
    else
        bootStateFileName = "../Files/DMGBootState.bin";
    
    builder: String_Builder;
    defer free_buffers(*builder);

    Save(*cpu, *builder);
    Save(*mmu, *builder);
    Save(*gpu, *builder);
    Save(*intService, *builder);
	// TODO Save audio, timer, joystick, serial

    stateStr := builder_to_string(*builder);
    defer free(stateStr);

    write_entire_file(bootStateFileName, stateStr);
}
