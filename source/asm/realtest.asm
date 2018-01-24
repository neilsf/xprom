#import "nucleus.asm"

.pc = $801
:BasicUpstart(2061)

pint #-5
int2real
plfac
jsr $aabc
pint #7130000
int2real
plfac
jsr $aabc

rts