	AREA	AsciiValue, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R4, ='2'	; Load '2','0','3','4' into R4...R1
	LDR	R3, ='0'	;
	LDR	R2, ='3'	;
	LDR	R1, ='4'	;
	
	; your program goes here
	;convert the character codes to the decimal values
	;Use R0 as the temp register to store the value '0'
	LDR R0, ='0'
	SUB R4, R4, R0
	SUB R3, R3, R0
	SUB R2, R2, R0
	SUB R1, R1, R0
	
	;multiply the values by their base 10 equivalent
	;multiply '2' by 1000
	LDR R5, =1000
	MUL R0, R4, R5
	
	;multiply '0' by 100 then add the result to the total
	LDR R5, =100
	MUL R6, R3, R5
	ADD R0, R0, R6
	
	;multiply '3' by 10 then add the result to the total
	LDR R5, =10
	MUL R6, R2, R5
	ADD R0, R0, R6
	
	;Add the units column to the total
	ADD R0, R0, R1
	
stop	B	stop

	END	