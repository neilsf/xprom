/* FLOATING-POINT LIBRARY */

.var reserved0	= $fb
.var reserved1	= $fc
.var reserved2	= $fd
.var reserved3	= $fe
.var reserved4	= $ff
.var GIVAYF = $b391

/* Converts 24-bit signed integer 
to floating-point format into FAC. Expects
location lowbyte in Y, highbyte in A */

twos_exponents:
	

INT2REAL:
	sty reserved0
	sta reserved1
	ldy #$00
	lda (reserved0),y
	tay
	lda #$00
	jsr GIVAYF
	
	ldy #$02
	lda (reserved0),y
	bmi int2real_minus
	
int2real_minus:
	
	
NEGOP:
	lda $61
	beq !+
	lda $66
	eor #$ff
	sta $66
!: rts
	
	