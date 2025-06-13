.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    /* Test LI ADD ADDI and SUB */
    
    li  t0, 170         /* t0 = 170 0xAA */
    li  t0, 171         /* t0 = 171 0xAB */
    li  t0, 172         /* t0 = 172 0xAC */
    li  t0, 173         /* t0 = 173 0xAD */
    li  t0, 174         /* t0 = 174 0xAE */
    li  t0, 175         /* t0 = 175 0xAF */

    addi t0 , x0,   1001  /* t0  = 1001 0x3E9 */
    addi t1 , t0,   2000  /* t1  = 3001 0xBB9 */
    addi t2 , t1,  -1000  /* t2  = 2001 0x7D1 */

    add t2, t0, t0      /* t2 =  170 + 170  = 340  0x154 */ 
    add t3, t0, t1      /* t3 =  170 + 1000 = 1170 0x492 */
    add t3, t3, t2      /* t3 = 48 + 10 = 58  ; t3 is a source and the destination */

    sub t3, t2, t0      /* t3 = 2001 - 1001 = 1000 */

    /* la x6, variable */
    /* addi x6, x6, 4 */

.data
variable:
	.word 0xdeadbeef