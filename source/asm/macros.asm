RESERVED1	= $fe
RESERVED2	= $ff

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
			JMP end
	true	#PONE
	end  	.endm

CMPBGTE		.macro		;Compare two bytes on stack for greqter than or equal
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BCS true
			#PZERO
			JMP end
	true	#PONE
	end  	.endm

CMPBEQ		.macro		;Compare two bytes on stack for equality
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BEQ true
			#PZERO
			JMP end
	true	#PONE
	end  	.endm

CMPBNEQ		.macro		;Compare two bytes on stack for inequality
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BNE true
			#PZERO
			JMP end
	true	#PONE
	end  	.endm

CMPBGT		.macro		;Compare two bytes on stack for greater than
			PLA
			STA RESERVED1
			PLA
			CMP RESERVED1
			BCS false
			#PONE
			JMP end
	false	#PZERO
	end  	.endm


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
			BNE false
			#PONE
			JMP end
	false	#PZERO
	end  	.endm

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
			BNE true
			#PZERO
			JMP end
	true	#PONE
	end  	.endm

