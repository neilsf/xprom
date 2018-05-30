KERNAL_PRINTCHR	EQU $e716
c
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
	
; convert byte type decimal petscii
STDLIB_BYTE_TO_PETSCII SUBROUTINE
	ldy #$2f
  	ldx #$3a
  	sec
.1: iny
  	sbc #100
  	bcs .1
.2: dex
  	adc #10
  	bmi .2
  	adc #$2f
  	rts
  	
; print byte type as decimal
STDLIB_PRINT_BYTE SUBROUTINE
	jsr STDLIB_BYTE_TO_PETSCII
	pha
	tya
	cmp #$30
	beq .skip
	jsr KERNAL_PRINTCHR
.skip
	txa
	cmp #$30
	beq .skip2
	jsr KERNAL_PRINTCHR
.skip2
	pla
	jsr KERNAL_PRINTCHR
	rts
	
	; opcode for print byte as decimal  	
	MAC stdlib_printb
	pla
	jsr STDLIB_PRINT_BYTE
	ENDM

; print word as petscii decimal
STDLIB_PRINT_WORD SUBROUTINE
	lda #<.tt
	sta $6f         ; store dividend_ptr_lb
	lda #>.tt
    sta $70         ; store dividend_ptr_hb
	
	sta reserved2
	sty reserved2+1
	
	ldy #$00
.loop:
	lda ($6f),y
	sta reserved0
	iny
	lda ($6f),y
	sta reserved0+1
	
	jsr NUCL_DIV16
	lda reserved2+1
	beq .skip
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
.skip:
	iny	
	cpy #$08	
	beq .end	
	jmp .loop	
.end:
	rts
.tt	DC.W #10000
.ot DC.W #1000
.oh DC.W #100
.tn DC.W #10
.re DS.B 

	; opcode for print word as decimal  	
	MAC stdlib_printw
	pla
	sta reserved2+1
	pla
	sta reserved2
	jsr STDLIB_PRINT_WORD
	ENDM

; print integer as petscii decimal
STDLIB_PRINT_INT SUBROUTINE
	lda #<.om
	sta $6f         ; store dividend_ptr_lb
	lda #>.om
    sta $70         ; store dividend_ptr_hb
	
	lda reserved7
	bpl .skip1
					; negate number and print "-"
	twoscomplement_of_int reserved5
	lda #$2d
	jsr KERNAL_PRINTCHR
.skip1:	
	ldy #$00
	sty .re			; no non-zero numbers have been printed yet
.loop:
	lda ($6f),y
	sta reserved8
	iny
	lda ($6f),y
	sta reserved9
	iny
	lda ($6f),y
	sta reservedA
	
	tya
	pha
	
	jsr NUCL_UDIV24
	lda reserved5
	bne .doit
	lda .re
	beq .skip2
	lda reserved5
.doit	
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
	inc .re
.skip2:

	lda reserved0
	sta reserved5
	lda reserved1
	sta reserved6
	lda reserved2
	sta reserved7

	pla
	tay

	iny	
	cpy #18	
	beq .end	
	jmp .loop	
.end:
	lda reserved0
	clc
	adc #$30
	jsr KERNAL_PRINTCHR
	rts
.om HEX 40 42 0F	; one million 
.ht	HEX A0 86 01  	; hundred thousands
.tt	HEX 10 27 00	; etc..
.ot HEX E8 03 00
.oh HEX 64 00 00
.tn HEX 0A 00 00
.re DS.B

; opcode for print word as decimal  	
	MAC stdlib_printi
	pla
	sta reserved7
	pla
	sta reserved6
	pla
	sta reserved5
	jsr STDLIB_PRINT_INT
	ENDM

	
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