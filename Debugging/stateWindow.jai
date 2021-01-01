StateWindow :: struct {
    using window : Window;
	cpu : *CPU;
	gpu : *GPU;

	//sf::Font font;

	// cpu
	/*sf::Text labelPC;
	sf::Text labelSP;

	sf::Text valueAF;
	sf::Text valueBC;
	sf::Text valueDE;
	sf::Text valueHL;
	sf::Text valuePC;
	sf::Text valueSP;

	// gpu
	sf::Text labelLCDC;
	sf::Text labelLCDStat;
	sf::Text labelLY;
	sf::Text labelLYC;
	sf::Text labelSCX;
	sf::Text labelSCY;
	sf::Text labelWX;
	sf::Text labelWY;
	sf::Text labelBGPI;
	sf::Text labelOBPI;
	sf::Text labelBGP;
	sf::Text labelOBP0;
	sf::Text labelOBP1;

	sf::Text valueLCDC;
	sf::Text valueLCDStat;
	sf::Text valueLY;
	sf::Text valueLYC;
	sf::Text valueSCX;
	sf::Text valueSCY;
	sf::Text valueWX;
	sf::Text valueWY;
	sf::Text valueBGPI;
	sf::Text valueOBPI;
	sf::Text valueBGP;
	sf::Text valueOBP0;
	sf::Text valueOBP1;*/
};

Init :: (using stateWindow : *StateWindow, Width: u16, Height: u16, Title: string, posX: s32, posY: s32, gb: *GameBoy) {
    Init(*window, Width, Height, Title, posX, posY, false);
    gpu = *gb.gpu;
    cpu = *gb.cpu;

	//if (!font.loadFromFile("Pokemon_GB.ttf"))
	{
		// error...
	}

	/*SetupLabel(labelPC, "PC", 2, 42);
	SetupLabel(labelSP, "SP", 2, 52);

	SetupValue(valueAF, 2, 2);
	SetupValue(valueBC, 2, 12);
	SetupValue(valueDE, 2, 22);
	SetupValue(valueHL, 2, 32);
	SetupValue(valuePC, 52, 42);
	SetupValue(valueSP, 52, 52);

	SetupLabel(labelLCDC, "LCDC", 110, 2);
	SetupLabel(labelLCDStat, "LCDS", 110, 12);
	SetupLabel(labelLY, "LY", 110, 22);
	SetupLabel(labelLYC, "LYC", 110, 32);
	SetupLabel(labelSCX, "SCX", 110, 42);
	SetupLabel(labelSCY, "SCY", 110, 52);
	SetupLabel(labelWX, "WX", 110, 62);
	SetupLabel(labelWY, "WY", 110, 72);
	SetupLabel(labelBGPI, "BGPI", 110, 82);
	SetupLabel(labelOBPI, "OBPI", 110, 92);
	SetupLabel(labelBGP, "BGP", 110, 102);
	SetupLabel(labelOBP0, "OBP0", 110, 112);
	SetupLabel(labelOBP1, "OBP1", 110, 122);

	SetupValue(valueLCDC, 183, 2);
	SetupValue(valueLCDStat, 183, 12);
	SetupValue(valueLY, 183, 22);
	SetupValue(valueLYC, 183, 32);
	SetupValue(valueSCX, 183, 42);
	SetupValue(valueSCY, 183, 52);
	SetupValue(valueWX, 183, 62);
	SetupValue(valueWY, 183, 72);
	SetupValue(valueBGPI, 183, 82);
	SetupValue(valueOBPI, 183, 92);
	SetupValue(valueBGP, 183, 102);
	SetupValue(valueOBP0, 183, 112);
	SetupValue(valueOBP1, 183, 122);*/

	Update(stateWindow);
}

Update :: (using stateWindow: *StateWindow) {
    if !IsOpen(stateWindow)
        return;

	/*valueAF.setString(cpu.reg16ToString(CPU16BitReg::af));
	valueBC.setString(cpu.reg16ToString(CPU16BitReg::bc));
	valueDE.setString(cpu.reg16ToString(CPU16BitReg::de));
	valueHL.setString(cpu.reg16ToString(CPU16BitReg::hl));
	valuePC.setString(ToHex(cpu.pc));
	valueSP.setString(ToHex(cpu.sp));

	valueLCDC.setString(ToHex(gpu.Read(0xFF40)));
	valueLCDStat.setString(ToHex(gpu.Read(0xFF41)));
	valueLY.setString(ToHex(gpu.Read(0xFF44)));
	valueLYC.setString(ToHex(gpu.Read(0xFF45)));
	valueSCX.setString(ToHex(gpu.Read(0xFF43)));
	valueSCY.setString(ToHex(gpu.Read(0xFF42)));
	valueWX.setString(ToHex(gpu.Read(0xFF4B)));
	valueWY.setString(ToHex(gpu.Read(0xFF4A)));
	valueBGPI.setString(ToHex(gpu.Read(0xFF68)));
	valueOBPI.setString(ToHex(gpu.Read(0xFF6A)));
	valueBGP.setString(ToHex(gpu.Read(0xFF47)));
	valueOBP0.setString(ToHex(gpu.Read(0xFF48)));
	valueOBP1.setString(ToHex(gpu.Read(0xFF49)));

	renderWindow->clear();
	renderWindow->draw(labelPC);
	renderWindow->draw(labelSP);
	renderWindow->draw(valueAF);
	renderWindow->draw(valueBC);
	renderWindow->draw(valueDE);
	renderWindow->draw(valueHL);
	renderWindow->draw(valuePC);
	renderWindow->draw(valueSP);

	renderWindow->draw(labelLCDC);
	renderWindow->draw(labelLCDStat);
	renderWindow->draw(labelLY);
	renderWindow->draw(labelLYC);
	renderWindow->draw(labelSCX);
	renderWindow->draw(labelSCY);
	renderWindow->draw(labelWX);
	renderWindow->draw(labelWY);
	renderWindow->draw(labelBGPI);
	renderWindow->draw(labelOBPI);
	renderWindow->draw(labelBGP);
	renderWindow->draw(labelOBP0);
	renderWindow->draw(labelOBP1);
	renderWindow->draw(valueLCDC);
	renderWindow->draw(valueLCDStat);
	renderWindow->draw(valueLY);
	renderWindow->draw(valueLYC);
	renderWindow->draw(valueSCX);
	renderWindow->draw(valueSCY);
	renderWindow->draw(valueWX);
	renderWindow->draw(valueWY);
	renderWindow->draw(valueBGPI);
	renderWindow->draw(valueOBPI);
	renderWindow->draw(valueBGP);
	renderWindow->draw(valueOBP0);
	renderWindow->draw(valueOBP1);
	renderWindow->display();*/
}
