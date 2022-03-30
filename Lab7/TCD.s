; Sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2020.

	area	tcd,code,readonly
	export	__main
__main
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010		; guess
	
	ldr	r0,=IO1DIR
	mov	r1,#0x0000000F		; might rightmost 4 bits outputs
	str	r1,[r0]				; set the outputs
	ldr	r4,=IO1PIN
	

loop
	ldr	r0,=sample
	ldr	r1,[r0]
	ldr	r0,=lut
	
next	
	ldr	r2,[r0]   ; the power of 10 we wish to subtract...
	cmp	r2,#0
	beq	loop	  ; do it all again
	mov	r3,#0
kg
	add	r3,#1
	subs r1,r2	  ; trial subtraction
	bpl	kg		  ; keep subtracting until the result goes negative
	sub	r3,#1
	add	r1,r2	  ; undo the last subtraction

;	r3 contains the binary of the next digit we wish to display
	str	r3,[r4]	  ; output to the display
	add	r0,#4	  ; got to the next entry in the LUT
	b	next
	
	

fin	b	fin

	area	tcdro,data,readonly
sample
	dcd	0x4ABCD123

lut	dcd	1000000000
	dcd	100000000
	dcd	10000000
	dcd	1000000
	dcd	100000
	dcd	10000
	dcd	1000
	dcd	100
	dcd	10
	dcd	1
	dcd	0			; sentinel value

	end