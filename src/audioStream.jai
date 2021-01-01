SamplesSize : u16 : 735;
MaxRecordedSeconds : u32 : 5;

AudioStream :: struct {
    gb : *GameBoy;
    sdlStream : *SDL_AudioStream;

    //samples : [SamplesSize]s16;
    //sampleIndex : s32;

    recordedFrames : u32;
    isRecording : bool;
	outFile : File;
};

Init :: (using audioStream: *AudioStream, gameBoy: *GameBoy) {
    gb = gameBoy;
}

Play :: (using audioStream: *AudioStream) {
    using audioSpec : SDL_AudioSpec;
    freq = 44100;
    format = AUDIO_S16;
    channels = 1;
    samples = 256;
    callback = GetSamples;
	userdata = audioStream;

    if SDL_OpenAudio(*audioSpec, null) < 0 {
	  print("ERROR: Couldn't open audio: %s\n", SDL_GetError());
	  return;
	}

    SDL_PauseAudio(0);
}

Cleanup :: (using audioStream: *AudioStream) {
    SDL_CloseAudio();
}

GetSamples :: (userdata: *void, stream: *u8, length: s32) #c_call {
    using audioStream := cast(*AudioStream)userdata;

    stream16 : *s16 = cast,no_check(*s16)stream;

    sampleIndex : s32;
    while sampleIndex < (length / 2) {
        new_context: Context;
        push_context new_context {
            MainLoop(gb);

            if gb.sampleGenerated {
                stream16[sampleIndex] = gb.audio.sample;
                sampleIndex += 1;
            }

            if gb.frameFinished && isRecording
                recordedFrames += 1;
        }
    }

    
    if isRecording {
        new_context: Context;
        push_context new_context {
            file_write(*outFile, stream, length);
            if recordedFrames >= 60 * MaxRecordedSeconds
                StopRecording(audioStream);
        }
    }
}

StartRecording :: (using audioStream: *AudioStream) {
	if isRecording
		return;

    isRecording = true;
    recordedFrames = 0;
	file, success := file_open("samples.bin", true);
    outFile = file;
}

StopRecording :: (using audioStream: *AudioStream) {
	if !isRecording
		return;

	file_close(*outFile);
	print("Recorded % seconds of samples\n", recordedFrames / 60.0);
	isRecording = false;
}