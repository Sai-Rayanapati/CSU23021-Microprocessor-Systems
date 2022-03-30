; Lab 3 Tentative Solution
	area	tcd,code,readonly
	export	__main
__main
	ldr r0,=nums
	bl	arradd
	bcs	uhoh		; branch if there was a problem
; here, the result should be in r1 and should be right
	ldr	r0,=sum
	str	r1,[r0]
uhoh
fin	b	fin

arradd
	stmfd sp!,{r0,r2,r3} ; we modify these registers, so save them in advance
	ldr	r1,[r0]	; get the count into r1

	mov	r3,#0
	ldr	r4,=0x10000000 ; this is where the C bit is in the CPSR
lab1
	add	r0,#4
	ldr	r2,[r0]	; point to the "next" number
	adds	r3,r2	; add it to the running total (in r3)
	bvs	lab2		; branch if arithmetic overflow
	subs r1,#1	; remember to set (s) the condition flags according to the outcome
	bne	lab1
	mov	r1,r3	; move the result into place
	mov	r4,#0	; indicate we do not want to turn on the C bit
lab2
	; here, set or clear the C bit depending on r4
	mrs	r0,cpsr
	ldr	r2,=0xEFFFFFFF
	and	r0,r2	;  turn off the equivalent of the C bit in R0
	orr	r0,r4	; turn on the equivalent of the C bit in R0 if R4 is not cleared
	msr cpsr_f,r0 ;put it into the C bit (f -> condition Flags, I think!)
	
	ldmfd sp!,{r0,r2,r3} ; restore the original contents of the registers
	bx	lr		; return program execution to the caller

	area	tcdrodata,data,readonly
nums dcd	5
	dcd	6
	dcd	11
	dcd	-25
	dcd	47
	dcd	0x45678
		
	area	tcddata,data,readwrite
sum	space	4

	end