; XPROM SYSTEM NUCLEUS

reserved0	EQU $fb
reserved1	EQU $fc
reserved2	EQU $fd
reserved3	EQU $fe
reserved4	EQU $ff
stack 		EQU $0100

FAC 		EQU $61
MOVFM 		EQU $bba2
MOVMF 		EQU $bbd4
FACINX 		EQU $b1aa
GIVAYF 		EQU $b391
QINT	 	EQU $bc9b

; Push a zero on the stack
MAC pzero
	lda #$00
	pha
ENDM

; Push a one on the stack
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
	.if (arg.getType()==AT_IMMEDIATE) {
		lda #<arg.getValue()
		pha
		lda #>arg.getValue()
		pha
	} else {
		lda arg
		pha
		lda arg.getValue()+1
		pha
	}
ENDM

/* Push integer on stack */
MAC pint arg {
	.if (arg.getType()==AT_IMMEDIATE) {
		.var x = 0;
		.if(arg.getValue() < 0) {
			.eval x = 16777216 + arg.getValue();
		} else {
			.eval x = arg.getValue();
		}
		lda #(x & $0000ff)
		pha
		lda #([x>>8] & $00ff)
		pha
		lda #(x>>16)
		pha
	} else {
		lda arg
		pha
		lda arg.getValue()+1
		pha
		lda arg.getValue()+2
		pha
	}
}

/* Push real var on stack */
MAC prvar arg{
		lda arg
		pha
		lda arg.getValue()+1
		pha
		lda arg.getValue()+2
		pha
		lda arg.getValue()+3
		pha
		lda arg.getValue()+4
		pha
}

/* Push address on stack */
MAC paddr arg {
	lda #<arg.getValue()
	pha
	lda #>arg.getValue()
	pha
}

/* Pull byte to variable */
MAC plb2var arg {
	pla
	sta arg.getValue()
}

/* Pull word to variable */
MAC plw2var arg {
	pla
	sta arg.getValue()+1
	pla
	sta arg.getValue()
}

/* Pull int to variable */
MAC pli2var arg {
	pla
	sta arg.getValue()+2
	pla
	sta arg.getValue()+1
	pla
	sta arg.getValue()
}

/* Pull real to variable */
MAC plr2var arg {
	pla
	sta arg.getValue()+4
	pla
	sta arg.getValue()+3
	pla
	sta arg.getValue()+2
	pla
	sta arg.getValue()+1
	pla
	sta arg.getValue()
}

/* Compare two bytes on stack for less than */
MAC cmpblt {
			pla
			sta reserved1
			pla
			cmp reserved1
			bcc pht
			pzero
			jmp end
	pht:	pone
	end:  
}

/* Compare two bytes on stack for greater than or equal */
MAC cmpbgte {
			pla
			sta reserved1
			pla
			cmp reserved1
			bcs pht
			pzero
			jmp end
	pht:	pone
	end:
}

/* Compare two bytes on stack for equality */
MAC cmpbeq {
			pla
			sta reserved1
			pla
			cmp reserved1
			beq pht
			pzero
			jmp end
	pht:	pone
	end:
}

/* Compare two bytes on stack for inequality */
MAC cmpbneq {
			pla
			sta reserved1
			pla
			cmp reserved1
			bne pht
			pzero
			jmp end
	pht:	pone
	end:
}

/* Compare two bytes on stack for greater than */
MAC cmpbgt {
			pla
			sta reserved1
			pla
			cmp reserved1
			bcs phf
			pone
			jmp end
	phf:	pzero
	end:
}

/* Compare two words on stack for equality */
MAC cmpweq {
			pla
			sta reserved1
			pla
			sta reserved2
			pla
			cmp reserved1
			bne phf
			pla
			cmp reserved2
			bne phf+1
			pone
			jmp end
	phf:	pla
			pzero
	end:
}

/* Compare two words on stack for inequality */
MAC cmpwneq {
			pla
			sta reserved1
			pla
			sta reserved2
			pla
			cmp reserved1
			bne pht
			pla
			cmp reserved2
			bne pht+1
			pzero
			jmp end
	pht:	pla
			pone
	end:
}

/* Compare two words on stack for less than (Higher on stack < Lower on stack) */
MAC cmpwlt {
			tsx
			lda stack+4, x
			cmp stack+2, x
			lda stack+3, x
			sbc stack+1, x
			bcs phf			
			inx
			inx
			inx
			inx
			txs
			pone
			jmp end
	phf:	inx
			inx
			inx
			inx
			txs
			pzero
	end: 
}

/* Compare two words on stack for greater than or equal (H >= L) */
MAC cmpwgte {
			tsx
			lda stack+4, x
			cmp stack+2, x
			lda stack+3, x
			sbc stack+1, x
			bcs pht	
			inx
			inx
			inx
			inx
			txs
			pzero
			jmp end
	pht:	inx
			inx
			inx
			inx
			txs
			pone
	end:
}

/* Compare two words on stack for greater than (H > L) */
MAC cmpwgt {
			tsx
			lda stack+2, x
			cmp stack+4, x
			lda stack+1, x
			sbc stack+3, x
			bcc pht	
			inx
			inx
			inx
			inx
			txs
			pzero
			jmp end
	pht:	inx
			inx
			inx
			inx
			txs
			pone
	end:
}

/* Compare two ints on stack for equality */
MAC cmpieq {		
			tsx
			lda stack+6, x
			cmp stack+3, x
			bne phf
			lda stack+5, x
			cmp stack+2, x
			bne phf
			lda stack+4, x
			cmp stack+1, x
			bne phf
			.fill 6, $e8
			txs
			pone
			jmp end
	phf:	.fill 6, $e8	// 6 times inx	
			txs
			pzero
	end:
}

/* Compare two ints on stack for inequality */
MAC cmpineq {
			tsx
			lda stack+6, x
			cmp stack+3, x
			beq phf
			lda stack+5, x
			cmp stack+2, x
			beq phf
			lda stack+4, x
			cmp stack+1, x
			beq phf
			.fill 6, $e8
			txs
			pone
			jmp end
	phf:	.fill 6, $e8	// 6 times inx	
			txs
			pzero
	end:
}

/* Compare two ints on stack for less than */
MAC cmpilt {
			tsx
			lda stack+4, x
			cmp stack+1, x
			beq !+
			bpl phf
	!:		lda stack+5, x
			cmp stack+2, x
			beq !+
			bpl phf
	!:		lda stack+6, x
			cmp stack+3, x
			bpl phf
			.fill 6, $e8
			txs
			pone
			jmp end
	phf:	.fill 6, $e8	// 6 times inx	
			txs
			pzero
	end:
}

/* Compare two ints on stack for greater than or equal */
MAC cmpigte {
			tsx
			lda stack+4, x
			cmp stack+1, x
			bmi phf
			lda stack+5, x
			cmp stack+2, x
			bmi phf
			lda stack+6, x
			cmp stack+3, x
			bmi phf
			.fill 6, $e8
			txs
			pone
			jmp end
	phf:	.fill 6, $e8	// 6 times inx	
			txs
			pzero
	end:
}

/* Compare two ints on stack for less than or equal */
MAC cmpilte {
			tsx
			lda stack+4, x
			cmp stack+1, x
			beq !+
			bpl phf
	!:		lda stack+5, x
			cmp stack+2, x
			beq !+
			bpl phf
	!:		lda stack+6, x
			cmp stack+3, x
			bpl !+
			bpl phf
	!:		.fill 6, $e8
			txs
			pone
			jmp end
	phf:	.fill 6, $e8	// 6 times inx	
			txs
			pzero
	end:
}

/* Compare two ints on stack for greater than */
MAC cmpigt {
			tsx
			lda stack+4, x
			cmp stack+1, x
			beq !+
			bpl pht
	!:		lda stack+5, x
			cmp stack+2, x
			beq !+
			bpl pht
	!:		lda stack+6, x
			cmp stack+3, x
			beq !+
			bpl pht
	!:		.fill 6, $e8
			txs
			pzero
			jmp end
	pht:	.fill 6, $e8	// 6 times inx	
			txs
			pone
	end:
}

/* Add bytes on stack */
MAC addb {
		pla
		tsx
		clc
		adc stack+1,x
		sta stack+1,x
}

/* Add words on stack */
MAC addw {
		tsx
		lda stack+2,x
		clc
		adc stack+4,x
		sta stack+4,x
		pla
		adc stack+3,x
		sta stack+3,x
		pla
}

/* Add ints on stack */
MAC addi {
		tsx
		clc
		lda stack+3, x
		adc stack+6, x
		sta stack+6, x
		lda stack+2, x
		adc stack+5, x
		sta stack+5, x
		pla
		adc stack+4, x
		sta stack+4, x
		inx
		inx
		txs
}

/* Substract bytes on stack */
MAC subb {
		tsx
		lda stack+2,x
		sec
		sbc stack+1,x
		sta stack+2,x
		pla
}

/* Substract words on stack */
MAC subw {
		tsx
		lda stack+4, x
		sec
		sbc stack+2, x
		sta stack+4, x
		lda stack+3, x
		sbc stack+1, x
		sta stack+3, x
		inx
		inx
		txs
}

/* Substract ints on stack */
MAC subi {
		tsx
		sec
		lda stack+6, x
		sbc stack+3, x
		sta stack+6, x
		lda stack+5, x
		sbc stack+2, x
		sta stack+5, x
		lda stack+4, x
		sbc stack+1, x
		sta stack+4, x
		inx
		inx
		inx
		txs
}

/* Multiply bytes on stack
by White Flame 20030207 */
MAC mulb {
		pla
		sta reserved1
		pla
		sta reserved2
		lda #$00
		beq enterLoop		
doAdd:
		clc
		adc reserved1	
loop:		
		asl reserved1
enterLoop:
		lsr reserved2
		bcs doAdd
		bne loop
end:	
		pha
}

/* Perform OR on top 2 bytes of stack */
MAC orb {
		pla
		sta reserved1
		pla
		ora reserved1
		pha 
}

/* Perform AND on top 2 bytes of stack */
MAC andb {
		pla
		sta reserved1
		pla
		and reserved1
		pha 
}

/* Perform XOR on top 2 bytes of stack */
MAC xorb {
		pla
		sta reserved1
		pla
		eor reserved1
		pha 
}

/* Invert true/false value on top byte of stack */
MAC notbool {
		pla
		beq skip
		pzero
		jmp end
skip:
		pone			
end:
}

MAC phfac {
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
}

MAC plfac {
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
}

MAC byte2real {
    pla
    tay
    jsr $b3a2
    phfac
}

MAC word2real {
    pla
    tax
    pla
    ldy #$00
    sec
    jsr $af87
    jsr $af7e
    phfac
}

MAC int2real {
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
	bmi !+
	sec
!:	jsr $b8d2
	phfac
}

MAC real2byte {
	plfac
	ldy #reserved0
	lda #$00
	jsr FACINX
	lda reserved0
	pha
}

MAC real2word {
	plfac
	jsr QINT
	lda $65
	pha
	lda $64
	pha
}

MAC real2int {

}

MAC _cmpr{
    
}

MAC cmprgt {
    
}
