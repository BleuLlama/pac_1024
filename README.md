
This is an entry for the 1k hackaday contest.

The idea is to use 1k of my material, running on a pac-man machine.

Pac-Man has a few different ROMs and PROMS:

pacman.6e	4096 bytes	0x0000 - 0x0FFF Program ROM
pacman.6f	4096 bytes	0x1000 - 0x1FFF Program ROM
pacman.6h	4096 bytes	0x2000 - 0x2FFF Program ROM
pacman.6j	4096 bytes	0x3000 - 0x3FFF Program ROM

pacman.5e	4096 bytes	Graphics - Character ROM 
pacman.5f	4096 bytes	Graphics - Sprite ROM

82s123.7f	32 bytes	Color ROM
82s126.1m	256 bytes	Sound ROM 1
82s126.3m	256 bytes	Sound ROM 2
82s126.4a	256 bytes	Palette ROM

Our one source ROM file (pac1k.ROM) is 1kbyte in size.  It contains
the base graphics, edited in Turaco.

pacman.6e	4096 bytes	lowest 1k used
pacman.6f	4096 bytes	ignored - filled with 0x00
pacman.6h	4096 bytes	ignored - filled with 0x00
pacman.6j	4096 bytes	ignored - filled with 0x00

pacman.5e	4096 bytes	same as pacman.6e
pacman.5f	4096 bytes	same as pacman.6e

82s123.7f	32 bytes	extracted from pacman.6e
82s126.1m	256 bytes	ignored - filled with 0x00
82s126.3m	256 bytes	ignored - filled with 0x00
82s126.4a	256 bytes	extracted from pacman.6e

ref:
http://www.lomont.org/Software/Games/PacMan/PacmanEmulation.pdf

This is the build procedure:

1. Edit graphics ROM data:
	gfx/pacman - edit in turaco

	Bank 1 - Tileset Graphics (use only first 1/4)
	Bank 2 - Same bank, mapped as sprites (use only first 1/4)
	Bank 2 - Actual Sprites (not used, for reference)

2. Save out Graphics ROM (pacman.1k)

3. Make file does these steps:
    A: assemble the source
    C: prep rom package:
	1. copy pacman.1k to source data directory
	2. zero out top 3/4 of the rom -> 1k4
	3. copy pacman.1k4 as pacman.5e, 5f, 6e, 6f, 6h, 6j
	4. extract 75, 1m, 3m, 4a (how?)
		dd if=input.binary of=output.binary skip=$offset count=$bytes iflag=skip_bytes,count_bytes 

	5. 


