.section .text 
.globl main
main:
  # Initialize registers with immediate values  
  ADDI $31, $0, -5         
  ADDI $2, $0, 5          
  ADDI $3, $0, 5      
  ADDI $4, $0, 23
   
L1:  
  #  Test BEQ       
  BEQ $2, $3, L2    
  NOP          # No operation / SLL $0, $0, 0        
  JAL ra, L1              
L2:  
  # Test BNE   
  BNE $2, $3, L3   
L3:  
  NOP              
L4:  
  # Test BLTZ  
  BLTZ $31, L5      
  NOP              
  JAL ra, L4             
L5:  
  #  Test BGEZ   
  BGEZ $2, L6      
  NOP             
  JAL ra, L5             
L6:  
  #  Test JAL  
  JAL ra, L7                
  NOP                 
  JAL ra, L6             
L7:  
  #  Test JR   
  JR $4            
  NOP               
  JAL ra, L7                
L8:  
  NOP             # end of test cases
  li a0, 0
  call exit
exit:
    li a7, 93
    ecall
    ret
