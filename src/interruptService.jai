InterruptFlag :: enum u8 {
	VBlank :: 0x01;
	LCDStat :: 0x02;
	Timer :: 0x04;
	Serial :: 0x08;
	Joypad :: 0x10;
};

InterruptServiceRoutine :: struct {
    IE : u8;		// 0xFFFF - Interrupt Enabled (R/W)
	IF : u8 = 0xE0;	// 0xFF0F - Interrupt Flag (R/W)

	IME : bool;     // not addressable - Interrupt Master Enable Flag(Write Only)
	eiDelay : bool; // EI takes one more instruction to take effect

    doLogs : bool;
};

Read :: inline (using intService: *InterruptServiceRoutine, address: u16) -> u8 {
	if address == {
	case 0xFFFF;
		return IE;
	case 0xFF0F;
		return IF | 0xE0;
	}
	return 0xFF;
}

Write :: (using intService: *InterruptServiceRoutine, value: u8, address: u16) {
	if address == {
	case 0xFFFF;
		IE = value;
	case 0xFF0F;
		IF = value | 0xE0;
	}
}

Load :: (using intService: *InterruptServiceRoutine, fileContent: *string) {
	consume_u8_and_length(fileContent, *IE, 1);
	consume_u8_and_length(fileContent, *IF, 1);
	consume_u8_and_length(fileContent, cast(*u8)*IME, 1);
}

Save :: (using intService: *InterruptServiceRoutine, builder: *String_Builder) {
	append(builder, *IE, 1);
	append(builder, *IF, 1);
	append(builder, cast(*u8)*IME, 1);
}

IsInterruptEnabled :: (using intService: *InterruptServiceRoutine, flag: InterruptFlag) -> bool {
	return (IE & cast(u8)flag) != 0;
}

IsInterruptSet :: (using intService: *InterruptServiceRoutine, flag: InterruptFlag) -> bool {
	return (IF & cast(u8)flag) != 0;
}

ResetInterruptFlag :: (using intService: *InterruptServiceRoutine, flag: InterruptFlag) {
	IF &= ~cast(u8)flag;
    if doLogs logger(tprint("Reset flag %\n",u8ToHex(cast(u8)flag)));
}

SetInterruptFlag :: (using intService: *InterruptServiceRoutine, flag: InterruptFlag) {
	IF |= cast(u8)flag;
    if doLogs logger(tprint("Set flag %\n",u8ToHex(cast(u8)flag)));
}
