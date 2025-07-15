.section .data 
myArray:  
    .word 1, 4, 5, 7, 9, 12, 15, 17, 20, 21, 30 
arraySize: 
    .word 11 
 
.section .text 
.globl main
main:
#Initailiztion 
addi $1, $0, 0x0  
addi $2, $0, 0xB  
addi $3, $0, 0x7  
 
loop: 
    slt $7, $2, $1 
    bne $0, $7, notFound         
    add $4, $2, $1                 
    srli $10, $4, 1                   

    slli $10, $10, 2 # For byte addressable memory 
    lw  $6, 0x0($10)                   
     
    srli $10, $10, 2 # For byte addressable memory 
     
    beq $3, $6, found               
    slt $6, $6, $3         
    beq $6, $0, leftHalf         
    j   rightHalf                    
 
leftHalf: 
    addi $2, $10, 0xFFFF # "FFFF=-1" # the instruction was: add / after: addi because you are dealing with immediate, it is a wrong from the mentors
    j   loop                     
 
rightHalf: 
    addi $1, $10, 0x1             
    j    loop                 
 
found:  
    add $8, $0, $10              
    j finish 
  
notFound:  
    addi $8, $0, 0xFFFF          
    j finish 
 
finish: 
    NOP 
    li a0, 0
    call exit
exit:
    li a7, 93
    ecall
    ret
