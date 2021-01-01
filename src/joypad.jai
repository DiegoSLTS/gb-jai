Joypad :: struct {
    doLogs : bool;
	intService : *InterruptServiceRoutine;

    JOYP : u8 = 0xFF; //0xFF00
};

Update :: (using joypad: *Joypad) {
    currentState := JOYP;
	JOYP |= 0x0F;
	if (JOYP & 0x20) == 0 {
		keyboardState := SDL_GetKeyboardState(null);
		if keyboardState[SDL_SCANCODE_S] // A
			JOYP &= 0xFE; //~0x01;

		if keyboardState[SDL_SCANCODE_A] // B
			JOYP &= 0xFD; //~0x02;

		if keyboardState[SDL_SCANCODE_RSHIFT] // select
			JOYP &= 0xFB; //~0x04;

		if keyboardState[SDL_SCANCODE_RETURN] // start
			JOYP &= 0xF7; //~0x08;
	} else if (JOYP & 0x10) == 0 {
		keyboardState := SDL_GetKeyboardState(null);
		if keyboardState[SDL_SCANCODE_RIGHT] // right
			JOYP &= 0xFE; //~0x01;

		if keyboardState[SDL_SCANCODE_LEFT] // left
			JOYP &= 0xFD; //~0x02;

		if keyboardState[SDL_SCANCODE_UP] // up
			JOYP &= 0xFB; //~0x04;

		if keyboardState[SDL_SCANCODE_DOWN] // down
			JOYP &= 0xF7; //~0x08;
	}

    for bit: 0..3 {
        if (currentState & (1 << bit)) > (JOYP & (1 << bit)) {
			SetInterruptFlag(intService,.Joypad);
            break;
        }
    }
}

Read :: inline (using joypad: *Joypad, address: u16) -> u8 {
	return JOYP;
}

Write :: (using joypad: *Joypad, value: u8, address: u16) {
	JOYP = 0xC0 | (value & 0x30) | (JOYP & 0x0F);
	if doLogs logger(tprint("JOYP = % ; %\n",u8ToHex(value),u8ToHex(JOYP)));
	Update(joypad);
    if doLogs logger(tprint("JOYP (after) = %\n",u8ToHex(JOYP)));
}
