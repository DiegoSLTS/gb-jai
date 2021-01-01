#import "String";
#import "File";
#import "Zip_File_Directory";
#load "mbc.jai";

Cartridge :: struct {
    mbc: *MBC;
    header : RomHeader;
	hasBattery : bool;
	romFullPath : string;
	romName : string;
};

GetRomPtr :: (using cartridge: *Cartridge) -> *u8 {
    return GetRomPtr(mbc);
}

Init :: (using cart: *Cartridge, romPath: string) {
    romFullPath = romPath;
    LoadFile(cart, romFullPath);
    
	if hasBattery {
		romName = path_filename(romFullPath);
        savePath := join(path_strip_extension(romFullPath),".sav");
		
        LoadRam(cart, savePath);
	}
}

Cleanup :: (using cart: *Cartridge) {
	if hasBattery {
		romName = path_filename(romFullPath);
        savePath := join(path_strip_extension(romFullPath),".sav");
        defer free(savePath);

		SaveRam(cart, savePath);
	}

    if mbc != null {
        Cleanup(mbc);
        free(mbc);
    }
}

InitMBC :: (using cart: *Cartridge) {
    mbcType := GetMBCType(*header);
    if mbcType == type_of(null) {
        print("ERROR: cartridgeType % not supported\n", header.cartridgeType);
        return;
    }

    if mbcType == {
    case RomOnly; mbc = New(RomOnly);
    case MBC1; mbc = New(MBC1);
    case MBC2; mbc = New(MBC2);
    case MBC3; mbc = New(MBC3);
    case MBC5; mbc = New(MBC5);
    }
    mbc.type = mbcType;
    mbc.header = header;

    InitArrays(mbc);
}

GetMBCType :: (using header: *RomHeader) -> Type {
    if header.cartridgeType == {
    case 0; #through;
    case 8; #through;
    case 9;
        return RomOnly;
    case 1; #through;
    case 2; #through;
    case 3;
        return MBC1;
    case 5; #through;
    case 6;
        return MBC2;
    case 0x0F; #through;
    case 0x10; #through;
    case 0x11; #through;
    case 0x12; #through;
    case 0x13;
        return MBC3;
    case 0x19; #through;
    case 0x1A; #through;
    case 0x1B; #through;
    case 0x1C; #through;
    case 0x1D; #through;
    case 0x1E;
        return MBC5;
    }
    
	return type_of(null);
}

LoadHeaderFromPath :: (using cart: *Cartridge, filePath: string) {
    fileContent, success := read_entire_file(filePath);
    if success {
	    LoadHeader(cart, fileContent);
        free(fileContent);
    }
}

LoadHeader :: (using cart: *Cartridge, fileContent: string) {
    // copy all fields from header from stream to header struct (not just the title)
    // IMPORTANT: variables defined in the same order as the header
    memcpy(*header.title, fileContent.data + 0x0134, 0x014F - 0x0134 + 1);

    for 0..3
        header.manufacturerCode[it] = header.title[12 + it];
    header.cgbFlag = (header.title[15] == 0x80) || (header.title[15] == 0xC0);
    Print(*header);
}

LoadRam :: (using cart: *Cartridge, path: string) {
    fileContent, success := read_entire_file(path);
    if success {
        backup := fileContent;
        defer free(backup);

        consume_u8_and_length(*fileContent, mbc.ram.data, mbc.ram.count);
        mbc.ramBanksCount = xx (mbc.ram.count / 0x2000);
        print("Ram size: % (% banks)\n", mbc.ram.count, mbc.ramBanksCount);
    }
}

SaveRam :: (using cart: *Cartridge, path: string) {
    write_entire_file(path, mbc.ram.data, mbc.ram.count);
}

LoadFile :: (using cart: *Cartridge, path: string) {
    /*success, dir := load_zip_directory(path);
    if success {
        romIndex : int = -1;
        for dir.entries {
            if path_extension(it.filename) == "gb"
                romIndex = index;
        }
        
        if romIndex != -1 {
            char* buffer = new char[ze.unc_size];
            UnzipItem(hz, ze.index, buffer, ze.unc_size);

            LoadHeader(buffer);
            InitMBC();
            mbc->LoadRom(buffer);
            delete[] buffer;
        } else
            std::cout << "ERROR: No .gb or .gbc file inside zip file at " << path << std::endl;
        CloseZip(hz);
    } else */{
        LoadHeaderFromPath(cart, path);
        InitMBC(cart);
        LoadRomFromPath(mbc, path);
    }

    hasBattery = header.cartridgeType == 0x03 || header.cartridgeType == 0x06 || header.cartridgeType == 0x09
        || header.cartridgeType == 0x0D || header.cartridgeType == 0x0F || header.cartridgeType == 0x10
        || header.cartridgeType == 0x13 || header.cartridgeType == 0x17 || header.cartridgeType == 0x1B
        || header.cartridgeType == 0x1E || header.cartridgeType == 0xFF;
}

Read :: inline (using cart: *Cartridge, address: u16) -> u8 {
	return Read(mbc, address);
}

Write :: (using cart: *Cartridge, value: u8, address: u16) {
	Write(mbc, value, address);
}

Load :: (using cart: *Cartridge, fileContent: string) {
	Load(mbc, fileContent);
}

Save :: (using cart: *Cartridge, builder: *String_Builder) {
	Save(mbc, builder);
}

IsGBCCartridge :: (using cart: *Cartridge) -> bool {
    return header.cgbFlag;
}
