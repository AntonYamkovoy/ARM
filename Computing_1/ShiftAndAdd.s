	AREA	ShiftAndAdd, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, =9
	LDR	R2, =10
	LDR R3, =0 ; count =0
	LDR R0, =0; result =0
	MOV R4, R2  ; temp = value
	

while
	CMP R4, #0 ; while(temp != 0)
	BEQ exit
	
	MOVS R4, R4, LSR #1 ; temp = temp >> 1
	
	BCC eif  ; if no carry skip
	ADD R0, R1, R2, LSL R3 ; result+= value << count
	
eif
	ADD R3, R3, #1 ; count ++
	B while
	

exit

	ADD R0 ,R0, #0x1
	
stop	B	stop


	END	
	