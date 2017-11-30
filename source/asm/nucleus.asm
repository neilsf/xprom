.var reserved1	= $fc
.var reserved2	= $fd
.var reserved3	= $fe
.var reserved4	= $ff
.var stack = $0100

/* Push a zero on the stack */
.pseudocommand pzero {
	lda #$00
	pha
}

/* Push a one on the stack */
.pseudocommand pone {
	lda #$01
	pha
}

/* Push one byte on the stack */
.pseudocommand pbyte arg {
	lda arg
	pha
}

/* Push one byte as a word on the stack */
.pseudocommand pbyteasw	arg {
	lda arg
	pha
	lda #$00
	pha
}

/* Push one word on the stack */ 
.pseudocommand pword arg {
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
}

/* Push integer on stack */
.pseudocommand pint arg {
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

/* Push real var on stack *
.pseudocommand prvar arg{
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
.pseudocommand paddr arg {
	lda #<arg.getValue()
	pha
	lda #>arg.getValue()
	pha
}

/* Pull byte to variable */
.pseudocommand plb2var arg {
	pla
	sta arg.getValue()
}

/* Pull word to variable */
.pseudocommand plw2var arg {
	pla
	sta arg.getValue()+1
	pla
	sta arg.getValue()
}

/* Pull int to variable */
.pseudocommand pli2var arg {
	pla
	sta arg.getValue()+2
	pla
	sta arg.getValue()+1
	pla
	sta arg.getValue()
}

/* Compare two bytes on stack for less than */
.pseudocommand cmpblt {
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
.pseudocommand cmpbgte {
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
.pseudocommand cmpbeq {
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
.pseudocommand cmpbneq {
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
.pseudocommand cmpbgt {
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
.pseudocommand cmpweq {
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
.pseudocommand cmpwneq {
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
.pseudocommand cmpwlt {
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
.pseudocommand cmpwgte {
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
.pseudocommand cmpwgt {
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
.pseudocommand cmpieq {		
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
.pseudocommand cmpineq {
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
.pseudocommand cmpilt {
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
.pseudocommand cmpigte {
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
.pseudocommand cmpilte {
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
.pseudocommand cmpigt {
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
.pseudocommand addb {
		pla
		tsx
		clc
		adc stack+1,x
		sta stack+1,x
}

/* Add words on stack */
.pseudocommand addw {
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
.pseudocommand addi {
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
.pseudocommand subb {
		tsx
		lda stack+2,x
		sec
		sbc stack+1,x
		sta stack+2,x
		pla
}

/* Substract words on stack */
.pseudocommand subw {
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
.pseudocommand subi {
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
.pseudocommand mulb {
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
.pseudocommand orb {
		pla
		sta reserved1
		pla
		ora reserved1
		pha 
}

/* Perform AND on top 2 bytes of stack */
.pseudocommand andb {
		pla
		sta reserved1
		pla
		and reserved1
		pha 
}

/* Perform XOR on top 2 bytes of stack */
.pseudocommand xorb {
		pla
		sta reserved1
		pla
		eor reserved1
		pha 
}

/* Invert true/false value on top byte of stack */
.pseudocommand notbool {
		pla
		beq skip
		pzero
		jmp end
skip:
		pone			
end:
}
