#import "Basic";
#import "SDL";
#import "String";
#import "System";

#load "roms.jai";
#load "gameboy.jai";
#load "gameWindow.jai";
#load "audioStream.jai";
#load "../Debugging/palettesWindow.jai";
#load "../Debugging/tilesWindow.jai";
#load "../Debugging/tileMapWindow.jai";
#load "../Debugging/soundWindow.jai";
#load "../Debugging/spritesWindow.jai";
#load "../Debugging/stateWindow.jai";

WindowWidth :: 160;
WindowHeight :: 144;

main :: () {
    set_working_directory(path_strip_filename(get_path_of_running_executable()));

    commandLineArgs := get_command_line_arguments();
    romPath, romName : string;

	if commandLineArgs.count > 1 {
		romPath = commandLineArgs[1];
		romName = path_filename(romPath);
		print("Loading rom from args = %\n", romPath);
	} else {
        //romName = "gb-test-roms-master/cpu_instrs/individual/02-interrupts.gb";
        romName = "cgb/Tetris DX (World) (SGB Enhanced) (GB Compatible).gbc";
		romPath = join(HardcodedRomsDir, romName);
        print("Loading hardcoded rom from = %\n", romPath);
	}

    gameName := path_strip_extension(romName);
    
    gameBoy : GameBoy;
    Init(*gameBoy, romPath);
    defer Cleanup(*gameBoy.cartridge);

    SDL_Init(SDL_INIT_VIDEO);

    gameWindow : GameWindow;
    Init(*gameWindow, 160, 144, "Game", 0, 40, true);
    defer Cleanup(*gameWindow);
    gameWindow.gpu = *gameBoy.gpu;
    gameBoy.gpu.gameWindow = *gameWindow;

    tilesWindow : TilesWindow;
    Init(*tilesWindow, 128, 192, "Tiles", 350, 40, *gameBoy);
    defer Cleanup(*tilesWindow);

    tileMap0Window : TileMapWindow;
    Init(*tileMap0Window, 256, 256, "Tile map 0", 600, 40, *gameBoy, 0);
    defer Cleanup(*tileMap0Window);

    tileMap1Window : TileMapWindow;
    Init(*tileMap1Window, 256, 256, "Tile map 1", 600, 40, *gameBoy, 1);
    defer Cleanup(*tileMap1Window);

    spritesWindow : SpritesWindow;
    Init(*spritesWindow, 256 + 8, 256 + 16, "Sprites", 700, 40, *gameBoy);
    defer Cleanup(*spritesWindow);

    soundWindow : SoundWindow;
    Init(*soundWindow, 360, 150, "Sound", 0, 400, *gameBoy);
    defer Cleanup(*soundWindow);

    palettesWindow : PalettesWindow;
    Init(*palettesWindow, 250, 200, "Palettes", 700, 50, *gameBoy);
    defer Cleanup(*palettesWindow);

    stateWindow : StateWindow;
    Init(*stateWindow, 250, 144, "State", 400, 50, *gameBoy);
    defer Cleanup(*stateWindow);

    // Used only when not syncing emulation with audio
	SamplesSize : u16 : 735;
	samples : [SamplesSize]s16;
	sampleIndex : u32;
	/*sf::SoundBuffer Buffer;
	sf::Sound Sound;*/
    
    framesCount : u32;
	previousTime := get_time();

    audioStream : AudioStream;
    Init(*audioStream, *gameBoy);
    defer {
        if gameBoy.syncWithAudio
            Cleanup(*audioStream);
    }

    if gameBoy.syncWithAudio
        Play(*audioStream);

    framesToLog : u8;
    breakAt : u16 = 0xFFFF;
    exit := false;
    while !exit {
        if !gameBoy.syncWithAudio {
            MainLoop(*gameBoy);

            if gameBoy.sampleGenerated {
                samples[sampleIndex] = gameBoy.audio.sample;
                sampleIndex += 1;

                if sampleIndex == SamplesSize {
                    /*Buffer.loadFromSamples(samples, SamplesSize, 1, 44100);
                    Sound.setBuffer(Buffer);
                    Sound.play();*/
                    sampleIndex = 0;
                }
            }
        }

        if gameBoy.cpu.pc == breakAt {
            gameBoy.isPaused = true;
            Open(*stateWindow);
            Open(*tileMap0Window);
            Open(*palettesWindow);
            GiveFocus(*gameWindow);
        }

        if gameBoy.isPaused || gameBoy.frameFinished {
            if framesToLog > 0 {
                framesToLog -= 1;
                if framesToLog == 0 {
                    gameBoy.cpu.doLogs = false;
                    gameBoy.gpu.doLogs = false;
                    gameBoy.gpu.dma.doLogs = false;
                    gameBoy.cartridge.mbc.doLogs = false;
                    gameBoy.joypad.doLogs = false;
                }
            }

            Update(*gameWindow);
            Update(*tilesWindow);
            Update(*tileMap0Window);
            Update(*tileMap1Window);
            Update(*spritesWindow);
			Update(*stateWindow);
			Update(*palettesWindow);

            event : SDL_Event;
            while SDL_PollEvent(*event) {
                focusedWindow := SDL_GetKeyboardFocus();
                focusedWindowID := SDL_GetWindowID(focusedWindow);

                if focusedWindow == gameWindow.renderWindow {
                    if event.type == {
                    case SDL_WINDOWEVENT;
                        if event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == focusedWindowID
                            exit = true;
                    case SDL_KEYUP;
                        sym := event.key.keysym.sym;
                        if sym == SDLK_ESCAPE
                            exit = true;
                        else if sym >= SDLK_0 && sym <= SDLK_9 {
                            if sym == {
                            case SDLK_1; Toggle(*tilesWindow); GiveFocus(*gameWindow);
                            case SDLK_2; Toggle(*tileMap0Window); GiveFocus(*gameWindow);
                            case SDLK_3; Toggle(*tileMap1Window); GiveFocus(*gameWindow);
                            case SDLK_4; Toggle(*spritesWindow); GiveFocus(*gameWindow);
                            case SDLK_5; Toggle(*soundWindow); GiveFocus(*gameWindow);
                            case SDLK_6; Toggle(*stateWindow); GiveFocus(*gameWindow);
                            case SDLK_7; Toggle(*palettesWindow); GiveFocus(*gameWindow);
                            case SDLK_8; ToggleChannel(*gameBoy.audio, 1);
                            case SDLK_9; ToggleChannel(*gameBoy.audio, 2);
                            case SDLK_0; ToggleChannel(*gameBoy.audio, 3);
                            //case SDLK_0; ToggleChannel(*gameBoy.audio, 4);
                            }
                        } else if sym == SDLK_F9 {
                            gameBoy.isPaused = !gameBoy.isPaused;
                        } else if sym == SDLK_r {
                            Reset(*gameBoy);
                            Clear(*gameWindow);
                        } else if sym == SDLK_l {
                            ToggleLogging(*gameBoy);
                            //framesToLog = 2;
                        } else if sym == SDLK_F3 {
                            gameBoy.isPaused = false;
                            gameBoy.stepsToEmulate = 1;
                        } else if sym == SDLK_w {
                            gameBoy.isPaused = false;
                            gameBoy.stepsToEmulate = 10;
                        } else if sym == SDLK_e {
                            gameBoy.isPaused = false;
                            gameBoy.stepsToEmulate = 100;
                        } else if sym == SDLK_c
                            TakeScreenshot(*gameWindow);
                        else if sym == SDLK_q {
                            if !audioStream.isRecording {
                                CloseStream(*soundWindow);
                                StartRecording(*audioStream);
                            } else {
                                StopRecording(*audioStream);
                                OpenStream(*soundWindow);
                            }
                        }
                    }
                }

                if focusedWindow == tilesWindow.renderWindow {
                    if event.type == {
                    case SDL_WINDOWEVENT;
                        if event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == focusedWindowID
                            Close(*tilesWindow);
                    case SDL_KEYUP;
                        sym := event.key.keysym.sym;
                        if sym == SDLK_ESCAPE
                            Close(*tilesWindow);
                        else if sym == SDLK_PAGEUP
                            NextPalette(*tilesWindow);
                        else if sym == SDLK_PAGEDOWN
                            PreviousPalette(*tilesWindow);
                        else if sym == SDLK_END
                            ToggleBank(*tilesWindow);
                        else if sym == SDLK_HOME
                            ToggleBgSprite(*tilesWindow);
                    case SDL_MOUSEBUTTONDOWN;
                        OnMouseClicked(*tilesWindow, xx event.button.x, xx event.button.y);
                    }
                }

                if focusedWindow == soundWindow.renderWindow {
                    if event.type == {
                    case SDL_WINDOWEVENT;
                        if event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == focusedWindowID
                            Close(*soundWindow);
                    case SDL_KEYUP;
                        sym := event.key.keysym.sym;
                        if sym == SDLK_ESCAPE
                            Close(*soundWindow);
                        else if sym == SDLK_PAGEUP
                            NextFrame(*soundWindow);
                        else if sym == SDLK_PAGEDOWN
                            PreviousFrame(*soundWindow);
                        else if sym == SDLK_KP_PLUS
                            IncrementFramesPerScreen(*soundWindow);
                        else if sym == SDLK_KP_MINUS
                            DecrementFramesPerScreen(*soundWindow);
                        else if sym == SDLK_y {
                            if audioStream.isRecording
                                StopRecording(*audioStream);
                            OpenStream(*soundWindow);
                        }
                    }
                }

                if focusedWindow == spritesWindow.renderWindow {
                    if event.type == {
                    case SDL_WINDOWEVENT;
                        if event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == focusedWindowID
                            Close(*spritesWindow);
                    case SDL_KEYUP;
                        sym := event.key.keysym.sym;
                        if sym == SDLK_ESCAPE
                            Close(*spritesWindow);
                        else if sym == SDLK_END
                            ToggleBackground(*spritesWindow);
                    case SDL_MOUSEBUTTONDOWN;
                        OnMouseClicked(*spritesWindow, xx event.button.x, xx event.button.y);
                    }
                }

                if focusedWindow == tileMap0Window.renderWindow {
                    if event.type == {
                    case SDL_WINDOWEVENT;
                        if event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == focusedWindowID
                            Close(*tileMap0Window);
                    case SDL_MOUSEBUTTONDOWN;
                        OnMouseClicked(*tileMap0Window, xx event.button.x, xx event.button.y);
                    }
                }

                if focusedWindow == tileMap1Window.renderWindow {
                    if event.type == {
                    case SDL_WINDOWEVENT;
                        if event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == focusedWindowID
                            Close(*tileMap1Window);
                    case SDL_MOUSEBUTTONDOWN;
                        OnMouseClicked(*tileMap1Window, xx event.button.x, xx event.button.y);
                    }
                }
            }
            
            framesCount += 1;
            currentTime := get_time();
            if currentTime - previousTime >= 1 {
				SetTitle(*gameWindow, tprint("Game - FPS: %\0", framesCount));
                //print("FPS: %\n",framesCount);
                previousTime = currentTime;
                framesCount = 0;
            }
        }
        reset_temporary_storage();
    }

    SDL_Quit();
}

//#run main();