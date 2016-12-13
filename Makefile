# Makefile for the 1k experiment
#
#  Scott Lawrence


# main definitions
VERSION	:= 0.01
THISDIR := pacpatch

# define these four based on the above table.
# the .asm file
TARGET  := 1k
# the source romset
SRCSET	:= pacman
# the destination romset
ROMSET	:= pacman



# executables
MAKE	:= make
GENROMS := genroms
TURACODIR := /Users/slawrence/Documents/Turaco
TURACOCL	:= turacocl
XMAME	:= xmame
XMAMED	:= xmamed
XMAMEARGS := -snapshot_directory . -rompath . -cheat -scale 2 -nomitshm
XMAMEDARGS := $(XMAMEARGS) -debug -nr -ds 640x480 

# the target.asm file
ASM 	:= $(TARGET).asm

# derivative definitions
RELS	:= $(ASM:%.asm=%.rel)
LSTS	:= $(ASM:%.asm=%.lst)
MAPS	:= $(ASM:%.asm=%.map)
IHX	:= $(ASM:%.asm=%.ihx)

# listings of roms
GENERATEDROMS := $(shell $(GENROMS) auxfiles/pacman1k.roms -listall)
ROMFILES := $(GENERATEDROMS:%=$(ROMSET)/%)

################################################################################
# the main target
all: roms

# listing: good for verbose debugging
listing: $(LSTS)

# roms: generate the rom files from the .ihx file via 'genroms'

OFFSET7F := 496
OFFSET4A := 512
OFFSET1M := 0
OFFSET3M := 0

roms:	$(IHX) genroms pgmroms gfxroms colorroms soundroms

genroms: $(IHX)
	@echo "Building base .1k file"
	@-mkdir $(ROMSET)
	@cd $(ROMSET) ; $(GENROMS) ../auxfiles/pacman1k.roms ../$(IHX) -patch . 

pgmroms: genroms
	@echo " Generating Program Roms 6e, 6f, 6h, 6j"
	@cp $(ROMSET)/pacman.1k $(ROMSET)/pacman.6e
	@dd if=/dev/zero bs=3072 count=1 >& /dev/null >> $(ROMSET)/pacman.6e
	@dd if=/dev/zero of=$(ROMSET)/pacman.6f bs=4096 count=1 >& /dev/null
	@dd if=/dev/zero of=$(ROMSET)/pacman.6h bs=4096 count=1 >& /dev/null
	@dd if=/dev/zero of=$(ROMSET)/pacman.6j bs=4096 count=1 >& /dev/null

gfxroms: genroms
	@echo " Generating Graphics Roms 5e, 5f"
	@cp $(ROMSET)/pacman.1k $(ROMSET)/pacman.5e
	@dd if=/dev/zero bs=3072 count=1 >& /dev/null >> $(ROMSET)/pacman.5e
	@cp $(ROMSET)/pacman.5e $(ROMSET)/pacman.5f

colorroms: genroms
	@echo " Extracting Color PROM 7f"
	@dd if=$(ROMSET)/pacman.1k of=$(ROMSET)/82s123.7f bs=1 count=16 skip=$(OFFSET7F) >& /dev/null
	@echo " Extracting Palette PROM 4a"
	@dd if=$(ROMSET)/pacman.1k of=$(ROMSET)/82s126.4a bs=1 count=256 skip=$(OFFSET4A) >& /dev/null

soundroms: genroms
	@echo " Extracting Sound Wavetable PROMs 1m, 3m"
	@dd if=$(ROMSET)/pacman.1k of=$(ROMSET)/82s126.1m bs=256 count=1 skip=$(OFFSET1M) >& /dev/null
	@dd if=$(ROMSET)/pacman.1k of=$(ROMSET)/82s126.3m bs=256 count=1 skip=$(OFFSET3M) >& /dev/null




# test: generate the roms, try them in MAME

test:	mametest

mametest: clean roms
	$(XMAME) $(XMAMEARGS) $(ROMSET)

debug:	clean roms
	$(XMAMED) $(XMAMEDARGS) $(ROMSET)

################################################################################
# Graphics targets using Turaco.exe and DOSBOX/BOXER

graphics:
	cd $(TURACODIR) ; \
	open -a Boxer.app TURACO.BAT


################################################################################
# list version of asm files via asz80
%.lst: %.asm
	asz80 -l $<

# ihx file from rel files via aslink
$(IHX): $(RELS)
	aslink -i -m -o $(IHX) $(RELS)

# rels from asms via asz80
%.rel: %.asm
	asz80 $<

################################################################################
# utility targets

# clean: remove extra files
clean:
	rm -rf $(IHX) $(RELS) $(LSTS) $(MAPS) $(ROMFILES)
	rm -rf $(ROMSET)
	rm -f *.ihx *.rel *.lst *.map
.PHONY: clean

# clobber: remove all generated files
clobber: clean
	rm -rf $(PROGROMFILESPATH) $(ROMSET).zip
.PHONY: clobber
	
# backup: tar-gzip the source tree
backup: clean
	cd .. ; tar -cvf $(THISDIR)_$(VERSION).tar $(THISDIR)
	gzip -f ../$(THISDIR)_$(VERSION).tar
.PHONY: backup

# winbackup: zip the source tree
winbackup: clean
	cd .. ; zip -rp $(THISDIR)_$(VERSION).zip $(THISDIR)

dist: roms
	zip -rp $(TARGET).zip $(ROMFILES)
