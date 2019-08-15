	AREA	ArrayMove, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R0, =array
	LDR	R1, =N ; R1 is arrayLength
	LDR	R2, =6		; originalIndex
	LDR	R3, =6		; indexToSwitchWith
	LDR R4, = 0; R4 = temp;
	SUB R5, R2, #1; R5 is the counter; counter = originalIndex -1
	
	ADD R7, R2, #1; r7 is the alt counter;
	
	
	CMP R2, R3; if both indexes are equal don't change anything
	BEQ stop
	
	LDR R4, [R0,R2, LSL #2] ; temp = array[OriginalIndex]
	
	CMP R2, R3;
	BHI while;
	B alternate
	
while
	CMP R5, R3; for(int i = originalIndex -1; i >= indexToSwitchWith; i--) {
	BLO eWhile
	
	LDR R6,  [R0,R5, LSL #2] ; = index[i];
	ADD R5, R5, #1;counter++ temporarily
	STR R6, [R0,R5, LSL #2]; store index[i+1] 
	
	
	SUB R5, R5, #2; i -= 2
	B	while
	
alternate
	CMP R7, R3;
	BHI eWhile
	
	LDR R6,  [R0,R7, LSL #2] ; = index[i];
	SUB R7, R7, #1; counter-- temporarily
	STR R6, [R0,R7, LSL #2]; store index[i-1] 
	
	ADD R7, R7, #2; i += 2;
	B alternate
eWhile


	STR R4, [R0,R3, LSL #2] ; array[indexToSwitchWith] = temp;
	
stop	B	stop


	AREA	TestArray, DATA, READWRITE

N	equ	9
array	DCD	7,2,5,9,1,3,2,3,4

	END	