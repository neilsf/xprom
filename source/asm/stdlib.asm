.var KERNAL_PRINT = $AB1E
.var KERNAL_PRINTCHR = $EA13

.pseudocommand stdlib_putstr {
    pla
    pla
    tay
    jsr KERNAL_PRINT
}

.pseudocommand stdlib_putchar {
    pla
    jsr KERNAL_PRINTCHR
}