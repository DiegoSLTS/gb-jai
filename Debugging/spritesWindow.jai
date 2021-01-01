SpritesWindow :: struct {
    using window : Window;

	gameBoy : *GameBoy;

	IsCGB : bool;
	lcdc : *LCDC;
	oam : *u8; // cached pointer to OAM to avoid going through MMU for each read

	clearColor : u8 = 0xFF;
    loggedSprite : u8 = 255;
};

Init :: (using spritesWindow: *SpritesWindow, Width: u16, Height: u16, Title: string, posX: s32, posY: s32, gb: *GameBoy) {
    Init(*window, Width, Height, Title, posX, posY, false);
    gameBoy = gb;
    lcdc = GetLCDCRef(*gameBoy.gpu);
	oam = GetOAMPtr(*gameBoy.gpu);
	IsCGB = gameBoy.IsCGB;

	Update(spritesWindow);
}

Update :: (using spritesWindow: *SpritesWindow) {
    if !IsOpen(spritesWindow)
        return;

	memset(screenArray.data, clearColor, width * height * 2);
	for 0..39
		DrawSprite(spritesWindow, xx it);

	SDL_UpdateTexture(screenTexture, null, screenArray.data, xx (width * 2));
    SDL_RenderCopy(renderer, screenTexture, null, null);
    SDL_RenderPresent(renderer);
}

DrawSprite :: (using spritesWindow: *SpritesWindow, index: u8) {
	spriteIndex := index * 4;

	spriteY := oam[spriteIndex];
	spriteX := oam[spriteIndex + 1];
	tileIndex : u16 = oam[spriteIndex + 2];
	attributes := MakeOBJAttributes(oam[spriteIndex + 3]);

	tileAddress : u16 = 0x8000 + tileIndex * 16;

	for line: 0..lcdc.SpritesHeight-1 {
        spriteLine := cast(u8)line;
        if attributes.FlipY 
            spriteLine = lcdc.SpritesHeight - 1 - line;
        
		lowByte := ReadVRAM(*gameBoy.gpu, tileAddress + spriteLine * 2, attributes.Bank);
		highByte := ReadVRAM(*gameBoy.gpu, tileAddress + spriteLine * 2 + 1, attributes.Bank);

        screenPosBase := cast(u16)(spriteY + line - 1) * (256 + 8) + spriteX;

        for < bit: 7..0 {
			pixel : u8;
			if attributes.FlipX
				pixel = xx (7 - bit);
			else
				pixel = xx bit;
            
            screenPos := screenPosBase + (7 - bit);
            
			lowBit := (lowByte >> pixel) & 0x01;
			highBit := (highByte >> pixel) & 0x01;
			index := lowBit | (highBit << 1);

            if index > 0 {
				pixelInfo : PixelInfo;
				pixelInfo.ColorIndex = index;
                if IsCGB
				    pixelInfo.PaletteIndex = attributes.PaletteIndex;
                else
                    pixelInfo.PaletteIndex = attributes.Palette;

				screenArray[screenPos] = GetABGR(*gameBoy.gpu, *pixelInfo);
            }
        }
	}
}

ToggleBackground :: (using spritesWindow: *SpritesWindow) {
    if clearColor == 0x00
	    clearColor = 0xFF;
    else
        clearColor = 0x00;
}

OnMouseClicked :: (using spritesWindow: *SpritesWindow, x: u32, y: u32) {
    index : u8;
    spriteIndex : u8;
    found : bool;
    for 0..39 {
        spriteIndex = cast,no_check(u8)it * 4;
        spriteY := oam[spriteIndex];
        spriteX := oam[spriteIndex + 1];
        
        if spriteX <= (x >> 1) && spriteX + 8 >= (x >> 1) && spriteY <= (y >> 1) && spriteY + lcdc.SpritesHeight >= (y >> 1) {
            found = true;
            index = cast,no_check(u8)it;
            break;
        }
    }

    if found && spriteIndex != loggedSprite {
        print("\nMouse X: % Y: %\n", x, y);
        loggedSprite = index;
        PrintSprite(spritesWindow, loggedSprite);
    }
}

PrintSprite :: (using spritesWindow: *SpritesWindow, index: u8) {
    oamIndex := index * 4;    
    tileIndex : u16 = oam[oamIndex + 2];
    attributes := MakeOBJAttributes(oam[oamIndex + 3]);
    dataAddress := 0x8000 + tileIndex * 16;

    print("Sprite: % (8x%)\n", index, lcdc.SpritesHeight);
    print("Tile index: %\n", u8ToHex(tileIndex));
    print("Data address: %\n", u16ToHex(dataAddress));
    print("X: %\n", oam[oamIndex + 1]);
    print("Y: %\n", oam[oamIndex]);
    print("Bank: %\n", attributes.Bank);
    print("Flip X: %\n", attributes.FlipX);
    print("Flip Y: %\n", attributes.FlipY);
    print("Priority: %\n", attributes.BehindBG);
    print("BG Palette: %\n", attributes.Palette);
    print("CGB Palette: %\n", attributes.PaletteIndex);
}
