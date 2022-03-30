irqhan    sub    lr,lr,#4
    stmfd    sp!,{r0-r2,lr}    ; the lr will be restored to the pc

    ldr    r0,=T0
    mov    r1,#TimerResetTimer0Interrupt
    str    r1,[r0,#IR]           ; remove MR0 interrupt request from timer

    ldr    r0,=VIC
    mov    r1,#0
    str    r1,[r0,#VectAddr]    ; reset VIC

    ldr    ro, = #40000004          ; check it again
    ldr    r1, [r0]
    ldr    r2, =16234870           ; nano seconds
    add    r1,r2
    
    sub    r1, #1000000000
    cmp    r1,#0
    blo    notSecond
    str    r1, [r0]
    ldr    r0,=seconds
    ldr    r1,[r0]
    add    r1,#1
    str    r1, [r0]
    b      end
notSecond
    add    r1, #1000000000
    str    r1, [r0]
end

    ldmfd    sp!,{r0-r2 ,pc}^    ; return from interrupt, restoring pc from lr
                ; and also restoring the CPSR


__main

; timer set up
; VIC set up
    
    ldr    r3,=1               ; counter
loop
    ; Initialise Timer 0
    ldr    r0,=T0            ; looking at you, Timer 0!

    mov    r1,#TimerCommandReset
    str    r1,[r0,#TCR]

    mov    r1,#TimerResetAllInterrupts
    str    r1,[r0,#IR]
    
    cmp    r3,#1
    bne    alternate
    ldr    r1,=501350          ;34 milliseconds
    str    r1,[r0,#MR0]
    ldr    r3,=2
    b      cont

alternate
    cmp    r3,#2
    bne    cont
    ldr    r1,=973209           ; 66 milliseconds
    str    r1,[r0,#MR0]
    ldr    r3,=1

cont
    mov    r1,#TimerModeResetAndInterrupt
    str    r1,[r0,#MCR]

    mov    r1,#TimerCommandRun
    str    r1,[r0,#TCR]
    b      loop

f   b      f

irqhan    sub    lr,lr,#4
    stmfd    sp!,{r0-r2,lr}    ; the lr will be restored to the pc

    ldr    r0,=T0
    mov    r1,#TimerResetTimer0Interrupt
    str    r1,[r0,#IR]           ; remove MR0 interrupt request from timer

    ldr    r0,=VIC
    mov    r1,#0
    str    r1,[r0,#VectAddr]    ; reset VIC

    ldr    r0,=0xE0003000
    ldr    r1,[r0]
        
    cmp    r3,#1                ; if it is HIGHTIME
    bne    next
    ldr    r2,=1
    str    r2,[r0]

next
    cmp    r3,#2                ; if it is LOWTIME
    bne    last
    ldr    r2,=0
    str    r2,[r0]

last

    ldmfd    sp!,{r0-r2 ,pc}^    ; return from interrupt, restoring pc from lr
                ; and also restoring the CPSR

irqhan    sub    lr,lr,#4
    stmfd    sp!,{r0-r2,lr}    ; the lr will be restored to the pc

    ldr    r0,=T0
    mov    r1,#TimerResetTimer0Interrupt
    str    r1,[r0,#IR]           ; remove MR0 interrupt request from timer

    ldr    r0,=VIC
    mov    r1,#0
    str    r1,[r0,#VectAddr]    ; reset VIC

    ldr    r0,=0xE0003000
    ldr    r1,[r0]
        
    if it is HIGHTIME

    ldr    r2,=1
    str    r2,[r0]

    if it is LOWTIME

    ldr    r2,=0
    str    r2,[r0]


    ldmfd    sp!,{r0-r2 ,pc}^    ; return from interrupt, restoring pc from lr
                ; and also restoring the CPSR
