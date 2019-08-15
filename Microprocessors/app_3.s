	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; (c) Mike Brady, 2011 -- 2019.

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN  EQU 0xE0028010
    
    
	ldr	r5,=IO1PIN

	ldr r4, =0x00f00000
	ldr r2, =0


while
	ldr r6, [r5]
	and r6, r6, r4
	cmp r6, #0x00f00000
	beq while
	mov r1, r6
    
startProcess

	BL getIndex
	BL performOperation
	BL changeLights
	b while
    
stop	B	stop

; subroutine to get index
; params :
; r1 - button press
; output :
; r0 - index of button
getIndex

	STMFD sp!, {r4-r9,lr}

	mov r4, #0
	ldr	r5,=IO1PIN

wait
	add r4, r4, #1
	ldr r6, [r5]
	and r6, r6, #0x00f00000
	cmp r6, #0x00f00000
	bne wait

	ldr r5,=8000000
	cmp r4,r5
	bgt longPress
	b shortPress
    
longPress
	mov r6,#1
	b calcShift
shortPress
	mov r6,#0
	b calcShift
    
    
calcShift
    
	mov r7,#20 ; counter
	mov r8,#0x00100000
while2
	and r9, r8, r1
	cmp r9, #0
	beq endwhile
	mov r8, r8, lsl #1
	add r7, r7,#1
	b while2
    
endwhile

	cmp r6, #1
	beq negate
	b return
negate
	mov r9, #0
	sub r7, r9, r7
	b return

return
	mov r0,r7

	LDMFD sp!, {r4-r9,pc}


; PERFORM OPERATION
; in r0 - int - index of button
; in r1 - boolean - has Display been Cleared
; in/out r2 - int - current display number

; out r0 - boolean - display last calculation

; in memory : int - last operation number
;           	int - running sum

performOperation
	stmfd sp!, {r4-r12, lr}

	cmp r0, #20
	beq addNumber
	cmp r0, #21
	beq subNumber
	cmp r0, #22
	beq addOperation
	cmp r0, #23
	beq subOperation
	cmp r0, #0xFFFFFFEA
	beq clearLastOperation
	cmp r0, #0xFFFFFFE9
	beq clearAllOperations
	b returnError
    
addNumber
	cmp r1, #1
	beq clearDisplayPlease
	add r2, #1
	mov r0, #0
	b endSubroutine

subNumber
	cmp r1, #1
	beq clearDisplayPlease
	sub r2, #1
	mov r0, #0
	b endSubroutine
    
addOperation
	ldr r4, =RunningSum
	ldr r5, [r4]
	add r5, r2
	str r5, [r4]
    
	ldr r4, =LastNumber
	str r2, [r4]
    
	mov r0, #1
	mov r2, #0
	b endSubroutine
    
subOperation
	ldr r4, =RunningSum
	ldr r5, [r4]
	sub r5, r2
	str r5, [r4]
    
	mov r4, #0
	sub r4, r4, r2
	mov r2, r4
    
	ldr r4, =LastNumber
	str r2, [r4]
    
	mov r0, #1
	mov r2, #0
	b endSubroutine
    
clearDisplayPlease
	mov r1, #0
	b endSubroutine
    
clearLastOperation
	ldr r4, =LastNumber
	ldr r5, [r4]
	mov r6, r5
	mov r2, #0

	ldr r4, =RunningSum
	ldr r5, [r4]
	add r5, r6
	str r5, [r4]
	b endSubroutine

clearAllOperations
	ldr r4, =RunningSum
	mov r5, #0
	str r5, [r4]
	ldr r4, =LastNumber
	mov r5, #0
	str r5, [r4]
	mov r2, #0
	b endSubroutine
    
returnError
	ldr r1, =0xFFFFFFFF
	b endSubroutine
    
endSubroutine
	ldmfd sp!, {r4-r12, pc}

; in r0 - bool - display result
; in r2 - int - current number to display

changeLights
	stmfd sp!, {r4-r12, lr}

    cmp r0, #0
    beq displayCurrent
    b displayTotal
    
displayCurrent
    mov r4, r2
    b drawNum
    
displayTotal
    ldr r4, =RunningSum
    ldr r4, [r4]
    b drawNum
    
drawNum
    ;Shift numbers up by 16 and store in led pins
    and r10, r4, #0x0000000f
    ;mov r4, r4, lsl #16
    ;mvn r4, r4
    ldr	r9,=IO1DIR
	ldr	r5,=0x000f0000	;select P1.19--P1.16
	str	r5,[r9]		;make them outputs
	ldr	r9,=IO1SET
	str	r5,[r9]		;set them to turn the LEDs off
	ldr	r5,=IO1CLR
	; r4 points to the SET register
	; r5 points to the CLEAR register
	
	ldr	r6,=0x00100000	; end when the mask reaches this value
	ldr	r7,=0x00010000	; start with P1.16.
	
	cmp r10,#0
	bgt skipMinus
	
skipMinus
for
	cmp r10,#0
	beq endfor
	
	MOVS R10, R10, LSR #1;
	BCS led
	B else1
led
	str	r7,[r5]	 
	B skip
else1
	str	r7,[r9]
skip
	mov	r7,r7,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	
	B for
endfor

	ldmfd sp!, {r4-r12, pc}

	AREA	Memory, DATA, READWRITE

RunningSum
	DCD 0x00000000

LastNumber
	DCD 0x00000000

	END


