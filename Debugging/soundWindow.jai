SoundWindow :: struct {
    using window : Window;
    audio : *Audio;

    samplesFile : File;
    samplesFileOpen : bool;
    frameIndex : u16;
	eofReached : bool;

	samples : [..]s16;
	framesPerScreen : u16 = 10;
};

Init :: (using soundWindow: *SoundWindow, Width: u16, Height: u16, Title: string, posX: s32, posY: s32, gb: *GameBoy) {
    Init(*window, Width, Height, Title, posX, posY, false);
    audio = *gb.audio;
}

Cleanup :: (using soundWindow: *SoundWindow) {
    CloseStream(soundWindow);
}

CloseStream :: (using soundWindow: *SoundWindow) {
	if samplesFileOpen {
		file_close(*samplesFile);
        samplesFileOpen = false;
    }
}

OpenStream :: (using soundWindow: *SoundWindow) {
    frameIndex = 0;
	eofReached = false;
    array_reserve(*samples, 735 * framesPerScreen);
    file, success := file_open("samples.bin", false);
    if !success
        print("Error loading samples.bin");
    else {
        samplesFile = file;
        samplesFileOpen = true;
        Update(soundWindow);
    }
}

NextFrame :: (using soundWindow: *SoundWindow) {
    if !eofReached {
        frameIndex += 1;
        Update(soundWindow);
    }
}

PreviousFrame :: (using soundWindow: *SoundWindow) {
    if frameIndex > 0 {
        frameIndex -= 1;
		eofReached = false;
        Update(soundWindow);
    }
}

IncrementFramesPerScreen :: (using soundWindow: *SoundWindow) {
	framesPerScreen += 1;
	array_resize(*samples, 735 * framesPerScreen);
	print("framesPerScreen %\n",framesPerScreen);
	Update(soundWindow);
}

DecrementFramesPerScreen :: (using soundWindow: *SoundWindow) {
	if framesPerScreen > 1 {
		framesPerScreen -= 1;
		array_resize(*samples, 735 * framesPerScreen);
		print("framesPerScreen %\n",framesPerScreen);
		Update(soundWindow);
	}
}

Update :: (using soundWindow: *SoundWindow) {
    if !IsOpen(soundWindow)
        return;

    length := file_length(samplesFile);
    readOffset := frameIndex * 735 * 2;
    bytesToRead := 735 * framesPerScreen * 2;
    bytesLeft := length - readOffset;

    file_set_position(samplesFile, readOffset);

    array_resize(*samples, bytesToRead);
    if bytesLeft > bytesToRead
        file_read(samplesFile, samples.data, bytesToRead);
    else {
        file_read(samplesFile, samples.data, bytesLeft);
		memset(samples.data, 0, bytesToRead - bytesLeft);
		eofReached = true;
	}

    memset(screenArray.data, 0xFF, width * height * 2);

    x, y : s32;

    // Zero line, gray
    for 0..width-1
        screenArray[width * height / 2 + it] = 0xC210;

	lastY : s32 = cast(s32)(height / 2) - samples[0] / cast(s32)height;
	max, min : s16;
    for index: 0..width-1 {
        // Red dots at the first row for frames
		if (index % (width / framesPerScreen)) == 0
			screenArray[index] = 0x801F;

        sampleIndex := index * 735 / width;
		sample := samples[sampleIndex * framesPerScreen] / cast(s16)height;
        y = cast(s32)(height / 2) - sample;

		if sample > max
			max = sample;
		if sample < min
			min = sample;

		if y > cast,no_check(s32)height
			continue;

        // Black for vertical lines
        if lastY < y {
            for i: lastY..y
                screenArray[width * cast,no_check(u32)i + index] = 0x8000;
        } else if lastY > y {
            for < i: lastY..y
                screenArray[width * cast,no_check(u32)i + index] = 0x8000;
        }

        lastY = y;

        // Black for the current sample
        screenArray[width * cast,no_check(u32)y + index] = 0x8000;
    }
    
    SDL_UpdateTexture(screenTexture, null, screenArray.data, xx (width * 2));
    SDL_RenderCopy(renderer, screenTexture, null, null);
    SDL_RenderPresent(renderer);

    frameTime : float = 1 / 60.0;
    print("Showing samples for frame %. From % to %\n", frameIndex, frameTime * frameIndex, frameTime * (frameIndex + framesPerScreen));
	print("Min % - Max %\n", min, max);
}
