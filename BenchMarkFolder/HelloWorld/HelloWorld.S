.section .text
.globl main
main:
    LI a0, 1
    LA a1, StringLits0
    LI a2, 14
    call write
    LI s0, 0
    mv a0, s0
    call exit
exit:
    li a7, 93
    ecall
    ret
write:
    li a7, 64
    ecall
    ret
.section .data
StringLits0:
    .string "Hello, World!\n"
