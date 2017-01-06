1k ROM for Pac-Man hardware

Scott Lawrence
yorgle@gmail.com

--------------------------------------------------------------------------------

This is my entry for the 1k hackaday contest.

The idea is to use 1k of my material, running on a pac-man machine.

This is *NOT* a "Pac-Man" style game running in 1k of space.

----------------------------------------

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

ref: http://www.lomont.org/Software/Games/PacMan/PacmanEmulation.pdf

----------------------------------------

The program space in Pac-Man is usually the first 16 kbytes of space
in the Z80's mrmory space.  This is from $0000 through $3FFF.  Since
we're limited to 1024 bytes, we're only using $0000 through $03FF.

Pac-Man hardware uses dedicated PROMs and ROMs for sound waveforms,
character glyphs, sprites, and color palettes.  I feel like it would
be cheating for the contest to requre use of existing graphics and
color/palette PROMs on board, so I include all of them within the
$0400 ROM space.

The graphics are not accessible from the CPU normally, and in this
case, they're still not, but since all data is derived from this
single ROM image, we are able to see it from the CPU.  We do not
take advantage of this though, although I could see being able to
use them to make large rendered text on the screen or somesuch.

Okay...

Each character is 8x8 pixels, at 2 bits of depth.  Each pixel can
be one of three colors in the selected palette.  Sprites are the 
same way, but they're 16x16 pixels.

Normally, the character rom contains 255 characters, in a 4kbyte
rom (PACMAN.5E), with each glyph being (4096/256) 16 bytes long.
For this exercise, we're only using the character glyphs for ASCII
'0' through '9', plus 'A'-'F', all starting at 0x300.  This uses
up a decent chunk of our memory space.

Sprites use 4 times the amount of storage, as they're 16x16 pixels,
so they use 64 bytes each.  The two of these that I have in this
project are 128 bytes of storage, or 1/8 the full space available
for the project!  The two sprites are at 0x280 and ox2C0.

You can see the graphics and sprites via MAME by hitting "F4".  Use
the joystick left and right to scroll through the color lookup
tables and the characters/sprites.  Up/Down will select the color
palette used to view the sprites.  Try color 1, with GFXSet 0 for
example.  You will see some garbage which is the program code, then
the sprites all jumbled up, then the digits 0-9,A,B and some solid
blocks of color. With GFXSet 1, you'll see something similar, but
the sprites will now be assembled (circle and ghost) while the
digits are all jumbled together.

I should also note that the color PROM and palette PROMs are extracted
from the 1k ROM as well.  The 16 byte Color PROM is extracted
starting at 592 bytes and the 256 byte palette PROM is extracted
starting at 608 bytes.  If you use the F4 browser of Mame, you'll 
also see here that the Color PROM is is mostly garbage.  I needed 
more space for the program, so the Color PROM is inaccurate with 
the original game.

Sound ROMs are extracted starting at the beginning of the ROM since
we don't care about those right now anyway.

All of this is taken care of in the Makefile, through the use of
'dd' on the assembled 1kbyte ROM file.

All of this adds up.  We end up with right around HALF of the
available 1 kilobyte alotted!

I did this mainly because I wanted to see if I could, since I'm
pretty sure it's never been done before (and with good reason).

Sadly, with everything going on in the past month, I have not been
able to make a full game out if this, but instead made this little
toy that moves a couple sprites around the screen while you move
the joystick.

If you want to try this in a real Pac-Man arcade machine, you do
not need to replace any of the PROMs, as the colors and palette are
subsets of the "real" PROMs, and the sound PROMs are ignored. The
character ROM (5E) should be fine, and the sprite ROM (5F) can be
left in place.  In fact, all you need to program is the 6E ROM and
drop that one on the board, and you should see something. ;)

Anyway, it was fun to make.  Have a great day!

----------------------------------------

This is the build procedure:

1. Edit graphics ROM data:
	gfx/pacman - edit in turaco

	Bank 1 - Tileset Graphics (use only first 1/4)
	Bank 2 - Same bank, mapped as sprites (use only first 1/4)
	Bank 2 - Actual Sprites (not used, for reference)

2. Save out Graphics ROM (pacman.1k)

3. Make file does these steps:
    A: assemble the source
    B: prep rom package:
	1. copy pacman.1k to source data directory
	2. zero out top 3/4 of the rom -> 1k4
	3. copy pacman.1k4 as pacman.5e, 5f, 6e, 6f, 6h, 6j
	4. extract 75, 1m, 3m, 4a 

----------------------------------------

Prereqs on my system: (MacOS 10.11.6)

- Xcode and command line tool expansion installed
- Boxer.app installed
- Turaco extracted out to a directory, MS-DOS fully functional via 'Boxer'
- Bleu-Romtools installed and in the path (genroms, asz80, aslink)
- XMame installed (version 0.11.1 from Nov 2007)

Additional Links:
- Bleu-Romtools -- https://github.com/BleuLlama/bleu-romtools
- Turaco - https://www.csh.rit.edu/~jerry/turaco/old.shtml
