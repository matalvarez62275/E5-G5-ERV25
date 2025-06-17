.global _boot
.text

_boot:               
   addi a0, x0, 100  
   addi a1, x0, 200  
   addi t1, x0, 22
   addi t2, x0, 33
   call add_int
   addi t1, x0, 22
   addi t2, x0, 33  
   addi t1, x0, 22
   addi t2, x0, 33 
   nop
   nop

add_int:
   add  a0, a0, a1 
   ret