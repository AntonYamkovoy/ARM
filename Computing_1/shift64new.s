	AREA	Shift64, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =0x13131313
	LDR	R1, =0x13131313
	LDR	R2, =-2
	LDR R3, =1
	
;check if the shift is a right or left shift by reading if the nymber is negative
	CMP R2, #0
	BGT rightShift
	
	
;leftShift
	RSB R2, R2, #0	;get the absolute value of the shift
	
	;get the number of bits to shift the mask right by
	RSB R4, R2, #32
	
	;
	MOV R3, R3, LSR R2
	SUB R3, R3, #1
	
	MOV R3, R3, LSL R4 ; make the msb the lsb in the mask
	MVN R3, R3 ; invert r6 mask mask is now in r6
	
	MOV R1, R1, LSR R2   ; shift r0 left by one
	MOV R0, R0, LSR R2 ;
	ADD R1, R1, R3
	
	; leftShift Complete
	B stop
	
	
	
	
	

rightShift	
	; mask with only 1 at the start
	
	;get the mask through the formula 2^n -1
	
	;get the number of bits to shift the mask right by
	RSB R4, R2, #32
	
	
	MOV R3, R3, LSL R2
	SUB R3, R3, #1
	
	MOV R3, R3, LSR R4 ; make the msb the lsb in the mask
	MVN R3, R3 ; invert r6 mask mask is now in r6
	
	MOV R1, R1, LSL R2   ; shift r0 left by one
	MOV R0, R0, LSL R2 ;
	ADD R1, R1, R3
	
	;rightShift complete
	
	
	
stop	B	stop


	END
		