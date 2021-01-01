SerialDataTransfer :: struct {
    intService : *InterruptServiceRoutine;

	SB : u8;		//0xFF01 Serial Transfer data (R/W)
	SC : u8 = 0x7E;	//0xFF02 Serial Transfer Control (R/W)
    normalClock := true;

    elapsedCycles : u16;
    maxCycles : u16;
    bitsTransfered : u8 = 8;
};

Read :: inline (using serial: *SerialDataTransfer, address: u16) -> u8 {
	if address == {
	case 0xFF01;
		return SB;
	case 0xFF02;
		return SC | 0x7C;
	}
	return 0xFF;
}

Write :: (using serial: *SerialDataTransfer, value: u8, address: u16) {
	if address == {
	case 0xFF01;
		SB = value;
	case 0xFF02;
		SC = value | 0x7C;
        if (value & 0x80) != 0 {
            bitsTransfered = 0;
            elapsedCycles = 0;
            normalClock = ((value & 0x02) == 0);
            // 8KHz or 32KHz
            if normalClock
                maxCycles = 512;
            else
                maxCycles = 16;
        }
	}
}

Step :: (using serial: *SerialDataTransfer, cycles: u8, isDoubleSpeedEnabled: bool) {
    if bitsTransfered == 8
        return;

    if isDoubleSpeedEnabled
        elapsedCycles += cycles * 2;
    else
        elapsedCycles += cycles;

    while elapsedCycles >= maxCycles {
        SB = SB << 1;
        SB |= 1; // default input value when there's no connection with another console
        bitsTransfered += 1;
        elapsedCycles -= maxCycles;

        if bitsTransfered == 8 {
            SC &= 0x7F; //~0x80;
            if SB != 0xFF
                SetInterruptFlag(intService,.Serial);
            return;
        }
    }
}
