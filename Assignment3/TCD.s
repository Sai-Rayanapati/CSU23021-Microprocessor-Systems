; Time since start of program dispaly using interut handlers
; (c) Vitali Borsak, 2021.

	area	tcd,code,readonly
	export	__main
__main

; Definitions  -- references to 'UM' are to the User Manual.

; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF

; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58
	
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010
	
T1TCR	EQU	0xE0008004
T1MR0	EQU	0xE0008018
T1MCR	EQU	0xE0008014

; initialisation code

; Initialise the VIC
	ldr	r0,=VIC			; looking at you, VIC!

	ldr	r1,=irqhan
	str	r1,[r0,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r1,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r1,[r0,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r1,#Timer0Mask
	str	r1,[r0,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r1,#0
	str	r1,[r0,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r0,=T0			; looking at you, Timer 0!

	mov	r1,#TimerCommandReset
	str	r1,[r0,#TCR]

	mov	r1,#TimerResetAllInterrupts
	str	r1,[r0,#IR]

	ldr	r1,=(14745600)- 1	; used 14745600 ticks as recommended in lectures, however, varies depending on hardware, therefore was way too slow for me
					
	str	r1,[r0,#MR0]

	mov	r1,#TimerModeResetAndInterrupt
	str	r1,[r0,#MCR]

	mov	r1,#TimerCommandRun
	str	r1,[r0,#TCR]

;from here, initialisation is finished, so it should be the main body of the main program
	
; Initialising the GPIO1
	ldr	r0,=IO1DIR
	mov	r4,#0xffffffff	; select P1.31--P1.0
	str	r4,[r0]		; make them outputs
	ldr	r2,=IO1CLR
	str	r4,[r2]		; set them to turn the LEDs off
	ldr	r1,=IO1SET
	ldr r3,=IO1PIN
	ldr r4,=0x00f00f00	; forced to used ldr here as mov was giving an error
	str r4,[r1]		; set the divifing bits to be displayed
	
while1
	ldr r4,=t	; load in memory address for t
	ldr r5,[r4]	; read in the current time (seconds)
	cmp	r5,#60	; check that the current amount of seconds elapsed is not equal to 60
	blo	skip1	
	bl	minutePassed	; if 60 seconds have passed, call minutePassed subroutine
	b	while1

skip1
	bl divide	; divide the time elapsed
	lsl r6,#4	; move the multiple of 10 of the elapsed time into bits P1.7 - P1.4
	add	r5,r6	; add the multiple of 10 of the elapsed time with the single digit
	ldr r6,[r3]	; load in the current status of the IO1PIN
	and	r6,#0xffffff00	; remove the previous bits in the seconds region, while keeping the minutes, hours and dividing bits still there
	add	r5,r6	; add the new seconds to the current time
	str	r5,[r1]	; set the bits of the new time
	ldr	r6,=0xffffffff	
	eor	r5,r6	; get the 0'd out bits
	str	r5,[r2]	; clear the bits that are meant to be 0's
	b	while1	; loop back around

fin b fin
	
divide	
	mov r6,#0	; result
	mov	r7,#10	; divisor
	
divideLoop
	cmp	r5,#10	; check that the running total is still divisible by 10
	bge	notEnd
	b	end		; if it can#t be divided further, end the division

notEnd
	sub	r5,r7	; subtract 10 from the running total
	add	r6,#1	; add one to the result
	b	divideLoop
	
end	
	bx lr	; exit subroutine
	
	
minutePassed
	stmfd	sp!,{r5-r7,lr}	; the lr will be restored to the pc
	
	ldr r5,[r4,#4]	; read in the current time (minutes)
	add r5,#1	; increment the minutes by 1
	str r5,[r4,#4]	; store back the minutes into memory
	cmp	r5,#60	; check that the amount of minutes elapsed is not 60
	blo	skip2
	bl	hourPassed	; if 60 minutes have passed, call hourPassed subroutine
	b	while1

skip2
	bl divide	; divide the time elapsed
	lsl r6,#4	; move the multiple of 10 of the elapsed time into bits P1.7 - P1.4
	add	r5,r6	; add the multiple of 10 of the elapsed time with the single digit
	ldr r6,[r3]	; load in the current status of the IO1PIN
	ldr r7,=0xfff00f00		; remove the previous bits in the seconds and minutes region, while keeping the hours and dividing bits still there
	and	r6,r7
	lsl r5,#12	; shift the minutes into the correct P1.19 - P1.12
	add	r5,r6	; add the new minutes to the current time
	str	r5,[r1]	; set the bits of the new time
	ldr	r6,=0xffffffff
	eor	r5,r6	; get the 0'd out bits
	str	r5,[r2]	; clear the bits that are meant to be 0's
	
	mov r5,#0
	str	r5,[r4]	; clear the seconds in memory
	ldmfd	sp!,{r5-r7,pc}^	; return from interrupt, restoring pc from lr
	
	
hourPassed
	stmfd	sp!,{r5-r7,lr}	; the lr will be restored to the pc
	
	ldr r5,[r4,#8]	; read in the current time (hours)
	add r5,#1	; increment the minutes by 1
	str r5,[r4,#8]	; store back the minutes into memory
	cmp	r5,#24	; check if 24 hours passed
	blo	skip3
	b	fin

skip3
	bl divide	; divide the time elapsed
	lsl r6,#4	; move the multiple of 10 of the elapsed time into bits P1.7 - P1.4
	add	r5,r6	; add the multiple of 10 of the elapsed time with the single digit
	ldr r6,[r3]	; load in the current status of the IO1PIN
	ldr r7,=0x00f00f00		; remove all bits except the dividing bits
	and	r6,r7
	lsl r5,#24	; shift the minutes into the correct P1.31 - P1.24
	add	r5,r6	; add the new hours to the current time
	str	r5,[r1]	; set the bits of the new time
	ldr	r6,=0xffffffff
	eor	r5,r6	; get the 0'd out bits
	str	r5,[r2]	; clear the bits that are meant to be 0's
	
	mov r5,#0
	str	r5,[r4]	; clear the seconds in memory
	str r5,[r4,#4]	; clear the minutes in memory

	mov r5,#0
	str	r5,[r4]	; clear the seconds in memory
	str r5,[r4,#4]	; clear the minutes in memory	
		
	ldmfd	sp!,{r5-r7,pc}^	; return from interrupt, restoring pc from lr
	
	
	AREA	InterruptStuff, CODE, READONLY
irqhan	sub	lr,lr,#4
	stmfd	sp!,{r0-r1,lr}	; the lr will be restored to the pc

;this is the body of the interrupt handler

;here you'd put the unique part of your interrupt handler
	
	ldr r0,=t	; load in memory address for t
	ldr r1,[r0]	; read in the current time (seconds)
	add	r1,#0x1	; increment it by 1
	str r1,[r0]	; store back the result into memory (seconds)

;all the other stuff is "housekeeping" to save registers and acknowledge interrupts

;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r1,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR
				
				
	AREA	StoringTime, CODE, READWRITE		
t	space	4*3
				
	END
