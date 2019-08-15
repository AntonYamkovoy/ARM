	AREA	Sudoku, CODE, READONLY
	IMPORT  main
	IMPORT  getkey
	IMPORT  sendchar
	IMPORT  printf
	EXPORT  start
	PRESERVE8

start

	;
	;MOV R0,#0x51;
	;BL sendchar
	
	; write tests for getSquare subroutine
	
	
	;LDR R1, =2;
	;LDR R2, =4;
	;BL getSquare
	
	;LDR R1, =8;
	;LDR R2, =8;
	;BL getSquare
	
	;LDR R1, =0;
	;LDR R2, =0;
	;BL getSquare
	
	; getSquare is working as expected



	;
	; write tests for setSquare subroutine
	;
	
	;LDR R1, =8; row = 1
	;LDR R2, =8; col = 1
	;LDR R3,=5; value = 5
	;BL setSquare

	;LDR R1, =1; row = 1
	;LDR R2, =1; col = 1
	;LDR R3,=7; value = 5
	;BL setSquare
	
	; SetSquare is working as expected
	
	;
	
	
	
	; check 3x3 tests
	; 
	;LDR R1,=3 ; row
	;LDR R2, =3; col
	;BL threeCheck
	
	
	
	;LDR R1, =3
	;LDR R2, =2
	;(square 4);
	;BL threeCheck
	;
	; write tests for other subroutines
	;
	;LDR R0,=gridOne
	;LDR R1,=1;
	;LDR R2, =2;
	;BL isValid
	
	;LDR R1, =3
	;LDR R2, =2
	;(square 4);
	;BL isValid
	
	;isUnique test
	;BL isUnique
	
	;LDR R0,=gridOne
	;LDR R1,=0
	;LDR R2,=0;
	;BL printBoard
	;LDR R0,=0
	;BL printBoard
	LDR R0,=gridOne
	LDR R1,=0
	LDR R2,=0;
	BL getSquare
	MOV R0,R9
	BL printf

	
	;LDR	R0, =gridOne
	;MOV	R1, #0
	;MOV	R2, #0
	;BL	sudokuSolver

stop	B	stop



;isValid subroutine
; checks whether the given row, col position is a valid position for the sudoku solutions
; parameters:
	; R0 - start address of grid
	; R1 - row index
	; R2 - col index
isValid

	STMFD	sp!, {r0-r2,r10 ,lr}
	
	LDR R10, =checkarray
	BL threeCheck
	;result stored in r12
	CMP R12, #1
	BNE notValid
	
	LDR R10, =checkarray
	BL checkCol
	CMP R12, #1
	BNE notValid
	
	LDR R10,=checkarray
	; r1 is set
	BL checkRow
	CMP R12, #1
	BNE notValid
	
	; all three are valid
	;MOV R12, #1;
	B stopValid
	
notValid
	MOV R12, #0
		
		
		
stopValid
	LDMFD 	sp!, {r0-r2,r10 , pc}





; check row
; checks if there are reapeating values in the 1x9 row
; parameters:
;			r0 - start of array
;           r1 - row index
;           r2 - counter
;           r3 - dimension
;			
;checkRow subroutine
checkRow
	STMFD	sp!, {r0-r4,r9 ,lr}
	LDR R0, =gridOne
	LDR R2, =0; i=0;
forRow
	CMP R2, #9
	BEQ efor
	; R1 is row iundex and const
	LDR R0, =gridOne

	
	BL getSquare; ; now we have the value of the square in r9

	STRB R9, [R10]; storing the value found in the rowCheck array
	ADD R10, R10, #1; incrementing the address in the array
	
cont1
	ADD R2, R2, #1
	B forRow
	
efor
	;  now we have the values of the current row in an array we need to check if the values that are 1-9 are all unique;
	; result of isUnique is stored in r9;

	BL isUnique
	
	CMP R12, #1;
	BNE false
	LDR R12, =1;
	B goToEnd
	
false
	LDR R12, =0;
	
	
goToEnd

	LDMFD 	sp!, {r0-r4,r9, pc}




; check col
; checks if there are reapeating values in the 1x9 row
; parameters:
;			r0 - start of array
;           r1 - col index
;           r2 - counter
;           r3 - dimension

checkCol
	STMFD	sp!, {r0-r4,r10,r9 ,lr}
	LDR R0, =gridOne
	LDR R1, =0; i=0;
forCol
	CMP R1, #9
	BEQ eforCol
	
	BL getSquare; ; now we have the value of the square in r4

	STRB R9, [R10]; storing the value found in the rowCheck array
	ADD R10, R10, #1; incrementing the address in the array
	
cont1Col
	ADD R1, R1, #1
	B forCol
	
eforCol
	;  now we have the values of the current row in an array we need to check if the values that are 1-9 are all unique;
	; result of isUnique is stored in r9;

	BL isUnique
	
	CMP R12, #1;
	BNE falseCol
	LDR R12, =1;
	B goToEndCol
	
falseCol
	LDR R12, =0;
	
	
goToEndCol

	LDMFD 	sp!, {r0-r4,r10,r9 , pc}




threeCheck


	STMFD	sp!, {r0-r2,r6,r7,r8 ,lr}
	LDR R0, =gridOne
	LDR R10,=checkarray

	LDR R7, =0;
	
	; r1 is the row
	; r2 is the col
	
	; we can use r6, and r8 for the starting row and col
	

	
	
	
	CMP R1, #3  ; if(row < 3) {
	BGE elseif
	
	CMP R2, #3 ; if( col < 3)
	BLO gotoOne ; gotoOne
	
	CMP R2, #6 ; else if(col < 6)
	BLO gotoTwo ; goto2
	
	CMP R2, #9 ; elseif( col < 9);
	BLO gotoThree ; goto3
	
elseif
	CMP R1, #6 ; else if( row < 6);
	BGE elseif2 ; 
	
	CMP R2, #3 ; if( col < 3)
	BLO gotoFour
	
	CMP R2, #6 ; else if(col < 6)
	BLO gotoFive
	
	CMP R2, #9 ; elseif( col < 9);
	BLO gotoSix
	
elseif2

	CMP R1, #9 ; else if (row < 9)
	BGE exitcheck
	
	CMP R2, #3;  if( col < 3)
	BLO gotoSeven ;
	
	CMP R2, #6; else if(col < 6)
	BLO gotoEight
	
	CMP R2, #9 ; elseif( col < 9);
	BLO gotoNine
	
exitcheck


gotoOne
	LDR R6,=3
	LDR R8, =3 ; each of these boxes sets the upper and lower limits for row and col
	MOV R1, #0;
	MOV R2, #0; ; where upperLim -3 == lowerLim
	B loop

gotoTwo

	LDR R6, =3
	LDR R8, =6
	MOV R1, #0;
	MOV R2, #3;
	B loop

gotoThree
	LDR R6, =3
	LDR R8, =9
	MOV R1, #0;
	MOV R2, #6;
	B loop

gotoFour
	LDR R6, =6
	LDR R8, =3
	MOV R1, #3;
	MOV R2, #0;
	B loop

gotoFive
	LDR R6, =6
	LDR R8, =6
	MOV R1, #3;
	MOV R2, #3;
	B loop

gotoSix	
	LDR R6, =6
	LDR R8, =9
	MOV R1, #3;
	MOV R2, #6;
	B loop

gotoSeven
	LDR R6, =9
	LDR R8, =3
	MOV R1, #6;
	MOV R2, #0;
	B loop

gotoEight
	LDR R6, =9
	LDR R8, =6
	MOV R1, #6;
	MOV R2, #3;
	B loop

gotoNine
	LDR R6, =9
	LDR R8, =9
	MOV R1, #6;
	MOV R2, #6;
	B loop



loop
	CMP R1,R6
	BGE endLoop
	
loop2
	CMP R2, R8
	BGE endLoop2
	
	
	
	LDR R0, =gridOne
	;MOV R1, R5;              ; nested for loop
	;MOV R2, R7;
	
	BL getSquare 
	; result in r9
	
	STRB R9, [R10, R7 , LSL #0]
	ADD R7, R7, #1;

	ADD R2, R2, #1;
	B loop2
endLoop2
	
	SUB R2, R2, #3
	ADD R1, R1, #1;
	B loop
endLoop

	
	BL isUnique
	; isUnique output is overriden in r9
	
	CMP R12, #1;
	BNE falseThree
	LDR R12, =1;
	B goToEndThree
	
falseThree
	LDR R12, =0;
	
	
goToEndThree

; output of check3x3 stored in r12

	
	LDMFD 	sp!, {r0-r2,r6,r7,r8  , pc}




; setSquare sutroutine
; setss the digit value at a certain (row,col) position
; parameters:
;			r0 - start address of the sudoku array
;			r1 - row index
;			r2 - col index
;           r7 - value to be set
;           r9 - temp

setSquare
	STMFD	sp!, {r0-r2,r7,lr}

	
	LDR R0, =gridOne
	MOV R9, #9;
	MUL R9, R1, R9; finding the postition of the digit in the 2D array
	ADD R9, R9, R2;
	; the position is stored in r3
	STRB R7, [R0, R9, LSL #0]
	
	
	
	;the value given in r3 is stored at position at (row,col);
	LDMFD 	sp!, {r0-r2,r7 , pc}




; getSquare sutroutine
; gets the digit value at a certain (row,col) position
; parameters:
;			r0 - start address of the sudoku array
;			r1 - row index
;			r2 - col index
;           

; getSquare subroutine
getSquare
	STMFD	sp!, {r0-r2 ,lr}
	LDR R0, =gridOne
	MOV R9, #9
	MUL R9,R1, R9; finding the postition of the digit in the 2D array
	ADD R9, R9, R2;
	; the position is stored in r3
	LDRB R9, [R0, R9, LSL #0] ; storing a byte value;
	
	; the result of the subroutine is stored in r4, eg the value of the digit at this position
	
	
	
	LDMFD 	sp!, {r0-r2 , pc}



; isUnique subroutine
; checks whether an array is unique stores boolean result in r9
; parameters:
;  			R0 - starting address of array
isUnique
	STMFD	sp!, {r0-r4 ,lr}
	LDR R0, =checkarray
	
	LDR R1, =0; i =0;
	LDR R2, =1; j = i+1;

for1
	CMP R1, #8 ; while(i < 8) {
	BGE ef1
	
for2 
	CMP R2, #9 ; while(j < 9) {
	BGE ef2
	
	LDRB R3, [R0, R1, LSL #0]; array[i]
	LDRB R4, [R0, R2, LSL #0] ; array[j]
	
	CMP R3, R4
	BNE continue
	CMP R3, #0
	BEQ continue
	CMP R4, #0
	BEQ continue
	
	;if(array[i] == array[j] && array[i] != 0 && array[j] != 0) {
		; goto --> continue
	;}
	
	B gotoNotUnique
	
continue
	
	
	ADD R2, R2, #1; j++
	B for2
ef2
	
	ADD R1, R1, #1; i++
	MOV R2, R1 ;
	ADD R2, R2, #1
	
	B for1 ; }
ef1

; we have read over the whole array without finding any matches 

	MOV R12, #1
	B endu


gotoNotUnique
	MOV R12, #0;

endu
	
	LDMFD 	sp!, {r0-r4 , pc}
	



;sudokuSolver subroutine
;solves the given grid 
; parameters:
	;R0 - start of grid
	;R1 - row index
	;R2 - col index
	
sudokuSolver
	STMFD	sp!, {r0,r1,r2,r3,r5,r6,r4,r7 ,lr}
	LDR R0, =gridOne
	

	
	LDR R11, =0; boolean result = false;
	; r5 will be used as nextRow
	; r6 will be used as nextCol
	
	; r1 is row
	; r2 is col (current)
	
	ADD R6, R2, #1; nextCol = col+1
	MOV R5, R1; nextRow = row;
	
	CMP R6, #8 ;if(nextCol > 8) {
	BLE skip
	MOV R6, #0; nextCol =0;
	ADD R5, R5, #1; nextRow++;
skip ;}

	
	; r1 and r2 are set
	BL getSquare
	; getSquare value in r9
	CMP R9, #0
	BEQ else1
	
	CMP R1, #8
	BNE else2
	CMP R2, #8
	BNE else2
	;(row == 8 AND col ==8)
	B returnTrue
	
else2
	; save current values R1,R2
	MOV R3, R1
	MOV R4, R2
	
	MOV R1, R5 ; next row
	MOV R2, R6 ; next col
	BL sudokuSolver
	; result stored in r11;
	; restore R1, R2
	MOV R1, R3
	MOV R2, R4
	
	B returnResult	
	
	
else1


	LDR R7,=1; try = 1;
	
forLoop
	CMP R7, #9
	BGT endForLoop
	CMP R11, #1
	BEQ endForLoop
	
	
	
	;MOV R5, R7; value = try
	; r1 and r2 are aread set
	BL setSquare
	; point to check r3
	
	
	
	; r1 and r2 are already set
	BL isValid
	; isValid result total is stored in r12
	CMP R12, #1
	BNE skip2
	
	CMP R1, #8
	BNE else3
	CMP R2, #8
	BNE else3
	
	MOV R11, #1
	; changed from B returnResult
	B skip2
	
else3

	; save current values R1,R2
	
	MOV R3, R1
	MOV R4, R2

	MOV R1, R5 ; next row
	MOV R2, R6 ; next col 
	
	BL sudokuSolver
	; result stored in r11;
	; restore R1, R2
	MOV R1, R3
	MOV R2, R4
	
skip2
	
	ADD R7, R7, #1 ; try++
	B forLoop
endForLoop

	CMP R11, #0
	BNE conti
	
	MOV R7,#0; value = 0
	; r1 and r2 are alrady set
	BL setSquare
	
conti


returnResult
;(end of function)
 B endFunc
	
returnTrue
	MOV R11, #1;
	
endFunc
	LDMFD 	sp!, {r0,r1,r2,r3,r5,r6,r4,r7 , pc}



; printBoard subroutine
; prints the sudoku board from memory
; parameters:
	; R3 - starting address of board in memory
printBoard
	
	STMFD	sp!, {r1-r3 ,lr}
	LDR R0,=gridOne
	LDR R1,=8
	LDR R2,=8
	
	BL getSquare
	MOV R0, R9
	;BL sendchar
	BL printf
	
	LDMFD 	sp!, {r1-r3 , pc}
	

	

	AREA	Grids, DATA, READWRITE



gridOneC
		DCB	0,0,3, 0,4,2 ,0,9,0
    	DCB	0,9,0, 0,6,0 ,5,0,0
    	DCB	5,0,0, 0,0,0, 0,1,0
		
    	DCB	0,0,1, 7,0,0 ,2,8,5
    	DCB	0,0,8, 0,0,0 ,1,0,0
    	DCB	3,2,9, 0,0,8, 7,0,0
		
    	DCB	0,3,0, 0,0,0, 0,0,1
    	DCB	0,0,5, 0,9,0 ,0,2,0
    	DCB	0,8,0, 2,1,0, 6,0,0


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


gridOneB
		DCB	7,9,0, 0,0,0 ,3,0,0 ; correct
    	DCB	0,0,0, 0,0,6 ,9,0,0 ; correct
    	DCB	8,0,1, 2,3,9, 0,7,6
		
    	DCB	0,3,0, 0,0,5 ,0,0,2
    	DCB	0,0,5, 4,1,8 ,7,6,0
    	DCB	4,0,0, 7,0,0, 5,0,0
		
    	DCB	6,1,0, 0,9,7, 0,0,8
    	DCB	5,8,2, 3,0,1 ,0,0,0
    	DCB	0,0,9, 6,8,0, 0,5,4
		; can solve this one
	
checkarray
		DCB 0,0,0 ,0,0,0 ,0,0,0
	;

uniquetest 
		DCB 0,0,0, 1,2,3, 3,4,6
	END

