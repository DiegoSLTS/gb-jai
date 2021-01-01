TilesWindow :: struct {
    using window : Window;
	gameBoy : *GameBoy;

	isCGB : bool;

	tilesPerRow : u8;
	rows : u8;
    
    cgbPaletteIndex : u8;
    VRAMBank : u8;
    displayAsBG : bool = true;

    loggedTileX : u8 = 255;
    loggedTileY : u8 = 255;
};

Init :: (using tilesWindow: *TilesWindow, Width: u16, Height: u16, Title: string, posX: s32, posY: s32, gb: *GameBoy) {
    Init(*tilesWindow.window, Width, Height, Title, posX, posY, false);
    gameBoy = gb;
	tilesPerRow = xx (Width / 8);
	rows = xx (Height / 8);
    isCGB = gameBoy.IsCGB;
}

Update :: (using tilesWindow: *TilesWindow) {
    if !IsOpen(tilesWindow)
        return;
        
    for y: 0..rows-1
		for x: 0..tilesPerRow-1
			UpdateTile(tilesWindow, x, y);

	SDL_UpdateTexture(screenTexture, null, screenArray.data, xx (width * 2));
    SDL_RenderCopy(renderer, screenTexture, null, null);
    SDL_RenderPresent(renderer);
}

GetTileAddress :: (using tilesWindow: *TilesWindow, x: u8, y: u8) -> u16 {
	return 0x8000 + (cast(u16)y * tilesPerRow + x) * 16;
}

UpdateTile :: (using tilesWindow: *TilesWindow, x: u8, y: u8) {
	tileDataAddress := GetTileAddress(tilesWindow, x, y);

	for line: 0..7 {
		lowByte := ReadVRAM(*gameBoy.gpu, xx (tileDataAddress + line * 2), VRAMBank);
		highByte := ReadVRAM(*gameBoy.gpu, xx (tileDataAddress + line * 2 + 1), VRAMBank);

        screenPosBase := (y * 8 + line) * width + x * 8;

        for < pixel: 7..0 {
            screenPos := screenPosBase + (7 - pixel);
			lowBit := (lowByte >> pixel) & 0x01;
			highBit := (highByte >> pixel) & 0x01;
			pixelInfo : PixelInfo;
			pixelInfo.ColorIndex = lowBit | (highBit << 1);
            pixelInfo.PaletteIndex = cgbPaletteIndex;
			pixelInfo.IsBG = displayAsBG;
            
			screenArray[screenPos] = GetABGR(*gameBoy.gpu, *pixelInfo);
        }
	}
}

NextPalette :: (using tilesWindow: *TilesWindow) {
    if cgbPaletteIndex == 7
        cgbPaletteIndex = 0;
    else
        cgbPaletteIndex += 1;
    UpdateTitle(tilesWindow);
}

PreviousPalette :: (using tilesWindow: *TilesWindow) {
    if cgbPaletteIndex == 0
        cgbPaletteIndex = 7;
    else
        cgbPaletteIndex -= 1;
    UpdateTitle(tilesWindow);
}

ToggleBank :: (using tilesWindow: *TilesWindow) {
    VRAMBank = (VRAMBank + 1) % 2;
    UpdateTitle(tilesWindow);
}

ToggleBgSprite :: (using tilesWindow: *TilesWindow) {
    displayAsBG = !displayAsBG;
    UpdateTitle(tilesWindow);
}

UpdateTitle :: (using tilesWindow: *TilesWindow) {
    displayMode : string;
    if displayAsBG
        displayMode = "BG";
    else
        displayMode = "OBJ";
    
    /*if isCGB
        SetTitle(tilesWindow, tprint("% (CGB) - Bank: % - Palette: %",title,displayMode,VRAMBank,cgbPaletteIndex));
    else
        SetTitle(tilesWindow, tprint("% (GB) - %",title,displayMode));*/
}

PrintTile :: (using tilesWindow: *TilesWindow, x: u8, y: u8) {
    print("\nTile X: % Y: %\n", x, y);
    print("Map address: %\n", u16ToHex(GetTileAddress(tilesWindow, x, y)));
}

OnMouseClicked :: (using tilesWindow: *TilesWindow, x: u32, y: u32) {
    newX := x / 16; // tile size (8) * window scale (2)
    newY := y / 16;

    if newX != loggedTileX || newY != loggedTileY {
        loggedTileX = xx newX;
        loggedTileY = xx newY;
        PrintTile(tilesWindow, loggedTileX, loggedTileY);
    }
}
