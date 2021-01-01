RomHeader :: struct {
	title : [16]u8; // 0x0134 - 0x0143
	newLicenseeCode : u16; // 0x0144 - 0x0145 - Only games newer than SGB
	sgbFlag : u8; // 0x0146 - 0x03: Game supports SGB functions
	cartridgeType : u8; // 0x0147 - MBC + RAM + BATTERY combination used
	romSize : u8; // 0x0148 - "32Kb << romSize"
	ramSize : u8; // 0x0149 - 0, 2KB, 8KB, 32KB
	destinationCode : u8; // 0x014A - 0: Japanese, 1: Non-Japanese
	oldLicenseeCode : u8; // 0x014B - 0x33 means newLicenseCode is used
	maskROMVersionNumber : u8; // 0x14C - 
	headerChecksum : u8; // 0x014D - "x=0:FOR i=0134h TO 014Ch:x=x-MEM[i]-1:NEXT" TODO validate?
	globalChecksum : u16; // 0x014E - 0x014F - big endian?

	// CGB only
	manufacturerCode : [4]u8; // 0x013F - 0x0142
	cgbFlag : bool; // 0x0143
};

Print :: (using header: *RomHeader) {
	print("title: %\n", title);
	print("newLicenseeCode: %\n", newLicenseeCode);
	print("sgbFlag: %\n", sgbFlag);
	print("cartridgeType: %\n", cartridgeType);
	print("romSize: %\n", romSize);
	print("ramSize: %\n", ramSize);
	print("destinationCode: %\n", destinationCode);
	print("oldLicenseeCode: %\n", oldLicenseeCode);
	print("maskROMVersionNumber: %\n", maskROMVersionNumber);
	print("headerChecksum: %\n", headerChecksum);
	print("globalChecksum: %\n", globalChecksum);
	print("manufacturerCode: %\n", manufacturerCode);
	print("Is CGB: %\n", cgbFlag);
}

MBC :: struct {
    doLogs : bool;
	rom : [..]u8;
	ram : [..]u8;
    romBanksCount : u16;
    ramBanksCount : u8;
	header : RomHeader;
	type: Type;
};

InitArrays :: (using mbc: *MBC) {
	array_resize(*rom, GetRomSize(mbc));
    array_resize(*ram, GetRamSize(mbc));
}

Cleanup :: (using mbc: *MBC) {
    array_free(rom);
    array_free(ram);
}

GetRomSize :: (using mbc: *MBC) -> u32 {
	if header.romSize <= 0x08
		return xx (32 * 1024) << header.romSize;
	else {
		if header.romSize == {
		case 0x52; return 72 * 16 * 1024; // 72 banks
		case 0x53; return 80 * 16 * 1024;
		case 0x54; return 96 * 16 * 1024;
		}
	}

	print("ERROR: Invalid romSize value %\n", header.romSize);
	return 0;
}

GetRamSize :: (using mbc: *MBC) -> u32 {
	if mbc.type == MBC2 {
		// actual ram is 512 * 4, but it's easier to access as bytes
		return 512 * 8;
	}

	if header.ramSize == {
	case 0x00; return 0;
	case 0x01; return 2 * 1024;
	case 0x02; return 8 * 1024;
	case 0x03; return 32 * 1024; // 4 * 8KBytes banks
	case 0x04; return 128 * 1024;
	case 0x05; return 64 * 1024;
	}

    print("ERROR: Invalid ramSize value %\n", header.ramSize);
	return 0;
}

GetRomPtr :: (using mbc: *MBC) -> *u8 {
    return rom.data;
}

RomOnly :: struct {
    using mbc : MBC;
};

MBC1 :: struct {
    using mbc : MBC;
	romBank : u8 = 1;
	ramBank : u8;
	romBankOffset : u32 = 16 * 1024;
	ramBankOffset : u32 = 0;
	ramEnabled : bool; // 0x00 disabled, 0x0A enabled
	romRamSwitch : u8; // 0 = rom, 1 = ram
};

MBC2 :: struct {
    using mbc : MBC;
	romBank : u8 = 1;
	romBankOffset : u32 = 16 * 1024;
	ramEnabled : bool; // The least significant bit of the upper address byte must be zero to enable/disable cart RAM
};

MBC3 :: struct {
    using mbc : MBC;
	romBank : u8 = 1; // 0x01-0x1F
	ramBank : u8; // 0x00-0x03
	romBankOffset : u32 = 16 * 1024;
	ramBankOffset : u32;
	ramMapped : bool = true;
	ramTimerEnabled : u8; // 0x00 disabled, 0x0A enabled
	mappedRtcRegister : u8 = 0x08; // 0x08-0x0C
	//0 - 0x08: rtcS - seconds, 0-59 (0x00-0x3B)
	//1 - 0x09: rtcM - minutes, 0-59 (0x00-0x3B)
	//2 - 0x0A: rtcH - hours, 0-23 (0x00-0x17)
	//3 - 0x0B: rtcDL - day low bits
	//4 - 0x0C: rtcDH - day high bit, halt flag, carry bit
	rtcRegisters : [5]u8;
	latch0Wrote : bool;
};

MBC5 :: struct {
    using mbc : MBC;
	romBank : u16 = 1;
	ramBank : u8;
	romBankOffset : u32 = 16 * 1024;
	ramBankOffset : u32;
	ramEnabled : bool;
};

Read :: inline (using mbc: *MBC, address: u16) -> u8 {
	if type == {
	case RomOnly; return Read(cast(*RomOnly)mbc,address);
	case MBC1; return Read(cast(*MBC1)mbc,address);
	case MBC2; return Read(cast(*MBC2)mbc,address);
	case MBC3; return Read(cast(*MBC3)mbc,address);
	case MBC5; return Read(cast(*MBC5)mbc,address);
	}
	
	print("ERROR: Invalid mbc type %\n",type);
	return 0;
}

Read :: inline (using m: *RomOnly, address: u16) -> u8 {
	if doLogs logger(tprint("read rom[%] = %\n",u16ToHex(address),u8ToHex(rom[address])));
    return rom[address];
}

Read :: inline (using m: *MBC1, address: u16) -> u8 {
	if address < 0x4000
		return rom[address];
	else if address < 0x8000
		return rom[romBankOffset + address - 0x4000];
	else if address >= 0xA000 && address < 0xC000
		return ram[ramBankOffset + address - 0xA000];

	return 0xFF;
}

Read :: inline (using m: *MBC2, address: u16) -> u8 {
	if address < 0x4000
		return rom[address];
	else if address < 0x8000
		return rom[romBankOffset + address - 0x4000];
	else if address >= 0xA000 && address < 0xA200
		return ram[address - 0xA000] & 0x0F;

	return 0xFF;
}

Read :: inline (using m: *MBC3, address: u16) -> u8 {
	if address < 0x4000
		return rom[address];
	else if address < 0x8000
		return rom[romBankOffset + address - 0x4000];
	else if address >= 0xA000 && address < 0xC000 {
		if ramMapped
			return ram[ramBankOffset + address - 0xA000];
		else
			return rtcRegisters[mappedRtcRegister - 0x08];
	}

	return 0xFF;
}

Read :: inline (using m: *MBC5, address: u16) -> u8 {
	if address < 0x4000
		return rom[address];
    else if address < 0x8000
        return rom[romBankOffset + address - 0x4000];
    else if address >= 0xA000 && address < 0xC000 && ramEnabled {
		finalAddress := ramBankOffset + address - 0xA000;
		if ram.count > 0 && finalAddress < ram.count
			return ram[finalAddress];
	}

	return 0xFF;
}

Write :: (using mbc: *MBC, value: u8, address: u16) {
	if type == {
	case RomOnly;
	case MBC1; Write(cast(*MBC1)mbc,value,address);
	case MBC2; Write(cast(*MBC2)mbc,value,address);
	case MBC3; Write(cast(*MBC3)mbc,value,address);
	case MBC5; Write(cast(*MBC5)mbc,value,address);
	}
}

Write :: (using m: *MBC1, value: u8, address: u16) {
	if address < 0x2000
        ramEnabled = value == 0x0A && ram.count > 0;
	else if address >= 0x2000 && address < 0x4000 {
		lowBits := value & 0x1F;
		if lowBits == 0
			lowBits = 1;
		romBank &= 0x60;
		romBank |= lowBits;
        romBank = cast(u8)(cast(u16)romBank % romBanksCount);
        romBankOffset = 16 * 1024 * cast(u32)romBank;
	} else if address >= 0x4000 && address < 0x6000 {
		if romRamSwitch == 0 {
			highBits := (value & 0x03) << 5;
			romBank &= 0x1F;
			romBank |= highBits;
            romBank = cast(u8)(cast(u16)romBank % romBanksCount);
            romBankOffset = 16 * 1024 * cast(u32)romBank;
		} else if ramEnabled {
			ramBank = value & 0x03;
            if ramBank > ramBanksCount
                ramBank = ramBanksCount;
			ramBankOffset = 8 * 1024 * cast(u32)ramBank;
		}
	} else if address >= 0x6000 && address < 0x8000
		romRamSwitch = value;
	else if address >= 0xA000 && address < 0xC000 && ramEnabled {
		finalAddress := ramBankOffset + address - 0xA000;
		if ram.count > 0 && finalAddress < ram.count
			ram[finalAddress] = value;
	}
}

Write :: (using m: *MBC2, value: u8, address: u16) {
	if address < 0x2000 {
		if (address & 0x0100) == 0
            ramEnabled = value == 0x0A && ram.count > 0;
	} else if address >= 0x2000 && address < 0x4000 {
		if (address & 0x0100) > 0 {
			romBank = value & 0x0F;
            romBank = cast(u8)(cast(u16)romBank % romBanksCount);
			romBankOffset = 16 * 1024 * cast(u32)romBank;
		}
	} else if address >= 0xA000 && address < 0xA200 && ramEnabled {
		finalAddress := address - 0xA000;
		if ram.count > 0 && finalAddress < ram.count
			ram[finalAddress] = value;
	}
}

Write :: (using m: *MBC3, value: u8, address: u16) {
	if address < 0x2000
		ramTimerEnabled = value;
	else if address >= 0x2000 && address < 0x4000 {
		romBank := value & 0x7F;
		if romBank == 0
			romBank = 1;
        romBank = cast(u8)(cast(u16)romBank % romBanksCount);
		romBankOffset = 16 * 1024 * cast(u32)romBank;
	} else if address >= 0x4000 && address < 0x6000 {
		if value < 0x07 {
			ramMapped = true;
			ramBank = value;
            if ramBank > ramBanksCount
                ramBank = ramBanksCount;
			ramBankOffset = 8 * 1024 * cast(u32)ramBank;
		} else if value >= 0x08 && value <= 0x0C {
			ramMapped = false;
			mappedRtcRegister = value;
		}
	} else if address >= 0x6000 && address < 0x8000 {
		if value == 0x01 && latch0Wrote {
			/* TODO time_t now = time(NULL);
			struct tm localTime;
			localtime_s(&localTime,&now);
			rtcRegisters[0] = localTime.tm_sec;
			rtcRegisters[1] = localTime.tm_min;
			rtcRegisters[2] = localTime.tm_hour;

			u16 rtcYearDay = rtcRegisters[3] | ((cast(u16)rtcRegisters[4] & 0x01) << 8);
			int nowYearDay = localTime.tm_yday;

			rtcRegisters[3] = nowYearDay < 256 ? nowYearDay : 255;
			u8 rtcDH = rtcRegisters[4] & 0xC0; // keep only bits 7, 6, discard 0
			if (nowYearDay > 255)
				rtcDH |= 0x01;
			if (nowYearDay < rtcYearDay)
				rtcDH |= 0x80;

			rtcRegisters[4] = rtcDH;
			latch0Wrote = false;*/
		} else if value == 0x00
			latch0Wrote = true;
	} else if address >= 0xA000 && address < 0xC000 && ramTimerEnabled {
		if ramMapped
			ram[ramBankOffset + address - 0xA000] = value;
		else
			rtcRegisters[mappedRtcRegister - 0x08] = value;
	}
}

Write :: (using m: *MBC5, value: u8, address: u16) {
	if address < 0x2000 {
		ramEnabled = value == 0x0A;
	} else if address >= 0x2000 && address < 0x3000 {
		lowBits := value;
		romBank &= 0x0100;
		romBank |= lowBits;
        romBank = cast(u8)(cast(u16)romBank % romBanksCount);
        romBankOffset = 16 * 1024 * cast(u32)romBank;
        if doLogs logger(tprint("ROMBank: % ; lowBits: % ; offset: %\n", u16ToHex(romBank), u8ToHex(value), u16ToHex(romBankOffset)));
	} else if address >= 0x3000 && address < 0x4000 {
		highBit : u16 = value & 0x01;
		romBank &= 0x00FF;
		romBank |= (highBit << 8);
        romBank = cast(u8)(cast(u16)romBank % romBanksCount);
        romBankOffset = 16 * 1024 * cast(u32)romBank;
        if doLogs logger(tprint("ROMBank: % ; highBits: %\n", u16ToHex(romBank), u8ToHex(value)));
	} else if address >= 0x4000 && address < 0x6000 {
		ramBank = value & 0x0F;
        if ramBank > ramBanksCount
            ramBank = ramBanksCount;
        ramBankOffset = 8 * 1024 * cast(u32)ramBank;
        if doLogs logger(tprint("RAMBank: % ; %\n", u16ToHex(ramBank), u8ToHex(value)));
	} else if address >= 0xA000 && address < 0xC000 && ramEnabled {
		finalAddress := ramBankOffset + address - 0xA000;
		if ram.count > 0 && finalAddress < ram.count
			ram[finalAddress] = value;
	}
}

LoadRomFromPath :: (using mbc: *MBC, path: string) {
    fileContent, success := read_entire_file(path);
    if success {
	    LoadRom(mbc, fileContent);
        free(fileContent);
    }
}

LoadRom :: (using mbc: *MBC, fileContent: string) {
    romSize := GetRomSize(mbc);
    memcpy(rom.data, fileContent.data, romSize);
    romBanksCount = cast(u16)(romSize / 0x4000);
    print("Rom size: % (% banks)\n", romSize, romBanksCount);
}

LoadRam :: (using mbc: *MBC, path: string) {
	
}

SaveRam :: (using mbc: *MBC, path: string) {
	
}

Load :: (using mbc: *MBC, fileContent: string) {
	if type == {
	/* TODO case RomOnly;
	case MBC1; Write(cast(*MBC1)mbc,value,address);
	case MBC2; Write(cast(*MBC2)mbc,value,address);
	case MBC3; Write(cast(*MBC3)mbc,value,address);
	case MBC5; Write(cast(*MBC5)mbc,value,address);*/
	}
}

Save :: (using mbc: *MBC, builder: *String_Builder) {
	if type == {
	/* TODO case RomOnly;
	case MBC1; Write(cast(*MBC1)mbc,value,address);
	case MBC2; Write(cast(*MBC2)mbc,value,address);
	case MBC3; Write(cast(*MBC3)mbc,value,address);
	case MBC5; Write(cast(*MBC5)mbc,value,address);*/
	}
}