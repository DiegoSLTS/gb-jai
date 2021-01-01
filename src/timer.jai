TIMABits :: u8.[9, 3, 5, 7];

Timer :: struct {
    intService : *InterruptServiceRoutine;

	DIV : u8;	//0xFF04 Divider Register (R/W)
	TIMA : u8;	//0xFF05 Timer counter (R/W)
	TMA : u8;	//0xFF06 Timer Modulo (R/W)
	TAC : u8;	//0xFF07 Timer Control (R/W)

    timerReg : u16;
    TACInput : u8;
};

Step :: (using timer: *Timer, cycles: u8) {
    wasHigh := TACInput == 1;
    timerReg += cycles;
    UpdateTACInput(timer);
    UpdateTIMA(timer, wasHigh);
}

Read :: inline (using timer: *Timer, address: u16) -> u8 {
	if address == {
	case 0xFF04;
        return xx (timerReg >> 8);
	case 0xFF05;
		return TIMA;
	case 0xFF06;
		return TMA;
	case 0xFF07;
		return TAC | 0xF8;
	}
	return 0xFF;
}

Write :: (using timer: *Timer, value: u8, address: u16) {
	if address == {
    case 0xFF04;
        wasHigh := TACInput == 1;
        timerReg = 0;
        UpdateTACInput(timer);
	case 0xFF05;
		TIMA = value;
	case 0xFF06;
		TMA = value;
    case 0xFF07;
        wasEnabled := (TAC & 0x04 != 0);
        wasHigh := TACInput == 1;
        TAC = value | 0xF8;
        UpdateTACInput(timer);
        if wasEnabled
            UpdateTIMA(timer, wasHigh);
	}
}

UpdateTACInput :: (using timer: *Timer) {
    timeFreq := TIMABits[TAC & 0x03];
    TACInput = xx (timerReg >> timeFreq) & 0x01;
}

UpdateTIMA :: (using timer: *Timer, wasHigh: bool) {
    if (TAC & 0x04) != 0 { // is on
        if wasHigh && TACInput == 0 {
            TIMA += 1;
            if TIMA == 0 {
                TIMA = TMA;
                SetInterruptFlag(intService,.Timer);
            }
        }
    }
}
