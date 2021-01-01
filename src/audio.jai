#import "Math";

deltaTimePerEmulatedCycle : float : 1 / (1.0485 * 1000000);
sampleTime : float : 1 / 44100.0;

Audio :: struct {
    sample : s16;

	elapsedTime : float;

    channel1 : struct {
        Enabled : bool;

        FrequencySweepTime : u8;            // NR10 - Bit 6-4 - Sweep Time
        FrequencyIncrease : bool = true;    // NR10 - Sweep Increase/Decrease - 0: Addition(frequency increases) - 1 : Subtraction(frequency decreases)
        FrequencySweepShifts : u8;          // NR10 - Bit 2-0 - Number of sweep shift (n: 0-7)
        FrequencySweepPeriod : float;
        FrequencySweepEnabled : bool;

        DutyCycle : float;                  // NR11 - Bit 7-6 - Wave Pattern Duty (Read/Write)
        Length : float;                     // NR11 - Bit 5-0 - Sound length data (Write Only)

        Volume : u8;                        // NR12 - Bit 7-4 - Initial Volume of envelope (0-0Fh) (0=No Sound)
        VolumeDecrease : bool;              // NR12 - Bit 3   - Envelope Direction (0=Decrease, 1=Increase)
        EnvelopeSweepCount : u8;            // NR12 - Bit 2-0 - Number of envelope sweep (n: 0-7) (If zero, stop envelope operation.)
        EnvelopeSweepStep : float;

        FrequencyX : u16;                   // NR13 - Lower 8 bits of 11 bit frequency (x). Next 3 bits are in NR14
        FrequencyXShadow : u16;
        Frequency : float;                  // Hz
        Period : float;

        Initial : bool;                     // NR14 - Bit 7 - Initial(1 = Restart Sound)     (Write Only)
        UseLength : bool;                   // NR14 - Bit 6 - Counter / consecutive selection (Read / Write) (1 = Stop output when length in NR11 expires)

        ElapsedTime : float;
        FrequencySweepElapsedTime : float;
        EnvelopeSweepElapsedTime : float;
    };

    channel2 : struct {
        Enabled : bool;

        DutyCycle : float;          // NR21 - Bit 7-6 - Wave Pattern Duty (Read/Write)
        Length : float;             // NR21 - Bit 5-0 - Sound length data (Write Only)

        Volume : u8;                // NR22 - Bit 7-4 - Initial Volume of envelope (0-0Fh) (0=No Sound)
        VolumeDecrease : bool;      // NR22 - Bit 3   - Envelope Direction (0=Decrease, 1=Increase)
        EnvelopeSweepCount : u8;    // NR22 - Bit 2-0 - Number of envelope sweep (n: 0-7) (If zero, stop envelope operation.)
        EnvelopeSweepStep : float;

        FrequencyX : u16;           // NR23 - Lower 8 bits of 11 bit frequency (x). Next 3 bits are in NR24
        Frequency : float;          // Hz
        Period : float;

        Initial : bool;             // NR24 - Bit 7 - Initial(1 = Restart Sound)     (Write Only)
        UseLength : bool;           // NR24 - Bit 6 - Counter / consecutive selection (Read / Write) (1 = Stop output when length in NR21 expires)

        ElapsedTime : float;
        EnvelopeSweepElapsedTime : float;
    };

    channel3 : struct {
        Enabled : bool;     // NR30 - Bit 7 - Sound Channel 3 Off  (0=Stop, 1=Playback)  (Read/Write)

        Length : float;     // NR31 - Bit 7-0 - Sound length (t1: 0 - 255)

        Volume : u8;        // NR32 - Bit 6-5 - Select output level (Read/Write)

        FrequencyX : u16;   // NR33 - Lower 8 bits of an 11 bit frequency (x). Next 3 bits are in NR34
        Frequency : float;  // Hz
        Period : float;

        Initial : bool;     // NR34 - Bit 7 - Initial(1 = Restart Sound)     (Write Only)
        UseLength : bool;   // NR44 - Bit 6 - Counter / consecutive selection (Read / Write) (1 = Stop output when length in NR31 expires)

        ElapsedTime : float;
    };

    channel4 : struct {
        Enabled : bool;

        Length : float;             // NR41 - Bit 5-0 - Sound length data (t1: 0-63)

        Volume : u8;                // NR42 - Bit 7-4 - Initial Volume of envelope (0-0Fh) (0=No Sound)
        VolumeDecrease : bool;      // NR42 - Bit 3   - Envelope Direction (0=Decrease, 1=Increase)
        EnvelopeSweepCount : u8;    // NR42 - Bit 2-0 - Number of envelope sweep (n: 0-7) (If zero, stop envelope operation.)
        EnvelopeSweepStep : float;

        ShiftClockFrequency : u8;   // NR43 - Bit 7-4 - Shift Clock Frequency (s)
        CounterWidth15 : bool;      // NR43 - Bit 3   - Counter Step/Width (0=15 bits, 1=7 bits)
        DividingRatio : u8;         // NR43 - Bit 2-0 - Dividing Ratio of Frequencies (r)
        Frequency : float;
        Period : float;

        Initial : bool;             // NR44 - Bit 7 - Initial(1 = Restart Sound)     (Write Only)
        UseLength : bool;           // NR44 - Bit 6 - Counter / consecutive selection (Read / Write) (1 = Stop output when length in NR21 expires)

        ElapsedTime : float;
        EnvelopeSweepElapsedTime : float;
    };

    lfsr : u16 = 0x7FFF;
    lfsrOutput : u8;

    channel1UserOn : bool = true;
    channel2UserOn : bool = true;
    channel3UserOn : bool = true;
    channel4UserOn : bool;

	// Sound Channel 1 - Tone & Sweep
	NR10 : u8 = 0x80;	// 0xFF10 Sweep register (R/W)
	NR11 : u8;	        // 0xFF11 Sound length/Wave pattern duty (R/W)
	NR12 : u8;	        // 0xFF12 Volume Envelope (R/W)
	NR13 : u8;      	// 0xFF13 Frequency lo (Write Only)
	NR14 : u8;      	// 0xFF14 Frequency hi (R/W)

	// Sound Channel 2 - Tone
	NR21 : u8;	// 0xFF16 Sound Length/Wave Pattern Duty (R/W)
	NR22 : u8;	// 0xFF17 Volume Envelope (R/W)
	NR23 : u8;	// 0xFF18 Frequency lo data (W)
	NR24 : u8;	// 0xFF19 Frequency hi data (R/W)

	// Sound Channel 3 - Wave Output
	NR30 : u8 = 0x7F;	// 0xFF1A Sound on/off (R/W)
	NR31 : u8;			// 0xFF1B Sound Length
	NR32 : u8 = 0x9F;	// 0xFF1C Select output level (R/W)
	NR33 : u8;			// 0xFF1D Frequency's lower data (W)
	NR34 : u8;			// 0xFF1E Frequency's higher data (R/W)
	WaveRAM : [0x10]u8;	// 0xFF30-0xFF3F Wave Pattern RAM

	// Sound Channel 4 - Noise
	NR41 : u8 = 0xC0;	// 0xFF20 Sound Length (R/W)
	NR42 : u8;			// 0xFF21 Volume Envelope (R/W)
	NR43 : u8;			// 0xFF22 Polynomial Counter (R/W)
	NR44 : u8 = 0x3F;	// 0xFF23 Counter/consecutive; Inital (R/W)

	// Sound Control Registers
	NR50 : u8;			// 0xFF24 Channel control / ON-OFF / Volume (R/W)
	NR51 : u8;			// 0xFF25 Selection of Sound output terminal (R/W)
	NR52 : u8 = 0x70;	// 0xFF26 Sound on/off 
};

Step :: (using audio: *Audio, cycles: u8, isDoubleSpeedEnabled: bool) -> bool {
    delta := deltaTimePerEmulatedCycle * cycles;
    if isDoubleSpeedEnabled
        delta /= 2;
	elapsedTime += delta;
    
    UpdateChannel1(audio, delta);
    UpdateChannel2(audio, delta);
    UpdateChannel3(audio, delta);
    UpdateChannel4(audio, delta);
    
	if elapsedTime >= sampleTime {
		elapsedTime -= sampleTime;
		sample = GetSample(audio);
		return true;
	}
	return false;
}

GetSample :: (using audio: *Audio) -> s16 {
	if (NR52 & 0x80) == 0
		return 0;

	channel1Sample, channel2Sample, channel3Sample, channel4Sample : s16;
    if channel1UserOn channel1Sample = GetChannel1Sample(audio);
    if channel2UserOn channel2Sample = GetChannel2Sample(audio);
    if channel3UserOn channel3Sample = GetChannel3Sample(audio);
    if channel4UserOn channel4Sample = GetChannel4Sample(audio);

	mix := channel1Sample + channel2Sample + channel3Sample + channel4Sample;
	return mix * 500;
}

GetChannel1Sample :: (using audio: *Audio) -> s16 {
    if !channel1.Enabled
        return 0;

    if fmod(channel1.ElapsedTime, channel1.Period) / channel1.Period <= channel1.DutyCycle
	    return channel1.Volume;
    else
        return - cast(s16)channel1.Volume;
}

GetChannel2Sample :: (using audio: *Audio) -> s16 {
    if !channel2.Enabled
        return 0;

    if fmod(channel2.ElapsedTime, channel2.Period) / channel2.Period <= channel2.DutyCycle
        return channel2.Volume;
    else
        return - cast(s16)channel2.Volume;
}

GetChannel3Sample :: (using audio: *Audio) -> s16 {
    if !channel3.Enabled || channel3.Volume == 0
        return 0;

    temp := fmod(channel3.ElapsedTime, channel3.Period) / channel3.Period;
    temp *= 16;

    byteNum : float;
    // TODO reminder := modf(temp, &byteNum);

    waveByte := WaveRAM[cast(int)byteNum];
	if byteNum <= 0.5
		waveByte = waveByte >> 4;
	else
		waveByte &= 0x0F;

	if channel3.Volume > 1
		waveByte = waveByte >> (channel3.Volume - 1);

    return cast(s16)waveByte - 8;
}

GetChannel4Sample :: (using audio: *Audio) -> s16 {
    if !channel4.Enabled
        return 0;

    if lfsrOutput == 0
        return channel4.Volume;
    else
        return - cast(s16)channel4.Volume;
}

UpdateChannel1 :: (using audio: *Audio, deltaTime: float) {
    if channel1.Enabled {
        channel1.ElapsedTime += deltaTime;

        if channel1.UseLength && channel1.ElapsedTime > channel1.Length {
            channel1.Enabled = false;
            return;
        }
        
        if channel1.FrequencySweepPeriod > 0.0 && channel1.FrequencySweepShifts > 0 && channel1.FrequencySweepEnabled {
            channel1.FrequencySweepElapsedTime += deltaTime;

            if channel1.FrequencySweepElapsedTime >= channel1.FrequencySweepPeriod {
                temp := channel1.FrequencyXShadow >> channel1.FrequencySweepShifts;
                if channel1.FrequencyIncrease {
                    channel1.FrequencyXShadow += temp;
                    if channel1.FrequencyXShadow > 2047 { // overflow
                        channel1.FrequencyXShadow = 2047;
                        channel1.Enabled = false;
                        return;
                    }
                } else {
                    // TODO "Note that sweep shifts are repeatedly performed until the new value becomes either less than 0
                    //(the previous value is then retained) or, when incrementing, if the new frequency value exceeds the
                    //maximum frequency (131Khz or 2048 in register value)"
                    // http://belogic.com/gba/channel1.shtml
                    //if (temp <= channel1.FrequencyXShadow)
                    channel1.FrequencyXShadow -= temp;
                    //else
                    //    channel1.FrequencySweepEnabled = false;
                }

                channel1.Frequency = 131072.0 / (2048 - channel1.FrequencyXShadow);
                channel1.Period = 1 / channel1.Frequency;

                channel1.FrequencySweepElapsedTime -= channel1.FrequencySweepPeriod;
            }
        }

        if channel1.EnvelopeSweepStep > 0.0 {
            channel1.EnvelopeSweepElapsedTime += deltaTime;
            if channel1.EnvelopeSweepElapsedTime >= channel1.EnvelopeSweepStep {
                if channel1.VolumeDecrease && channel1.Volume > 0
                    channel1.Volume -= 1;
                else if !channel1.VolumeDecrease && channel1.Volume < 15
                    channel1.Volume += 1;

                channel1.EnvelopeSweepElapsedTime -= channel1.EnvelopeSweepStep;
            }
        }
    }
}

UpdateChannel2 :: (using audio: *Audio, deltaTime: float) {
    if channel2.Enabled {
        channel2.ElapsedTime += deltaTime;

        if channel2.UseLength && channel2.ElapsedTime > channel2.Length {
            channel2.Enabled = false;
            return;
        }

        if channel2.EnvelopeSweepStep > 0.0 {
            channel2.EnvelopeSweepElapsedTime += deltaTime;
            if channel2.EnvelopeSweepElapsedTime >= channel2.EnvelopeSweepStep {
                if channel2.VolumeDecrease && channel2.Volume > 0
                    channel2.Volume -= 1;
                else if !channel2.VolumeDecrease && channel2.Volume < 15
                    channel2.Volume += 1;

                channel2.EnvelopeSweepElapsedTime -= channel2.EnvelopeSweepStep;
            }
        }
    }
}

UpdateChannel3 :: (using audio: *Audio, deltaTime: float) {
    if channel3.Enabled {
        channel3.ElapsedTime += deltaTime;

        if channel3.UseLength && channel3.ElapsedTime > channel3.Length
            channel3.Enabled = false;
    }
}

UpdateChannel4 :: (using audio: *Audio, deltaTime: float) {
    if channel4.Enabled {
        channel4.ElapsedTime += deltaTime;

        if channel4.UseLength && channel4.ElapsedTime > channel4.Length {
            channel4.Enabled = false;
            return;
        }

        UpdateLFSR(audio,deltaTime);

        if channel4.EnvelopeSweepStep > 0.0 {
            channel4.EnvelopeSweepElapsedTime += deltaTime;
            if channel4.EnvelopeSweepElapsedTime >= channel4.EnvelopeSweepStep {
                if channel4.VolumeDecrease && channel4.Volume > 0
                    channel4.Volume -= 1;
                else if !channel4.VolumeDecrease && channel4.Volume < 15
                    channel4.Volume += 1;

                channel4.EnvelopeSweepElapsedTime -= channel4.EnvelopeSweepStep;
            }
        }
    }
}

ToggleChannel :: (using audio: *Audio, channel: u8) {
    if channel == {
    case 1; channel1UserOn = !channel1UserOn;
    case 2; channel2UserOn = !channel2UserOn;
    case 3; channel3UserOn = !channel3UserOn;
    case 4; channel4UserOn = !channel4UserOn;
    }
}

UpdateLFSR :: (using audio: *Audio, deltaTime: float) {
    while deltaTime > channel4.Period {
        firstBit : u8 = xx (lfsr & 0x0001);
        lfsr = lfsr >> 1;
        newBit := ((firstBit ^ (lfsr & 0x0001)) != 0);

        if newBit
            lfsr |= 0x4000;
        else
            lfsr &= 0xBFFF;

        if !channel4.CounterWidth15 {
            if newBit
                lfsr |= 0x0040;
            else
                lfsr &= 0xFFBF;
        }

        lfsrOutput = firstBit;
        deltaTime -= channel4.Period;
    }
}

Read :: inline (using audio: *Audio, address: u16) -> u8 {
	if address >= 0xFF30 && address <= 0xFF3F
		return WaveRAM[address - 0xFF30];

	if address == {
	case 0xFF10;
		return NR10 | 0x80;
	case 0xFF11;
		return NR11;
	case 0xFF12;
		return NR12;
	case 0xFF13;
		return NR13;
	case 0xFF14;
		return NR14;
	case 0xFF16;
		return NR21;
	case 0xFF17;
		return NR22;
	case 0xFF18;
		return NR23;
	case 0xFF19;
		return NR24;
	case 0xFF1A;
		return NR30 | 0x7F;
	case 0xFF1B;
		return NR31;
	case 0xFF1C;
		return NR32 | 0x9F;
	case 0xFF1D;
		return NR33;
	case 0xFF1E;
		return NR34;
	case 0xFF20;
		return NR41 | 0xC0;
	case 0xFF21;
		return NR42;
	case 0xFF22;
		return NR43;
	case 0xFF23;
		return NR44 | 0x3F;
	case 0xFF24;
		return NR50;
	case 0xFF25;
		return NR51;
	case 0xFF26;
		return NR52 | 0x70;
	}

	return 0xFF;
}

Write :: (using audio: *Audio, value: u8, address: u16) {
	if address >= 0xFF30 && address <= 0xFF3F {
		WaveRAM[address - 0xFF30] = value;
		return;
	}

	if address == {
	case 0xFF10;
 		NR10 = value | 0x80;
	case 0xFF11;
		NR11 = value;
	case 0xFF12;
		NR12 = value;
	case 0xFF13;
		NR13 = value;
	case 0xFF14;
		NR14 = value;
		channel1.Initial = ((NR14 & 0x80) != 0);
		if channel1.Initial
			channel1.Enabled = true;

        if channel1.Enabled {
			channel1.FrequencySweepTime = (NR10 >> 4) & 0x07;
			channel1.FrequencyIncrease = (NR10 & 0x08) == 0;
			channel1.FrequencySweepShifts = NR10 & 0x07;
			channel1.FrequencySweepPeriod = channel1.FrequencySweepTime / 128.0;
			channel1.FrequencySweepElapsedTime = 0.0;
			channel1.FrequencyXShadow = channel1.FrequencyX;
			channel1.FrequencySweepEnabled = channel1.FrequencySweepTime > 0 && channel1.FrequencySweepShifts > 0;

			if NR11 >> 6 == {
			case 0x00; channel1.DutyCycle = 0.125;
			case 0x01; channel1.DutyCycle = 0.25;
			case 0x02; channel1.DutyCycle = 0.5;
			case 0x03; channel1.DutyCycle = 0.75;
			}
			channel1.Length = (64 - (NR11 & 0x3F)) / 256.0;

			channel1.Volume = NR12 >> 4;
			channel1.VolumeDecrease = ((NR12 & 0x08) == 0);
			channel1.EnvelopeSweepCount = NR12 & 0x03;
			channel1.EnvelopeSweepStep = channel1.EnvelopeSweepCount / 64.0;

			channel1.UseLength = ((NR14 & 0x40) != 0);

			channel1.FrequencyX = ((cast(u16)NR14 & 0x07) << 8) + (NR13 & 0x00FF);
			channel1.Frequency = 131072.0 / (2048 - channel1.FrequencyX);
			channel1.Period = 1 / channel1.Frequency;

            channel1.ElapsedTime = 0.0;
            channel1.EnvelopeSweepElapsedTime = 0.0;
            channel1.FrequencySweepElapsedTime = 0.0;
        }
	case 0xFF16;
		NR21 = value;
	case 0xFF17;
		NR22 = value;
	case 0xFF18;
		NR23 = value;
	case 0xFF19;
		NR24 = value;
		channel2.Initial = ((NR24 & 0x80) != 0);
		if channel2.Initial
			channel2.Enabled = true;

        if channel2.Enabled {
			if NR21 >> 6 == {
			case 0x00; channel2.DutyCycle = 0.125;
			case 0x01; channel2.DutyCycle = 0.25;
			case 0x02; channel2.DutyCycle = 0.5;
			case 0x03; channel2.DutyCycle = 0.75;
			}
			channel2.Length = (64 - (NR21 & 0x3F)) / 256.0;

			channel2.Volume = NR22 >> 4;
			channel2.VolumeDecrease = ((NR22 & 0x08) == 0);
			channel2.EnvelopeSweepCount = NR22 & 0x03;
			channel2.EnvelopeSweepStep = channel2.EnvelopeSweepCount / 64.0;

			channel2.FrequencyX = NR23 + (channel2.FrequencyX & 0xFF00);

			channel2.UseLength = ((NR24 & 0x40) != 0);
			channel2.FrequencyX = ((cast(u16)NR24 & 0x07) << 8) + (channel2.FrequencyX & 0x00FF);
			channel2.Frequency = 131072.0 / (2048 - channel2.FrequencyX);
			channel2.Period = 1 / channel2.Frequency;

            channel2.ElapsedTime = 0.0;
            channel2.EnvelopeSweepElapsedTime = 0.0;
        }
	case 0xFF1A;
		NR30 = value | 0x7F;
	case 0xFF1B;
		NR31 = value;
	case 0xFF1C;
		NR32 = value | 0x9F;
	case 0xFF1D;
		NR33 = value;
	case 0xFF1E;
		NR34 = value;
        channel3.Initial = ((NR34 & 0x80) != 0);
        
        if channel3.Initial && ((NR30 & 0x80) != 0)
            channel3.Enabled = true;
        else if (NR30 & 0x80) == 0
            channel3.Enabled = false;

        if channel3.Enabled {
			channel3.Length = (256 - NR31) / 256.0;

			channel3.Volume = ((NR32 & 0x60) >> 5);

			channel3.FrequencyX = NR33 + (channel3.FrequencyX & 0xFF00);

			channel3.UseLength = ((NR34 & 0x40) != 0);
			channel3.FrequencyX = ((cast(u16)NR34 & 0x07) << 8) + (channel3.FrequencyX & 0x00FF);
			channel3.Frequency = 65536.0 / (2048 - channel3.FrequencyX);
			channel3.Period = 1 / channel3.Frequency;

            channel3.ElapsedTime = 0.0;
        }
	case 0xFF20;
		NR41 = value | 0xC0;
	case 0xFF21;
		NR42 = value;
	case 0xFF22;
        NR43 = value;
	case 0xFF23;
		NR44 = value | 0x3F;
        channel4.Initial = ((NR44 & 0x80) != 0);
        
		if channel4.Initial
			channel4.Enabled = true;

        if channel4.Enabled {
            channel4.Length = (64 - (NR41 & 0x3F)) / 256.0;

            channel4.Volume = NR42 >> 4;
            channel4.VolumeDecrease = ((NR42 & 0x08) == 0);
            channel4.EnvelopeSweepCount = NR42 & 0x03;
            channel4.EnvelopeSweepStep = channel4.EnvelopeSweepCount / 64.0;

            channel4.ShiftClockFrequency = (NR43 >> 4);
            channel4.CounterWidth15 = ((NR43 & 0x08) == 0);
            channel4.DividingRatio = NR43 & 0x07;
            r : u8;
            if channel4.DividingRatio == 0
                r = 8;
            else
                r = 16 * channel4.DividingRatio;
            channel4.Frequency = 4194304.0 / (r * (1 << (channel4.ShiftClockFrequency + 1)));
            channel4.Period = 1 / channel4.Frequency;

            channel4.UseLength = ((NR44 & 0x40) != 0);

            channel4.ElapsedTime = 0.0;
            channel4.EnvelopeSweepElapsedTime = 0.0;
        }
	case 0xFF24;
		NR50 = value;
	case 0xFF25;
		NR51 = value;
	case 0xFF26;
		NR52 = (value & 0xF0) | (NR52 & 0x0F) | 0x70;
	}
}

Load :: (using audio: *Audio, fileContent: *string) {
    // TODO load channels' state
    consume_u8_and_length(fileContent, xx *NR10, 37);
}

Save :: (using audio: *Audio, builder: *String_Builder) {
    // TODO save channels' state
    append(builder, *NR10, 37);
}