	AREA	FpAdd, CODE, READONLY
	IMPORT	main
	EXPORT	start

start


	
	;R5 as first float number
	; R6 as second float number
	;eg 
	;LDR R0,=0x3FA00000 ; 1.25
	;LDR R1,=0x41C40000 ;24.5
	;LDR R0,=0x3bb0f27c ;0.0054
	;LDR R1,=0x447a0eb8 ; 1000.23
	;LDR r0, =0xc0ae6666
	;LDR	r1, =0xc0ae6666	; -5.45
	;LDR	r1, =0x40ae6666	;+5.45
	LDR	r1, =0x41240000	; 10.25	 res = 4.8 = 0x4099999a
	LDR	r0, =0xc0c80000	; - 6.25
	;LDR	r1, =0xc1240000	; -10.25
	BL	floatAdd			; result in R0
	

	
	


stop	B	stop


;getSign subroutine
; finds the sign bit for a IEEE754 floating point number;
; parameters:
	; R1 as the input floating point number
	
; the output will be be a r0
getSign
	STMFD	sp!, {r1,r2,lr} 
	LDR R2,=0x80000000 ; sign bit mask.
	AND R0, R1, R2 ; input float AND sign_bit mask.
	; in r0 we have stored a number where the first bit represents
	
	MOV R0,R0, LSR #31;
	; now we have the value of the sign in r0
	
	LDMFD	sp!, {r1,r2,pc}
	
	
	
;getExponent subroutine
; finds the exponent for a IEEE754 floating point number;
; parameters:
; 		R1 as the input floating point number
; returns:
; 		R0 - exponent unbiased
getExponent
	STMFD	sp!, {r1,r2,lr} 
	LDR R2,=0x7F800000 ; exponent mask.
	AND R0, R1, R2 ; input float AND exponent mask.
	MOV R0, R0, LSR #23 
	; in r0 we have stored a number which represents the value for the exponent
	SUB R0, R0, #127; subtracting the bias from the exp
	
	
		
	LDMFD	sp!, {r1,r2,pc}
	
	
	
;getFraction subroutine
; finds the exponent for a IEEE754 floating point number;
; parameters:
; 		R1 as the input floating point number
; returns:
; 		R0 - matissa 
getFraction
	STMFD	sp!, {r1-r2,lr} 
	LDR R2,=0x007FFFFF ; fraction mask.
	AND R0, R1, R2 ; input float AND exponent mask.
	; the fraction part doesn't need to be shifted anywhere
	; in r0 we have stored a number which represents the value for the fraction
	LDR R2,=0x00800000
	ORR R0, R2, R0; adding the assumed 23rd bit 
	
	
	
		
	LDMFD	sp!, {r1,r2,pc}


; floatAdd subroutine;
; adds 2 floating point numbers
; parameters :
; 		R0, : float  1
; 		R1 : float 2
; returns:
;		R0: sum = float1 + float2 in IEEE 754 form
floatAdd
	STMFD	sp!, {r4-r12,lr} 
	MOV	r7, r0				; save float 1 as local var
	MOV	r8, r1				; save float 2 as local var
	
	
	MOV R1,R7
	BL getSign;
	MOV R9,R0				; sign1 -  the sign bit of the first number is stored in r9
	MOV R1,R7
	BL getExponent 
	MOV R10,R0				; exp1 -  the exponent of the first number is in r10
	MOV R1,R7
	BL getFraction
	MOV R11,R0				; frac1 -  the fraction of the first number is in r11
	
	MOV R1,R8
	BL getSign
	MOV R4,R0				; sign2 - the sign of the second number is stored in r4
	MOV R1,R8
	BL getExponent
	MOV R5,R0				; exp2 -  the exponent of the second number is in r5;
	MOV R1,R8
	BL getFraction
	MOV R6,R0				; frac2 - the fraction of the second number is in r6
	
	; Program assumes that largest number is stores as float1
	; We need to check if that's true and swap is necessary
	CMP R10, R5				; if (exp2 > exp1)
	BLO swap				;		swap()
	BNE	continue
	CMP R11, R6				; else if (exp2 == exp1 && frac2 > frac1)
	BLO swap				;		swap()
	B continue
	
	
swap
	EOR	R9,R9, R4				; swap signs
	EOR	R4, R4, R9
	EOR R9, R9, R4
	
	EOR R10, R10, R5			; swap exponents
	EOR R5, R5, R10
	EOR R10, R10, R5
	
	EOR R11, R11, R6			; swap fractions
	EOR R6, R6, R11
	EOR R11, R11, R6
	

continue	


	SUB R12, R10, R5;				; ediff =  now we have the difference of the exponents in r12
	
	MOV R6, R6, LSR r12				; frac2 >> ediff -  multiplying the exponent to allign it with the exp of the other number
	
	CMP R9, #0 						; check first sign bit
	BEQ skipCompSigns
									; if (sign1 == 1)
	MVN R11, R11					;	frac1 = - frac1
	ADD R11, R11, #1				;get 2s complement of the first fraction
	
	
	
skipCompSigns
	
	CMP R4, #0						; if(sign2 == 1):
	BEQ endcomp						; 	frac2 = - frac2
	MVN R6, R6;
	ADD R6, R6, #1;
	
endcomp
	
	
	ADDS R12, R6, R11							; fractRes = frac1 + frac2 adding the fraction parts of each float number.
	BMI setsign									; if fracRes < 0 : signRes = negative
	MOV R3, #0									; sign = positive
	B normalise 
	
	
setsign
	MOV R3, #1 << 31 						; sign is negative

	MVN R12, R12							; fractRes = abs(fractRes)
	ADD R12, R12, #1						;
	
normalise
	MOV	r0, r12
	BL	countLeadingZeroes						; correct up to here
	RSB	r0, r0 , #8								;	counter = 8 - counter
	CMP	r0, #0									;	if(counter >= 0)
	BGE	shiftRight								;		fractRes >>counter
	MVN	r0, r0
	ADD	r0, r0, #1
	MOV	r12, r12, LSL r0						;		expRes + counter
	SUB	r10, r10, r0							;	else:	
	B	finish									;		fractRes << counter
												;		expRes - counter
shiftRight
	MOV	r12, r12, LSR r0
	ADD	r12, r12, r0
												
finish
	; now in r12 we have the final result fraction
	CMP	r12, #0								; if (fractRes == 0):
	BEQ	zeroCase							;	floatRes = 0; => move to sign
	LDR	r0, =0x007FFFFF
	AND	r12, r12, r0						; remove leading 1 from the fractRes
	
	ADD R10, R10, #127						; adding the bias back to the exponent
	MOV R10, R10, LSL #23					; shifting the exp back 
											; storing exponent in r10
	MOV	r0, #0								; clearing the result holder
	ORR R0, R10, R12						; combining the results into IEEE 754 form
	B	nonZeroCont
zeroCase
	MOV	r0, #0
nonZeroCont
	ORR R0, R0, R3;
	LDMFD	sp!, {r4-r12,pc}
	
; countLeadingZeroes subroutine
; counts the number of leading zeroes in the number passed
; parameter:
;		r0: number in which to count
; returns:
;		r0: number of leading zeroes
	
countLeadingZeroes

	STMFD sp!, {r4,lr}
	MOV	r4, #0						; counter
while
	MOVS	r0, r0, LSL #1			; while (carry from number << 1 != 1 && counter < 32)
	BCS		ewhile
	CMP	r4, #32						; 
	BHS		ewhile
	ADD	r4, r4, #1					;	counter++
	B	while
ewhile	
	MOV	r0, r4
	LDMFD	sp!, {r4,pc}

	AREA	TestData, DATA, READWRITE

	END
