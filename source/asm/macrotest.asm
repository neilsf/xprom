#import "nucleus.asm"

.pc = $801
:BasicUpstart(2061)

pint #-3200
pint #45
cmpigte
pla
sta $c040

pint #89000
pint #89000
cmpigte
pla
sta $c041

pint #-300
pint #-400
cmpigte
pla
sta $c042

rts