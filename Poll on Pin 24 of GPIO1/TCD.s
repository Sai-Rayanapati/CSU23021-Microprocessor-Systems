; Sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2020.

	area	tcd,code,readonly
	export	__main
__main

IO1PIN	EQU	0xE0028010

	ldr	r0,=IO1PIN		; point to the pin register of GPIO1
	mov	r2,#0x01000000	; mask for bit 24

ploop
	ldr	r1,[r0]			; read all the pin values
	and	r1,r2			; set all bits to zero except for bit 24
	cmp	r1,r2			; is bit 24 set?
	beq	ploop			; branch if so
	nop
	
	
wloop
	b	wloop
	end
