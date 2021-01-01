PalettesWindow :: struct {
    using window : Window;
	gpu : *GPU;
	bgpMemory : *u8;
	obpMemory : *u8;

	//sf::Font font;

	// cpu
	/*sf::Text labelBGP;
	sf::Text labelOBP0;
	sf::Text labelOBP1;
	sf::Text labelBG0;
	sf::Text labelBG1;
	sf::Text labelBG2;
	sf::Text labelBG3;
	sf::Text labelBG4;
	sf::Text labelBG5;
	sf::Text labelBG6;
	sf::Text labelBG7;
	sf::Text labelOB0;
	sf::Text labelOB1;
	sf::Text labelOB2;
	sf::Text labelOB3;
	sf::Text labelOB4;
	sf::Text labelOB5;
	sf::Text labelOB6;
	sf::Text labelOB7;

	sf::Text valueBGP;
	sf::Text valueOBP0;
	sf::Text valueOBP1;
	sf::Text valueBG0;
	sf::Text valueBG1;
	sf::Text valueBG2;
	sf::Text valueBG3;
	sf::Text valueBG4;
	sf::Text valueBG5;
	sf::Text valueBG6;
	sf::Text valueBG7;
	sf::Text valueOB0;
	sf::Text valueOB1;
	sf::Text valueOB2;
	sf::Text valueOB3;
	sf::Text valueOB4;
	sf::Text valueOB5;
	sf::Text valueOB6;
	sf::Text valueOB7;*/
};

Init :: (using palettesWindow : *PalettesWindow, Width: u16, Height: u16, Title: string, posX: s32, posY: s32, gb: *GameBoy) {
    Init(*window, Width, Height, Title, posX, posY, false);
    gpu = *gb.gpu;
	bgpMemory = GetBGPPtr(gpu);
	obpMemory = GetOBPPtr(gpu);

	//if (!font.loadFromFile("Pokemon_GB.ttf"))
	{
		// error...
	}

	/*SetupLabel(palettesWindow, labelBGP, "BGP", 2, 2);
	SetupLabel(palettesWindow, labelOBP0, "OBP0", 87, 2);
	SetupLabel(palettesWindow, labelOBP1, "OBP1", 172, 2);
	SetupLabel(palettesWindow, labelBG0, "BG0", 2, 22);
	SetupLabel(palettesWindow, labelBG1, "BG1", 2, 32);
	SetupLabel(palettesWindow, labelBG2, "BG2", 2, 42);
	SetupLabel(palettesWindow, labelBG3, "BG3", 2, 52);
	SetupLabel(palettesWindow, labelBG4, "BG4", 2, 62);
	SetupLabel(palettesWindow, labelBG5, "BG5", 2, 72);
	SetupLabel(palettesWindow, labelBG6, "BG6", 2, 82);
	SetupLabel(palettesWindow, labelBG7, "BG7", 2, 92);
	SetupLabel(palettesWindow, labelOB0, "OB0", 2, 112);
	SetupLabel(palettesWindow, labelOB1, "OB1", 2, 122);
	SetupLabel(palettesWindow, labelOB2, "OB2", 2, 132);
	SetupLabel(palettesWindow, labelOB3, "OB3", 2, 142);
	SetupLabel(palettesWindow, labelOB4, "OB4", 2, 152);
	SetupLabel(palettesWindow, labelOB5, "OB5", 2, 162);
	SetupLabel(palettesWindow, labelOB6, "OB6", 2, 172);
	SetupLabel(palettesWindow, labelOB7, "OB7", 2, 182);

	SetupValue(palettesWindow, valueBGP, 52, 2);
	SetupValue(palettesWindow, valueOBP0, 137, 2);
	SetupValue(palettesWindow, valueOBP1, 222, 2);
	SetupValue(palettesWindow, valueBG0, 52, 22);
	SetupValue(palettesWindow, valueBG1, 52, 32);
	SetupValue(palettesWindow, valueBG2, 52, 42);
	SetupValue(palettesWindow, valueBG3, 52, 52);
	SetupValue(palettesWindow, valueBG4, 52, 62);
	SetupValue(palettesWindow, valueBG5, 52, 72);
	SetupValue(palettesWindow, valueBG6, 52, 82);
	SetupValue(palettesWindow, valueBG7, 52, 92);
	SetupValue(palettesWindow, valueOB0, 52, 112);
	SetupValue(palettesWindow, valueOB1, 52, 122);
	SetupValue(palettesWindow, valueOB2, 52, 132);
	SetupValue(palettesWindow, valueOB3, 52, 142);
	SetupValue(palettesWindow, valueOB4, 52, 152);
	SetupValue(palettesWindow, valueOB5, 52, 162);
	SetupValue(palettesWindow, valueOB6, 52, 172);
	SetupValue(palettesWindow, valueOB7, 52, 182);*/
}

Cleanup :: (using palettesWindow : *PalettesWindow) {
	bgpMemory = null;
	obpMemory = null;
}

Update :: (using palettesWindow : *PalettesWindow) {
    if !IsOpen(palettesWindow)
        return;

	/*renderWindow->clear();

	valueBGP.setString(u8ToHex(gpu.Read(0xFF47)));
	valueOBP0.setString(u8ToHex(gpu.Read(0xFF48)));
	valueOBP1.setString(u8ToHex(gpu.Read(0xFF49)));
	renderWindow->draw(labelBGP);
	renderWindow->draw(labelOBP0);
	renderWindow->draw(labelOBP1);
	renderWindow->draw(valueBGP);
	renderWindow->draw(valueOBP0);
	renderWindow->draw(valueOBP1);*/

	if gpu.isCGB {
		/*valueBG0.setString(PaletteToString(0, true));
		valueBG1.setString(PaletteToString(1, true));
		valueBG2.setString(PaletteToString(2, true));
		valueBG3.setString(PaletteToString(3, true));
		valueBG4.setString(PaletteToString(4, true));
		valueBG5.setString(PaletteToString(5, true));
		valueBG6.setString(PaletteToString(6, true));
		valueBG7.setString(PaletteToString(7, true));

		valueOB0.setString(PaletteToString(0, false));
		valueOB1.setString(PaletteToString(1, false));
		valueOB2.setString(PaletteToString(2, false));
		valueOB3.setString(PaletteToString(3, false));
		valueOB4.setString(PaletteToString(4, false));
		valueOB5.setString(PaletteToString(5, false));
		valueOB6.setString(PaletteToString(6, false));
		valueOB7.setString(PaletteToString(7, false));
	
		renderWindow->draw(labelBG0);
		renderWindow->draw(labelBG1);
		renderWindow->draw(labelBG2);
		renderWindow->draw(labelBG3);
		renderWindow->draw(labelBG4);
		renderWindow->draw(labelBG5);
		renderWindow->draw(labelBG6);
		renderWindow->draw(labelBG7);
	
		renderWindow->draw(labelOB0);
		renderWindow->draw(labelOB1);
		renderWindow->draw(labelOB2);
		renderWindow->draw(labelOB3);
		renderWindow->draw(labelOB4);
		renderWindow->draw(labelOB5);
		renderWindow->draw(labelOB6);
		renderWindow->draw(labelOB7);
	
		renderWindow->draw(valueBG0);
		renderWindow->draw(valueBG1);
		renderWindow->draw(valueBG2);
		renderWindow->draw(valueBG3);
		renderWindow->draw(valueBG4);
		renderWindow->draw(valueBG5);
		renderWindow->draw(valueBG6);
		renderWindow->draw(valueBG7);
	
		renderWindow->draw(valueOB0);
		renderWindow->draw(valueOB1);
		renderWindow->draw(valueOB2);
		renderWindow->draw(valueOB3);
		renderWindow->draw(valueOB4);
		renderWindow->draw(valueOB5);
		renderWindow->draw(valueOB6);
		renderWindow->draw(valueOB7);*/
	}
	//renderWindow->display();
}

PaletteToString :: (using palettesWindow : *PalettesWindow, index: u8, bg: bool) -> string {
    mem : *u8 = obpMemory;
    if bg
	    mem = bgpMemory;
	/*std::stringstream palette;
	palette << ToHex(mem[index * 8 + 1]) << ToHex(mem[index * 8]) << " ";
	palette << ToHex(mem[index * 8 + 3]) << ToHex(mem[index * 8 + 2]) << " ";
	palette << ToHex(mem[index * 8 + 5]) << ToHex(mem[index * 8 + 4]) << " ";
	palette << ToHex(mem[index * 8 + 7]) << ToHex(mem[index * 8 + 6]);
	return palette.str();*/
    return "";
}

SetupLabel :: (using palettesWindow : *PalettesWindow/*, sf::Text& label*/, text: string, x: float, y: float) {
	/*label.setFont(font);
	label.setString(text);
	label.setCharacterSize(10);
	label.setFillColor(sf::Color::White);
	label.setStyle(sf::Text::Style::Regular);
	label.setPosition(x, y);*/
}

SetupValue :: (using palettesWindow : *PalettesWindow/*, sf::Text& value*/, x: float, y: float) {
	/*value.setFont(font);
	value.setCharacterSize(10);
	value.setFillColor(sf::Color::White);
	value.setStyle(sf::Text::Style::Regular);
	value.setPosition(x, y);*/
}
