TileMapWindow :: struct {
    using tWindow: TilesWindow;
	
    map : u8;
    address : u16;
	lcdc : *LCDC;
};

Init :: (using tileMapWindow: *TileMapWindow, Width: u16, Height: u16, Title: string, posX: s32, posY: s32, gb: *GameBoy, mapNumber: u8) {
    Init(*tileMapWindow.tWindow, Width, Height, Title, posX, posY, gb);
    map = mapNumber;
    lcdc = GetLCDCRef(*gameBoy.gpu);
    if map == 0
        address = 0x9800;
    else
        address = 0x9C00;
}

GetTileAddress :: (using tileMapWindow: *TileMapWindow, x: u8, y: u8) -> u16 {
    // y casted to u16 so multiplying by 32 gives a u16
	tileOffset := ReadVRAM(*gameBoy.gpu, address + cast(u16)y * 32 + x, 0);
    tileAddress := lcdc.BgWinData;
    if lcdc.BgWinData == 0x8000
        tileAddress += (cast(u16)tileOffset) * 16;
    else {
        // TODO simplify this?
        temp := cast,no_check(s8)tileOffset;
        temp2 := cast(s16)temp;
        temp3 := cast,no_check(u16)temp2;
        tileAddress += temp3 * 16;
    }
    return tileAddress;
}

Update :: (using tileMapWindow: *TileMapWindow) {
    if !IsOpen(tileMapWindow)
        return;

    for y: 0..rows-1
		for x: 0..tilesPerRow-1
			UpdateTile(tileMapWindow, x, y);

	SDL_UpdateTexture(screenTexture, null, screenArray.data, xx (width * 2));
    SDL_RenderCopy(renderer, screenTexture, null, null);
    SDL_RenderPresent(renderer);
}

UpdateTile :: (using tileMapWindow: *TileMapWindow, x: u8, y: u8) {
    tileDataAddress := GetTileAddress(tileMapWindow, x, y);
    value : u8;
    if isCGB
        value = ReadVRAM(*gameBoy.gpu, address + y * 32 + x, 1);
	attributes := MakeBGAttributes(value);

    for line: 0..7 {
        tileLine : u8 = xx line;
        if attributes.FlipY
            tileLine = xx (7 - line);
        
		lowByte := ReadVRAM(*gameBoy.gpu, tileDataAddress + tileLine * 2, attributes.Bank);
		highByte := ReadVRAM(*gameBoy.gpu, tileDataAddress + tileLine * 2 + 1, attributes.Bank);

        screenPosBase := (y * 8 + line) * width + x * 8;
        for < bit: 7..0 {
            pixel : u8;
			if attributes.FlipX
				pixel = xx (7 - bit);
			else
				pixel = xx bit;
            
            screenPos := screenPosBase + (7 - bit);
            lowBit := (lowByte >> pixel) & 0x01;
            highBit := (highByte >> pixel) & 0x01;
			pixelInfo : PixelInfo;
			pixelInfo.ColorIndex = lowBit | (highBit << 1);
            pixelInfo.PaletteIndex = attributes.PaletteIndex;
            pixelInfo.IsBG = true;

			screenArray[screenPos] = GetABGR(*gameBoy.gpu,*pixelInfo);
        }
    }
}

PrintTile :: (using tileMapWindow: *TileMapWindow, x: u8, y: u8) {
    tileDataAddress := GetTileAddress(tileMapWindow, x, y);
    attributes : BGAttributes;
    if (tWindow.isCGB)
        attributes := MakeBGAttributes(ReadVRAM(*gameBoy.gpu, address + y * 32 + x, 1));

    tileOffset := ReadVRAM(*gameBoy.gpu, address + y * 32 + x, 0);

    print("\nTile X: % Y: %\n", x, y);
    print("Map address: %\n", u16ToHex(address + y * 32 + x));
    print("Tile ID: %\n", u8ToHex(tileOffset));
    print("Address: %\n", u16ToHex(tileDataAddress));
    print("Bank: %\n", attributes.Bank);
    print("Flip X: %\n", attributes.FlipX);
    print("Flip Y: %\n", attributes.FlipY);
    print("Priority: %\n", attributes.HasPriority);
    print("Palette: %\n", attributes.PaletteIndex);
}

OnMouseClicked :: (using tileMapWindow: *TileMapWindow, x: u32, y: u32) {
    newX := cast(u8)(x / 16); // tile size (8) * window scale (2)
    newY := cast(u8)(y / 16);

    if newX != loggedTileX || newY != loggedTileY {
        loggedTileX = newX;
        loggedTileY = newY;
        PrintTile(tileMapWindow, loggedTileX, loggedTileY);
    }
}
