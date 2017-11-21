RESERVED1	= $fc
RESERVED2	= $fd
RESERVED3	= $fe
RESERVED4	= $ff
STACK = $0100

PZERO		.segment
			LDA #$00
			PHA
			.endm

PONE		.segment
			LDA #$01
			PHA
			.endm

PBYTE		.segment
			LDA #\1
			PHA
			.endm

PBYTEASW	.segment
			LDA #\1
			PHA
			LDA #$00
			PHA
			.endm

PWORD		.segment
			LDA #<\1
			PHA
			LDA #>\1
			PHA
			.endm

PVARB		.segment		;Push byte variable to stack
			LDA @1
			PHA
			.endm

PVARW		.segment		;Push word variable to stack
			LDA @1
			PHA
			LDA @1+1
			PHA
			.endm

PVARI		.segment		;Push int variable to stack
			LDA @1
			PHA
			LDA @1+1
			PHA
			LDA @1+2
			PHA
			.endm

PADDR	  	.segment		;Push address of target variable
			LDA #<@1
			PHA
			LDA #>@1
			PHA
			.endm

PLB2VAR		.segment		;Pull byte to variable
			PLA
			STA @1
			.endm

PLW2VAR		.segment		;Pull word to variable
			PLA
			STA @1+1
			PLA
			STA @1
			.endm

PLI2VAR		.segment		;Pull int to variable
			PLA
			STA @1+2
			PLA
			STA @1+1
			PLA
			STA @1
			.endm

CMPBLT		.macro		;Compare two bytes on stack for less than
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BCC true
			#PZERO
			JMP end_CMPBLT
	true	#PONE
end_CMPBLT  .endm

CMPBGTE		.macro		;Compare two bytes on stack for greater than or equal
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BCS true
			#PZERO
			JMP end_CMPBGTE
	true	#PONE
end_CMPBGTE .endm

CMPBEQ		.macro		;Compare two bytes on stack for equality
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BEQ true
			#PZERO
			JMP end_CMPBEQ
	true	#PONE
end_CMPBEQ 	.endm

CMPBNEQ		.macro		;Compare two bytes on stack for inequality
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BNE true
			#PZERO
			JMP end_CMPBNEQ
	true	#PONE
end_CMPBNEQ .endm

CMPBGT		.macro		;Compare two bytes on stack for greater than
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BCS false
			#PONE
			JMP end_CMPBGT
	false	#PZERO
end_CMPBGT	.endm


CMPWEQ		.macro		;Compare two words on stack for equality
			PLA
			STA RESERVED1
			PLA
			STA RESERVED2
			PLA
			CMP RESERVED1
			BNE false
			PLA
			CMP RESERVED2
			BNE false+1
			#PONE
			JMP *+7
	false	PLA
			#PZERO
end_CMPWEQ  .endm

CMPWNEQ		.macro		;Compare two words on stack for inequality
			PLA
			STA RESERVED1
			PLA
			STA RESERVED2
			PLA
			CMP RESERVED1
			BNE true
			PLA
			CMP RESERVED2
			BNE true+1
			#PZERO
			JMP *+7
	true	PLA
			#PONE
end_CMPWNEQ	.endm

CMPWLT		.macro		;Compare two words on stack for less than (Higher on stack < Lower on stack)
			TSX
			LDA STACK+4, x
			CMP STACK+2, x
			LDA STACK+3, x
			SBC STACK+1, x
			BCS false			
			INX
			INX
			INX
			INX
			TXS
			#PONE
			JMP end_CMPWLT
	false	INX
			INX
			INX
			INX
			TXS
			#PZERO
end_CMPWLT  .endm

CMPWGTE		.macro		;Compare two words on stack for greater than or equal (H >= L)
			TSX
			LDA STACK+4, x
			CMP STACK+2, x
			LDA STACK+3, x
			SBC STACK+1, x
			BCS true	
			INX
			INX
			INX
			INX
			TXS
			#PZERO
			JMP *+11
	true	INX
			INX
			INX
			INX
			TXS
			#PONE
end_CMPWGTE .endm

CMPWGT		.macro		;Compare two words on stack for greater than (H > L)
			TSX
			LDA STACK+2, x
			CMP STACK+4, x
			LDA STACK+1, x
			SBC STACK+3, x
			BCC true	
			INX
			INX
			INX
			INX
			TXS
			#PZERO
			JMP *+11
	true	INX
			INX
			INX
			INX
			TXS
			#PONE
end_CMPWGT .endm

CMPIEQ		.macro		;Compare two ints on stack for equality
			TSX
			LDA STACK+6, x
			CMP STACK+3, x
			BNE false
			LDA STACK+5, x
			CMP STACK+2, x
			BNE false
			LDA STACK+4, x
			CMP STACK+1, x
			BNE false
			#PONE
			JMP doinx
	false	#PZERO
	doinx	.repeat 6, $e8 ; 6 times INX	
			TXS
			.endm


CMPINEQ		.macro		;Compare two ints on stack for inequality
			TSX
			LDA STACK+6, x
			CMP STACK+3, x
			BEQ false
			LDA STACK+5, x
			CMP STACK+2, x
			BEQ false
			LDA STACK+4, x
			CMP STACK+1, x
			BEQ false
			#PONE
			JMP doinx
	false	#PZERO
	doinx	.repeat 6, $e8 ; 6 times INX	
			TXS
			.endm

