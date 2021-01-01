#import "Basic";
#load "dma.jai";

LCDC :: struct {
	Reg : u8;
	Dirty : bool;
	BgOn : bool; 				// Bit 0 - BG / Window Display / Priority(0 = Off, 1 = On)
	SpritesOn : bool; 			// Bit 1 - OBJ(Sprite) Display Enable(0 = Off, 1 = On)
	SpritesHeight : u8 = 8; 	// Bit 2 - OBJ(Sprite) Size(0 = 8x8, 1 = 8x16)
	BgMap : u16 = 0x9800; 		// Bit 3 - BG Tile Map Display Select(0 = 9800 - 9BFF, 1 = 9C00 - 9FFF)
	BgWinData : u16 = 0x9000; 	// Bit 4 - BG & Window Tile Data Select(0 = 8800 - 97FF, 1 = 8000 - 8FFF)
	WinOn : bool; 				// Bit 5 - Window Display Enable(0 = Off, 1 = On)
	WinMap : u16 = 0x9800; 		// Bit 6 - Window Tile Map Display Select(0 = 9800 - 9BFF, 1 = 9C00 - 9FFF)
	DisplayOn : bool; 			// Bit 7 - LCD Display Enable(0 = Off, 1 = On)
}

SetLCDC :: (using gpu: *GPU, value: u8) {
	using lcdc;
	Reg = value;
	Dirty = false;
	BgOn = (Reg & 0x01 != 0);
	SpritesOn = (Reg & 0x02 != 0);
	if Reg & 0x04 == 0	SpritesHeight = 8;
	else				SpritesHeight = 16;
	if Reg & 0x08 == 0	BgMap = 0x9800;
	else				BgMap = 0x9C00;
	if Reg & 0x10 == 0	BgWinData = 0x9000;
	else				BgWinData = 0x8000;
	WinOn = (Reg & 0x20 != 0);
	if Reg & 0x40 == 0	WinMap = 0x9800;
	else				WinMap = 0x9C00;
	DisplayOn = (Reg & 0x80 != 0);
}

GetLCDC :: (using gpu: *GPU) -> u8 {
	if lcdc.Dirty {
		using lcdc;
		Reg = 0;
		if BgOn					Reg |= 0x01;
		if SpritesOn			Reg |= 0x02;
		if SpritesHeight == 16	Reg |= 0x04;
		if BgMap == 0x9C00		Reg |= 0x08;
		if BgWinData == 0x8000	Reg |= 0x10;
		if WinOn 				Reg |= 0x20;
		if WinMap == 0x9C00		Reg |= 0x40;
		if DisplayOn			Reg |= 0x80;
		Dirty = false;
	}
	return lcdc.Reg;
}

LCDStat :: struct {
	Reg : u8;
	Dirty : bool;
	Mode : GPUMode; 			// Bit 1 - 0 - Mode Flag(Mode 0 - 3, see below) (Read Only)
	LYCoincidence : bool; 		// Bit 2 - Coincidence Flag(0:LYC<>LY, 1 : LYC = LY) (Read Only)
	hBlankIntEnabled : bool; 	// Bit 3 - Mode 0 H - Blank Interrupt(1 = Enable) (Read / Write)
	vBlankIntEnabled : bool; 	// Bit 4 - Mode 1 V - Blank Interrupt(1 = Enable) (Read / Write)
	oamIntEnabled : bool; 		// Bit 5 - Mode 2 OAM Interrupt(1 = Enable) (Read / Write)
	lycIntEnabled : bool; 		// Bit 6 - LYC = LY Coincidence Interrupt(1 = Enable) (Read / Write)
}

SetLCDStat :: (using gpu: *GPU, value: u8) {
	using lcdStat;
	Reg = value | 0x80;
	Reg &= 0xFC; // Clear Mode bits
	Reg |= xx Mode; // ReadOnly
	LYCoincidence = (Reg & 0x04 != 0);
	hBlankIntEnabled = (Reg & 0x08 != 0);
	vBlankIntEnabled = (Reg & 0x10 != 0);
	oamIntEnabled = (Reg & 0x20 != 0);
	lycIntEnabled = (Reg & 0x40 != 0);
}

GetLCDStat :: (using gpu: *GPU) -> u8 {
	if lcdStat.Dirty {
		using lcdStat;
		Reg = 0x80;
		Reg |= xx Mode;
		if LYCoincidence		Reg |= 0x04;
		if hBlankIntEnabled 	Reg |= 0x08;
		if vBlankIntEnabled 	Reg |= 0x10;
		if oamIntEnabled		Reg |= 0x20;
		if lycIntEnabled		Reg |= 0x40;
		Dirty = false;
	}
	return lcdStat.Reg;
}

BGAttributes :: struct {
	Reg : u8;
	Dirty : bool;
	PaletteIndex : u8; 		// Bit 0 - 2 Background Palette number(BGP0 - 7)
	Bank : u8; 				// Bit 3     Tile VRAM Bank number(0 = Bank 0, 1 = Bank 1)
	FlipX : bool; 			// Bit 5     Horizontal Flip(0 = Normal, 1 = Mirror horizontally)
	FlipY : bool; 			// Bit 6     Vertical Flip(0 = Normal, 1 = Mirror vertically)
	HasPriority : bool; 	// Bit 7     BG - to - OAM Priority(0 = Use OAM priority bit, 1 = BG Priority)
}

MakeBGAttributes :: (value: u8) -> BGAttributes {
	using attr : BGAttributes;
	Reg = value;
	PaletteIndex = value & 0x07;
	Bank = (value & 0x08) >> 2;
	FlipX = (value & 0x20 != 0);
	FlipY = (value & 0x40 != 0);
	HasPriority = (value & 0x80 != 0);
	return attr;
}

OBJAttributes :: struct {
	Reg : u8;
	PaletteIndex : u8;		// Bit 0 - 2 Palette number  **CGB Mode Only**     (OBP0 - 7)
	Bank : u8;				// Bit 3     Tile VRAM - Bank * *CGB Mode Only**     (0 = Bank 0, 1 = Bank 1)
	Palette : u8;			// Bit 4     Palette number  **Non CGB Mode Only** (0 = OBP0, 1 = OBP1)
	FlipX : bool;			// Bit 5     Horizontal Flip(0 = Normal, 1 = Mirror horizontally)
	FlipY : bool;			// Bit 6     Vertical Flip(0 = Normal, 1 = Mirror vertically)
	BehindBG : bool;		// Bit 7     OBJ - to - BG Priority(0 = OBJ Above BG, 1 = OBJ Behind BG color 1 - 3) (Used for both BG and Window.BG color 0 is always behind OBJ)
}

MakeOBJAttributes :: (value: u8) -> OBJAttributes {
	using attr : OBJAttributes;
	Reg = value;
	PaletteIndex = value & 0x07;
	Bank = (value & 0x08) >> 2;
	Palette = (value & 0x10) >> 3;
	FlipX = (value & 0x20 != 0);
	FlipY = (value & 0x40 != 0);
	BehindBG = (value & 0x80 != 0);
	return attr;
}

PixelInfo :: struct {
	ColorIndex : u8;	// its 0 - 1 colorIndex [0,3]
	PaletteIndex : u8;	// paletteIndex [0,7] for CGB, [0,1] for sprites in GB, 0 for BG in GB
	IsBG : bool;		// bg/win or sprite, 1 for BG, 0 for sprites
	BgPriority : bool;	// BG priority (CGB only, used when rendering sprites)
	Blank : bool;       // Set to 1 when LCD is off
}

GPUMode :: enum {
	HBlank :: 0;
	VBlank :: 1;
	OAMAccess :: 2;
	VRAMAccess :: 3;
};

// u16 so multiplications with these constants also give a u16
LCDWidth : u16 : 160;
LCDHeight : u16 : 144;

GPU :: struct {
	screen : [LCDWidth*LCDHeight]PixelInfo;
	isCGB : bool;

    gameWindow : *GameWindow;

	doLogs : bool;
    dma : DMA;
	mmu : *MMU;
	intService : *InterruptServiceRoutine;

	modeCycles : u16;

    spritesInLineCount : u8;
    spritesInLine : [11]u8; // limit is 10, but adding one more to simplify the sorting algorithm

    videoRAM0 : [0x2000]u8;
	oam : [0xA0]u8;

	lcdc : LCDC;	  	// 0xFF40
	lcdStat : LCDStat;	// 0xFF41
	SCY : u8;			// 0xFF42
	SCX : u8;			// 0xFF43
	LY : u8;			// 0xFF44
	LYC : u8;			// 0xFF45
	BGP : u8;			// 0xFF47
	OBP0 : u8;			// 0xFF48
	OBP1 : u8;			// 0xFF49
	WY : u8;			// 0xFF4A
	WX : u8;			// 0xFF4B
    
	// CGB
	BGPI : u8;  					// 0xFF68
	OBPI : u8;  					// 0xFF6A

	videoRAM1 : [0x2000]u8;     	// Used for CGB only
	VRAMBank : u8;  				// Used for CGB only

	BGPMemory : [64]u8;     		// through 0xFF69 based on BGPI
	OBPMemory : [64]u8;     		// through 0xFF6B based on OBPI

    FF4C : u8;				    	// CGB non-CGB mode (value = 0x04)
};

Init :: (gpu: *GPU, mmu: *MMU, intService: *InterruptServiceRoutine) {
    gpu.mmu = mmu;
    gpu.intService = intService;
	gpu.dma.mmu = mmu;
	gpu.dma.oam = GetOAMPtr(gpu);
	memset(gpu.spritesInLine.data,0xFF,gpu.spritesInLine.count);
}

Read :: (using gpu: *GPU, address: u16) -> u8 {
	if address >= 0x8000 && address < 0xA000
		return ReadVRAM(gpu, address, VRAMBank);

	if address >= 0xFE00 && address < 0xFEA0
		return oam[address - 0xFE00];

	if address == {
	case 0xFF40; return GetLCDC(gpu);
	case 0xFF41; return GetLCDStat(gpu);
	case 0xFF42; return SCY;
	case 0xFF43; return SCX;
	case 0xFF44; return LY;
	case 0xFF45; return LYC;
	case 0xFF47; return BGP;
	case 0xFF48; return OBP0;
	case 0xFF49; return OBP1;
	case 0xFF4A; return WY;
	case 0xFF4B; return WX;
	case 0xFF68; return BGPI;
	case 0xFF69; return BGPMemory[BGPI & 0x3F];
	case 0xFF6A; return OBPI;
	case 0xFF6B; return OBPMemory[OBPI & 0x3F];
	case 0xFF4F; return VRAMBank | 0xFE;
	case 0xFF46; #through; // dma
	case 0xFF51; #through; // hdma - CGB
	case 0xFF52; #through;
	case 0xFF53; #through;
	case 0xFF54; #through;
	case 0xFF55;
		return Read(*dma, address);
	case 0xFF4C; return FF4C;
	}
	return 0xFF;
}

Write :: (using gpu: *GPU, value: u8, address: u16) {
	if address >= 0x8000 && address < 0xA000 {
		if address > 0xFE00
			doLogs = true;

        if VRAMBank == 0 {
            videoRAM0[address - 0x8000] = value;
            if doLogs logger(tprint("VRAM0[%] = %\n",u16ToHex(address),u8ToHex(value)));
        } else {
            videoRAM1[address - 0x8000] = value;
			if doLogs logger(tprint("VRAM1[%] = %\n",u16ToHex(address),u8ToHex(value)));
        }
		return;
	}

	if address >= 0xFE00 && address < 0xFEA0 {
		oam[address - 0xFE00] = value;
        if doLogs logger(tprint("oam[%] = %\n",u16ToHex(address),u8ToHex(value)));
		return;
	}

	if address == {
    case 0xFF40;
        wasOn := lcdc.DisplayOn;
        SetLCDC(gpu, value);
        if lcdc.DisplayOn != wasOn {
            if lcdc.DisplayOn {
                SetCurrentLine(gpu, 0);
                lcdStat.Mode = .OAMAccess; lcdStat.Dirty = true; // TODO SetMode?
                modeCycles = 0;
                if doLogs logger("LCD on\n");
            } else {
                // TODO memset(screen.data, 0x80, screen.count); // 0x80 = PixelInfo bytes with "blank" bit set
                if doLogs logger("LCD off\n");
            }
        }
        if doLogs logger(tprint("LCDC = % ; %\n",u8ToHex(value),u8ToHex(lcdc.Reg)));
	case 0xFF41;
		SetLCDStat(gpu, value);
        if doLogs logger(tprint("LCDStat = % ; %\n",u8ToHex(value),u8ToHex(lcdStat.Reg)));
	case 0xFF42;
		SCY = value;
        if doLogs logger(tprint("SCY = % ; %\n",u8ToHex(value),u8ToHex(SCY)));
	case 0xFF43;
		SCX = value;
        if doLogs logger(tprint("SCX = % ; %\n",u8ToHex(value),u8ToHex(SCX)));
	case 0xFF44;
		LY = 0;
        if doLogs logger(tprint("LY = % ; %\n",u8ToHex(value),u8ToHex(LY)));
	case 0xFF45;
		LYC = value;
        if doLogs logger(tprint("LYC = % ; %\n",u8ToHex(value),u8ToHex(LYC)));
	case 0xFF47;
		BGP = value;
        if doLogs logger(tprint("BGP = % ; %\n",u8ToHex(value),u8ToHex(BGP)));
	case 0xFF48;
		OBP0 = value;
        if doLogs logger(tprint("OBP0 = % ; %\n",u8ToHex(value),u8ToHex(OBP0)));
	case 0xFF49;
		OBP1 = value;
        if doLogs logger(tprint("OBP1 = % ; %\n",u8ToHex(value),u8ToHex(OBP1)));
	case 0xFF4A;
		WY = value;
        if doLogs logger(tprint("WY = % ; %\n",u8ToHex(value),u8ToHex(WY)));
	case 0xFF4B;
		WX = value;
        if doLogs logger(tprint("WX = % ; %\n",u8ToHex(value),u8ToHex(WX))); 
	case 0xFF68;
		BGPI = value & 0xBF;
        if doLogs logger(tprint("BGPI = % ; %\n",u8ToHex(value),u8ToHex(BGPI)));
	case 0xFF69;
		index := BGPI & 0x3F;
		if doLogs logger(tprint("BG palette %: %\n",u8ToHex(index),u8ToHex(value)));
		BGPMemory[index] = value;
		if BGPI & 0x80 {
			BGPI += 1;
			BGPI = BGPI & 0xBF;
		}
	case 0xFF6A;
		OBPI = value & 0xBF;
        if doLogs logger(tprint("OBPI = % ; %\n",u8ToHex(value),u8ToHex(OBPI)));
	case 0xFF6B;
		index := value & 0x3F;
        if doLogs logger(tprint("OBJ palette %: %\n",u8ToHex(index),u8ToHex(value)));
		OBPMemory[OBPI & 0x3F] = value;
		if OBPI & 0x80 {
			OBPI += 1;
			OBPI = OBPI & 0xBF;
		}
	case 0xFF4F;
		VRAMBank = (value & 0x01);
        if doLogs logger(tprint("VRAMBank = % ; %\n",u8ToHex(value),u8ToHex(VRAMBank)));
	case 0xFF46; #through; // dma
	case 0xFF51; #through; // hdma - CGB
	case 0xFF52; #through;
	case 0xFF53; #through;
	case 0xFF54; #through;
	case 0xFF55;
		Write(*dma, value, address);
		if doLogs logger(tprint("dma % = %\n",u16ToHex(address),u8ToHex(value)));
        if lcdStat.Mode == .HBlank
            StepHDMA(*dma);
	case 0xFF4C;
		FF4C = value;
        if doLogs logger(tprint("FF4C = % ; %\n",u8ToHex(value),u8ToHex(FF4C)));
	}
}

Load :: (using gpu: *GPU, fileContent: *string) {
	consume_u8_and_length(fileContent, xx *modeCycles, 2);
	reg : u8;
	consume_u8_and_length(fileContent, *reg, 1);
	SetLCDC(gpu, reg);
	consume_u8_and_length(fileContent, *reg, 1);
	SetLCDStat(gpu, reg);
	consume_u8_and_length(fileContent, *SCY, 1);
	consume_u8_and_length(fileContent, *SCX, 1);
	consume_u8_and_length(fileContent, *LY, 1);
	consume_u8_and_length(fileContent, *LYC, 1);
	consume_u8_and_length(fileContent, *BGP, 1);
	consume_u8_and_length(fileContent, *OBP0, 1);
	consume_u8_and_length(fileContent, *OBP1, 1);
	consume_u8_and_length(fileContent, *WY, 1);
	consume_u8_and_length(fileContent, *WX, 1);
	consume_u8_and_length(fileContent, videoRAM0.data, videoRAM0.count);
	consume_u8_and_length(fileContent, videoRAM1.data, videoRAM1.count);
	consume_u8_and_length(fileContent, oam.data, oam.count);
	consume_u8_and_length(fileContent, *VRAMBank, 1);
	consume_u8_and_length(fileContent, *BGPI, 1);
	consume_u8_and_length(fileContent, *OBPI, 1);
	consume_u8_and_length(fileContent, BGPMemory.data, BGPMemory.count);
	consume_u8_and_length(fileContent, OBPMemory.data, OBPMemory.count);
	consume_u8_and_length(fileContent, *FF4C, 1);
	Load(*dma, fileContent);
}

Save :: (using gpu: *GPU, builder: *String_Builder) {
	append(builder, xx *modeCycles, 2);
	reg := GetLCDC(gpu);
	append(builder, *reg, 1);
	reg = GetLCDStat(gpu);
	append(builder, *reg, 1);
	append(builder, *SCY, 1);
	append(builder, *SCX, 1);
	append(builder, *LY, 1);
	append(builder, *LYC, 1);
	append(builder, *BGP, 1);
	append(builder, *OBP0, 1);
	append(builder, *OBP1, 1);
	append(builder, *WY, 1);
	append(builder, *WX, 1);
	append(builder, videoRAM0.data, videoRAM0.count);
	append(builder, videoRAM1.data, videoRAM1.count);
	append(builder, oam.data, oam.count);
	append(builder, *VRAMBank, 1);
	append(builder, *BGPI, 1);
	append(builder, *OBPI, 1);
	append(builder, BGPMemory.data, BGPMemory.count);
	append(builder, OBPMemory.data, OBPMemory.count);
	append(builder, *FF4C, 1);
	Save(*dma, builder);
}

Step :: (using gpu: *GPU, cycles: u8, isDoubleSpeedEnabled: bool) -> bool {
	Step(*dma, cycles);

	if isDoubleSpeedEnabled
		modeCycles += cycles / 2;
	else
		modeCycles += cycles;
	
	frameDrawn := false;
	if lcdStat.Mode == {
	case .OAMAccess;
		if modeCycles >= 80 {
            spritesInLineCount = 0;

            for 0..39 {
                spriteIndex := cast(u8) it * 4;
				oamV := oam[spriteIndex];

                if (LY + 16 >= oamV) && (LY + 16 < oamV + lcdc.SpritesHeight) {
                    SortSprites(gpu, spriteIndex);

                    if spritesInLineCount == 10
                        break;
                }
            }
			
			SetMode(gpu, .VRAMAccess);
			modeCycles -= 80;
		}
	case .VRAMAccess;
		if modeCycles >= 172 {
            currentLine := LY;
            if currentLine < 144 && lcdc.DisplayOn
                DrawLine(gpu, currentLine);

			SetMode(gpu, .HBlank);
			modeCycles -= 172;
			StepHDMA(*dma);
		}
	case .HBlank;
		if modeCycles >= 204 {
			newLine := OnLineFinished(gpu);
            
			if newLine > 143
				SetMode(gpu, .VBlank);
			else
				SetMode(gpu, .OAMAccess);

			modeCycles -= 204;
            if newLine == 144
                frameDrawn = true;
		}
	case .VBlank;
        if LY == 153
            SetCurrentLine(gpu, 0);

		if modeCycles >= 456 {
			modeCycles -= 456;

            // Line 153 is considered line 0 by the LCD driver, but then there's also a line 0
            // once VBlank finishes and the new frame begins.
            // So, VBlank runs from line 144 through 152, then a line 0, then that line and the frame
            // finish and it's line 0 again and the new frame starts.
            // https://forums.nesdev.com/viewtopic.php?t=13727#p162336
            // This fixes Aladdin and lots of games using HiColor mode
            
            // For every line that finishes during VBlank, I just increment it's value. OnLineFinished
            // takes care of wrapping after line 152, so it'll be 0 again.
            // If the current line is 0, since this is VBlank, it means the fake line 0 is finishing,
            // and that means the frame finished. The line is set to 0 again to trigger the LYC interrupt
            // if necessary
            if LY == 0
                SetMode(gpu, .OAMAccess);
            else
                OnLineFinished(gpu);
		}
	}

	return frameDrawn;
}

SortSprites :: (using gpu: *GPU, spriteIndex: u8) {
    spritesInLine[spritesInLineCount] = spriteIndex;
    if !isCGB && spritesInLineCount > 0 {
        spriteX := oam[spriteIndex + 1];
        for < 0..spritesInLineCount {
            otherSpriteIndex := spritesInLine[it];
            otherSpriteX := oam[otherSpriteIndex + 1];
            if spriteX < otherSpriteX {
                spritesInLine[it] = spriteIndex;
                spritesInLine[it + 1] = otherSpriteIndex;
            } else
                break;
        }
    }

    if spritesInLineCount < 10
        spritesInLineCount += 1;
}

SetMode :: (using gpu: *GPU, newMode: GPUMode) {
	lcdStat.Mode = newMode; lcdStat.Dirty = true;

    if lcdStat.Mode == .VBlank && lcdc.DisplayOn {
        SetInterruptFlag(intService, .VBlank);

        // Apparently, when VBlank mode starts the LCD driver still fires the OAM-STAT interrupt if enabled
        // as if OAM mode has started
        // https://forums.nesdev.com/viewtopic.php?t=13727
        if lcdStat.oamIntEnabled
            SetInterruptFlag(intService, .LCDStat);
    }

	if lcdc.DisplayOn && ((lcdStat.Mode == .OAMAccess && lcdStat.oamIntEnabled) ||
		(lcdStat.Mode == .VBlank && lcdStat.vBlankIntEnabled) ||
		(lcdStat.Mode == .HBlank && lcdStat.hBlankIntEnabled))
		SetInterruptFlag(intService, .LCDStat);

    //if doLogs logger(tprint("lcdStat.Mode: %\n",lcdStat.Mode));
}

SetCurrentLine :: (using gpu: *GPU, newLine: u8) {
	LY = newLine;
	lcdStat.LYCoincidence = (LYC == newLine); lcdStat.Dirty = true;

	if lcdStat.lycIntEnabled && lcdStat.LYCoincidence && lcdc.DisplayOn
		SetInterruptFlag(intService, .LCDStat);

	//if doLogs logger(tprint("line: %\n",LY));
}

OnLineFinished :: (using gpu: *GPU) -> u8 {
	line := LY + 1;
	SetCurrentLine(gpu, line);
	return line;
}

DrawLine :: (using gpu: *GPU, line: u8) {
    drawBG := isCGB || lcdc.BgOn;
    drawWIN := lcdc.WinOn && (isCGB || lcdc.BgOn) && line >= WY && WX >= 0 && WX <= 166;
    drawSprites := lcdc.SpritesOn;

    if drawBG {
		if drawWIN
        	DrawBackground(gpu, line, WX);
		else
			DrawBackground(gpu, line, xx (LCDWidth + 8));
	} else
        memset(screen.data + line*LCDWidth, 0x80, LCDWidth); // TODO 0x80 = PixelInfo bytes with "blank" bit set

    if drawWIN
        DrawWindow(gpu, line);

    if drawSprites
        DrawSprites(gpu, line);

	if gameWindow != null
		DrawLine(gameWindow, line);
}

DrawBackground :: (using gpu: *GPU, line: u8, pixelCount: u8) {
	tileY : u16 = ((SCY + line) / 8) % 32;
    tileLine := (SCY + line) % 8;
	firstTileX := SCX / 8;
	xOffset := SCX % 8;
	
	tilesToDraw := pixelCount / 8;

	addressBase := lcdc.BgMap + tileY * 32 - 0x8000;
	for 0..tilesToDraw-1 {
		address := addressBase + (firstTileX + it) % 32;
		tileOffset := videoRAM0[address];
		cgbAttributes := MakeBGAttributes(videoRAM1[address]);

        tileAddress := lcdc.BgWinData;
		if lcdc.BgWinData == 0x8000 {
			tileAddress += (cast(u16)tileOffset) * 16;
		} else {
			temp := cast,no_check(s8)tileOffset;
			temp2 := cast(s16)temp;
			temp3 := cast,no_check(u16)temp2;
			tileAddress += temp3 * 16;
		}

		if cgbAttributes.FlipY
			tileAddress += (7 - tileLine) * 2;
		else
			tileAddress += tileLine * 2;

		lowByte := ReadVRAM(gpu, tileAddress, cgbAttributes.Bank);
		highByte := ReadVRAM(gpu, tileAddress + 1, cgbAttributes.Bank);

		screenPosBase := line * LCDWidth + it * 8 - xOffset;

		for < bit: 7..0 {
			pixel : u8;
			if cgbAttributes.FlipX
				pixel = xx (7 - bit);
			else
				pixel = xx bit;

			screenPos := screenPosBase + (7 - bit);
			if (screenPos >= line * LCDWidth) && (screenPos < (line + 1) * LCDWidth) {
				lowBit := (lowByte >> pixel) & 0x01;
				highBit := (highByte >> pixel) & 0x01;
				pixelInfo : PixelInfo;
				pixelInfo.ColorIndex = lowBit | (highBit << 1);
				pixelInfo.PaletteIndex = cgbAttributes.PaletteIndex;
				pixelInfo.IsBG = true;

				if cgbAttributes.HasPriority && lcdc.BgOn // LCDC.bgOn on GBC is bgPriority
					pixelInfo.BgPriority = true;

				screen[screenPos] = pixelInfo;
			}
		}
	}
}

DrawWindow :: (using gpu: *GPU, line: u8) {
	tileY : u16 = ((line - WY) / 8) % 32;
    tileLine := (line - WY) % 8;

	tilesToDraw := (LCDWidth - (WX - 7)) / 8 + 1;
	
	addressBase := lcdc.WinMap + tileY * 32 - 0x8000;
	for 0..tilesToDraw-1 {
		address := addressBase + it % 32;
		tileOffset := videoRAM0[address];
		cgbAttributes := MakeBGAttributes(videoRAM1[address]);

		tileAddress := lcdc.BgWinData;
		if lcdc.BgWinData == 0x8000 {
			tileAddress += (cast(u16)tileOffset) * 16;
		} else {
			// TODO simplify this?
			temp := cast,no_check(s8)tileOffset;
			temp2 := cast(s16)temp;
			temp3 := cast,no_check(u16)temp2;
			tileAddress += temp3 * 16;
		}
		
		if cgbAttributes.FlipY
			tileAddress += (7 - tileLine) * 2;
		else
			tileAddress += tileLine * 2;
		
		lowByte := ReadVRAM(gpu, tileAddress, cgbAttributes.Bank);
		highByte := ReadVRAM(gpu, tileAddress + 1, cgbAttributes.Bank);

		screenPosBase := line * LCDWidth + it * 8 + (WX - 7);

		for < bit: 7..0 {
			pixel : u8;
			if cgbAttributes.FlipX
				pixel = xx (7 - bit);
			else
				pixel = xx bit;

			screenPos := screenPosBase + (7 - bit);
			if (screenPos >= line * LCDWidth) && (screenPos < (line + 1) * LCDWidth) {
				lowBit := (lowByte >> pixel) & 0x01;
				highBit := (highByte >> pixel) & 0x01;
				pixelInfo : PixelInfo;
				pixelInfo.ColorIndex = lowBit | (highBit << 1);
				pixelInfo.PaletteIndex = cgbAttributes.PaletteIndex;
				pixelInfo.IsBG = true;

				// TODO confirm if this applies to the window too
				if cgbAttributes.HasPriority && lcdc.BgOn
					pixelInfo.BgPriority = true;

				screen[screenPos] = pixelInfo;
			}
		}
	}
}

DrawSprites :: (using gpu: *GPU, line: u8) {
	if spritesInLineCount == 0
		return;

	for 0..spritesInLineCount-1 {
		spriteIndex := spritesInLine[it];
		spriteY := cast(s16)oam[spriteIndex] - 16;

		if (line >= spriteY) && (line < spriteY + lcdc.SpritesHeight) {
			spriteX := (cast(s16)oam[spriteIndex + 1]) - 8;
			tileIndex : u16 = oam[spriteIndex + 2];
            if lcdc.SpritesHeight == 16
                tileIndex &= 0xFE;
            tileAddress : u16 = 0x8000 + tileIndex * 16;

			attributes := MakeOBJAttributes(oam[spriteIndex + 3]);
            spriteLine : u8;
			if attributes.FlipY
				spriteLine = xx (lcdc.SpritesHeight - 1 - (line - spriteY));
			else
				spriteLine = xx (line - spriteY);

			lowByte := ReadVRAM(gpu, tileAddress + spriteLine * 2, attributes.Bank);
			highByte := ReadVRAM(gpu, tileAddress + spriteLine * 2 + 1, attributes.Bank);

			temp := cast(s16)spriteX;
			screenPosBase := line * LCDWidth + cast,no_check(u16)temp;

			for < bit: 7..0 {
				pixel : u8;
				if attributes.FlipX
					pixel = xx (7 - bit);
				else
					pixel = xx bit;
				
				screenPos := screenPosBase + (7 - bit);

				if screenPos < 0 || screenPos >= screen.count
					continue;

				// if LCDC is set and the BG has priority, ignore the pixel color
				if lcdc.BgOn && screen[screenPos].BgPriority && screen[screenPos].ColorIndex > 0
					continue;

				if screenPos >= line * LCDWidth && screenPos < (line + 1) * LCDWidth {
					lowBit := (lowByte >> pixel) & 0x01;
					highBit := (highByte >> pixel) & 0x01;
					pixelInfo : PixelInfo;
					pixelInfo.ColorIndex = lowBit | (highBit << 1);

					if pixelInfo.ColorIndex > 0 && screen[screenPos].IsBG && (!lcdc.BgOn || !attributes.BehindBG || (screen[screenPos].ColorIndex == 0)) {
						if isCGB && FF4C != 0x04
							pixelInfo.PaletteIndex = attributes.PaletteIndex;
						else
							pixelInfo.PaletteIndex = attributes.Palette;
						// pixelInfo.isBG already false

						screen[screenPos] = pixelInfo;
					}
				}
			}
		}
	}
}

GetABGR :: inline (using gpu: *GPU, pixelInfo: *PixelInfo) -> u16 {
    if pixelInfo.Blank
        return 0xFFFF;

	// OLD turn gb color [0,3] into an 8 bit color [255,0], 85 == 255/3 // 255 - index * 85 
	// NEW for 5 bit color format:
	greyColors :: u8.[0x1F, 0x10 , 0x08, 0x00]; 

	gpuColor : u16 = 0x8000;

	gbPalette := 0;
	if pixelInfo.IsBG
		gbPalette = BGP;
	else if pixelInfo.PaletteIndex == 0
		gbPalette = OBP0;
	else
		gbPalette = OBP1;

	if isCGB {
		if FF4C == 0x04 // GBC Non-CGB mode
			pixelInfo.ColorIndex = xx ((gbPalette >> (pixelInfo.ColorIndex << 1)) & 0x03);

		paletteOffset := (pixelInfo.PaletteIndex << 3) + (pixelInfo.ColorIndex << 1);
		if pixelInfo.IsBG
			gpuColor |= ((cast(u16)BGPMemory[paletteOffset + 1]) << 8) | BGPMemory[paletteOffset];
		else
			gpuColor |= ((cast(u16)OBPMemory[paletteOffset + 1]) << 8) | OBPMemory[paletteOffset];

		// TODO check for a better conversion, first to consider this: https://gbdev.gg8.se/wiki/articles/Video_Display#RGB_Translation_by_CGBs
		// but also because 0x1F * 8 is not 255 (the actual max value for each component)... 255/31 should be used, but it's not round
		// When that's changed, change the TileViewers and SpritesViewers code
		// https://byuu.net/video/color-emulation <- GameBoy Color section
	} else {
		// u16 so it can be shifted left
		grey : u16 = greyColors[(gbPalette >> (pixelInfo.ColorIndex << 1)) & 0x03];

		gpuColor |= grey;
		gpuColor |= (grey << 5);
		gpuColor |= (grey << 10);
	}

	return gpuColor;
}

ReadVRAM :: (using gpu: *GPU, address: u16, bank: u8) -> u8 {
	if bank == 0 || !isCGB || FF4C == 0x04
		return videoRAM0[address - 0x8000];

	return videoRAM1[address - 0x8000];
}

GetLCDCRef :: (using gpu: *GPU) -> *LCDC {
	return *lcdc;
}

GetOAMPtr :: (using gpu: *GPU) -> *u8 {
	return oam.data;
}

GetBGPPtr :: (using gpu: *GPU) -> *u8 {
	return BGPMemory.data;
}

GetOBPPtr :: (using gpu: *GPU) -> *u8 {
	return OBPMemory.data;
}
