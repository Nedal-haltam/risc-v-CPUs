

.section .text 
.globl main
main:

ADDI $1 $zero 3
ADDI $1 $1 2
JR $1
ADDI $2 $0 123
ADDI $3 $0 123
ADDI $4 $0 123
li a0, 0
call exit
exit:
    li a7, 93
    ecall
    ret
