; Sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2020.

	area	tcd,code,readonly
	export	__main
__main
	
	LDR R2,= num	
	LDR	R0,[R2]					; load 5
	LDR R2, =res
	STR R0,[R2]
	ADD R2,R2,#4
	STR	R1,[R2]
	
	LDR R2,= num1
	LDR	R0,[R2]					; load 14
	BL fact
	LDR R2, =res1
	STR R0,[R2]
	ADD R2,R2,#4
	STR	R1,[R2]
	
	LDR R2,= num2
	LDR	R0,[R2]					; load 20
	BL fact
	LDR R2, =res2
	STR R0,[R2]
	ADD R2,R2,#4
	STR	R1,[R2]
	
	LDR R2,= num3
	LDR	R0,[R2]					; load 30
	BL fact
	LDR R2, =res3
	STR R0,[R2]
	ADD R2,R2,#4
	STR	R1,[R2]
	

fin b fin

fact 
	STMFD 	SP!,{LR,R3,R5,R6}		; Push the registers onto the stack 
	
	MOV		 R3, #0x00000000		; R3 is used to set the CPSR
	CMP		 R4, #0					;
	MOVEQ	 R4,#1					; Set R4=1 if it equals 0
	CMP 	 R0,#0					; Check if R0(Input value initially) the decrasing =0 
	BEQ		 strR0R1
	
	UMULL	 R4,R5,R0,R4			; multiply 2 32bit values and store the 64 bit result in R4 and R5
	UMULL	 R1,R6,R0,R1			;
	ADD		 R1,R1,R5
	CMP	 	 R6,#0
	BEQ	   	 cZero
	MOV 	 R3, #0x20000000		; Set the C bit 
	MSR 	 CPSR_f, R3				; Set the C bit of the CPSR to 1
	MOV 	 R0, #0x00000000		; Move 0 to R0
	MOV 	 R1, #0x00000000		; Move 0 to R1
	B 		 factReturn

cZero
	SUB 	 R0,R0,#1				; (N-1)
	BL 		 fact					; fact(n-1)
	
strR0R1
	CMP 	 R4,#0					; R4!=0 ( RETURN R1 AND R0)
	BEQ		 factReturn
	MOV 	 R0,R1					; Move MSB into R0
	MOV 	 R1,R4					; Move LSB intp R1
	MOV		 R4,#0					; R4 set to zero to ensure the subroutine is well behaved 
	B		 factReturn

factReturn 	
	MSR		CPSR_f, R3				; Set the C bit of the CPSR
	LDMFD 	SP!,{LR,R3,R5,R6}		; Restore reh stored refisret values
	BX 		LR
	
	area	stuffnum,data,READONLY
num		dcd	5
num1	dcd	14
num2	dcd	20
num3	dcd	30
	
	area	stuff,data,readwrite
res 	space	8
res1 	space	8
res2 	space	8
res3 	space	8	
		

	end