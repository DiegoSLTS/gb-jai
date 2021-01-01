#import "Basic";
#load "logger.jai";

opCodeNames :: string.[
    "NOP", 			"LD ",		"LD ",	"INC ",		"INC ", 		"DEC ", 		"LD ", 		"RLC ", 		"LD ",	"ADD ", 	"LD ",	"DEC ", 	"INC ", 		"DEC ", 	"LD ",		"RRC A",
    "STOP",			"LD ",		"LD ",	"INC ", 		"INC ", 		"DEC ", 		"LD ", 		"RL ", 		"JR ", 		"ADD ", 	"LD ",	"DEC ", 	"INC ",		"DEC ", 	"LD ", 		"RR ",
    "JR NZ,", 		"LD ",		"LDI ",	"INC ", 		"INC ", 		"DEC ", 		"LD ", 		"DAA", 			"JR Z,", 		"ADD ", 	"LDI ",	"DEC ", 	"INC ", 		"DEC ", 	"LD ", 		"CPL",
    "JR NC,", 		"LD ",		"LDD ",	"INC ", 		"INC ", 	"DEC ", 	"LD ", 	"SCF", 			"JR C,", 		"ADD ", 	"LDD ",	"DEC ", 	"INC ", 		"DEC ", 	"LD ", 		"CCF",
    "LD ",		"LD ", 		"LD ",		"LD ", 		"LD ", 		"LD ", 		"LD ",	"LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ", 	"LD ",		"LD ", 	"LD ",	"LD ",
    "LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ",	"LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ", 	"LD ", 		"LD ", 	"LD ",	"LD ",
    "LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ",	"LD ", 		"LD ", 		"LD ", 		"LD ", 		"LD ", 	"LD ", 		"LD ", 	"LD ",	"LD ",
    "LD ",	"LD ",	"LD ",	"LD ",	"LD ", 	"LD ",	"HALT", 		"LD ",	"LD ", 		"LD ", 		"LD ", 		"LD ", 	"LD ", 		"LD ", 	"LD ",	"LD ",
    "ADD ", 		"ADD ", 		"ADD ", 		"ADD ", 		"ADD ", 		"ADD ", 		"ADD ",	"ADD ", 		"ADC ", 		"ADC ", 		"ADC ", 		"ADC ", 	"ADC ", 		"ADC ", 	"ADC ",	"ADC ",
    "SUB ", 		"SUB ", 		"SUB ", 		"SUB ", 		"SUB ", 		"SUB ", 		"SUB ",	"SUB ", 		"SBC ", 		"SBC ", 		"SBC ", 		"SBC ", 	"SBC ", 		"SBC ", 	"SBC ",	"SBC ",
    "AND ",		"AND ", 		"AND ", 		"AND ", 		"AND ", 		"AND ", 		"AND ", 	"AND ", 		"XOR ", 		"XOR ", 		"XOR ", 		"XOR ", 	"XOR ", 		"XOR ", 	"XOR ", 	"XOR ",
    "OR ",			"OR ", 		"OR ", 		"OR ", 		"OR ", 		"OR ", 		"OR ", 		"OR ", 		"CP ", 		"CP ",			"CP ", 		"CP ", 	"CP ", 		"CP ", 	"CP ", 		"CP ",
    "RET NZ", 		"POP ", 		"JP NZ,",		"JP ", 		"CALL NZ,", 	"PUSH ", 		"ADD ", 		"RST ", 		"RET Z", 		"RET", 			"JP Z,", 		"CB", 		"CALL Z,", 	"CALL ", 	"ADC ",		"RST ",
    "RET NC", 		"POP ", 		"JP NC,",		"XX", 			"CALL NC,",	"PUSH ", 		"SUB ", 		"RST ", 		"RET C", 		"RETI", 		"JP C,", 		"XX", 		"CALL C,", 	"XX", 		"SBC ", 		"RST ",
    "LDH ",	"POP ", 		"LDH ",	"XX", 			"XX", 			"PUSH ", 		"AND ", 		"RST ",		"ADD ", 	"JP ", 		"LD ", 	"XX", 		"XX", 			"XX",		"XOR ", 		"RST ",
    "LDH ",	"POP ", 		"LDH ", 	"DI", 			"XX", 			"PUSH ",		"OR ", 		"RST ", 		"LDHL ", 	"LD ", 	"LD ",	"EI", 		"XX", 			"XX", 		"CP ", 		"RST ",
];

cbOpCodeNames :: string.[
    "RLC B", 	"RLC C", 	"RLC D", 	"RLC E", 	"RLC H", 	"RLC L", 	"RLC (HL)",		"RLC A", 	"RRC B", 	"RRC C", 	"RRC D", 	"RRC E", 	"RRC H", 	"RRC L", 	"RRC (HL)", 	"RRC A",
    "RL B", 	"RL C", 	"RL D", 	"RL E", 	"RL H", 	"RL L", 	"RL (HL)", 		"RL A", 	"RR B", 	"RR C", 	"RR D", 	"RR E", 	"RR H", 	"RR L", 	"RR (HL)", 		"RR A",
    "SLA B", 	"SLA C", 	"SLA D", 	"SLA E", 	"SLA H", 	"SLA L", 	"SLA (HL)",		"SLA A", 	"SRA B", 	"SRA C", 	"SRA D", 	"SRA E",	"SRA H", 	"SRA L", 	"SRA (HL)", 	"SRA A",
    "SWAP B",	"SWAP C", 	"SWAP D", 	"SWAP E", 	"SWAP H", 	"SWAP L", 	"SWAP (HL)", 	"SWAP A", 	"SRL B", 	"SRL C", 	"SRL D", 	"SRL E",	"SRL H", 	"SRL L", 	"SRL (HL)", 	"SRL A",
    "BIT 0,B", 	"BIT 0,C", 	"BIT 0,D", 	"BIT 0,E", 	"BIT 0,H", 	"BIT 0,L", 	"BIT 0,(HL)",	"BIT 0,A", 	"BIT 1,B", 	"BIT 1,C", 	"BIT 1,D", 	"BIT 1,E", 	"BIT 1,H", 	"BIT 1,L", 	"BIT 1,(HL)",	"BIT 1,A",
    "BIT 2,B", 	"BIT 2,C", 	"BIT 2,D", 	"BIT 2,E", 	"BIT 2,H", 	"BIT 2,L", 	"BIT 2,(HL)",	"BIT 2,A", 	"BIT 3,B", 	"BIT 3,C", 	"BIT 3,D", 	"BIT 3,E", 	"BIT 3,H", 	"BIT 3,L", 	"BIT 3,(HL)",	"BIT 3,A",
    "BIT 4,B", 	"BIT 4,C", 	"BIT 4,D", 	"BIT 4,E", 	"BIT 4,H", 	"BIT 4,L", 	"BIT 4,(HL)",	"BIT 4,A", 	"BIT 5,B", 	"BIT 5,C", 	"BIT 5,D", 	"BIT 5,E", 	"BIT 5,H", 	"BIT 5,L", 	"BIT 5,(HL)",	"BIT 5,A",
    "BIT 6,B", 	"BIT 6,C", 	"BIT 6,D", 	"BIT 6,E", 	"BIT 6,H", 	"BIT 6,L", 	"BIT 6,(HL)",	"BIT 6,A", 	"BIT 7,B", 	"BIT 7,C", 	"BIT 7,D", 	"BIT 7,E", 	"BIT 7,H", 	"BIT 7,L", 	"BIT 7,(HL)",	"BIT 7,A",
    "RES 0,B", 	"RES 0,C", 	"RES 0,D", 	"RES 0,E", 	"RES 0,H", 	"RES 0,L", 	"RES 0,(HL)",	"RES 0,A", 	"RES 1,B", 	"RES 1,C", 	"RES 1,D", 	"RES 1,E", 	"RES 1,H", 	"RES 1,L", 	"RES 1,(HL)",	"RES 1,A",
    "RES 2,B", 	"RES 2,C", 	"RES 2,D", 	"RES 2,E", 	"RES 2,H", 	"RES 2,L", 	"RES 2,(HL)",	"RES 2,A", 	"RES 3,B", 	"RES 3,C", 	"RES 3,D", 	"RES 3,E", 	"RES 3,H", 	"RES 3,L", 	"RES 3,(HL)",	"RES 3,A",
    "RES 4,B", 	"RES 4,C", 	"RES 4,D", 	"RES 4,E", 	"RES 4,H", 	"RES 4,L", 	"RES 4,(HL)",	"RES 4,A", 	"RES 5,B", 	"RES 5,C", 	"RES 5,D", 	"RES 5,E", 	"RES 5,H", 	"RES 5,L", 	"RES 5,(HL)",	"RES 5,A",
    "RES 6,B", 	"RES 6,C", 	"RES 6,D", 	"RES 6,E", 	"RES 6,H", 	"RES 6,L", 	"RES 6,(HL)",	"RES 6,A", 	"RES 7,B", 	"RES 7,C", 	"RES 7,D", 	"RES 7,E", 	"RES 7,H", 	"RES 7,L", 	"RES 7,(HL)",	"RES 7,A",
    "SET 0,B", 	"SET 0,C", 	"SET 0,D", 	"SET 0,E", 	"SET 0,H", 	"SET 0,L", 	"SET 0,(HL)",	"SET 0,A", 	"SET 1,B", 	"SET 1,C", 	"SET 1,D", 	"SET 1,E", 	"SET 1,H", 	"SET 1,L", 	"SET 1,(HL)",	"SET 1,A",
    "SET 2,B", 	"SET 2,C", 	"SET 2,D", 	"SET 2,E", 	"SET 2,H", 	"SET 2,L", 	"SET 2,(HL)",	"SET 2,A", 	"SET 3,B", 	"SET 3,C", 	"SET 3,D", 	"SET 3,E", 	"SET 3,H", 	"SET 3,L", 	"SET 3,(HL)",	"SET 3,A",
    "SET 4,B", 	"SET 4,C", 	"SET 4,D", 	"SET 4,E", 	"SET 4,H", 	"SET 4,L", 	"SET 4,(HL)",	"SET 4,A", 	"SET 5,B", 	"SET 5,C", 	"SET 5,D", 	"SET 5,E", 	"SET 5,H", 	"SET 5,L", 	"SET 5,(HL)",	"SET 5,A",
    "SET 6,B", 	"SET 6,C", 	"SET 6,D", 	"SET 6,E", 	"SET 6,H", 	"SET 6,L", 	"SET 6,(HL)",	"SET 6,A", 	"SET 7,B", 	"SET 7,C", 	"SET 7,D", 	"SET 7,E", 	"SET 7,H", 	"SET 7,L", 	"SET 7,(HL)",	"SET 7,A",
];

BIG_ENDIAN :: true;

CPU8BitReg :: enum {
/*#if BIG_ENDIAN {
	#insert "a; f; b; c; d; e; h; l;";
} else {*/
	f; a; c; b; e; d; l; h;
//}
};

CPU16BitReg :: enum {
	af;
    bc;
    de;
    hl;
};

FlagBit :: enum {
	Carry :: 1 << 4;
	HalfCarry :: 1 << 5;
	Negative :: 1 << 6;
	Zero :: 1 << 7;
};

r8Names :: string.["F", "A", "C", "B", "E", "D", "L", "H"];
r16Names :: string.["AF", "BC", "DE", "HL"];

CPU :: struct {
    opCode : u8;
	pc : u16;
	sp : u16;
    doLogs := false;
	
	mmu : *MMU;
    key1 : u8 = 0x7E;
	intService : *InterruptServiceRoutine;

	isHalted : bool;
	lastOpCycles : u8;

    registers : union {
	    b : [8]u8; // 8 bits registers
        w : [4]u16; // 16 bits registers
    };

	haltBug : bool;

    opCalls : [256]u64;
    cbCalls : [256]u64;
}

Init :: (cpu: *CPU, mmu: *MMU, intService: *InterruptServiceRoutine) {
    cpu.mmu = mmu;
    cpu.intService = intService;
}

// Waits one clock if halted or runs one instruction and returns the clocks spent
Step :: (using cpu: *CPU) -> u8 {
    lastOpCycles = 0;
	if intService.IE && intService.IF {
		if isHalted {
            if doLogs logger("cpu unhalted\n");
			isHalted = false;
			lastOpCycles += 1;
		}

		if intService.IME {
			for 0..4 {
				flag := cast(InterruptFlag) (1 << it);
				if IsInterruptSet(intService, flag) && IsInterruptEnabled(intService, flag) {
					intService.IME = false;
					ResetInterruptFlag(intService, flag);
					Push16(cpu, pc); // cpu.lastOpCycles set to 2
					pc = xx (0x40 + it * 8); //0x40, 0x48, 0x50, 0x58, 0x60
					lastOpCycles += 3; // +2 idle cycles, +1 updating PC
					break;
				}
			}
		}
	}
    
	if intService.eiDelay {
		intService.IME = true;
		intService.eiDelay = false;
	}
    
	// used only for debugging to break at specific instructions
	//if pc == 0x0100
	//	doLogs = true;

	if !isHalted {
        opCode = ReadAtPC(cpu);
		if opCode == 0xCB {
			opCode = ReadAtPC(cpu);
			CallCBOpCode(cpu, opCode);
		} else
			CallOpCode(cpu, opCode);
    } else
        lastOpCycles = 1;

	return lastOpCycles;
}

Read :: inline (using cpu: *CPU, address: u16) -> u8 {
    if address == 0xFF4D
        return key1 | 0x7E;
    return 0xFF;
}

Write :: (using cpu: *CPU, value: u8, address: u16) {
    if address == 0xFF4D
        key1 = (key1 & 0xFE) | (value & 0x01);
}

IsDoubleSpeedEnabled :: (using cpu: *CPU) -> bool {
    return (key1 & 0x80) == 0x80;
}

Read8BitReg :: (using cpu: *CPU, reg: CPU8BitReg) -> u8 {
    return registers.b[reg];
}

Read16BitReg :: (using cpu: *CPU, reg: CPU16BitReg) -> u16 {
	return registers.w[reg];
}
	
Load :: (using cpu: *CPU, fileContent: *string) {
    consume_u8_and_length(fileContent, registers.b.data, registers.b.count);
    consume_u8_and_length(fileContent, cast(*u8)*pc, 2);
    consume_u8_and_length(fileContent, cast(*u8)*sp, 2);

    //TODO deserialize IME, isHalted
}

Save :: (using cpu: *CPU, builder: *String_Builder) {
    append(builder, registers.b.data, registers.b.count);
    append(builder, cast(*u8)*pc, 2);
    append(builder, cast(*u8)*sp, 2);

	//TODO serialize IME, isHalted
}

reg8ToString :: (using cpu: *CPU, reg: CPU8BitReg) -> string {
    value := Read8BitReg(cpu, reg);
    return tprint("% = %", r8Names[cast(u8)reg], u8ToHex(value));
}

reg16ToString :: (using cpu: *CPU, reg: CPU16BitReg) -> string {
    value := Read16BitReg(cpu, reg);
    return tprint("% = %", r16Names[cast(u8)reg], u16ToHex(value));
}

CallOpCode :: (using cpu: *CPU, code: u8) {
    if doLogs {
        logger(pc-1);
        logger(opCodeNames[code]);
    }

    opCalls[code] += 1;
    if (opCalls[code] == 0)
        print("!!! %\n",code);

    if code == {
        //case 0x00; NOP(cpu);
        case 0x01; LDr16n16(cpu, .bc);
        case 0x02; LDr16A(cpu, .bc);
        case 0x03; INCr16(cpu, .bc);
        case 0x04; INCr8(cpu, .b);
        case 0x05; DECr8(cpu, .b);
        case 0x06; LDr8n8(cpu, .b);
        case 0x07; RLCA(cpu);
        case 0x08; LDn16SP(cpu);
        case 0x09; ADDHLr16(cpu, .bc);
        case 0x0A; LDAr16(cpu, .bc);
        case 0x0B; DECr16(cpu, .bc);
        case 0x0C; INCr8(cpu, .c);
        case 0x0D; DECr8(cpu, .c);
        case 0x0E; LDr8n8(cpu, .c);
        case 0x0F; RRCA(cpu);

        case 0x10; STOP(cpu);
        case 0x11; LDr16n16(cpu, .de);
        case 0x12; LDr16A(cpu, .de);
        case 0x13; INCr16(cpu, .de);
        case 0x14; INCr8(cpu, .d);
        case 0x15; DECr8(cpu, .d);
        case 0x16; LDr8n8(cpu, .d);
        case 0x17; RLA(cpu);
        case 0x18; JRe8(cpu);
        case 0x19; ADDHLr16(cpu, .de);
        case 0x1A; LDAr16(cpu, .de);
        case 0x1B; DECr16(cpu, .de);
        case 0x1C; INCr8(cpu, .e);
        case 0x1D; DECr8(cpu, .e);
        case 0x1E; LDr8n8(cpu, .e);
        case 0x1F; RRA(cpu);

        case 0x20; JRcce8(cpu, !HasFlag(cpu, .Zero));
        case 0x21; LDr16n16(cpu, .hl);
        case 0x22; LDHLincA(cpu);
        case 0x23; INCr16(cpu, .hl);
        case 0x24; INCr8(cpu, .h);
        case 0x25; DECr8(cpu, .h);
        case 0x26; LDr8n8(cpu, .h);
        case 0x27; DAA(cpu);
        case 0x28; JRcce8(cpu, HasFlag(cpu, .Zero));
        case 0x29; ADDHLr16(cpu, .hl);
        case 0x2A; LDAHLinc(cpu);
        case 0x2B; DECr16(cpu, .hl);
        case 0x2C; INCr8(cpu, .l);
        case 0x2D; DECr8(cpu, .l);
        case 0x2E; LDr8n8(cpu, .l);
        case 0x2F; CPL(cpu);

        case 0x30; JRcce8(cpu, !HasFlag(cpu, .Carry));
        case 0x31; LDSPn16(cpu);
        case 0x32; LDHLdecA(cpu);
        case 0x33; INCSP(cpu);
        case 0x34; INCHL(cpu);
        case 0x35; DECHL(cpu);
        case 0x36; LDHLn8(cpu);
        case 0x37; SCF(cpu);
        case 0x38; JRcce8(cpu, HasFlag(cpu, .Carry));
        case 0x39; ADDHLSP(cpu);
        case 0x3A; LDAHLdec(cpu);
        case 0x3B; DECSP(cpu);
        case 0x3C; INCr8(cpu, .a);
        case 0x3D; DECr8(cpu, .a);
        case 0x3E; LDr8n8(cpu, .a);
        case 0x3F; CCF(cpu);

        case 0x40; LDr8r8(cpu, .b, .b);
        case 0x41; LDr8r8(cpu, .b, .c);
        case 0x42; LDr8r8(cpu, .b, .d);
        case 0x43; LDr8r8(cpu, .b, .e);
        case 0x44; LDr8r8(cpu, .b, .h);
        case 0x45; LDr8r8(cpu, .b, .l);
        case 0x46; LDr8HL(cpu, .b);
        case 0x47; LDr8r8(cpu, .b, .a);
        case 0x48; LDr8r8(cpu, .c, .b);
        case 0x49; LDr8r8(cpu, .c, .c);
        case 0x4A; LDr8r8(cpu, .c, .d);
        case 0x4B; LDr8r8(cpu, .c, .e);
        case 0x4C; LDr8r8(cpu, .c, .h);
        case 0x4D; LDr8r8(cpu, .c, .l);
        case 0x4E; LDr8HL(cpu, .c);
        case 0x4F; LDr8r8(cpu, .c, .a);

        case 0x50; LDr8r8(cpu, .d, .b);
        case 0x51; LDr8r8(cpu, .d, .c);
        case 0x52; LDr8r8(cpu, .d, .d);
        case 0x53; LDr8r8(cpu, .d, .e);
        case 0x54; LDr8r8(cpu, .d, .h);
        case 0x55; LDr8r8(cpu, .d, .l);
        case 0x56; LDr8HL(cpu, .d);
        case 0x57; LDr8r8(cpu, .d, .a);
        case 0x58; LDr8r8(cpu, .e, .b);
        case 0x59; LDr8r8(cpu, .e, .c);
        case 0x5A; LDr8r8(cpu, .e, .d);
        case 0x5B; LDr8r8(cpu, .e, .e);
        case 0x5C; LDr8r8(cpu, .e, .h);
        case 0x5D; LDr8r8(cpu, .e, .l);
        case 0x5E; LDr8HL(cpu, .e);
        case 0x5F; LDr8r8(cpu, .e, .a);

        case 0x60; LDr8r8(cpu, .h, .b);
        case 0x61; LDr8r8(cpu, .h, .c);
        case 0x62; LDr8r8(cpu, .h, .d);
        case 0x63; LDr8r8(cpu, .h, .e);
        case 0x64; LDr8r8(cpu, .h, .h);
        case 0x65; LDr8r8(cpu, .h, .l);
        case 0x66; LDr8HL(cpu, .h);
        case 0x67; LDr8r8(cpu, .h, .a);
        case 0x68; LDr8r8(cpu, .l, .b);
        case 0x69; LDr8r8(cpu, .l, .c);
        case 0x6A; LDr8r8(cpu, .l, .d);
        case 0x6B; LDr8r8(cpu, .l, .e);
        case 0x6C; LDr8r8(cpu, .l, .h);
        case 0x6D; LDr8r8(cpu, .l, .l);
        case 0x6E; LDr8HL(cpu, .l);
        case 0x6F; LDr8r8(cpu, .l, .a);

        case 0x70; LDHLr8(cpu, .b);
        case 0x71; LDHLr8(cpu, .c);
        case 0x72; LDHLr8(cpu, .d);
        case 0x73; LDHLr8(cpu, .e);
        case 0x74; LDHLr8(cpu, .h);
        case 0x75; LDHLr8(cpu, .l);
        case 0x76; HALT(cpu);
        case 0x77; LDHLr8(cpu, .a);
        case 0x78; LDr8r8(cpu, .a, .b);
        case 0x79; LDr8r8(cpu, .a, .c);
        case 0x7A; LDr8r8(cpu, .a, .d);
        case 0x7B; LDr8r8(cpu, .a, .e);
        case 0x7C; LDr8r8(cpu, .a, .h);
        case 0x7D; LDr8r8(cpu, .a, .l);
        case 0x7E; LDr8HL(cpu, .a);
        case 0x7F; LDr8r8(cpu, .a, .a);

        case 0x80; ADDAr8(cpu, .b);
        case 0x81; ADDAr8(cpu, .c);
        case 0x82; ADDAr8(cpu, .d);
        case 0x83; ADDAr8(cpu, .e);
        case 0x84; ADDAr8(cpu, .h);
        case 0x85; ADDAr8(cpu, .l);
        case 0x86; ADDAHL(cpu);
        case 0x87; ADDAr8(cpu, .a);
        case 0x88; ADCAr8(cpu, .b);
        case 0x89; ADCAr8(cpu, .c);
        case 0x8A; ADCAr8(cpu, .d);
        case 0x8B; ADCAr8(cpu, .e);
        case 0x8C; ADCAr8(cpu, .h);
        case 0x8D; ADCAr8(cpu, .l);
        case 0x8E; ADCAHL(cpu);
        case 0x8F; ADCAr8(cpu, .a);

        case 0x90; SUBAr8(cpu, .b);
        case 0x91; SUBAr8(cpu, .c);
        case 0x92; SUBAr8(cpu, .d);
        case 0x93; SUBAr8(cpu, .e);
        case 0x94; SUBAr8(cpu, .h);
        case 0x95; SUBAr8(cpu, .l);
        case 0x96; SUBAHL(cpu);
        case 0x97; SUBAr8(cpu, .a);
        case 0x98; SBCAr8(cpu, .b);
        case 0x99; SBCAr8(cpu, .c);
        case 0x9A; SBCAr8(cpu, .d);
        case 0x9B; SBCAr8(cpu, .e);
        case 0x9C; SBCAr8(cpu, .h);
        case 0x9D; SBCAr8(cpu, .l);
        case 0x9E; SBCAHL(cpu);
        case 0x9F; SBCAr8(cpu, .a);

        case 0xA0; ANDAr8(cpu, .b);
        case 0xA1; ANDAr8(cpu, .c);
        case 0xA2; ANDAr8(cpu, .d);
        case 0xA3; ANDAr8(cpu, .e);
        case 0xA4; ANDAr8(cpu, .h);
        case 0xA5; ANDAr8(cpu, .l);
        case 0xA6; ANDAHL(cpu);
        case 0xA7; ANDAr8(cpu, .a);
        case 0xA8; XORAr8(cpu, .b);
        case 0xA9; XORAr8(cpu, .c);
        case 0xAA; XORAr8(cpu, .d);
        case 0xAB; XORAr8(cpu, .e);
        case 0xAC; XORAr8(cpu, .h);
        case 0xAD; XORAr8(cpu, .l);
        case 0xAE; XORAHL(cpu);
        case 0xAF; XORAr8(cpu, .a);

        case 0xB0; ORAr8(cpu, .b);
        case 0xB1; ORAr8(cpu, .c);
        case 0xB2; ORAr8(cpu, .d);
        case 0xB3; ORAr8(cpu, .e);
        case 0xB4; ORAr8(cpu, .h);
        case 0xB5; ORAr8(cpu, .l);
        case 0xB6; ORAHL(cpu);
        case 0xB7; ORAr8(cpu, .a);
        case 0xB8; CPAr8(cpu, .b);
        case 0xB9; CPAr8(cpu, .c);
        case 0xBA; CPAr8(cpu, .d);
        case 0xBB; CPAr8(cpu, .e);
        case 0xBC; CPAr8(cpu, .h);
        case 0xBD; CPAr8(cpu, .l);
        case 0xBE; CPAHL(cpu);
        case 0xBF; CPAr8(cpu, .a);

        case 0xC0; RETcc(cpu, !HasFlag(cpu, .Zero));
        case 0xC1; POPr16(cpu, .bc);
        case 0xC2; JPccn16(cpu, !HasFlag(cpu, .Zero));
        case 0xC3; JPn16(cpu);
        case 0xC4; CALLccn16(cpu, !HasFlag(cpu, .Zero));
        case 0xC5; PUSHr16(cpu, .bc);
        case 0xC6; ADDAn8(cpu);
        case 0xC7; RSTvec(cpu, 0x00);
        case 0xC8; RETcc(cpu, HasFlag(cpu, .Zero));
        case 0xC9; RET(cpu);
        case 0xCA; JPccn16(cpu, HasFlag(cpu, .Zero));
        //case 0xCB; CB!
        case 0xCC; CALLccn16(cpu, HasFlag(cpu, .Zero));
        case 0xCD; CALLn16(cpu);
        case 0xCE; ADCAn8(cpu);
        case 0xCF; RSTvec(cpu, 0x08);

        case 0xD0; RETcc(cpu, !HasFlag(cpu, .Carry));
        case 0xD1; POPr16(cpu, .de);
        case 0xD2; JPccn16(cpu, !HasFlag(cpu, .Carry));
        //case 0xD3;
        case 0xD4; CALLccn16(cpu, !HasFlag(cpu, .Carry));
        case 0xD5; PUSHr16(cpu, .de);
        case 0xD6; SUBAn8(cpu);
        case 0xD7; RSTvec(cpu, 0x10);
        case 0xD8; RETcc(cpu, HasFlag(cpu, .Carry));
        case 0xD9; RETI(cpu);
        case 0xDA; JPccn16(cpu, HasFlag(cpu, .Carry));
        //case 0xDB; 
        case 0xDC; CALLccn16(cpu, HasFlag(cpu, .Carry));
        //case 0xDD;
        case 0xDE; SBCAn8(cpu);
        case 0xDF; RSTvec(cpu, 0x18);

        case 0xE0; LDHn8A(cpu);
        case 0xE1; POPr16(cpu, .hl);
        case 0xE2; LDHCA(cpu);
        //case 0xE3;
        //case 0xE4;
        case 0xE5; PUSHr16(cpu, .hl);
        case 0xE6; ANDAn8(cpu);
        case 0xE7; RSTvec(cpu, 0x20);
        case 0xE8; ADDSPe8(cpu);
        case 0xE9; JPHL(cpu);
        case 0xEA; LDn16A(cpu);
        //case 0xEB;
        //case 0xEC;
        //case 0xED;
        case 0xEE; XORAn8(cpu);
        case 0xEF; RSTvec(cpu, 0x28);

        case 0xF0; LDHAn8(cpu);
        case 0xF1; POPr16(cpu, .af);
        case 0xF2; LDHAC(cpu);
        case 0xF3; DI(cpu);
        //case 0xF4;
        case 0xF5; PUSHr16(cpu, .af);
        case 0xF6; ORAn8(cpu);
        case 0xF7; RSTvec(cpu, 0x30);
        case 0xF8; LDHLSPe8(cpu);
        case 0xF9; LDSPHL(cpu);
        case 0xFA; LDAn16(cpu);
        case 0xFB; EI(cpu);
        //case 0xFC;
        //case 0xFD;
        case 0xFE; CPAn8(cpu);
        case 0xFF; RSTvec(cpu, 0x38);
	}
}

CallCBOpCode :: (using cpu: *CPU, code: u8) {
    if doLogs {
        logger(pc-1);
        logger(cbOpCodeNames[code]);
    }

    cbCalls[code] += 1;
    if (cbCalls[code] == 0)
        print("!!! %\n",code);

	if code == {
        case 0x00; RLCr8(cpu, .b);
        case 0x01; RLCr8(cpu, .c);
        case 0x02; RLCr8(cpu, .d);
        case 0x03; RLCr8(cpu, .e);
        case 0x04; RLCr8(cpu, .h);
        case 0x05; RLCr8(cpu, .l);
        case 0x06; RLCHL(cpu);
        case 0x07; RLCr8(cpu, .a);
        case 0x08; RRCr8(cpu, .b);
        case 0x09; RRCr8(cpu, .c);
        case 0x0A; RRCr8(cpu, .d);
        case 0x0B; RRCr8(cpu, .e);
        case 0x0C; RRCr8(cpu, .h);
        case 0x0D; RRCr8(cpu, .l);
        case 0x0E; RRCHL(cpu);
        case 0x0F; RRCr8(cpu, .a);

        case 0x10; RLr8(cpu, .b);
        case 0x11; RLr8(cpu, .c);
        case 0x12; RLr8(cpu, .d);
        case 0x13; RLr8(cpu, .e);
        case 0x14; RLr8(cpu, .h);
        case 0x15; RLr8(cpu, .l);
        case 0x16; RLHL(cpu);
        case 0x17; RLr8(cpu, .a);
        case 0x18; RRr8(cpu, .b);
        case 0x19; RRr8(cpu, .c);
        case 0x1A; RRr8(cpu, .d);
        case 0x1B; RRr8(cpu, .e);
        case 0x1C; RRr8(cpu, .h);
        case 0x1D; RRr8(cpu, .l);
        case 0x1E; RRHL(cpu);
        case 0x1F; RRr8(cpu, .a);

        case 0x20; SLAr8(cpu, .b);
        case 0x21; SLAr8(cpu, .c);
        case 0x22; SLAr8(cpu, .d);
        case 0x23; SLAr8(cpu, .e);
        case 0x24; SLAr8(cpu, .h);
        case 0x25; SLAr8(cpu, .l);
        case 0x26; SLAHL(cpu);
        case 0x27; SLAr8(cpu, .a);
        case 0x28; SRAr8(cpu, .b);
        case 0x29; SRAr8(cpu, .c);
        case 0x2A; SRAr8(cpu, .d);
        case 0x2B; SRAr8(cpu, .e);
        case 0x2C; SRAr8(cpu, .h);
        case 0x2D; SRAr8(cpu, .l);
        case 0x2E; SRAHL(cpu);
        case 0x2F; SRAr8(cpu, .a);

        case 0x30; SWAPr8(cpu, .b);
        case 0x31; SWAPr8(cpu, .c);
        case 0x32; SWAPr8(cpu, .d);
        case 0x33; SWAPr8(cpu, .e);
        case 0x34; SWAPr8(cpu, .h);
        case 0x35; SWAPr8(cpu, .l);
        case 0x36; SWAPHL(cpu);
        case 0x37; SWAPr8(cpu, .a);
        case 0x38; SRLr8(cpu, .b);
        case 0x39; SRLr8(cpu, .c);
        case 0x3A; SRLr8(cpu, .d);
        case 0x3B; SRLr8(cpu, .e);
        case 0x3C; SRLr8(cpu, .h);
        case 0x3D; SRLr8(cpu, .l);
        case 0x3E; SRLHL(cpu);
        case 0x3F; SRLr8(cpu, .a);

        case 0x40; BITu3r8(cpu, 0, .b);
        case 0x41; BITu3r8(cpu, 0, .c);
        case 0x42; BITu3r8(cpu, 0, .d);
        case 0x43; BITu3r8(cpu, 0, .e);
        case 0x44; BITu3r8(cpu, 0, .h);
        case 0x45; BITu3r8(cpu, 0, .l);
        case 0x46; BITu3HL(cpu, 0);
        case 0x47; BITu3r8(cpu, 0, .a);
        case 0x48; BITu3r8(cpu, 1, .b);
        case 0x49; BITu3r8(cpu, 1, .c);
        case 0x4A; BITu3r8(cpu, 1, .d);
        case 0x4B; BITu3r8(cpu, 1, .e);
        case 0x4C; BITu3r8(cpu, 1, .h);
        case 0x4D; BITu3r8(cpu, 1, .l);
        case 0x4E; BITu3HL(cpu, 1);
        case 0x4F; BITu3r8(cpu, 1, .a);

        case 0x50; BITu3r8(cpu, 2, .b);
        case 0x51; BITu3r8(cpu, 2, .c);
        case 0x52; BITu3r8(cpu, 2, .d);
        case 0x53; BITu3r8(cpu, 2, .e);
        case 0x54; BITu3r8(cpu, 2, .h);
        case 0x55; BITu3r8(cpu, 2, .l);
        case 0x56; BITu3HL(cpu, 2);
        case 0x57; BITu3r8(cpu, 2, .a);
        case 0x58; BITu3r8(cpu, 3, .b);
        case 0x59; BITu3r8(cpu, 3, .c);
        case 0x5A; BITu3r8(cpu, 3, .d);
        case 0x5B; BITu3r8(cpu, 3, .e);
        case 0x5C; BITu3r8(cpu, 3, .h);
        case 0x5D; BITu3r8(cpu, 3, .l);
        case 0x5E; BITu3HL(cpu, 3);
        case 0x5F; BITu3r8(cpu, 3, .a);

        case 0x60; BITu3r8(cpu, 4, .b);
        case 0x61; BITu3r8(cpu, 4, .c);
        case 0x62; BITu3r8(cpu, 4, .d);
        case 0x63; BITu3r8(cpu, 4, .e);
        case 0x64; BITu3r8(cpu, 4, .h);
        case 0x65; BITu3r8(cpu, 4, .l);
        case 0x66; BITu3HL(cpu, 4);
        case 0x67; BITu3r8(cpu, 4, .a);
        case 0x68; BITu3r8(cpu, 5, .b);
        case 0x69; BITu3r8(cpu, 5, .c);
        case 0x6A; BITu3r8(cpu, 5, .d);
        case 0x6B; BITu3r8(cpu, 5, .e);
        case 0x6C; BITu3r8(cpu, 5, .h);
        case 0x6D; BITu3r8(cpu, 5, .l);
        case 0x6E; BITu3HL(cpu, 5);
        case 0x6F; BITu3r8(cpu, 5, .a);

        case 0x71; BITu3r8(cpu, 6, .c);
        case 0x70; BITu3r8(cpu, 6, .b);
        case 0x72; BITu3r8(cpu, 6, .d);
        case 0x73; BITu3r8(cpu, 6, .e);
        case 0x74; BITu3r8(cpu, 6, .h);
        case 0x75; BITu3r8(cpu, 6, .l);
        case 0x76; BITu3HL(cpu, 6);
        case 0x77; BITu3r8(cpu, 6, .a);
        case 0x78; BITu3r8(cpu, 7, .b);
        case 0x79; BITu3r8(cpu, 7, .c);
        case 0x7A; BITu3r8(cpu, 7, .d);
        case 0x7B; BITu3r8(cpu, 7, .e);
        case 0x7C; BITu3r8(cpu, 7, .h);
        case 0x7D; BITu3r8(cpu, 7, .l);
        case 0x7E; BITu3HL(cpu, 7);
        case 0x7F; BITu3r8(cpu, 7, .a);

        case 0x81; RESu3r8(cpu, 0, .c);
        case 0x80; RESu3r8(cpu, 0, .b);
        case 0x82; RESu3r8(cpu, 0, .d);
        case 0x83; RESu3r8(cpu, 0, .e);
        case 0x84; RESu3r8(cpu, 0, .h);
        case 0x85; RESu3r8(cpu, 0, .l);
        case 0x86; RESu3HL(cpu, 0);
        case 0x87; RESu3r8(cpu, 0, .a);
        case 0x88; RESu3r8(cpu, 1, .b);
        case 0x89; RESu3r8(cpu, 1, .c);
        case 0x8A; RESu3r8(cpu, 1, .d);
        case 0x8B; RESu3r8(cpu, 1, .e);
        case 0x8C; RESu3r8(cpu, 1, .h);
        case 0x8D; RESu3r8(cpu, 1, .l);
        case 0x8E; RESu3HL(cpu, 1);
        case 0x8F; RESu3r8(cpu, 1, .a);

        case 0x90; RESu3r8(cpu, 2, .b);
        case 0x91; RESu3r8(cpu, 2, .c);
        case 0x92; RESu3r8(cpu, 2, .d);
        case 0x93; RESu3r8(cpu, 2, .e);
        case 0x94; RESu3r8(cpu, 2, .h);
        case 0x95; RESu3r8(cpu, 2, .l);
        case 0x96; RESu3HL(cpu, 2);
        case 0x97; RESu3r8(cpu, 2, .a);
        case 0x98; RESu3r8(cpu, 3, .b);
        case 0x99; RESu3r8(cpu, 3, .c);
        case 0x9A; RESu3r8(cpu, 3, .d);
        case 0x9B; RESu3r8(cpu, 3, .e);
        case 0x9C; RESu3r8(cpu, 3, .h);
        case 0x9D; RESu3r8(cpu, 3, .l);
        case 0x9E; RESu3HL(cpu, 3);
        case 0x9F; RESu3r8(cpu, 3, .a);

        case 0xA0; RESu3r8(cpu, 4, .b);
        case 0xA1; RESu3r8(cpu, 4, .c);
        case 0xA2; RESu3r8(cpu, 4, .d);
        case 0xA3; RESu3r8(cpu, 4, .e);
        case 0xA4; RESu3r8(cpu, 4, .h);
        case 0xA5; RESu3r8(cpu, 4, .l);
        case 0xA6; RESu3HL(cpu, 4);
        case 0xA7; RESu3r8(cpu, 4, .a);
        case 0xA8; RESu3r8(cpu, 5, .b);
        case 0xA9; RESu3r8(cpu, 5, .c);
        case 0xAA; RESu3r8(cpu, 5, .d);
        case 0xAB; RESu3r8(cpu, 5, .e);
        case 0xAC; RESu3r8(cpu, 5, .h);
        case 0xAD; RESu3r8(cpu, 5, .l);
        case 0xAE; RESu3HL(cpu, 5);
        case 0xAF; RESu3r8(cpu, 5, .a);

        case 0xB0; RESu3r8(cpu, 6, .b);
        case 0xB1; RESu3r8(cpu, 6, .c);
        case 0xB2; RESu3r8(cpu, 6, .d);
        case 0xB3; RESu3r8(cpu, 6, .e);
        case 0xB4; RESu3r8(cpu, 6, .h);
        case 0xB5; RESu3r8(cpu, 6, .l);
        case 0xB6; RESu3HL(cpu, 6);
        case 0xB7; RESu3r8(cpu, 6, .a);
        case 0xB8; RESu3r8(cpu, 7, .b);
        case 0xB9; RESu3r8(cpu, 7, .c);
        case 0xBA; RESu3r8(cpu, 7, .d);
        case 0xBB; RESu3r8(cpu, 7, .e);
        case 0xBC; RESu3r8(cpu, 7, .h);
        case 0xBD; RESu3r8(cpu, 7, .l);
        case 0xBE; RESu3HL(cpu, 7);
        case 0xBF; RESu3r8(cpu, 7, .a);

        case 0xC0; SETu3r8(cpu, 0, .b);
        case 0xC1; SETu3r8(cpu, 0, .c);
        case 0xC2; SETu3r8(cpu, 0, .d);
        case 0xC3; SETu3r8(cpu, 0, .e);
        case 0xC4; SETu3r8(cpu, 0, .h);
        case 0xC5; SETu3r8(cpu, 0, .l);
        case 0xC6; SETu3HL(cpu, 0);
        case 0xC7; SETu3r8(cpu, 0, .a);
        case 0xC8; SETu3r8(cpu, 1, .b);
        case 0xC9; SETu3r8(cpu, 1, .c);
        case 0xCA; SETu3r8(cpu, 1, .d);
        case 0xCB; SETu3r8(cpu, 1, .e);
        case 0xCC; SETu3r8(cpu, 1, .h);
        case 0xCD; SETu3r8(cpu, 1, .l);
        case 0xCE; SETu3HL(cpu, 1);
        case 0xCF; SETu3r8(cpu, 1, .a);

        case 0xD0; SETu3r8(cpu, 2, .b);
        case 0xD1; SETu3r8(cpu, 2, .c);
        case 0xD2; SETu3r8(cpu, 2, .d);
        case 0xD3; SETu3r8(cpu, 2, .e);
        case 0xD4; SETu3r8(cpu, 2, .h);
        case 0xD5; SETu3r8(cpu, 2, .l);
        case 0xD6; SETu3HL(cpu, 2);
        case 0xD7; SETu3r8(cpu, 2, .a);
        case 0xD8; SETu3r8(cpu, 3, .b);
        case 0xD9; SETu3r8(cpu, 3, .c);
        case 0xDA; SETu3r8(cpu, 3, .d);
        case 0xDB; SETu3r8(cpu, 3, .e);
        case 0xDC; SETu3r8(cpu, 3, .h);
        case 0xDD; SETu3r8(cpu, 3, .l);
        case 0xDE; SETu3HL(cpu, 3);
        case 0xDF; SETu3r8(cpu, 3, .a);

        case 0xE0; SETu3r8(cpu, 4, .b);
        case 0xE1; SETu3r8(cpu, 4, .c);
        case 0xE2; SETu3r8(cpu, 4, .d);
        case 0xE3; SETu3r8(cpu, 4, .e);
        case 0xE4; SETu3r8(cpu, 4, .h);
        case 0xE5; SETu3r8(cpu, 4, .l);
        case 0xE6; SETu3HL(cpu, 4);
        case 0xE7; SETu3r8(cpu, 4, .a);
        case 0xE8; SETu3r8(cpu, 5, .b);
        case 0xE9; SETu3r8(cpu, 5, .c);
        case 0xEA; SETu3r8(cpu, 5, .d);
        case 0xEB; SETu3r8(cpu, 5, .e);
        case 0xEC; SETu3r8(cpu, 5, .h);
        case 0xED; SETu3r8(cpu, 5, .l);
        case 0xEE; SETu3HL(cpu, 5);
        case 0xEF; SETu3r8(cpu, 5, .a);

        case 0xF0; SETu3r8(cpu, 6, .b);
        case 0xF1; SETu3r8(cpu, 6, .c);
        case 0xF2; SETu3r8(cpu, 6, .d);
        case 0xF3; SETu3r8(cpu, 6, .e);
        case 0xF4; SETu3r8(cpu, 6, .h);
        case 0xF5; SETu3r8(cpu, 6, .l);
        case 0xF6; SETu3HL(cpu, 6);
        case 0xF7; SETu3r8(cpu, 6, .a);
        case 0xF8; SETu3r8(cpu, 7, .b);
        case 0xF9; SETu3r8(cpu, 7, .c);
        case 0xFA; SETu3r8(cpu, 7, .d);
        case 0xFB; SETu3r8(cpu, 7, .e);
        case 0xFC; SETu3r8(cpu, 7, .h);
        case 0xFD; SETu3r8(cpu, 7, .l);
        case 0xFE; SETu3HL(cpu, 7);
        case 0xFF; SETu3r8(cpu, 7, .a);
	}
}

Write8BitReg :: (using cpu: *CPU, reg: CPU8BitReg, value: u8) {
    if reg == .f
		value &= 0xF0;
	registers.b[reg] = value;
}

Write16BitReg :: (using cpu: *CPU, reg: CPU16BitReg, value: u16) {
    if reg == .af
        value &= 0xFFF0;
	registers.w[reg] = value;
}

ReadAcc :: (using cpu: *CPU) -> u8 {
    return Read8BitReg(cpu, .a);
}

WriteAcc :: (using cpu: *CPU, value: u8) {
    Write8BitReg(cpu, .a, value);
}

ReadHL :: (using cpu: *CPU) -> u16 {
    return Read16BitReg(cpu, .hl);
}

WriteHL :: (using cpu: *CPU, value: u16) {
    Write16BitReg(cpu, .hl, value);
}

Pop16 :: (using cpu: *CPU) -> u16 {
    lsb := ReadMemory(cpu, sp);
	msb := (cast(u16)ReadMemory(cpu, sp + 1)) << 8;
	sp += 2;
	return msb | lsb;
}

Push16 :: (using cpu: *CPU, value: u16) {
    WriteMemory(cpu, sp - 1, xx (value >> 8));
	WriteMemory(cpu, sp - 2, xx (value & 0xFF));
	sp -= 2;
}
// registers

// memory
ReadMemory :: (using cpu: *CPU, address: u16) -> u8 {
    lastOpCycles += 1;
    return Read(mmu, address);
}

WriteMemory :: (using cpu: *CPU, address: u16, value: u8) {
    lastOpCycles += 1;
    Write(mmu, address, value);
}

ReadAtPC :: (using cpu: *CPU) -> u8 {
    valueAtPC := Read(mmu, pc);
    pc += 1;
    if haltBug {
        pc -= 1;
        haltBug = false;
    }
    lastOpCycles += 1;
    return valueAtPC;
}

Read16AtPC :: (using cpu: *CPU) -> u16 {
    low : u16 = ReadAtPC(cpu);
    high : u16 = ReadAtPC(cpu);
	return low | (high << 8);
}
// memory

// flags
SetFlag :: (using cpu: *CPU, flagBit: FlagBit, $$ set: bool) {
    flags := cast(FlagBit)registers.b[CPU8BitReg.f];
    if set
		Write8BitReg(cpu, CPU8BitReg.f, xx (flags | flagBit));
    else
		Write8BitReg(cpu, CPU8BitReg.f, xx (flags & ~flagBit));
}

HasFlag :: (using cpu: *CPU, flagBit: FlagBit) -> bool {
    flags := registers.b[cast(u8)CPU8BitReg.f];
	return (flags & cast(u8)flagBit) != 0;
}

UpdateZeroFlag :: (using cpu: *CPU, value: u8) -> bool {
    set := value == 0;
	SetFlag(cpu, .Zero, set);
	return set;
}

UpdateHalfCarryFlag :: (using cpu: *CPU, previous: u8, current: u8, isAdd: bool) -> bool {
    set : bool;
    if isAdd
        set = (current & 0x0F) < (previous & 0x0F);
    else
        set = (current & 0x0F) > (previous & 0x0F);
    
    SetFlag(cpu, .HalfCarry, set);
    return set;
}

/*UpdateCarryFlag :: (previous: u8, current: u8, isAdd: bool) -> bool {
    set : bool;
    if isAdd {
        set = current < previous;
    } else {
        set = current > previous;
    }
	SetFlag(.Carry, set);
	return set;
}

UpdateZeroFlag :: (value: u16) -> bool {
    set := value == 0;
	SetFlag(.Zero, set);
	return set;
}*/

UpdateHalfCarryFlag :: (using cpu: *CPU, previous: u16, current: u16, isAdd: bool) -> bool {
    set : bool;
    if isAdd
        set = (current & 0x0FFF) < (previous & 0x0FFF);
    else
        set = (current & 0x0FFF) > (previous & 0x0FFF);
    
	SetFlag(cpu, .HalfCarry, set);
	return set;
}

UpdateCarryFlag :: (using cpu: *CPU, previous: u16, current: u16, isAdd: bool) -> bool {
    set : bool;
    if isAdd
        set = current < previous;
    else
        set = current > previous;
    
	SetFlag(cpu, .Carry, set);
	return set;
}
// flags

// internal
ADCA :: (using cpu: *CPU, value: u8) {
    current := ReadAcc(cpu);
	result := current + value;
    
    if doLogs logger(tprint("A,%",u8ToHex(value)), reg8ToString(cpu,.a));

	// save carry state before updating
	addCarry := HasFlag(cpu, .Carry);

	carrySet := UpdateCarryFlag(cpu, current, result, true);
	halfCarrySet := UpdateHalfCarryFlag(cpu, current, result, true);

	if addCarry {
		// update "current" to properly detect carry when adding 1
		current = result;
		result += 1;
		// only update carry if it wasn't set by the previous sum
		if !carrySet
			UpdateCarryFlag(cpu, current, result, true);
		if !halfCarrySet
			UpdateHalfCarryFlag(cpu, current, result, true);
	}

	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
}

SBCA :: (using cpu: *CPU, value: u8) {
    current := ReadAcc(cpu);
	result := current - value;

    if doLogs logger(tprint("A,%",u8ToHex(value)), reg8ToString(cpu,.a));

	// save carry state before updating
	subCarry := HasFlag(cpu, .Carry);

	carrySet := UpdateCarryFlag(cpu, current, result, false);
	halfCarrySet := UpdateHalfCarryFlag(cpu, current, result, false);

	if subCarry {
		// update "current" to properly detect carry when substracting 1
		current = result;
		result -= 1;
		// only update carry if it wasn't set by the previous sub
		if !carrySet
			UpdateCarryFlag(cpu, current, result, false);
		if !halfCarrySet
			UpdateHalfCarryFlag(cpu, current, result, false);
	}

	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
}
// internal

// instructions
ADCAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    ADCA(cpu, Read8BitReg(cpu, reg));
}

ADCAHL :: (using cpu: *CPU) {
	ADCA(cpu, ReadMemory(cpu, ReadHL(cpu)));
}

ADCAn8 :: (using cpu: *CPU) {
	ADCA(cpu, ReadAtPC(cpu));
}

ADDAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
	current := ReadAcc(cpu);
	result := current + Read8BitReg(cpu, reg);

    if doLogs logger(tprint("A,%", r8Names[reg]), tprint("% = %",reg8ToString(cpu,.a),reg8ToString(cpu,reg)));

	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	UpdateHalfCarryFlag(cpu, current, result, true);
	UpdateCarryFlag(cpu, current, result, true);
}

ADDAHL :: (using cpu: *CPU) {
	mem := ReadMemory(cpu, ReadHL(cpu));
	current := ReadAcc(cpu);

    if doLogs logger("A,[HL]", tprint("% _ % _ [HL] = %",reg8ToString(cpu,.a),reg16ToString(cpu,.hl),u8ToHex(mem)));

	result := current + mem;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	UpdateHalfCarryFlag(cpu, current, result, true);
	UpdateCarryFlag(cpu, current, result, true);
}

ADDAn8 :: (using cpu: *CPU) {
	constant := ReadAtPC(cpu);
	current := ReadAcc(cpu);

    if doLogs logger(tprint("A,$%",u8ToHex(constant)), reg8ToString(cpu,.a));

	result := current + constant;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	UpdateHalfCarryFlag(cpu, current, result, true);
	UpdateCarryFlag(cpu, current, result, true);
}

ANDAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
	result := ReadAcc(cpu) & Read8BitReg(cpu, reg);
    if doLogs logger(tprint("A,%",r8Names[reg]), tprint("% _ %",reg8ToString(cpu,.a),reg8ToString(cpu,reg)));
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, true);
	SetFlag(cpu, .Carry, false);
}

ANDAHL :: (using cpu: *CPU) {
	mem := ReadMemory(cpu, ReadHL(cpu));
    if doLogs logger("A,[HL]", tprint("% _ % _ [HL] = %",reg8ToString(cpu,.a),reg16ToString(cpu,.hl),u8ToHex(mem)));

	result := ReadAcc(cpu) & mem;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, true);
	SetFlag(cpu, .Carry, false);
}

ANDAn8 :: (using cpu: *CPU) {
	constant := ReadAtPC(cpu);

    if doLogs logger(tprint("A,%",u8ToHex(constant)), reg8ToString(cpu,.a));

	result := ReadAcc(cpu) & constant;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, true);
	SetFlag(cpu, .Carry, false);
}

ADDHLr16 :: (using cpu: *CPU, reg: CPU16BitReg) {
	rCurrent := ReadHL(cpu);
    if doLogs logger(tprint("HL,%",r16Names[reg]), tprint("% _ %",reg16ToString(cpu,.hl),reg16ToString(cpu,reg)));

	result := rCurrent + Read16BitReg(cpu, reg);
	WriteHL(cpu, result);
	lastOpCycles += 1;

	SetFlag(cpu, .Negative, false);
	UpdateHalfCarryFlag(cpu, rCurrent, result, true);
	UpdateCarryFlag(cpu, rCurrent, result, true);
}

ADDHLSP :: (using cpu: *CPU) {
	current := ReadHL(cpu);
    if doLogs logger("HL,SP",tprint("% _ SP = %",reg16ToString(cpu,.hl),u16ToHex(sp)));

	result := current + sp;
	WriteHL(cpu, result);
	lastOpCycles += 1;

	SetFlag(cpu, .Negative, false);
	UpdateHalfCarryFlag(cpu, current, result, true);
	UpdateCarryFlag(cpu, current, result, true);
}

ADDSPe8 :: (using cpu: *CPU) {
	offset := cast,no_check(s8)ReadAtPC(cpu);
	current := sp;

    if doLogs logger(tprint("SP,%",offset),tprint("SP = %",u16ToHex(sp)));

    temp := cast(s16)offset;

	result := sp + (cast,no_check(u16)temp);
	sp = result;
	lastOpCycles += 2;
	
	SetFlag(cpu, .Zero, false);
	SetFlag(cpu, .Negative, false);
	// Carry and HalfCarry from lsb to pass blargg tests https://github.com/Drenn1/GameYob/issues/15
	UpdateHalfCarryFlag(cpu, cast(u8)(current & 0xFF), cast(u8)(result & 0xFF), true);
	UpdateCarryFlag(cpu, cast(u8)(current & 0xFF), cast(u8)(result & 0xFF), true);
}

BITu3r8 :: (using cpu: *CPU, bit: u8, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));

	result := Read8BitReg(cpu, reg) & (1 << bit);

	UpdateZeroFlag(cpu, xx result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, true);
}

BITu3HL :: (using cpu: *CPU, bit: u8) {
	mem := ReadMemory(cpu, ReadHL(cpu));

    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(mem)));

	result := mem & (1 << bit);

	UpdateZeroFlag(cpu, xx result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, true);
}

CALLn16 :: (using cpu: *CPU) {
	address := Read16AtPC(cpu);
	Push16(cpu, pc);
	pc = address;
	lastOpCycles += 1;
	//no flags affected
    if doLogs logger(tprint("%",u16ToHex(address)),"");
}

CALLccn16 :: (using cpu: *CPU, condition: bool) {
	address := Read16AtPC(cpu);
	if doLogs logger(tprint("%",u16ToHex(address)), reg8ToString(cpu,.f));
	if condition {
		Push16(cpu, pc);
		pc = address;
		lastOpCycles += 1;
	}
	//no flags affected
}

CCF :: (using cpu: *CPU) {
	SetFlag(cpu, .Carry, !HasFlag(cpu, .Carry));

	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);

    if doLogs logger("","");
}

CPAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
	current := ReadAcc(cpu);
	result := current - Read8BitReg(cpu, reg);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
	UpdateHalfCarryFlag(cpu, current, result, false);
	UpdateCarryFlag(cpu, current, result, false);

    if doLogs logger(tprint("A,%",r8Names[reg]),tprint("% _ %",reg8ToString(cpu,.a),reg8ToString(cpu,reg)));
}

CPAHL :: (using cpu: *CPU) {
	mem := ReadMemory(cpu, ReadHL(cpu));
	current := ReadAcc(cpu);
	result := current - mem;

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
	UpdateHalfCarryFlag(cpu, current, result, false);
	UpdateCarryFlag(cpu, current, result, false);

    if doLogs logger("A,[HL]",tprint("% _ % _ [HL] = %",reg8ToString(cpu,.a),reg16ToString(cpu,.hl),u8ToHex(mem)));
}

CPAn8 :: (using cpu: *CPU) {
	/*if (pc == 0x0ca9)
		int a = 0;*/
	constant := ReadAtPC(cpu);
	current := ReadAcc(cpu);
	result := current - constant;

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
	UpdateHalfCarryFlag(cpu, current, result, false);
	UpdateCarryFlag(cpu, current, result, false);

    if doLogs logger(tprint("A,%",u8ToHex(constant)), reg8ToString(cpu,.a));
}

CPL :: (using cpu: *CPU) {
	WriteAcc(cpu, ~ReadAcc(cpu));

	SetFlag(cpu, .Negative, true);
	SetFlag(cpu, .HalfCarry, true);

    if doLogs logger("","");
}

DAA :: (using cpu: *CPU) {
	// https://ehaskins.com/2018-01-30%20Z80%20DAA/
	// https://www.reddit.com/r/EmuDev/comments/cdtuyw/gameboy_emulator_fails_blargg_daa_test/
	old := ReadAcc(cpu);
	result := old;

	if HasFlag(cpu, .Negative) {
		if HasFlag(cpu, .HalfCarry)
			result -= 0x06;
		if HasFlag(cpu, .Carry) {
			result -= 0x60;
			SetFlag(cpu, .Carry, true);
		}
	} else {
		if (old & 0x0F) > 0x09 || HasFlag(cpu, .HalfCarry)
			result += 0x06;

		if old > 0x99 || HasFlag(cpu, .Carry) {
			result += 0x60;
			SetFlag(cpu, .Carry, true);
		}
	}

    WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .HalfCarry, false);

    if doLogs logger("", "");
}

DECr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger(r8Names[reg], reg8ToString(cpu,reg));
	current := Read8BitReg(cpu, reg);
    result := current - 1;
	Write8BitReg(cpu, reg, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
	UpdateHalfCarryFlag(cpu, current, result, false);
}

DECHL :: (using cpu: *CPU) {
    if doLogs {
        value := ReadHL(cpu);
        logger("[HL]",tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u16ToHex(value)));
    }
	current := ReadMemory(cpu, ReadHL(cpu));
	result := current - 1;
	WriteMemory(cpu, ReadHL(cpu), result);
	
	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
	UpdateHalfCarryFlag(cpu, current, result, false);
}

DECr16 :: (using cpu: *CPU, reg: CPU16BitReg) {
    if doLogs logger(r16Names[reg], reg16ToString(cpu,reg));
	current := Read16BitReg(cpu, reg);
	result := current - 1;
	Write16BitReg(cpu, reg, result);
	lastOpCycles += 1;
	//no flags affected
}

DECSP :: (using cpu: *CPU) {
    if doLogs logger("SP", tprint("SP = %",u16ToHex(sp)));
	sp -= 1;
	lastOpCycles += 1;
	//no flags affected
}

DI :: (using cpu: *CPU) {
	intService.IME = false;
	//no flags affected
    if doLogs logger("", "");
}

EI :: (using cpu: *CPU) {
	intService.eiDelay = true;
	//no flags affected
    if doLogs logger("", "");
}

HALT :: (using cpu: *CPU) {
	isHalted = true;
	if !intService.IME && (intService.IE & intService.IF)
		haltBug = true;
	//no flags affected
    if doLogs logger("", "");
}

INCr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger(r8Names[reg], reg8ToString(cpu,reg));

	current := Read8BitReg(cpu, reg);
	result := current + 1;
	Write8BitReg(cpu, reg, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	UpdateHalfCarryFlag(cpu, current, result, true);
}

INCHL :: (using cpu: *CPU) {
    if doLogs {
        value := ReadHL(cpu);
        logger("[HL]", tprint("% [HL] = %",reg16ToString(cpu,.hl),u16ToHex(value)));
    }
	current := ReadMemory(cpu, ReadHL(cpu));
	result := current + 1;
	WriteMemory(cpu, ReadHL(cpu), result);
	
	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	UpdateHalfCarryFlag(cpu, current, result, true);
}

INCr16 :: (using cpu: *CPU, reg: CPU16BitReg) {
    if doLogs logger(r16Names[reg], reg16ToString(cpu,reg));
	current := Read16BitReg(cpu, reg);
	result := current + 1;
	Write16BitReg(cpu, reg, result);
	lastOpCycles += 1;
	//no flags affected
}

INCSP :: (using cpu: *CPU) {
	sp += 1;
	lastOpCycles += 1;
	//no flags affected
    if doLogs logger("SP", tprint("SP = %",u16ToHex(sp)));
}

JPn16 :: (using cpu: *CPU) {
	address := Read16AtPC(cpu);
	pc = address;
	lastOpCycles += 1;
	//no flags affected
    if doLogs logger(u16ToHex(address), "");
}

JPccn16 :: (using cpu: *CPU, condition: bool) {
	address := Read16AtPC(cpu);
	if doLogs logger(u16ToHex(address), reg8ToString(cpu,.f));
	if condition {
		pc = address;
		lastOpCycles += 1;
	}
	//no flags affected
}

JPHL :: (using cpu: *CPU) {
	pc = ReadHL(cpu);
	//no flags affected
    if doLogs logger("HL", reg16ToString(cpu,.hl));
}

JRe8 :: (using cpu: *CPU) {
    offset := cast,no_check(s8)ReadAtPC(cpu);
    temp := cast(s16)offset;
	pc += cast,no_check(u16)temp;
	lastOpCycles += 1;
	//no flags affected
    if doLogs logger(tprint("%",offset), "");
}

JRcce8 :: (using cpu: *CPU, condition: bool) {
    offset := cast,no_check(s8)ReadAtPC(cpu);
    if doLogs logger(tprint("%",offset), reg8ToString(cpu,.f));
	if condition {
        temp := cast(s16)offset;
		pc += cast,no_check(u16)temp;
		lastOpCycles += 1;
	}
	//no flags affected
}

LDr8r8 :: (using cpu: *CPU, leftReg: CPU8BitReg, rightReg: CPU8BitReg) {
    if doLogs logger(tprint("%,%",r8Names[leftReg],r8Names[rightReg]), reg8ToString(cpu,rightReg));

	Write8BitReg(cpu, leftReg, Read8BitReg(cpu, rightReg));
	//no flags affected
}

LDr8n8 :: (using cpu: *CPU, reg: CPU8BitReg) {
	constant := ReadAtPC(cpu);
    if doLogs logger(tprint("%,%",r8Names[reg],u8ToHex(constant)), "");

	Write8BitReg(cpu, reg, constant);
	//no flags affected
}

LDr16n16 :: (using cpu: *CPU, reg: CPU16BitReg) {
	constant := Read16AtPC(cpu);
    if doLogs logger(tprint("%,%",r16Names[reg],u16ToHex(constant)), "");

	Write16BitReg(cpu, reg, constant);
	//no flags affected
}

LDHLr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger(tprint("[HL],%",r8Names[reg]),tprint("% _ %",reg16ToString(cpu,.hl),reg8ToString(cpu,reg)));

	WriteMemory(cpu, ReadHL(cpu),Read8BitReg(cpu, reg));
	//no flags affected
}

LDHLn8 :: (using cpu: *CPU) {
	constant := ReadAtPC(cpu);
    if doLogs logger(tprint("[HL],%",u8ToHex(constant)), reg16ToString(cpu,.hl));

	WriteMemory(cpu, ReadHL(cpu),constant);
	//no flags affected
}

LDr8HL :: (using cpu: *CPU, reg : CPU8BitReg) {
	mem := ReadMemory(cpu, ReadHL(cpu));
    if doLogs logger(tprint("%,[HL]",r8Names[reg]),tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(mem)));

	Write8BitReg(cpu, reg, mem);
	//no flags affected
}

LDr16A :: (using cpu: *CPU, reg: CPU16BitReg) {
    if doLogs logger(tprint("[%],A",r16Names[reg]),tprint("% _ %",reg16ToString(cpu,reg),reg8ToString(cpu,.a)));

	WriteMemory(cpu, Read16BitReg(cpu, reg), ReadAcc(cpu));
	//no flags affected
}

LDn16A :: (using cpu: *CPU) {
	address := Read16AtPC(cpu);
    if doLogs logger(tprint("%,A",u16ToHex(address)), reg8ToString(cpu,.a));

	WriteMemory(cpu, address, ReadAcc(cpu));
	//no flags affected
}

LDHn8A :: (using cpu: *CPU) {
	addressOffset := ReadAtPC(cpu);
    if doLogs logger(tprint("0xFF%,A",u8ToHex(addressOffset)), reg8ToString(cpu,.a));

	WriteMemory(cpu, xx (0xFF00 + addressOffset), ReadAcc(cpu));
	//no flags affected
}

LDHCA :: (using cpu: *CPU) {
    if doLogs logger("0xFF00 + C,A",tprint("% _ %",reg8ToString(cpu,.c),reg8ToString(cpu,.a)));

	WriteMemory(cpu, xx (0xFF00 + Read8BitReg(cpu, .c)), ReadAcc(cpu));
	//no flags affected
}

LDAr16 :: (using cpu: *CPU, reg: CPU16BitReg) {
	mem := ReadMemory(cpu, Read16BitReg(cpu, reg));
    if doLogs logger(tprint("A,[%]",r16Names[reg]),tprint("% _ [r] = %",reg16ToString(cpu,reg),u8ToHex(mem)));

	WriteAcc(cpu, mem);
	//no flags affected
}

LDAn16 :: (using cpu: *CPU) {
	address := Read16AtPC(cpu);
	mem := ReadMemory(cpu, address);
    if doLogs logger(tprint("A,[%]",u16ToHex(address)),tprint("[r] = %",u8ToHex(mem)));

	WriteAcc(cpu, mem);
	//no flags affected
}

LDHAn8 :: (using cpu: *CPU) {
	addressOffset := ReadAtPC(cpu);
	mem := ReadMemory(cpu, xx (0xFF00 + addressOffset));
    if doLogs logger(tprint("A,[0xFF%]",u8ToHex(addressOffset)),tprint("[r] = %",u8ToHex(mem)));
	WriteAcc(cpu, mem);
	//no flags affected
}

LDHAC :: (using cpu: *CPU) {
	mem := ReadMemory(cpu, xx (0xFF00 + Read8BitReg(cpu, .c)));
    if doLogs logger("A,[0xFF00 + C]",tprint("% _ [r] = %",reg8ToString(cpu,.c),u8ToHex(mem)));
	WriteAcc(cpu, mem);
	//no flags affected
}

LDHLincA :: (using cpu: *CPU) {
    if doLogs logger("[HL++],A",tprint("% _ %",reg16ToString(cpu,.hl),reg8ToString(cpu,.a)));
	address := ReadHL(cpu);
	WriteMemory(cpu, address,ReadAcc(cpu));
	WriteHL(cpu, address + 1);
	//no flags affected
}

LDHLdecA :: (using cpu: *CPU) {
    if doLogs logger("[HL--],A", tprint("% _ %",reg16ToString(cpu,.hl),reg8ToString(cpu,.a)));
	address := ReadHL(cpu);
	WriteMemory(cpu, address, ReadAcc(cpu));
	WriteHL(cpu, address - 1);
	//no flags affected
}

LDAHLinc :: (using cpu: *CPU) {
	address := ReadHL(cpu);
    if doLogs {
        value := ReadMemory(cpu,address);
        logger("A,[HL++]",tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));
    }
	WriteAcc(cpu, ReadMemory(cpu, address));
	WriteHL(cpu, address + 1);
	//no flags affected
}

LDAHLdec :: (using cpu: *CPU) {
	address := ReadHL(cpu);
    if doLogs {
        value := ReadMemory(cpu,address);
        logger("A,[HL--]", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));
    }
	WriteAcc(cpu, ReadMemory(cpu, address));
	WriteHL(cpu, address - 1);
	//no flags affected
}

LDSPn16 :: (using cpu: *CPU) {
	sp = Read16AtPC(cpu);
	//no flags affected
    if doLogs logger(tprint("SP,%",u16ToHex(sp)), "");
}

LDn16SP :: (using cpu: *CPU) {
	lsb : u8 = xx (sp & 0xFF);
	msb : u8 = xx (sp >> 8);

	address := Read16AtPC(cpu);
    if doLogs logger(tprint("[%],SP",u16ToHex(address)),tprint("SP = %",u16ToHex(sp)));

	WriteMemory(cpu, address, lsb);
	WriteMemory(cpu, address + 1, msb);
	//no flags affected
}

LDHLSPe8 :: (using cpu: *CPU) {
    offset := cast,no_check(s8)ReadAtPC(cpu);
    if doLogs logger(tprint("HL,SP+(%)",offset), tprint("SP = %",u16ToHex(sp)));

	current := sp;
    temp := cast(s16)offset;
	result := current + cast,no_check(u16)offset;
	WriteHL(cpu, result);
	lastOpCycles += 1;

	SetFlag(cpu, .Zero, false);
	SetFlag(cpu, .Negative, false);
	// Carry and HalfCarry from lsb to pass blargg tests https://github.com/Drenn1/GameYob/issues/15
	UpdateHalfCarryFlag(cpu, cast(u8)(current & 0xFF), cast(u8)(result & 0xFF), true);
	UpdateCarryFlag(cpu, cast(u8)(current & 0xFF), cast(u8)(result & 0xFF), true);
}

LDSPHL :: (using cpu: *CPU) {
	sp = ReadHL(cpu);
	lastOpCycles += 1;
	//no flags affected
    if doLogs logger("SP,HL", reg16ToString(cpu,.hl));
}

NOP :: (using cpu: *CPU) {
    if doLogs logger("", "");
}

ORAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
	result := ReadAcc(cpu) | Read8BitReg(cpu, reg);
    if doLogs logger(tprint("A,%",r8Names[reg]), reg8ToString(cpu,reg));

	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, false);
}

ORAHL :: (using cpu: *CPU) {
	mem := ReadMemory(cpu, ReadHL(cpu));
    if doLogs logger("A,[HL]",tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(mem)));

	result := ReadAcc(cpu) | mem;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, false);
}

ORAn8 :: (using cpu: *CPU) {
	constant := ReadAtPC(cpu);
    if doLogs logger(tprint("A,%",u8ToHex(constant)), "");

	result := ReadAcc(cpu) | constant;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, false);
}

POPr16 :: (using cpu: *CPU, reg: CPU16BitReg) {
	Write16BitReg(cpu, reg, Pop16(cpu));
	//no flags affected (except if reg is AF)
    if doLogs logger(r16Names[reg],tprint("(after) % _ SP = %",reg16ToString(cpu,reg),u16ToHex(sp)));
}

PUSHr16 :: (using cpu: *CPU, reg: CPU16BitReg) {
	Push16(cpu, Read16BitReg(cpu, reg));
	lastOpCycles += 1;
	//no flags affected
    if doLogs logger(r16Names[reg],tprint("(after) % _ SP = %",reg16ToString(cpu,reg),u16ToHex(sp)));
}

RESu3r8 :: (using cpu: *CPU, bit: u8, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));
	value := Read8BitReg(cpu, reg) & ~(1 << bit);
	Write8BitReg(cpu, reg, xx value);
	//no flags affected
}

RESu3HL :: (using cpu: *CPU, bit: u8) {
	address := ReadHL(cpu);
	mem := ReadMemory(cpu, address);
	value := mem & ~(1 << bit);
	WriteMemory(cpu, address, xx value);
	//no flags affected
    if doLogs logger("",tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(mem)));
}

RETcc :: (using cpu: *CPU, condition: bool) {
	if doLogs logger("", reg8ToString(cpu,.f));
	lastOpCycles += 1;
	if condition {
		pc = Pop16(cpu);
		lastOpCycles += 1;
	}
	//no flags affected
}

RET :: (using cpu: *CPU) {
	pc = Pop16(cpu);
	lastOpCycles += 1;
	//no flags affected
    if doLogs logger("", "");
}

RETI :: (using cpu: *CPU) {
	RET(cpu);

	//TODO check if this has same bug of EI
	intService.IME = true;

	//no flags affected
    if doLogs logger("", "");
}

RLr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));
	value := Read8BitReg(cpu, reg);
	newCarry := value >> 7;
	value = value << 1;
	value |= cast(u8)HasFlag(cpu, .Carry);
	Write8BitReg(cpu, reg, value);
	
	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RLHL :: (using cpu: *CPU) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));
	newCarry := value >> 7;
	value = value << 1;
	value |= cast(u8)HasFlag(cpu, .Carry);
	WriteMemory(cpu, address,value);
	
	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RLA :: (using cpu: *CPU) {
    if doLogs logger("", reg8ToString(cpu,.a));
	value := ReadAcc(cpu);
	newCarry := value >> 7;
	value = value << 1;
	value |= cast(u8)HasFlag(cpu, .Carry);
	WriteAcc(cpu, value);

	SetFlag(cpu, .Zero, false);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RLCr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));

	value := Read8BitReg(cpu, reg);
	newCarry := value >> 7;
	value = value << 1;
	value =  value | newCarry;
	Write8BitReg(cpu, reg, value);
	
	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RLCHL :: (using cpu: *CPU) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));

	newCarry := value >> 7;
	value = value << 1;
	value |= newCarry;
	WriteMemory(cpu, address, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RLCA :: (using cpu: *CPU) {
    if doLogs logger("", reg8ToString(cpu,.a));
	value := ReadAcc(cpu);
	newCarry := value >> 7;
	value = value << 1;
	value |= newCarry;
	WriteAcc(cpu, value);

	SetFlag(cpu, .Zero, false);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RRr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));
	value := Read8BitReg(cpu, reg);
	newCarry := value & 0x01;
	value = value >> 1;
	value |= (cast(u8)HasFlag(cpu, .Carry)) << 7;
	Write8BitReg(cpu, reg, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RRHL :: (using cpu: *CPU) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));
	newCarry := value & 0x01;
	value = value >> 1;
	value |= (cast(u8)HasFlag(cpu, .Carry)) << 7;
	WriteMemory(cpu, address, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RRA :: (using cpu: *CPU) {
    if doLogs logger("", reg8ToString(cpu,.a));
	value := ReadAcc(cpu);
	newCarry := value & 0x01;
	value = value >> 1;
	value |= (cast(u8)HasFlag(cpu, .Carry)) << 7;
	WriteAcc(cpu, value);

	SetFlag(cpu, .Zero, false);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RRCr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));
	value := Read8BitReg(cpu, reg);
	newCarry := value & 0x01;
	value = value >> 1;
	value |= (newCarry << 7);
	Write8BitReg(cpu, reg, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RRCHL :: (using cpu: *CPU) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));
	newCarry := value & 0x01;
	value = value >> 1;
	value |= (newCarry << 7);
	WriteMemory(cpu, address, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RRCA :: (using cpu: *CPU) {
    if doLogs logger("", reg8ToString(cpu,.a));
	value := ReadAcc(cpu);
	newCarry := value & 0x01;
	value = value >> 1;
	value |= (newCarry << 7);
	WriteAcc(cpu, value);

	SetFlag(cpu, .Zero, false);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

RSTvec :: (using cpu: *CPU, vec: u8) {
	Push16(cpu, pc);
	pc = vec;
	lastOpCycles += 1;
	//no flags affected
    if doLogs logger(u8ToHex(vec), "");
}

SBCAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
	SBCA(cpu, Read8BitReg(cpu, reg));
}

SBCAHL :: (using cpu: *CPU) {
	SBCA(cpu, ReadMemory(cpu, ReadHL(cpu)));
}

SBCAn8 :: (using cpu: *CPU) {
	SBCA(cpu, ReadAtPC(cpu));
}

SCF :: (using cpu: *CPU) {
	SetFlag(cpu, .Carry, true);

	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Negative, false);
    if doLogs logger("", "");
}

SETu3r8 :: (using cpu: *CPU, bit: u8, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));
	value := Read8BitReg(cpu, reg) | (1 << bit);
	Write8BitReg(cpu, reg, xx value);
	//no flags affected
}

SETu3HL :: (using cpu: *CPU, bit: u8) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));
	value |= cast(u8)(1 << bit);
	WriteMemory(cpu, address, xx value);
	//no flags affected
}

SLAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));
	value := Read8BitReg(cpu, reg);
	newCarry := value >> 7;
	value = value << 1;
	Write8BitReg(cpu, reg, value);
	
	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

SLAHL :: (using cpu: *CPU) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));

	newCarry := value >> 7;
	value = value << 1;
	WriteMemory(cpu, address, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

SRAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));

	value := Read8BitReg(cpu, reg);
	newSeven := value & 0x80;
	newCarry := value & 0x01;
	value = value >> 1;
	value |= newSeven;
	Write8BitReg(cpu, reg, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

SRAHL :: (using cpu: *CPU) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));

	newSeven := value & 0x80;
	newCarry := value & 0x01;
	value = value >> 1;
	value |= newSeven;
	WriteMemory(cpu, address, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

SRLr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));
	value := Read8BitReg(cpu, reg);
	newCarry := value & 0x01;
	value = value >> 1;
	Write8BitReg(cpu, reg, value);
	
	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

SRLHL :: (using cpu: *CPU) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));

	newCarry := value & 0x01;
	value = value >> 1;
	WriteMemory(cpu, address, value);

	UpdateZeroFlag(cpu, value);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, newCarry == 1);
}

STOP :: (using cpu: *CPU) {
    //2 bytes? 0 cycles?
    if (key1 & 0x01) == 1 {
        key1 &= 0xFE; // reset bit 0
        if IsDoubleSpeedEnabled(cpu) {
            key1 &= 0x7F;
            print("Double Speed disabled\n");
        } else {
            key1 |= 0x80;
            print("Double Speed enabled\n");
        }
    } else
        isHalted = true;
	// TODO turn off LCD
	//no flags affected
    if doLogs logger("", "");
}

SUBAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger(tprint("A,%",r8Names[reg]),tprint("% _ %",reg8ToString(cpu,.a),reg8ToString(cpu,reg)));
	current := ReadAcc(cpu);
	result := current - Read8BitReg(cpu, reg);
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
	UpdateHalfCarryFlag(cpu, current, result, false);
	UpdateCarryFlag(cpu, current, result, false);
}

SUBAHL :: (using cpu: *CPU) {
	mem := ReadMemory(cpu, ReadHL(cpu));
    if doLogs logger("A,[HL]", tprint("% _ % _ [HL] = %",reg8ToString(cpu,.a),reg16ToString(cpu,.hl),u8ToHex(mem)));
	current := ReadAcc(cpu);
	result := current - mem;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
	UpdateHalfCarryFlag(cpu, current, result, false);
	UpdateCarryFlag(cpu, current, result, false);
}

SUBAn8 :: (using cpu: *CPU) {
	constant := ReadAtPC(cpu);
	current := ReadAcc(cpu);
    if doLogs logger(tprint("A,%",u8ToHex(constant)), reg8ToString(cpu,.a));

	result := current - constant;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, true);
	UpdateHalfCarryFlag(cpu, current, result, false);
	UpdateCarryFlag(cpu, current, result, false);
}

SWAPr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger("", reg8ToString(cpu,reg));
	value := Read8BitReg(cpu, reg);
	result := (value >> 4) + (value << 4);
	Write8BitReg(cpu, reg, result);
	
	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, false);
}

SWAPHL :: (using cpu: *CPU) {
	address := ReadHL(cpu);
	value := ReadMemory(cpu, address);
    if doLogs logger("", tprint("% _ [HL] = %",reg16ToString(cpu,.hl),u8ToHex(value)));

	result := (value >> 4) + (value << 4);
	WriteMemory(cpu, address, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, false);
}

XORAr8 :: (using cpu: *CPU, reg: CPU8BitReg) {
    if doLogs logger(tprint("A,%",r8Names[reg]), tprint("% _ %",reg8ToString(cpu,.a),reg8ToString(cpu,reg)));
	result := ReadAcc(cpu) ^ Read8BitReg(cpu, reg);
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, false);
}

XORAHL :: (using cpu: *CPU) {
	value := ReadMemory(cpu, ReadHL(cpu));
    if doLogs logger("A,[HL]", tprint("% _ % _ [HL] = %",reg8ToString(cpu,.a),reg16ToString(cpu,.hl),u8ToHex(value)));

	result := ReadAcc(cpu) ^ value;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, false);
}

XORAn8 :: (using cpu: *CPU) {
	constant := ReadAtPC(cpu);
    if doLogs logger(tprint("A,%",u8ToHex(constant)), reg8ToString(cpu,.a));

	result := ReadAcc(cpu) ^ constant;
	WriteAcc(cpu, result);

	UpdateZeroFlag(cpu, result);
	SetFlag(cpu, .Negative, false);
	SetFlag(cpu, .HalfCarry, false);
	SetFlag(cpu, .Carry, false);
}
// instructions
