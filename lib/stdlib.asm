KERNAL_PRINTCHR	EQU $e716

; setup default mem layout for xprom runtime environment
STDLIB_MEMSETUP SUBROUTINE
	lda #$36
	sta $01
	rts

; print null-terminated petscii string
STDLIB_PRINT SUBROUTINE
	sta $6f         ; store string start low byte
    sty $70         ; store string start high byte
    ldy #$00		; set length to 0
.1:
    lda ($6f),y     ; get byte from string
    beq .2		    ; exit loop if null byte [EOS] 
    jsr KERNAL_PRINTCHR
    iny             
    bne .1
.2:
	rts

; BLKOMOV routine for max 256 bytes blocks
STDLIB_BLKMOV_SMALL SUBROUTINE
.1:	
	lda ($02),y
	sta ($04),y
	dey
	bpl .1
	rts
	
; BLKOMOV routine for blocks larger than 256 bytes
STDLIB_BLKMOV_LARGE SUBROUTINE
	ldy #$00
	lda $06
	clc
	adc $04
	sta $06
	lda $07
	adc $05
	sta $07
.1:
	lda ($02),y
	sta ($04),y

	rts

	MAC stdlib_blkmov_small
	pla
	tay
	pla
	sta $05
	pla
	sta $04
	pla
	sta $03
	pla
	sta $02
	jsr STDLIB_BLKMOV_SMALL
	ENDM

	MAC stdlib_blkmov_large
	pla
	sta $07
	pla
	sta $06
	pla
	sta $05
	pla
	sta $04
	pla
	sta $03
	pla
	sta $02
	ENDM

	MAC stdlib_putstr
    pla
    tay
    pla
    jsr STDLIB_PRINT
	ENDM

	MAC stdlib_putchar
    pla
    jsr KERNAL_PRINTCHR
	ENDM