	AREA	DisplayResult, CODE, READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8

start

	LDR R3,=0;
	LDR R4,=0;

loop
	CMP R3,#9
	BGE endLoop
	
loop2
	CMP R4, #9
	BGE endLoop2
	
	
	
	LDR R0, =gridOne
	MOV R1, R3
	MOV R2, R4
	BL getSquare
	ADD R0, R9, #0x30
	BL sendchar
	
	


	ADD R4, R4, #1;
	B loop2
endLoop2
	
	MOV R0,#0xA
	BL sendchar
	
	SUB R4, R4, #9
	ADD R3, R3, #1;
	B loop
endLoop

	LDR R0,=gridOne
	LDR R1,=8;
	LDR R2,=8;
	BL getSquare
	ADD R0, R9, #0x30
	BL sendchar


stop	B	stop



; getSquare sutroutine
; gets the digit value at a certain (row,col) position
; parameters:
;			r0 - start address of the sudoku array
;			r1 - row index
;			r2 - col index
;           

; getSquare subroutine
getSquare
	STMFD	sp!, {r1-r2 ,lr}
	LDR R0, =gridOne
	MOV R9, #9
	MUL R9,R1, R9; finding the postition of the digit in the 2D array
	ADD R9, R9, R2;
	; the position is stored in r3
	LDRB R9, [R0, R9, LSL #0] ; storing a byte value;
	
	; the result of the subroutine is stored in r4, eg the value of the digit at this position
	
	
	
	LDMFD 	sp!, {r1-r2 , pc}




	LDR R0,=gridOne
	LDR R1,=0;
	LDR R2,=0;
	BL getSquare
	ADD R0, R9, #0x30
	BL sendchar


gridOne
		DCB	7,9,0, 0,0,0 ,3,0,0
    	DCB	0,0,0, 0,0,6 ,9,0,0
    	DCB	8,0,0, 0,3,0 ,0,7,6

    	DCB	0,0,0 ,0,0,5, 0,0,2
    	DCB	0,0,5, 4,1,8, 7,0,0
    	DCB	4,0,0 ,7,0,0, 0,0,0
		
    	DCB	6,1,0, 0,9,0 ,0,0,8
    	DCB	0,0,2 ,3,0,0 ,0,0,0
    	DCB	0,0,9, 0,0,0 ,0,5,4
		;original grid


	END	