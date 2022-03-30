; Program makes the LED's in P1.23--P1.16 light up in correspondance to a number, which is controlled by the
; buttons P1.27--P1.24 
;	-P1.27: Shift right by 1 bit
;	-P1.26:	Shift left by 1 bit
;	-P1.25:	Subtract 1
;	-P1.24:	Add 1
; (c) Vitali Borsak, 2021.

	area	tcd,code,readonly
	export	__main
__main
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010

	ldr	r0,=IO1DIR
	mov	r4,#0x00ff0000	; select P1.23--P1.16
	str	r4,[r0]		; make them outputs
	ldr	r2,=IO1CLR
	str	r4,[r2]		; set them to turn the LEDs off
	ldr	r1,=IO1SET
	ldr r3,=IO1PIN
	
whloop1
	ldr r4,[r3]			; infinite loop that checks if any of the buttons were pressed
	mov r5,#0x0f000000
	and r4,r5
	
	cmp	r4,#0x0f000000
	beq	whloop1
		
	cmp r4,#0x0e000000	; if button 24 is pressed, call the add subroutine
	bne skip1			; make sure that the correct corresponding subroutine is called
	bl	add1
	b	whloop2			; branch to whloop2 after subroutine is called
	
skip1	
	cmp r4,#0x0d000000	; if button 25 is pressed, call the subtract subroutine
	bne skip2			; make sure that the correct corresponding subroutine is called
	bl	sub1
	b	whloop2			; branch to whloop2 after subroutine is called
	
skip2	
	cmp r4,#0x0b000000	; if button 26 is pressed, call the shift left subroutine
	bne skip3			; make sure that the correct corresponding subroutine is called
	bl	shiftLeft1
	b	whloop2			; branch to whloop2 after subroutine is called
	
skip3	
	cmp	r4,#0x07000000	; if button 27 is pressed, call the shift right subroutine
	bne	skip4 			; make sure that the correct corresponding subroutine is called
	bl	shiftRight1
	b	whloop2			; branch to whloop2 after subroutine is called

skip4
whloop2
	ldr r4,[r3]			; keep going in the loop until none of the buttons are pressed
	mov r5,#0x0f000000
	and r4,r5
	
	cmp r4,#0x0f000000
	bne	whloop2
	b	whloop1
	
stop b stop	
	
add1
	stmfd	sp!,{r4-r5,lr}	; store the information in the registers that are to be used on the stack
	
	ldr r4,[r3]			; get all the bits in IO1PIN
	mov r5,#0x00ff0000	; mask to get the relevant bits
	and	r4,r5			; remove unwanted bits
	
	mov r5,#0x00010000	; mask to add 1 in the relevant location
	add	r4,r5			; increment by 1	
	mov	r5,#0x00ff0000
	and r4,r5			; remove unecessary bits in case of an overflow
	
	str r4,[r1]			; store values back into IO1SET
	eor	r4,r5			; clear the empty bits
	str	r4,[r2]			; store the cleared bits into IO1CLR
	ldmfd	sp!,{r4-r5,pc}	; pop the information on the stack back into it's respective registers
	

sub1
	stmfd	sp!,{r4-r5,lr}	; store the information in the registers that are to be used on the stack
	
	ldr r4,[r3]			; get all the bits in IO1PIN
	mov r5,#0x00ff0000	; mask to get the relevant bits
	and	r4,r5			; remove unwanted bits
	
	mov r5,#0x00010000	; mask to add 1 in the relevant location
	sub	r4,r5			; decrement by 1
	mov	r5,#0x00ff0000	
	and r4,r5			; remove unecessary bits in case of an overflow
	
	str r4,[r1]			; store values back into IO1SET
	eor	r4,r5			; clear the empty bits	
	str	r4,[r2]			; store the cleared bits into IO1CLR

	ldmfd	sp!,{r4-r5,pc}	; pop the information on the stack back into it's respective registers
	

shiftLeft1
	stmfd	sp!,{r4-r5,lr}	; store the information in the registers that are to be used on the stack
	
	ldr r4,[r3]			; get all the bits in IO1PIN
	mov r5,#0x00ff0000	; mask to get the relevant bits
	and	r4,r5			; remove unwanted bits
	
	mov r4,r4,lsl #1	; shift left by 1	
	and r4,r5			; remove unecessary bits in case of an overflow	
	
	str r4,[r1]			; store values back into IO1SET
	eor	r4,r5			; clear the empty bits
	str	r4,[r2]			; store the cleared bits into IO1CLR
	ldmfd	sp!,{r4-r5,pc}	; pop the information on the stack back into it's respective registers


shiftRight1
	stmfd	sp!,{r4-r5,lr}	; store the information in the registers that are to be used on the stack
	
	ldr r4,[r3]			; get all the bits in IO1PIN
	mov r5,#0x00ff0000	; mask to get the relevant bits
	and	r4,r5			; remove unwanted bits
	
	mov r4,r4,lsr #1	; shift right by 1	
	and r4,r5			; remove unecessary bits in case of an overflow	
	
	str r4,[r1]			; store values back into IO1SET
	eor	r4,r5			; clear the empty bits
	str	r4,[r2]			; store the cleared bits into IO1CLR
	ldmfd	sp!,{r4-r5,pc}	; pop the information on the stack back into it's respective registers
	
	end