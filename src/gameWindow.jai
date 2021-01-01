Window :: struct {
    width : u32;
    height : u32;

    screenArray : [..]u16;
    renderWindow : *SDL_Window;
    renderer : *SDL_Renderer;
    screenTexture : *SDL_Texture;
};

GameWindow :: struct {
    using window : Window;
    gpu : *GPU;
    //screenshotTexture : *SDL_Texture;
    //sf::Uint32* screenShotData = nullptr;
    //u16 screenshotsCount = 0;
    romName : string;
};

// Should be defined in SDL_pixels.h
SDL_PIXELFORMAT_RGBA8888 :: 373694468;
SDL_PIXELFORMAT_ABGR1555 :: 359862274;

Init :: (using window: *Window, Width: u16, Height: u16, Title: string, posX: s32, posY: s32, open: bool) {
	width = Width;
    height = Height;
	
    windowFlags := SDL_WINDOW_OPENGL;
    if open
        windowFlags |= SDL_WINDOW_SHOWN;
    else
        windowFlags |= SDL_WINDOW_HIDDEN;

    renderWindow = SDL_CreateWindow(Title.data, posX, posY,
        cast(s32)width * 2, cast(s32)height * 2, windowFlags);

    if renderWindow == null {
        print("Could not create window: %\n", to_string(SDL_GetError()));
        return;
    }

    SDL_SetWindowResizable(renderWindow, xx true);

    renderer = SDL_CreateRenderer(renderWindow, -1, .ACCELERATED /*.PRESENTVSYNC*/);
    screenTexture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ABGR1555, cast(s32)SDL_TextureAccess.STREAMING, xx width, xx height);

    array_resize(*screenArray, width * height);
}

Cleanup :: (using window: *Window) {
    Close(window);
    array_free(screenArray);
    SDL_DestroyTexture(screenTexture);
    screenTexture = null;
    SDL_DestroyRenderer(renderer);
    renderer = null;
    SDL_DestroyWindow(renderWindow);
    renderWindow = null;
}

DrawLine :: (using gameWindow: *GameWindow, line: u8) {
    x : u32 = line * width;
	xMax : u32 = x + width;
    
    for x..xMax-1
        screenArray[it] = GetABGR(gpu, *gpu.screen[it]);
}

Clear :: (using window: *Window) {
    memset(screenArray.data, 0xFF, width * height * 2);
}

Update :: (using gameWindow: *GameWindow) {
    SDL_UpdateTexture(screenTexture, null, screenArray.data, xx (width * 2));
    SDL_RenderCopy(renderer, screenTexture, null, null);
    SDL_RenderPresent(renderer);
}

Open :: (using window: *Window) {
    if !IsOpen(window)
        SDL_ShowWindow(renderWindow);
}

Close :: (using window: *Window) {
    if IsOpen(window)
        SDL_HideWindow(renderWindow);
}

IsOpen :: (using window: *Window) -> bool {
    flags := SDL_GetWindowFlags(renderWindow);
    return (flags & SDL_WINDOW_SHOWN) != 0;
}

Toggle :: (using window: *Window) {
    if (IsOpen(window))
        Close(window);
    else
        Open(window);
}

GiveFocus :: (using window: *Window) {
    SDL_RaiseWindow(renderWindow);
}

SetTitle :: (using window: *Window, title: string) {
    SDL_SetWindowTitle(renderWindow,title.data);
}

TakeScreenshot :: (using gameWindow: *GameWindow) {
    /*sf::Uint32* originalPixels = ((sf::Uint32*)screenArray);
    const u16 w = width * 2;
    for (u8 y = 0; y < height; y++) {
        for (u8 x = 0; x < width; x++) {
            u32 srcIndex = y * width + x;
            u32 destIndex = (y * w + x) * 2;
            sf::Uint32 color = originalPixels[srcIndex];
            screenShotData[destIndex] = color;
            screenShotData[destIndex + 1] = color;
            screenShotData[destIndex + w] = color;
            screenShotData[destIndex + w + 1] = color;
        }
    }
    screenshotTexture.update((sf::Uint8*)screenShotData);
    screenshotTexture.copyToImage().saveToFile(romName + "_" + std::to_string(screenshotsCount) + ".jpg");
    screenshotsCount++;*/
}
