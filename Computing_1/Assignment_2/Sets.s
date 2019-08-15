	AREA	Sets, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

	LDR R0, =ASize
	LDR R1, =AElems
	LDR R2, =BSize
	LDR R3, =BElems
	LDR R4,=CElems
	LDR R5, =CSize
	
	LDR R11, [R5]
	
	LDR R7, [R0] ; lenght of A stored in R7

	LDR R8, [R2] ; r8 stoeres the lenght of B
	
	LDR R10, =0 ; match found boolean
	



whileA
	CMP R7,#0  ; while lenghtA > 0
	BEQ exitA

	SUB R7, R7, #1
	LDR R6, [R1] ; element value of A stored in R6

whileB
	CMP R8, #0 ; while countB > 0
	BEQ exitB

	SUB R8, R8, #1  ; countB--
	LDR R9 , [R3] ; load next belem into r9
	
	CMP R6, R9; if ( elemA == elemB)
	BEQ flagSet
	
	ADD R3, R3, #4  ;addrB ++

	B whileB	
exitB
	LDR R3, =BElems  ; start back at the first address of B
	LDR R2, =BSize  ; reload in the size of B
	LDR R8, [R2] ; load size of B into R8
	
	CMP R10, #1
	BEQ continueA
	  ;AND match has no been found
	STR R6, [R4]  ; store the element of A into CElems
	ADD R11, R11, #1 ; c lenght++
	ADD R4, R4, #4 ; c addr ++
continueA		
	MOV R10, #0 ; reset match flag to 0;
	ADD R1, R1, #4  ; addrA ++

	B whileA

flagSet
	MOV R10, #1
	B exitB
exitA

; Now we have to repeat the same process but do B as an outer loop to store all B elements that are not in A

	LDR R7, [R0] ; lenght of A stored in R7

	LDR R8, [R2] ; r8 stoeres the lenght of B


whileBSecondLoop
	CMP R8,#0  ; while lenghtB > 0
	BEQ exitBSecondLoop

	SUB R8, R8, #1 ; countB--
	LDR R9, [R3] ; element value of B stored in R9

whileASecondLoop
	CMP R7, #0 ; while countA > 0
	BEQ exitASecondLoop

	SUB R7, R7, #1  ; countA--
	LDR R6 , [R1] ; load next a elem into r6
	
	CMP R6, R9; if ( elemA == elemB)
	BEQ flagSetSecondLoop
	
	ADD R1, R1, #4  ;addrA ++

	B whileASecondLoop	
exitASecondLoop
	LDR R1, =AElems  ; start back at the first address of A
	LDR R0, =ASize  ; reload in the size of A
	LDR R7, [R0] ; load size of A into R7
	
	CMP R10, #1
	BEQ continueBSecondLoop
	  ;AND match has no been found
	STR R9, [R4]  ; store the element of B into CElems
	ADD R11, R11, #1 ; c lenght++
	ADD R4, R4, #4 ; c addr ++
continueBSecondLoop		
	MOV R10, #0 ; reset match flag to 0;
	ADD R3, R3, #4  ; addrB ++

	B whileBSecondLoop



flagSetSecondLoop
	MOV R10, #1 
	B exitASecondLoop
exitBSecondLoop



	STR R11, [R5] ; store c elem count to CSize memory
	
stop	B	stop


	AREA	TestData, DATA, READWRITE
	
ASize	DCD	8			; Number of elements in A
AElems	DCD	4,6,2,13,19,7,1,3	; Elements of A

BSize	DCD	6			; Number of elements in B
BElems	DCD	13,9,1,9,5,8		; Elements of B

CSize	DCD	0			; Number of elements in C
CElems	SPACE	56			; Elements of C

	END

