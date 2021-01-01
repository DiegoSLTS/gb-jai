#import "Basic";

MMU :: struct {
    cpu : *CPU;
	cartridge : *Cartridge;
	joypad : *Joypad;
	gpu : *GPU;
	timer : *Timer;
	serial : *SerialDataTransfer;
	intService : *InterruptServiceRoutine;
    audio : *Audio;

	/*
	Interrupt Enable Register
	--------------------------- FFFF
	Internal High RAM
	--------------------------- FF80
	Empty but unusable for I/O
	--------------------------- FF4C
	I/O ports
	--------------------------- FF00
	Empty but unusable for I/O
	--------------------------- FEA0 
	Sprite Attrib Memory (OAM)
	--------------------------- FE00
	Echo of 8kB Internal RAM
	--------------------------- E000
	8kB Internal RAM 
	--------------------------- C000
	8kB switchable RAM bank
	--------------------------- A000
	8kB Video RAM
	--------------------------- 8000 --
	16kB switchable ROM bank         |
	--------------------------- 4000  |= 32kB Cartrigb
	16kB ROM bank #0                 |
	--------------------------- 0000 --*/
	zeroPageRAM : [0x80]u8;
	ioPorts : [0x80]u8;

	internalRAM : [0x8000]u8; // 0xC000 - 0xCFFF bank 0, 0xD000 - 0xDFFF bank N based on internalRAMIndex
	bankNIndex : u8 = 1; // [1,7], never set to 0
	
    bootRom : [..]u8;
};

Cleanup :: (using mmu: *MMU) {
    array_free(bootRom);
}

LoadBootRom :: (using mmu: *MMU, isCGB: bool) {
    romFileName : string;
    if isCGB
        romFileName = "../Files/cgb_bios.bin";
    else
        romFileName = "../Files/dmg_boot.bin";
    
    fileContent, success := read_entire_file(romFileName);

    if !success {
        print("ERROR: Could not open bootrom file %\n", romFileName);
        return;
    }

    array_reserve(*bootRom, fileContent.count);
    memcpy(bootRom.data, fileContent.data, fileContent.count);
    free(fileContent);

    //RomParser parser;
    //parser.ParseBiosROM(bootRom, bootRomStats.st_size);
    //parser.PrintCodeToFile();
}

Read :: inline (using mmu: *MMU, address: u16) -> u8 {
	if address < 0x8000 {
        // ioPorts[0x50] != 0 means the boot rom has already finished (reg 0xFF50)
        if ioPorts[0x50] != 0 || (address >= 0x0100 && address <= 0x014F) {
            // TODO MBC: https://gekkio.fi/files/gb-docs/gbctr.pdf
            if cartridge == null
                return 0xFF;
            else
                return Read(cartridge, address);
        } else
            return bootRom[address];
	} else if address < 0xA000 {
		return Read(gpu, address);
    } else if address < 0xC000 { // external (cart) ram
		if cartridge == null
                return 0xFF;
            else
                return Read(cartridge, address);
	} else if address < 0xE000 {
		if address < 0xD000 {
			return internalRAM[address - 0xC000];
        } else {
			return internalRAM[address - 0xD000 + bankNIndex * 0x1000];
        }
	} else if (address < 0xFE00) {
		if (address < 0xF000)
			return internalRAM[address - 0xE000];
		else
			return internalRAM[address - 0xF000 + bankNIndex * 0x1000];
	} else if (address < 0xFEA0)
		return Read(gpu, address);
	else if (address < 0xFF00)
		return 0; //TODO validate if 0 or 0xFF
    else {
        found, value := ReadFromComponent(mmu, address);
        if (found)
            return value;

        if IsUnusedReg(mmu, address)
            return 0xFF;

        if address < 0xFF80
            return ioPorts[address - 0xFF00];
        else
            return zeroPageRAM[address - 0xFF80];
    }
}

Write :: (using mmu: *MMU, address: u16, value: u8) {
	if address < 0x8000 {
		if cartridge != null
			Write(cartridge, value, address);
	} else if address < 0xA000 {
		Write(gpu, value, address);
	} else if address < 0xC000 {
		if cartridge != null
			Write(cartridge, value, address);
	} else if address < 0xE000 {
		if address < 0xD000
			internalRAM[address - 0xC000] = value;
        else
            internalRAM[address - 0xD000 + bankNIndex * 0x1000] = value;
	} else if address < 0xFE00 {
		if address < 0xF000
			internalRAM[address - 0xE000] = value;
        else
            internalRAM[address - 0xF000 + bankNIndex * 0x1000] = value;
	} else if address < 0xFEA0 {
		Write(gpu, value, address);
	} else if (address < 0xFF00) { // unused
		//TODO ignore?
    } else {
        if WriteToComponent(mmu, address, value)
            return;

		if address < 0xFF80 {
            if IsUnusedReg(mmu, address)
                return;

            if address == 0xFF70 {
                bankIndex := value & 0x07;
                if bankIndex == 0 {
                    bankNIndex = 1;
                } else {
                    bankNIndex = bankIndex;
                }
                // TODO confirm if writing a 0 should be read as 0 or as 1 too
                value |= 0xF8;
            } else if address == 0xFF50 {
                if (ioPorts[0x50] & 0x01) == 0x01
                    return;
            }
            
            ioPorts[address - 0xFF00] = value;
		} else
            zeroPageRAM[address - 0xFF80] = value;
    }
}

IsUnusedReg :: (using mmu: *MMU, address: u16) -> bool {
    if address == {
    case 0xFF02; return true;
    }
    return false;
}

ReadFromComponent :: (using mmu: *MMU, address: u16) -> bool, u8 {
    if address >= 0xFF30 && address <= 0xFF3F
        return true, Read(audio, address);

	if address == {
    case 0xFF4D;
        return true, Read(cpu, address);
	case 0xFF40; #through;
	case 0xFF41; #through;
	case 0xFF42; #through;
	case 0xFF43; #through;
	case 0xFF44; #through;
	case 0xFF45; #through;
	case 0xFF47; #through;
	case 0xFF48; #through;
	case 0xFF49; #through;
	case 0xFF4A; #through;
	case 0xFF4B; #through;
	case 0xFF68; #through; // CGB
	case 0xFF69; #through;
	case 0xFF6A; #through;
	case 0xFF6B; #through;
	case 0xFF4F; #through;
    case 0xFF4C; #through; // GBC Non-CGB mode
    case 0xFF46; #through; // dma
    case 0xFF51; #through; // CGB
    case 0xFF52; #through;
    case 0xFF53; #through;
    case 0xFF54; #through;
    case 0xFF55;
		return true, Read(gpu, address);
	case 0xFF00;
		return true, Read(joypad, address);
	case 0xFF04; #through;
	case 0xFF05; #through;
    case 0xFF06; #through;
	case 0xFF07;
		return true, Read(timer, address);
    case 0xFF10; #through;
    case 0xFF11; #through;
    case 0xFF12; #through;
    case 0xFF13; #through;
    case 0xFF14; #through;
    case 0xFF16; #through;
    case 0xFF17; #through;
    case 0xFF18; #through;
    case 0xFF19; #through;
    case 0xFF1A; #through;
    case 0xFF1B; #through;
    case 0xFF1C; #through;
    case 0xFF1D; #through;
    case 0xFF1E; #through;
    case 0xFF20; #through;
    case 0xFF21; #through;
    case 0xFF22; #through;
    case 0xFF23; #through;
    case 0xFF24; #through;
    case 0xFF25; #through;
    case 0xFF26;
        return true, Read(audio, address);
	case 0xFF01; #through;
	case 0xFF02;
		return true, Read(serial, address);
	case 0xFF0F; #through;
	case 0xFFFF;
		return true, Read(intService, address);
	}

	return false, 0;
}

WriteToComponent :: (using mmu: *MMU, address: u16, value: u8) -> bool {
    if address >= 0xFF30 && address <= 0xFF3F {
        Write(audio, value, address);
        return true;
    } 

	if address == {
    case 0xFF4D;
        Write(cpu, value, address);
        return true;
	case 0xFF40; #through;
	case 0xFF41; #through;
	case 0xFF42; #through;
	case 0xFF43; #through;
	case 0xFF44; #through;
	case 0xFF45; #through;
	case 0xFF47; #through;
	case 0xFF48; #through;
	case 0xFF49; #through;
	case 0xFF4A; #through;
	case 0xFF4B; #through;
	case 0xFF68; #through; // CGB
	case 0xFF69; #through;
	case 0xFF6A; #through;
	case 0xFF6B; #through;
	case 0xFF4F; #through;
    case 0xFF4C; #through; // GBC Non-CGB mode
    case 0xFF46; #through; // dma
    case 0xFF51; #through; // CGB
    case 0xFF52; #through;
    case 0xFF53; #through;
    case 0xFF54; #through;
    case 0xFF55;
        Write(gpu, value, address);
        return true;
	case 0xFF00;
        Write(joypad, value, address);
        return true;
	case 0xFF04; #through;
	case 0xFF05; #through;
	case 0xFF06; #through;
	case 0xFF07;
        Write(timer, value, address);
        return true;
    case 0xFF10; #through;
    case 0xFF11; #through;
    case 0xFF12; #through;
    case 0xFF13; #through;
    case 0xFF14; #through;
    case 0xFF16; #through;
    case 0xFF17; #through;
    case 0xFF18; #through;
    case 0xFF19; #through;
    case 0xFF1A; #through;
    case 0xFF1B; #through;
    case 0xFF1C; #through;
    case 0xFF1D; #through;
    case 0xFF1E; #through;
    case 0xFF20; #through;
    case 0xFF21; #through;
    case 0xFF22; #through;
    case 0xFF23; #through;
    case 0xFF24; #through;
    case 0xFF25; #through;
    case 0xFF26;
        Write(audio, value, address);
        return true;
	case 0xFF01; #through;
	case 0xFF02;
        Write(serial, value, address);
        return true;
	case 0xFF0F; #through;
	case 0xFFFF;
        Write(intService, value, address);
        return true;
	}

	return false;
}

Copy :: (using mmu: *MMU, from: u16, to: u16) {
	Write(mmu, to, Read(mmu, from));
}

Load :: (using mmu: *MMU, fileContent: *string) {
    consume_u8_and_length(fileContent, internalRAM.data, internalRAM.count);
    consume_u8_and_length(fileContent, *bankNIndex, 1);
    consume_u8_and_length(fileContent, ioPorts.data, ioPorts.count);
    consume_u8_and_length(fileContent, zeroPageRAM.data, zeroPageRAM.count);
}

Save :: (using mmu: *MMU, builder: *String_Builder) {
	append(builder, internalRAM.data, internalRAM.count);
    append(builder, *bankNIndex, 1);
	append(builder, ioPorts.data, ioPorts.count);
	append(builder, zeroPageRAM.data, zeroPageRAM.count);
}
