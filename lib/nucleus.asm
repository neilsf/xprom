; XPROM SYSTEM NUCLEUS
; DASM FORMAT

reserved0	EQU $fb
reserved1	EQU $fc
reserved2	EQU $fd
reserved3	EQU $fe

reserved4	EQU $ff

reserved5	EQU $02
reserved6	EQU $03

reserved7	EQU $04
reserved8	EQU $05

reserved9	EQU $06
reservedA	EQU $07

stack 		EQU $0100

FAC 		EQU $61
MOVFM 		EQU $bba2
MOVMF 		EQU $bbd4
FACINX 		EQU $b1aa
GIVAYF 		EQU $b391
QINT	 	EQU $bc9b

	; Push a zero on the stack
	; EXAMINE REFS BEFORE CHANGING!
	MAC pzero
	lda #$00
	pha
	ENDM

	; Push a one on the stack
	; EXAMINE REFS BEFORE CHANGING!
	MAC pone
	lda #$01
	pha
	ENDM

	; Push one byte on the stack
	MAC pbyte
	lda {1}
	pha
	ENDM

	; Push one byte as a word on the stack
	MAC pbyteasw
	lda {1}
	pha
	lda #$00
	pha
	ENDM

	; Push one word on the stack
	MAC pword
	lda #<{1}
	pha
	lda #>{1}
	pha
	ENDM
	
	; Push one word variable on the stack
	MAC pwordvar
	lda.w {1}
	pha
	lda.w {1}+1
	pha
	ENDM

	; Push integer on stack	
	MAC pint
.x	SET	0
	IF {1} < 0
.x	SET 16777216 + {1}
	ELSE
.x	SET {1}
	ENDIF
	lda #[.x & $0000ff]
	pha
	lda #[[.x>>8] & $00ff]
	pha
	lda #[.x>>16]
	pha
	ENDM
	
	; Push integer variable on stack
	MAC pintvar
	lda.w {1}
	pha
	lda.w {1}+1
	pha
	lda.w {1}+2
	pha
	ENDM

	; Push real variable on stack
	MAC prvar
	lda.w {1}
	pha
	lda.w {1}+1
	pha
	lda.w {1}+2
	pha
	lda.w {1}+3
	pha
	lda.w {1}+4
	pha
	ENDM

	; Push address on stack
	MAC paddr
	pword {1}
	ENDM

	; Pull byte to variable
	MAC plb2var
	pla
	sta {1}
	ENDM

	; Pull word to variable
	MAC plw2var
	pla
	sta {1}+1
	pla
	sta {1}
	ENDM	
		
	; Pull int to variable
	MAC pli2var
	pla
	sta {1}+2
	pla
	sta {1}+1
	pla
	sta {1}
	ENDM

	; Pull real to variable
	MAC plr2var
	pla
	sta {1}+4
	pla
	sta {1}+3
	pla
	sta {1}+2
	pla
	sta {1}+1
	pla
	sta {1}
	ENDM

	; Compare two bytes on stack for less than
	MAC cmpblt
	pla
	sta reserved1
	pla
	cmp reserved1
	bcc .pht
	pzero
	jmp *+6
.pht: pone 
	ENDM

	; Compare two bytes on stack for greater than or equal
	MAC cmpbgte
	pla
	sta reserved1
	pla
	cmp reserved1
	bcs .pht
	pzero
	jmp *+6
.pht: pone
	ENDM

	; Compare two bytes on stack for equality
	MAC cmpbeq
	pla
	sta reserved1
	pla
	cmp reserved1
	beq .pht
	pzero
	jmp *+6
.pht: pone
	ENDM

	; Compare two bytes on stack for inequality
	MAC cmpbneq
	pla
	sta reserved1
	pla
	cmp reserved1
	bne .pht
	pzero
	jmp *+6
.pht: pone
	ENDM

	; Compare two bytes on stack for greater than
	MAC cmpbgt
	pla
	sta reserved1
	pla
	cmp reserved1
	bcs .phf
	pone
	jmp *+6
.phf: pzero
	ENDM

	; Compare two words on stack for equality
	MAC cmpweq
	pla
	sta reserved1
	pla
	sta reserved2
	pla
	cmp reserved1
	bne .phf
	pla
	cmp reserved2
	bne .phf+1
	pone
	jmp *+7
.phf: pla
	pzero
	ENDM

	; Compare two words on stack for inequality
	MAC cmpwneq
	pla
	sta reserved1
	pla
	sta reserved2
	pla
	cmp reserved1
	bne .pht
	pla
	cmp reserved2
	bne .pht+1
	pzero
	jmp *+7
.pht: pla
	pone
	ENDM

	; Compare two words on stack for less than (Higher on stack < Lower on stack)
	MAC cmpwlt
	tsx
	lda.wx stack+4
	cmp.wx stack+2
	lda.wx stack+3
	sbc.wx stack+1
	bcs .phf			
	inx
	inx
	inx
	inx
	txs
	pone
	jmp *+11
.phf: inx
	inx
	inx
	inx
	txs
	pzero
	ENDM

	; Compare two words on stack for greater than or equal (H >= L)
	MAC cmpwgte
	tsx
	lda.wx stack+4
	cmp.wx stack+2
	lda.wx stack+3
	sbc.wx stack+1
	bcs .pht	
	inx
	inx
	inx
	inx
	txs
	pzero
	jmp *+11
.pht: inx
	inx
	inx
	inx
	txs
	pone
	ENDM

	; Compare two words on stack for greater than (H > L)
	MAC cmpwgt
	tsx
	lda.wx stack+2
	cmp.wx stack+4
	lda.wx stack+1
	sbc.wx stack+3
	bcc .pht	
	inx
	inx
	inx
	inx
	txs
	pzero
	jmp *+11
.pht: inx
	inx
	inx
	inx
	txs
	pone
	ENDM

	; Compare two ints on stack for equality
	MAC cmpieq		
	tsx
	lda.wx stack+6
	cmp.wx stack+3
	bne .phf
	lda.wx stack+5
	cmp.wx stack+2
	bne .phf
	lda.wx stack+4
	cmp.wx stack+1
	bne .phf
	DS.B 6, $e8 ; 6x inx
	txs
	pone
	jmp *+13
.phf:
	DS.B 6, $e8	; 6x inx	
	txs
	pzero
	ENDM

	; Compare two ints on stack for inequality
	MAC cmpineq
	tsx
	lda.wx stack+6
	cmp.wx stack+3
	beq .phf
	lda.wx stack+5
	cmp.wx stack+2
	beq .phf
	lda.wx stack+4
	cmp.wx stack+1
	beq .phf
	DS.B 6, $e8 ; 6x inx
	txs
	pone
	jmp *+13
.phf:	
	DS.B 6, $e8 ; 6x inx	
	txs
	pzero
	ENDM
	
	; Helper macro for all int comparisons
	MAC _icomparison
	tsx
	lda.wx stack+6
    cmp.wx stack+3
    lda.wx stack+5
    sbc.wx stack+2
    lda.wx stack+4
    sbc.wx stack+1
    bvc *+4
    eor #80
	ENDM

	; Compare two ints on stack for less than
	MAC cmpilt
	_icomparison
	bmi .pht
	DS.B 6, $e8 ; 6x inx
	txs
	pzero
	jmp *+13
.pht:
	DS.B 6, $e8 ; 6x inx	
	txs
	pone
	ENDM
	
	; Compare two ints on stack for greater than or equal
	MAC cmpigte
	_icomparison
	bpl .pht
	DS.B 6, $e8 ; 6x inx
	txs
	pzero
	jmp *+13
.pht:
	DS.B 6, $e8 ; 6x inx	
	txs
	pone
	ENDM

	; Compare two ints on stack for less than or equal
	MAC cmpilte
	tsx
	lda.wx stack+4
	cmp.wx stack+1
	beq .1
	bpl .phf
.1:	lda.wx stack+5
	cmp.wx stack+2
	beq .2
	bpl .phf
.2:	lda.wx stack+6
	cmp.wx stack+3
	beq .3
	bpl .phf
.3:	DS.B 6, $e8 ; 6x inx
	txs
	pone
	jmp *+13
.phf:	
	DS.B 6, $e8 ; 6x inx	
	txs
	pzero
	ENDM

	; Compare two ints on stack for greater than
	MAC cmpigt
	tsx
	lda.wx stack+4
	cmp.wx stack+1
	beq .1
	bpl .pht
.1:	lda.wx stack+5
	cmp.wx stack+2
	beq .2
	bpl .pht
.2:	lda.wx stack+6
	cmp.wx stack+3
	beq .3
	bpl .pht
.3:	DS.B 6, $e8 ; 6x inx
	txs
	pzero
	jmp *+13
.pht:	
	DS.B 6, $e8 ; 6x inx	
	txs
	pone
	ENDM

	; Add bytes on stack
	MAC addb
	pla
	tsx
	clc
	adc.wx stack+1
	sta.wx stack+1
	ENDM

	; Add words on stack
	MAC addw
	tsx
	lda.wx stack+2
	clc
	adc.wx stack+4
	sta.wx stack+4
	pla
	adc.wx stack+3
	sta.wx stack+3
	pla
	ENDM

	; Add ints on stack
	MAC addi
	tsx
	clc
	lda.wx stack+3
	adc.wx stack+6
	sta.wx stack+6
	lda.wx stack+2
	adc.wx stack+5
	sta.wx stack+5
	pla
	adc.wx stack+4
	sta.wx stack+4
	inx
	inx
	txs
	ENDM

	; Substract bytes on stack
	MAC subb
	tsx
	lda.wx stack+2
	sec
	sbc.wx stack+1
	sta.wx stack+2
	pla
	ENDM

	; Substract words on stack
	MAC subw
	tsx
	lda.wx stack+4
	sec
	sbc.wx stack+2
	sta.wx stack+4
	lda.wx stack+3
	sbc.wx stack+1
	sta.wx stack+3
	inx
	inx
	txs
	ENDM

	; Substract ints on stack
	MAC subi
	tsx
	sec
	lda.wx stack+6
	sbc.wx stack+3
	sta.wx stack+6
	lda.wx stack+5
	sbc.wx stack+2
	sta.wx stack+5
	lda.wx stack+4
	sbc.wx stack+1
	sta.wx stack+4
	inx
	inx
	inx
	txs
	ENDM

	; Multiply bytes on stack
	; by White Flame 20030207
	MAC mulb
	pla
	sta reserved1
	pla
	sta reserved2
	lda #$00
	beq .enterLoop		
.doAdd:
	clc
	adc reserved1	
.loop:		
	asl reserved1
.enterLoop:
	lsr reserved2
	bcs .doAdd
	bne .loop
.end:	
	pha
	ENDM
	
	;Multiply words at reserved0 and reserved2, with 16-bit result at reserved2
	;and 16-bit overflow at reserved5
NUCL_MUL16	SUBROUTINE
	ldx #$11		
	lda #$00
	sta reserved5
	clc
.1:	ror
	ror reserved5
	ror reserved1
	ror reserved0
	dex
	beq .q
	bcc .1
	sta reserved6
	lda reserved5
	clc
	adc reserved2
	sta reserved5
	lda reserved6
	adc reserved3
	jmp .1
.q:	sta reserved6
	rts
	
	; Multiply words on stack
	MAC mulw
	pla
	sta reserved1
	pla
	sta reserved0
	pla
	sta reserved3
	pla
	sta reserved2
	jsr NUCL_MUL16
	lda reserved0
	pha
	lda reserved1
	pha
	ENDM
	
	; Convert integer to its two's complement
	MAC twoscomplement_of_int
	lda {1}+2
	eor #$ff
	sta {1}+2
	lda	{1}+1
	eor #$ff
	sta {1}+1
	lda	{1}
	eor #$ff
	clc
	adc #$01
	sta	{1}
	ENDM
	
	; Signed 24-bit integer multiply routine	
signed_mul24	SUBROUTINE
	ldx #$00
	lda reserved0+2
	bpl .skip
	twoscomplement_of_int reserved0
	inx
.skip
	lda reserved5+2				
	bpl .skip2
	twoscomplement_of_int reserved5
	inx
.skip2
	jsr unsigned_mul24
	txa
	and #$01
	beq .q
	twoscomplement_of_int reserved8
.q	rts

	; Unsigned 24-bit multiply routine
unsigned_mul24	SUBROUTINE	
	lda #$00
	sta reserved8
	sta reserved8+1
	sta reserved8+2

.loop
	lda reserved5
	bne .nz
	lda reserved5+1
	bne .nz
	lda reserved5+2
	bne .nz
	rts
.nz
	lda reserved5
	and #$01
	beq .skip
	
	lda reserved0
	clc
	adc reserved8
	sta reserved8
	
	lda reserved0+1
	adc reserved8+1
	sta reserved8+1
	
	lda reserved0+2
	adc reserved8+2
	sta reserved8+2

.skip
	asl reserved0 
	rol reserved0+1
	rol reserved0+2
	lsr reserved5+2
	ror reserved5+1
	ror reserved5

	jmp .loop
	
	; Multiply integers on stack
	MAC muli
	pli2var reserved0
	pli2var reserved5
	jsr signed_mul24
	pintvar reserved8
	ENDM
	
	; 8 bit division routine
	; submitted by Graham at CSDb forum
	
NUCL_DIV8	SUBROUTINE
	asl reserved0
	lda #$00
	rol

	ldx #$08
.loop1
	cmp reserved1
	bcc *+4
	sbc reserved1
	rol reserved0
	rol
	dex
	bne .loop1
   
	ldx #$08
.loop2
   	cmp reserved1
	bcc *+4
	sbc reserved1
	rol reserved2
	asl
	dex
	bne .loop2
	rts
	
	; Divide two bytes on stack
	MAC divb
	pla
	sta reserved1
	pla
	sta reserved0
	jsr NUCL_DIV8
	lda reserved0
	pha
	ENDM
	
	; Two bytes' modulus on stack
	MAC modb
	pla
	sta reserved1
	pla
	sta reserved0
	jsr NUCL_DIV8
	lda reserved2
	pha
	ENDM

	; 16 bit division routine
	; Author: unknown
	
NUCL_DIV16 SUBROUTINE
.divisor 	EQU reserved0
.dividend 	EQU reserved2
.remainder 	EQU reserved5
.result 	EQU .dividend ; save memory by reusing divident to store the result

	lda #0	        ;preset remainder to 0
	sta .remainder
	sta .remainder+1
	ldx #16	        ;repeat for each bit: ...
.divloop:
	asl .dividend	;dividend lb & hb*2, msb -> Carry
	rol .dividend+1	
	rol .remainder	;remainder lb & hb * 2 + msb from carry
	rol .remainder+1
	lda .remainder
	sec
	sbc .divisor	;substract divisor to see if it fits in
	tay	        	;lb result -> Y, for we may need it later
	lda .remainder+1
	sbc .divisor+1
	bcc .skip		;if carry=0 then divisor didn't fit in yet

	sta .remainder+1	;else save substraction result as new remainder,
	sty .remainder	
	inc .result		;and INCrement result cause divisor fit in 1 times
.skip:
	dex
	bne .divloop	
	rts
	
	; Divide words on stack
	MAC divw
	pla
	sta reserved1
	pla
	sta reserved0
	pla
	sta reserved3
	pla
	sta reserved2
	jsr NUCL_DIV16
	lda reserved2
	pha
	lda reserved1
	pha
	ENDM
	
	; Two words' modulus on stack
	MAC modw
	pla
	sta reserved1
	pla
	sta reserved0
	pla
	sta reserved3
	pla
	sta reserved2
	jsr NUCL_DIV16
	lda reserved2
	pha
	lda reserved1
	pha
	ENDM
	
	; 24 bit signed division
	
NUCL_DIV24	SUBROUTINE
	ldx #$00
	lda reserved8+2
	bpl .skip
	twoscomplement_of_int reserved8
	inx
.skip
	lda reserved5+2		
	bpl .skip2
	twoscomplement_of_int reserved5
	inx
.skip2
	txa
	pha
	jsr NUCL_UDIV24
	pla
	and #$01
	beq .q
	twoscomplement_of_int reserved5
.q	rts
	
	; 24 bit unsigned division routine
	; Author: unknown
	
NUCL_UDIV24	SUBROUTINE
remainder	EQU	reserved0
dividend	EQU reserved5
divisor		EQU	reserved8
pztemp		EQU reserved3
	
	lda #0	        ;preset remainder to 0
	sta remainder
	sta remainder+1
	sta remainder+2
	ldx #24	        ;repeat for each bit: ...

.divloop:
	asl dividend	;dividend lb & hb*2, msb -> Carry
	rol dividend+1	
	rol dividend+2
	rol remainder	;remainder lb & hb * 2 + msb from carry
	rol remainder+1
	rol remainder+2
	lda remainder
	sec
	sbc divisor	;substract divisor to see if it fits in
	tay	        ;lb result -> Y, for we may need it later
	lda remainder+1
	sbc divisor+1
	sta pztemp
	lda remainder+2
	sbc divisor+2
	bcc .skip	;if carry=0 then divisor didn't fit in yet

	sta remainder+2	;else save substraction result as new remainder,
	lda pztemp
	sta remainder+1
	sty remainder	
	inc dividend 	;and INCrement result cause divisor fit in 1 times

.skip:
	dex
	bne .divloop	
	rts
	
	; Divide integers on stack
	MAC divi
	pli2var reserved8
	pli2var reserved5
	jsr NUCL_DIV24
	pintvar reserved5
	ENDM
	
	; Two integers' modulus on stack
	MAC modi
	pli2var reserved8
	pli2var reserved5
	jsr NUCL_DIV24
	pintvar reserved0
	ENDM
	
	; Perform OR on top 2 bytes of stack
	MAC orb
	pla
	sta reserved1
	pla
	ora reserved1
	pha 
	ENDM
	
	; Perform AND on top 2 bytes of stack
	MAC andb
	pla
	sta reserved1
	pla
	and reserved1
	pha 
	ENDM

	; Perform XOR on top 2 bytes of stack
	MAC xorb
	pla
	sta reserved1
	pla
	eor reserved1
	pha 
	ENDM

	; Invert true/false value on top byte of stack
	MAC notbool
	pla
	beq .skip
	pzero
	jmp *+6
.skip:
	pone			
	ENDM
	
	; Negate byte on stack (return twos complement)
	MAC negbyte
	pla
	eor #$FF
	clc
	adc #$01
	pha
	ENDM
	
	; Negate word on stack (return twos complement)
	MAC negword
	tsx
	lda.wx stack+1
	eor #$ff
	sta.wx stack+1
	lda.wx stack+2
	eor #$ff
	clc
	adc #$01
	sta.wx stack+2
	bcc *+5
	inc.wx stack+1
	ENDM
	
	; TODO
	; Negate int on stack
	MAC negint
	tsx
	lda.wx stack+1
	eor #$ff
	sta.wx stack+1
	lda.wx stack+2
	eor #$ff
	clc
	adc #$01
	sta.wx stack+2
	bcc *+5
	inc.wx stack+1
	ENDM
	
	; Bitwise left-shift byte on stack
	MAC lshb
	pla
	asl
	pha
	ENDM
	
	; Bitwise left-shift word on stack
	MAC lshw
	tsx
	asl.wx stack+2
	rol.ws stack+1
	ENDM
	
	; Bitwise left-shift int on stack
	MAC lshi
	tsx
	asl.wx stack+3
	rol.ws stack+2
	rol.ws stack+1
	ENDM
	
	; Bitwise right-shift byte on stack
	MAC rshb
	pla
	lsr
	pha
	ENDM
	
	; Bitwise right-shift word on stack
	MAC rshw
	tsx
	lsr.wx stack+1
	ror.ws stack+2
	ENDM
	
	; Bitwise right-shift int on stack
	MAC rshi
	tsx
	lsr.wx stack+1
	ror.ws stack+2
	ror.ws stack+3
	ENDM


	; TODO
	; Rewrite all REAL funcs to use own
	; library instead of BASIC ROM

	; Push real in FAC onto stack
	MAC phfac
    ldx #$fb
    ldy #$00
    jsr MOVMF
    lda reserved0
    pha
    lda reserved1
    pha
    lda reserved2
    pha
    lda reserved3
    pha
    lda reserved4
    pha
	ENDM

	; Pull real on stack into FAC
	MAC plfac
    pla
    sta reserved4
    pla
    sta reserved3
    pla
    sta reserved2
    pla
    sta reserved1
    pla
    sta reserved0
    lda #$fb
    ldy #$00
    jsr MOVFM
	ENDM

	; Convert byte value to real
	MAC byte2real
    pla
    tay
    jsr $b3a2
    phfac
	ENDM

	; Convert word value to real
	MAC word2real
    pla
    tax
    pla
    ldy #$00
    sec
    jsr $af87
    jsr $af7e
    phfac
	ENDM

	; Convert int value to real
	MAC int2real
	pla
	sta $62
	pla
	sta $63
	pla
	sta $64
	lda #$00
	sta $65
	sta $66
	sta $70
	lda #$98
	sta $61
	clc
	lda $62
	bmi .1
	sec
.1:	jsr $b8d2
	phfac
	ENDM

	; Convert real value to byte
	MAC real2byte
	plfac
	ldy #reserved0
	lda #$00
	jsr FACINX
	lda reserved0
	pha
	ENDM

	; Convert real value to word
	MAC real2word
	plfac
	jsr QINT
	lda $65
	pha
	lda $64
	pha
	ENDM