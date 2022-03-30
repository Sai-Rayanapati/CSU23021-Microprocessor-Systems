ploop
    stmfd  sp!,{r1,r2,r3}
    ldr    r0,= 0xFE808018
    ldr    r1,[r0]            ; read all the pin values

    ldr    r0,=7               ; if bit 7 not set return 7
    ldr    r2,=0x80            ; mask for bit 7
    and    r1,r2            ; set all bits to zero except for bit 7
    cmp    r1,r2            ; is bit 7 not set?
    bne    wait            ; branch if so
    ldr    r0,= 0xFE808018
    ldr    r1,[r0]            ; read all the pin values

    ldr    r0,=6            ;if bit 6 set return 6
    ldr    r2,=0x40    ; mask for bit 6
    and    r1,r2            ; set all bits to zero except for bit 6
    cmp    r1,r2            ; is bit 6 set?
    beq    ploop            ; branch if so

wait
ldr    r3,=2500         ; 2500 * 2 instructions = 5000 micro seconds
dloop
    subs   r3,r3,#1
    bne    dloop

    ldmfd   sp!,{r1,r2,r3}


ploop
    stmfd  sp!,{r1-r7}
    ldr    r0,= 0xFE808018
    ldr    r1,[r0]            ; read all the pin values
    ldr    r4,=0              ; counter
    
    // for bit 7
    ldr    r0,=7               ; if bit 7 not set return 7
    ldr    r2,=0x80            ; mask for bit 7
    and    r1,r2            ; set all bits to zero except for bit 7
    cmp    r1,r2            ; is bit 7 set?
    beq    bit6            ; branch if so

    add    r4,#1            ; increment counter
    ldr    r3,r0

bit6
    ldr    r0,= 0xFE808018
    ldr    r1,[r0]            ; read all the pin values
    
    // for bit 6

    ldr    r0,=6            ;if bit 6 set return 6
    ldr    r2,=0x40    ; mask for bit 6
    and    r1,r2            ; set all bits to zero except for bit 6
    cmp    r1,r2            ; is bit 6 not set?
    beq    bit5            ; branch if so
    
    ldr    r5,r0
    add    r4,#1
    cmp    r4,#2
    beq    wait
    
bit5
    ldr    r0,= 0xFE808018
    ldr    r1,[r0]            ; read all the pin values

    // for bit 5
    ldr    r0,=5            ;if bit 5 set return 5
    ldr    r2,=0x20         ; mask for bit 5
    and    r1,r2            ; set all bits to zero except for bit 5
    cmp    r1,r2            ; is bit 5 not set?
    beq    bit4            ; branch if so
    
    ldr    r6,r0
    add    r4,r4,#1
    cmp    r4,#2
    beq    wait

bit4
    ldr    r0,= 0xFE808018
    ldr    r1,[r0]            ; read all the pin values

    // for bit 4
    ldr    r0,=4            ;if bit 5 set return 5
    ldr    r2,=0x10         ; mask for bit 5
    and    r1,r2            ; set all bits to zero except for bit 5
    cmp    r1,r2            ; is bit 5 set?
    beq    ploop            ; branch if so
    
    ldr    r7,r0
    add    r4,r4,#1
    cmp    r4,#2
    bne    ploop

wait
    ldr r0,#0
    cmp r7,#1
    bne nex
    ldr r0,r7
nex
    cmp r6,#1
    bne nex1
    cmp r0,#1
    bne movr1
    ldr r0,r6
    b   nex1
movr1
    ldr r1,r6
nex1
    cmp r5,#1
    bne nex2
    cmp r0,#1
    bne movr11
    ldr r0,r5
    b   nex2
movr11
    ldr r1,r5
nex2
    cmp r4,#1
    bne end
    cmp r1,#1
    beq end
    ldr r1,r4
end
    ldmfd   sp!,{r1-r7}
