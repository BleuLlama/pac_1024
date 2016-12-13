; example 1k file


.area	.CODE (ABS)

.include "hardware.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RAM usage
        RAMLIST         == rambase

            ; timer
        timer           == RAMLIST+0    ; w timer incremented in interrupt

            ; random
        randval         == RAMLIST+2    ; w random helper

	incval		== RAMLIST+4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; text colors
	color_black	== 0x00
	color_red	== 0x01
	color_pink	== 0x03
	color_cyan	== 0x05
	color_orange	== 0x07
	color_yellow	== 0x09
	color_peach	== 0x0e
	color_dkpeach	== 0x15
	color_white	== 0x0f
	color_blue	== 0x10 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.org	0x0000 	; RST 0 / boot vector
	di
	jp	.start

.org 	0x0038	; interrupt routine, called 60x/second
.interrupt:
        di                      ; disable processor interrupts
        push    af              ; store aside register 'af' to the stack
        push    bc              ; store aside register 'bc' to the stack
        xor     a               ; a = 0
        ld      (irqen), a      ; disable the external interrupt mechanism
        ld      (watchdog), a   ; kick the dog

        ld      bc, (timer)     ; bc = timer
        inc     bc              ; bc++
        ld      (timer), bc     ; timer = bc

        ;call    atCheck         ; check for events
        ;call   ptInterrupt     ; update music
        ;call    inputpoll       ; poll the input centralizer

        xor     a
        ld      (watchdog), a   ; kick the dog
        ld      a, #0x01        ; a = 1
        ld      (irqen), a      ; enable the external interrupt mechanism

        pop     bc              ; restore register 'bc' from the stack
        pop     af              ; restore register 'af' from the stack
        ei                      ; enable processor interrupts
        reti                    ; return from interrupt routine


.org	0x0066 	; NMI vector, not used
	retn	; return for now

; startup code for pac-man hardware (bare bones)
.start:
	di
	ld	sp, #(stack)
	ld	a, #0xff
	out	(0), a		; set interrupt vector
	xor	a
	ld	(watchdog), a	; kick the watchdog
	im	1		; Interrupt mode 1
	ld	a, #0x01
	ld	(irqen), a
	ei
	jp	main


main:
	call	cls
	jr	main


; memset256
        ;; memset256 - set up to 256 bytes of ram to a certain value
        ;               in      a       value to poke
        ;               in      b       number of bytes to set 0x00 for 256
        ;               in      hl      base address of the memory location
        ;               out     -
        ;               mod     hl, bc
memset256:
        ld      (hl), a         ; *hl = 0
        inc     hl              ; hl++
        djnz    memset256       ; decrement b, jump to memset256 if b>0
        ret                     ; return


; memsetN
        ;; memsetN - set N blocks of ram to a certain value
        ;               in      a       value to poke
        ;               in      b       number of blocks to set
        ;               in      hl      base address of the memory location
        ;               out     -
        ;               mod     hl, bc
memsetN:
        push    bc              ; set aside bc
        ld      b, #0x00        ; b = 256
        call    memset256       ; set 256 bytes
        pop     bc              ; restore the outer bc
        djnz    memsetN         ; if we're not done, set another chunk.
        ret                     ; otherwise return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; clear screen
        ;; cls - clear the screen (color and video ram)
        ;               in      -
        ;               out     -
        ;               mod     -
cls:
        push    hl              ; set aside some registers
        push    af
        push    bc

        ; hl is at the base of color ram now.
        ld      hl, #(colram)   ; base of color ram
        ;ld      a, #0x00        ; clear the screen to 0x00 (black)
	ld	a, #color_cyan
        ld      b, #0x04        ; need to set 256 bytes 4 times.
        call    memsetN         ; do it.

	ld	a, (timer)
	srl	a
	srl	a
	srl	a
	srl	a
	and	#0x0F
	add	a, #'0

        ld      hl, #(vidram)   ; base of video ram
        ld      b, #0x04        ; need to set 256 bytes 4 times.
        call    memsetN         ; do it.

        pop     bc              ; restore the registers
        pop     af
        pop     hl
        ret                     ; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ROM data extracted for use elsewhere:

.org 0x1f0 ; 480 bytes
; Color PROM - 82s123.7f (standard Pac-Man values)
	.byte 0x00, 0x07, 0x66, 0xef, 0x00, 0xf8, 0xea, 0x6f
	.byte 0x00, 0x3f, 0x00, 0xc9, 0x38, 0xaa, 0xaf, 0xf6

.org 0x0200
; palette PROM - 82s126.4a (standard Pac-Man values values)
        .byte 0x00, 0x00, 0x00, 0x00  ; 00	black	black	black	black
        .byte 0x00, 0x0f, 0x0b, 0x01  ; 01	black	white	blue	red
        .byte 0x00, 0x00, 0x00, 0x00  ; 02	-	-	-	-
        .byte 0x00, 0x0f, 0x0b, 0x03  ; 03	black	white	blue	pink
        .byte 0x00, 0x00, 0x00, 0x00  ; 04	-	-	-	-
        .byte 0x00, 0x0f, 0x0b, 0x05  ; 05	black	white	blue	cyan
        .byte 0x00, 0x00, 0x00, 0x00  ; 06	-	-	-	-
        .byte 0x00, 0x0f, 0x0b, 0x07  ; 07	black	white	blue	orange
        .byte 0x00, 0x0b, 0x01, 0x09  ; 08	black	blue	red	yellow
        .byte 0x00, 0x00, 0x00, 0x00  ; 09	-	-	-	-
        .byte 0x00, 0x00, 0x00, 0x00  ; 0a	-	-	-	-
        .byte 0x00, 0x00, 0x00, 0x00  ; 0b	-	-	-	-
        .byte 0x00, 0x00, 0x00, 0x00  ; 0c	-	-	-	-
        .byte 0x00, 0x0f, 0x00, 0x0e  ; 0d	black	white	black	peach
        .byte 0x00, 0x01, 0x0c, 0x0f  ; 0e	black	red	green	white
        .byte 0x00, 0x0e, 0x00, 0x0b  ; 0f	black	peach	black	blue
        .byte 0x00, 0x0c, 0x0b, 0x0e  ; 10	black	green	blue	peach
        .byte 0x00, 0x0c, 0x0f, 0x01  ; 11	black	green	white	red
        .byte 0x00, 0x00, 0x00, 0x00  ; 12	-	-	-	-
        .byte 0x00, 0x01, 0x02, 0x0f  ; 13	black	red	brown	white
        .byte 0x00, 0x07, 0x0c, 0x02  ; 14	black	peach	green	brown
        .byte 0x00, 0x09, 0x06, 0x0f  ; 15	black	yellow	cyan	white
        .byte 0x00, 0x0d, 0x0c, 0x0f  ; 16	black	cyan	green	white
        .byte 0x00, 0x05, 0x03, 0x09  ; 17	black	cyan	pink	yellow
        .byte 0x00, 0x0f, 0x0b, 0x00  ; 18	black	white	blue	black
        .byte 0x00, 0x0e, 0x00, 0x0b  ; 19	black	peach	black	blue
        .byte 0x00, 0x0e, 0x00, 0x0b  ; 1a	black	peach	black	blue
        .byte 0x00, 0x00, 0x00, 0x00  ; 1b	-	-	-	-
        .byte 0x00, 0x0f, 0x0e, 0x01  ; 1c	black	white	peach	red
        .byte 0x00, 0x0f, 0x0b, 0x0e  ; 1d	black	white	blue	peach
        .byte 0x00, 0x0e, 0x00, 0x0f  ; 1e	black	peach	black	white
        .byte 0x00, 0x00, 0x00, 0x00  ; 1f	-	-	-	-



.org 0x0280
; circle sprite
	.byte 0x00, 0x00, 0x08, 0x0c, 0x0e, 0x86, 0xc3, 0xc3
	.byte 0x00, 0x00, 0x01, 0x03, 0x07, 0x16, 0x3c, 0x3c
	.byte 0x03, 0x0f, 0x3c, 0x78, 0xf1, 0xf3, 0xe6, 0xcc
	.byte 0x0c, 0x0f, 0xc3, 0xe1, 0xf8, 0xfc, 0x76, 0x33
	.byte 0xc3, 0xc3, 0x86, 0x0e, 0x0c, 0x08, 0x00, 0x00
	.byte 0x3c, 0x3c, 0x16, 0x07, 0x03, 0x01, 0x00, 0x00
	.byte 0xcc, 0xe6, 0xf3, 0xf1, 0x78, 0x3c, 0x0f, 0x03
	.byte 0x33, 0x76, 0xfc, 0xf8, 0xe1, 0xc3, 0x0f, 0x0c

.org 0x02c0
; ghost sprite
	.byte 0x00, 0xee, 0xcc, 0x88, 0xcc, 0xee, 0xee, 0x88
	.byte 0x00, 0x00, 0x00, 0x11, 0x33, 0x33, 0x77, 0x77
	.byte 0x00, 0x11, 0xbc, 0x3c, 0x0f, 0x8f, 0xff, 0xff
	.byte 0x00, 0xff, 0xff, 0x7f, 0x7f, 0xff, 0xff, 0xff
	.byte 0x88, 0xee, 0xee, 0xcc, 0x88, 0xcc, 0xee, 0x00
	.byte 0x77, 0x77, 0x33, 0x33, 0x11, 0x00, 0x00, 0x00
	.byte 0xbc, 0x3c, 0x0f, 0x8f, 0xff, 0xff, 0x11, 0x00
	.byte 0xff, 0x7f, 0x7f, 0xff, 0xff, 0xff, 0xff, 0x00

.org 0x0300
; 0..9,A-F  PET style
	.byte 0x00, 0xcc, 0x22, 0x22, 0x22, 0xaa, 0xcc, 0x00 ; 0
	.byte 0x00, 0x77, 0xaa, 0x99, 0x99, 0x88, 0x77, 0x00
	.byte 0x00, 0x22, 0x22, 0xee, 0x22, 0x22, 0x00, 0x00 ; 1
	.byte 0x00, 0x00, 0x00, 0xff, 0x44, 0x22, 0x00, 0x00
	.byte 0x00, 0x22, 0x22, 0x22, 0xaa, 0xaa, 0x66, 0x00 ; 2
	.byte 0x00, 0x66, 0x99, 0x99, 0x88, 0x88, 0x44, 0x00
	.byte 0x00, 0xcc, 0x22, 0x22, 0x22, 0x22, 0x44, 0x00 ; 3
	.byte 0x00, 0x66, 0x99, 0x99, 0x99, 0x88, 0x44, 0x00
	.byte 0x00, 0x88, 0xee, 0x88, 0x88, 0x88, 0x88, 0x00 ; 4
	.byte 0x00, 0x00, 0xff, 0x44, 0x22, 0x11, 0x00, 0x00
	.byte 0x00, 0x88, 0x44, 0x22, 0x22, 0x22, 0x44, 0x00 ; 5
	.byte 0x00, 0x00, 0x99, 0xaa, 0xaa, 0xaa, 0xee, 0x00
	.byte 0x00, 0xcc, 0x22, 0x22, 0x22, 0x22, 0xcc, 0x00 ; 6
	.byte 0x00, 0x00, 0x99, 0x99, 0x99, 0x55, 0x33, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0xee, 0x00, 0x00, 0x00 ; 7
	.byte 0x00, 0xcc, 0xaa, 0x99, 0x88, 0x88, 0xcc, 0x00
	.byte 0x00, 0xcc, 0x22, 0x22, 0x22, 0x22, 0xcc, 0x00 ; 8
	.byte 0x00, 0x66, 0x99, 0x99, 0x99, 0x99, 0x66, 0x00
	.byte 0x00, 0x88, 0x44, 0x22, 0x22, 0x22, 0x00, 0x00 ; 9
	.byte 0x00, 0x66, 0x99, 0x99, 0x99, 0x99, 0x66, 0x00
	.byte 0x00, 0xee, 0x00, 0x00, 0x00, 0x00, 0xee, 0x00 ; A
	.byte 0x00, 0x33, 0x55, 0x99, 0x99, 0x55, 0x33, 0x00
	.byte 0x00, 0xcc, 0x22, 0x22, 0x22, 0xee, 0x22, 0x00 ; B
	.byte 0x00, 0x66, 0x99, 0x99, 0x99, 0xff, 0x88, 0x00

	; all 0
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	; all 1
	.byte 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
	.byte 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f
	; all 2
	.byte 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0
	.byte 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0, 0xf0
	; all 3
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff

;	.byte 0x00, 0x44, 0x22, 0x22, 0x22, 0x44, 0x88, 0x00 ; C
;	.byte 0x00, 0x44, 0x88, 0x88, 0x88, 0x44, 0x33, 0x00
;	.byte 0x00, 0x88, 0x44, 0x22, 0x22, 0xee, 0x22, 0x00 ; D
;	.byte 0x00, 0x33, 0x44, 0x88, 0x88, 0xff, 0x88, 0x00
;	.byte 0x00, 0x22, 0x22, 0x22, 0x22, 0x22, 0xee, 0x00 ; E
;	.byte 0x00, 0x88, 0x88, 0x99, 0x99, 0x99, 0xff, 0x00
;	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xee, 0x00 ; F
;	.byte 0x00, 0x88, 0x88, 0x99, 0x99, 0x99, 0xff, 0x00
.bound	0x0400 ; 1 kilobyte