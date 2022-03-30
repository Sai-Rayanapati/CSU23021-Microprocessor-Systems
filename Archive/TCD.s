; 64-bit Factorial Calculator Pogram
; (c) Vitali Borsak, 2021.

	area	progmain,code,readonly
	export	__main
__main

	ldr r2,=testData
	ldr r3,=result
	mov r4,#4
	
while1						; loop to go through all 4 input variables
	cmp r4,#0
	beq	stop
	ldr r0,[r2],#4
	bl	fact
	
	str	r0,[r3],#4			; store the answer's least-significant bits into memory, offset by 4
	str	r1,[r3],#4			; store the answer's most-significant bits into memory, offset by 4
	sub r4,#1
	b	while1
		
stop b stop
	
fact
	stmfd	sp!,{r2-r4,lr}	; store the information in the registers that are to be used on the stack
	
	cmp r0,#0				; call fact recursivley, subtracting 1 from r0 each time and storing the values in r1 and r2 until we hit r0=0
	beq foundLast
	mov r2,r0
	mov r1,r0
	sub	r0,#1
	bl	fact
	
	orr	r3,r0,r1			; check if the two registers are equal to zero, if so, skip multiplication
	cmp	r3,#0
	beq	skipMul
	umull	r1,r3,r2,r1		; multiply what's in the answer's least-significant register by r2 (which was r0 but saved for future use when calling the function recursively)
							; store answer back into r1 and the carry (if any) into r3
	umull	r0,r4,r2,r0		; multiply what's in the answer's most-significant register by r2 (which was r0 but saved for future use when calling the function recursively)
							; store andwer back into r0 and the carry (if any) into r4
	add	r0,r0,r3			; add the carry (r3) from the answer's least-significant register's multiplication to the answer's most-significant register
	
	subs	r4,#0			; check if the carry of the multiplication of the answer's most-significant register produced a carry, if so set the carry flag
	beq	foundLast	
skipMul	
	mov	r0,#0
	mov r1,#0
	mov	r4,#0x20000000
	msr	cpsr_f,r4
	b carry
	
foundLast
	mov	r4,#0x00000000		; if there was no carry of the multiplication of the answer's most-significant register then the carry flag is set to 0
	msr	cpsr_f,r4
carry	
	ldmfd	sp!,{r2-r4,pc}	; pop the information on the stack back into it's respective registers

	area	progdata,data,readonly
testData	dcd	5,14,20,30
	
	area	progstoredata,data,readwrite	
result	space	4*8

	end