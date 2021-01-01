DMA :: struct {
    doLogs : bool;

    mmu : *MMU;

    // DMA 
	oam : *u8; // cached pointer to OAM to avoid going through MMU for each write
    currentCycles : u8 = 160;
    addressBase : u16;

    // HDMA
    HDMASource : u16; // msb = HDMA1 (0xFF51), lsb = HDMA2 (0xFF52)
    HDMADest : u16 = 0x8000; // msb = HDMA3 (0xFF53), lsb = HDMA4 (0xFF54)
    
    hdmaInProgress : bool;
    remaining : u8 = 0x7F;
};

Step :: (using dma: *DMA, cycles: u8) {
	while currentCycles < 160 && cycles > 0 {
		oam[currentCycles] = Read(mmu, addressBase + currentCycles);
        if doLogs logger(tprint("OAM[%] = %\n",u16ToHex(currentCycles),u8ToHex(oam[currentCycles])));
		currentCycles += 1;
		cycles -= 1;
        if currentCycles >= 160 && doLogs logger("DMA finished\n");
	}
}

StepHDMA :: (using dma: *DMA) {
    if !hdmaInProgress
        return;

    DoHDMATransfer(dma, 0x10);

    if remaining > 0 {
        remaining -= 1;
    } else {
        remaining = 0x7F;
        hdmaInProgress = false;
    }
    
    // TODO emulate time spent
}

Read :: inline (using dma: *DMA, address: u16) -> u8 {
	if address == {
	case 0xFF46;
		//TODO confirm this?
		return xx (addressBase >> 8);
	case 0xFF51;
		return xx (HDMASource >> 8);
	case 0xFF52;
		return xx (HDMASource & 0xFF);
	case 0xFF53;
		return xx (HDMADest >> 8);
	case 0xFF54;
		return xx (HDMADest & 0xFF);
	case 0xFF55;
    {
        bit7 : u8;
        if !hdmaInProgress
            bit7 = 0x80;
        return bit7 | remaining;
    }
	}

	return 0xFF;
}

Write :: (using dma: *DMA, value: u8, address: u16) {
    if address == {
    case 0xFF46;
        //TODO assert addressBase is valid?
        currentCycles = 0;
        addressBase = (cast(u16)value) << 8;
        if doLogs logger(tprint("DMA started from %\n",u16ToHex(addressBase)));
    case 0xFF51;
        HDMASource &= 0x00FF;
        HDMASource |= (cast(u16)value) << 8;
        if doLogs logger(tprint("HDMA1 = %\n",u8ToHex(value)));
    case 0xFF52;
        HDMASource &= 0xFF00;
        HDMASource |= (cast(u16)value) & 0xF0;
        if doLogs logger(tprint("HDMA2 = %\n",u8ToHex(value & 0xF0)));
	case 0xFF53;
        HDMADest &= 0x80FF;
        HDMADest |= (cast(u16)(value & 0x1F)) << 8;
        if doLogs logger(tprint("HDMA3 = %\n",u8ToHex(value & 0x1F)));
	case 0xFF54;
        HDMADest &= 0xFF00;
        HDMADest |= (cast(u16)value) & 0xF0;
        if doLogs logger(tprint("HDMA4 = %\n",u8ToHex(value & 0xF0)));
	case 0xFF55;
        if hdmaInProgress {
            if (value & 0x80) == 0
                hdmaInProgress = false;
        } else {
            if (value & 0x80) == 0 {
                if doLogs logger("GDMA started\n");
                count := cast(u16)((value & 0x7F) + 1) * 0x0010;
                DoHDMATransfer(dma,count);

                remaining = 0x7F;
                hdmaInProgress = false;
                // TODO emulate time spent
            } else {
                if doLogs logger("HDMA started\n");
                hdmaInProgress = true;
                remaining = value & 0x7F;
            }
        }
        if doLogs {
            HDMA5 := Read(dma, 0xFF55);
            logger(tprint("HDMA5 = % ; %\n",u8ToHex(value),u8ToHex(HDMA5)));
        }
	}
}

Load :: (using dma: *DMA, fileContent: *string) {
    // reads 9 bytes for CurrentCycles and the rest of the properties
    consume_u8_and_length(fileContent, *currentCycles, 9);
}

Save :: (using dma: *DMA, builder: *String_Builder) {
    // writes 9 bytes for CurrentCycles and the rest of the properties
    append(builder, *currentCycles, 9);
}

DoHDMATransfer :: (using dma: *DMA, count: u16) {
    if doLogs {
        logger("Transfering\n");
        logger(tprint("Count: %\n",u8ToHex(count)));
        logger(tprint("Source: %\n",u16ToHex(HDMASource)));
        logger(tprint("Dest: %\n",u16ToHex(HDMADest)));
    }

    for 0..count-1
        Copy(mmu, HDMASource + it, HDMADest + it);

    HDMASource += count;
    HDMADest += count;

    if doLogs logger("Transfer finished\n");
}
