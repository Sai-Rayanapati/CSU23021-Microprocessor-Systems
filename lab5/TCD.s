	area	tcd,code,readonly
	export	__main
__main
	
	
	ldr	r10,=MatB			; for manipulation in the loop
	ldr	r2,=MatC
	
	mov	r9,#2				; for 2 columns
	
bd2	mov	r1,r10				; point to the start of the relevant column
	ldr	r0,=MatA			; here it will be reset each time around the loop
	mov	r3,#0				; for accumulating partial results
	mov	r8,#3				; for 3 rows
bd1	ldr	r6,[r0],#4			; and point to the next element in the row
	ldr	r7,[r1],#4*2		; and point to the next element in the column
	umull	r5,r4,r6,r7		; we're assuming result fits in r5
	add	r3,r5				; add this in
	subs	r8,#1
	bne	bd1
	str	r3,[r2],#4			; save partial result
	add	r10,#4				; point to the start of the next column
	subs	r9,#1			; go to the next column
	bne	bd2					; loop until all columns are done
	; but but, r0 and r1 are not pointing to the correct items.

fin	b	fin

	area	tcddata,data,readonly
MatA	dcd	1,4,6	
MatB	dcd	2,3
		dcd	5,8
		dcd	7,9

	area	tcdresult,data,readwrite
MatC	space	2 * 4		; space for two four-byte elements
	end