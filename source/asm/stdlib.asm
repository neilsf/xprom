.var KERNAL_PRINTCHR = $E716

_STDLIB_MEMSETUP:	// setup default mem layout for xprom runtime environment
	lda #$36
	sta $01
	rts

_STDLIB_PRINT:
					// print null-terminated petscii string
	sta $6f         // store string start low byte
    sty $70         // store string start high byte
    ldy #$00		// set length to 0
!:
    lda ($6f),y     // get byte from string
    beq !+		    // exit loop if null byte [EOS] 
    jsr KERNAL_PRINTCHR
    iny             // increment length
    bne !-
!:
	rts

_STDLIB_BLKMOV_SMALL:
!:	
	lda ($02),y
	sta ($04),y
	dey
	bpl !-
	rts
	
_STDLIB_BLKMOV_LARGE:
	sty #$00
	lda $06
	clc
	adc $04
	sta $06
	lda $07
	adc $05
	sta $07
!:
	lda ($02),y
	sta ($04),y
	
	rts

.pseudocommand stdlib_blkmov_small {
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
	jsr _STDLIB_BLKMOV_SMALL
}

.pseudocommand stdlib_blkmov_large {
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
}

.pseudocommand stdlib_putstr {
    pla
    tay
    pla
    jsr STDLIB_PRINT
}

.pseudocommand stdlib_putchar {
    pla
    jsr KERNAL_PRINTCHR
}