# GameBoy emulator, Jai port

Este es un port escrito en Jai de mi emulador de GameBoy, originalmente escrito en C++ (https://github.com/DiegoSLTS/gb)

----

This is a Jai port of my GameBoy emulator, originally written in C++ (https://github.com/DiegoSLTS/gb)

## Prerequisitos / Prerequisites

* Configurar el compilador de Jai (actualmente en beta cerrada)
* Descargar SDL2.dll de https://www.libsdl.org/download-2.0.php
* Sólo testeado en Windows 10.

----

* Setup the Jai compiler (currently in closed beta)
* Download SDL2.dll from https://www.libsdl.org/download-2.0.php
* Only tested on Windows 10.

## Instrucciones / Instructions

1 - Abrir una terminal/consola en el directorio raíz de este repositorio
2 - Ejecutar el comando "jai .\first.jai". El ejecutable (gb-emulator.exe) será generado en <raiz>\builds\
3 - Copiar SDL2.dll en <raiz>\builds\

----

1 - Open a terminal/console at the root of this repository
2 - Run the command "jai .\first.jai". The executable (gb-emulator.exe) will be created at <root>\builds\
3 - Copy SDL2.dll to <raiz>\builds\

## Uso / Usage

Se puede cargar una rom desde cualquier ubicación local pasando el path absoluto entre comillas como único argumento, o se puede editar el código en main.jai y roms.jai donde hay varios paths hardcodeados. Esta última opción es solo para hacer pruebas y en el futuro planeo reemplazarla con alguna configuración o con una ventana de selección de rom como cualquier otro emulador.

Ej (desde una consola, en el directorio raiz): .\builds\gb-emulator "C:\gb_roms\tetris.gb"

## Boot

El emulador por defecto saltea la secuencia de boot, pero se puede habilitar con estos cambios:
* En gameboy.jai:62 cambiar "skipBios = true;" por "skipBios = false;"
* Copiar las boot rom de GameBoy y GameBoy Color en la carpeta "Files"
* Nombrar las roms como dmg_boot.bin (para GameBoy) y cgb_bios.bin (para GameBoy Color) o modificar los nombres en mmu.jai:LoadBootRom y recompilar.

Los roms son propiedad de Nintendo y no las puedo distribuir como parte del emulador ni puedo dar instrucciones de como conseguirlos.

----

The emulator skips the boot sequences by default, but it can be enabled with some changes:
* In gameboy.jai:62 change "skipBios = true;" to "skipBios = false;"
* Copy the boot rom files for GameBoy and GameBoy Color to the "Files" directory
* Name the roms as dmg_boot.bin (for GameBoy) and cgb_bios.bin (for GameBoy Color) or change the expected names at mmu.jai:LoadBootRom and recompile.

These roms are property of Nintendo so I can't distribute them nor can give you instructions of where to get them.

## Funcionalidad / Features

El emulador es un port de mi versión de C++ con casi toda la misma funcionalidad, para ver una lista detallada ir a https://github.com/DiegoSLTS/gb

Actualmente estas cosas no funcionan en este port:
* Soporte para ejeutar roms comprimidas. Sólo se pueden ejecutar roms descomprimidas (.gb para GameBoy, .gbc para GameBoyColor)
* El RTC de MBC3
* Ventana de debug de paletas y estado de CPU/GPU
* La emulación de sonido solo funciona en el modo sincrónizado
* No se pueden tomar capturas de pantalla

Planeo agregar esa funcionalidad de nuevo en algún momento pero no son prioridad.

----

The emulator is a port of my C++ version so almost all functionality is the same, for a detailed list see https://github.com/DiegoSLTS/gb

Currently these things don't work in this port:
* Support to run compressed roms. Only uncompressed roms cna be used (.gb for GameBoy, .gbc for GameBoyColor)
* RTC for MBC3
* Debug windows for palettes and CPU/GPU state
* Sound emulation only works in synced mode
* You can't take screenshots

I'm planning to add those things back at some point, but that's not a priority.

## Contributing / Contribuciones

Este es un proyecto que empecé para aprender así que estoy trabajando solo, pero podés mandarme comentarios a diegoslts@gmail.com si tenés alguna sugerencia.

----

This is a project I started to learn so I'm working alone, but feel free to send comments to diegoslts@gmail.com if you have any suggestion.

## Author / Autor

* **Diego Juodziukynas** - [DiegoSLTS](https://github.com/DiegoSLTS)

Todo esto está basado en información técnica pública que encontré usado Google. La mayoría de los links que usé están acá: https://github.com/gbdev/awesome-gbdev

----

All this is based on public technical information found on Google. Here's almost everything that you'll need: https://github.com/gbdev/awesome-gbdev

## License / Licencia

Este proyecto usa la licencia MIT - ver el archivo [LICENSE.md](LICENSE.md) para mas información

----

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments / Reconocimientos

* Gracias a todas las personas que encontraron y recopilaron toda la información disponible sobre el GameBoy
* Gracias al equipo que desarrolló BGB por hacer un emulador muy bueno con herramientas de debug muy útiles
* Gracias a Thekla. Inc por el acceso a la beta de Jai

----

* Thanks to everyone that compiled and found all the information available about the GameBoy
* Thanks to the BGB team for making a great GB emulator with really usefull debug tools
* Thanks to Thekla. Inc for giving me access to the Jai's beta
