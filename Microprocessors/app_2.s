	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
	
		ldr	r10,=16000000
sloop	subs	r10,r10,#1
	bne	sloop
	
	ldr r1, =WordSizedNumber
	ldr r1, [r1]

	ldr r3, =0

	;write 0 in mem
	
	ldr r5, =0x00000000
	ldr r6, =FinalNumber
	strb r5, [r6, r3]
	add r3, #1

	; Plus or Minus
	
	cmp r1, #0
	beq isZero
	bgt isPos
	blt isNeg
	
isZero
	ldr r5, =0x0000000f
	ldr r6, =FinalNumber
	strb r5, [r6, r3]
	add r3, #1
	b endCalculation


isPos
	ldr r5, =0x0000000a
	ldr r6, =FinalNumber
	strb r5, [r6, r3]
	add r3, #1
	b digits

isNeg
	mov r4, #0
	sub r1, r4, r1
	ldr r5, =0x0000000b
	ldr r6, =FinalNumber
	strb r5, [r6, r3]
	add r3, #1
	b digits
	
digits

	mov r4, #10       
	mov r5, #1 			
	ldr r6, =10
	
power
	cmp r1, r4			
	blt endPower		
						
	mov r5, r4			
	mul r4, r6, r4		
	b power				
endPower

	mov r2, r5
	
getDigit
	cmp r1, #0
	beq endCalculation
	bl getTopDigit
	;mov r7, r0 		; store result
	cmp r0, #0
	beq storeZero
	b storeNormal
	
storeZero
	ldr r5, =0x0000000f
	ldr r6, =FinalNumber
	strb r5, [r6, r3]
	add r3, #1
	b getDigit
	
storeNormal	
	ldr r5, =0x000000ff
	ldr r6, =FinalNumber
	add r0, #0x30
	and r0, r0, r5
	strb r0, [r6, r3]
	add r3, #1
	b getDigit
	
endCalculation
	
	;write 0 in mem
	
	ldr r5, =0x00000000
	ldr r6, =FinalNumber
	strb r5, [r6, r3]
	add r3, #1

	ldr r4, =FinalNumber
	ldr	r5,=0x00100000
	
arrayLoop

	ldr	r6,=0x00010000
	ldr r7, =0

displayDigits

	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr r2, =IO1CLR

	ldrb r8, [r4, r7]
		
	ldr r9, = 0x0000000f
	and r8, r8, r9
	
	; flip bottom 4 bits
	mov r10, #0
	mov r9, #0
floop
	cmp r9, #4
	bge efloop
	mov r10, r10, lsl #1
	movs r8, r8, lsr #1
	bcs addOne
	add r9, r9, #1
	b floop
addOne
	add r10, #1
	add r9, r9, #1
	b floop
efloop

	mov r8, r10
	mov r8, r8, lsl #16

	str	r8,[r2]

	ldr	r10,=16000000
dloop	subs	r10,r10,#1
	bne	dloop
	
	add r7, #1
	cmp r7, r3
	beq arrayLoop
	b displayDigits

stop	B	stop

; get digit - volatile
; input hex number - R1
; input highest power - R2
; output decimal result - R0
getTopDigit	
	stmfd sp!, {R4-R12, lr}	; Save local variables
	
	ldr R4, =0 ; quotient	
	
subtractIsDivide
	cmp R1, R2 					; while(remainder >= power)
	blo endSubtractIsDevide		; {
	sub R1, R1, R2   			;	 result = result - 10^realPower
	add R4, R4, #1	    		;	 quotient++
	b subtractIsDivide			; }
endSubtractIsDevide
	
	mov r0, r4
	
	ldr r5, =Powers
	ldr r6, [r5]
	
lowerPower
	cmp r2, r6
	beq changeStep
	add r5, #4
	ldr r6, [r5]
	b lowerPower

changeStep
	add r5, #4
	ldr r6, [r5]
	mov r2, r6
	
	ldmfd sp!, {r4 - r12, pc}

	AREA	Memory, DATA, READWRITE

WordSizedNumber
	DCD 0x00000000


Powers
	DCD 1000000000
	DCD 100000000
	DCD 10000000
	DCD 1000000
	DCD 100000
	DCD 10000
	DCD 1000
	DCD 100
	DCD 10
	DCD 1
		
FinalNumber
	SPACE 12

	END

