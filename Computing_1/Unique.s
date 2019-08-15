	AREA	Unique, CODE, READONLY
	IMPORT	main
	EXPORT	start

start

	LDR	R1, =VALUES		;loopOneValues
	LDR R2, =COUNT
	LDR R2, [R2]
	
	MOV R0, #1 			;isUnique = true
	MOV R3, #0			;loopOneCounter = 0
	MOV R4, #0			;loopTwoCounter = 0
	LDR R5, =VALUES		;loopTwoValues
	
whOne
	CMP R3, R2			;while (loopOneCounter <= totalCount)
	BGE ewhOne			;{
	LDR R6, [R1]			;valueOne = memory.load(r1)
	ADD R1, R1, #4			;Addr = addr + 4
	ADD R3, R3, #1			;loopOneCounter += 1
whTwo	
	CMP R4, R2				;while loopTwoCounter <= totalCount
	BGE ewhTwo				;{
	LDR R7, [R5]				;loopTwoValues = values
	ADD R5, R5, #4				;loopTwoAddr += 4
	ADD R4, R4, #1 				;loopTwoCounter += 1
	
	;compare if the memory addresses are the same, if so the same value is being compared
	CMP R1, R5
	BEQ skipCompare
	
	CMP R6, R7					;if (loopOneValue == loopTwoValue
	BEQ matchFound					;MatchFound()
skipCompare
	B whTwo						;}
							;}
ewhTwo
	MOV R4, #0			;reset loop values
	LDR R5, =VALUES
	B whOne				;}

matchFound
	MOV R0, #0
	B ewhOne
ewhOne
	
stop	B	stop


	AREA	TestData, DATA, READWRITE
	
COUNT	DCD	10
VALUES	DCD	5, 2, 7, 4, 13, 4, 18, 8, 9, 12


	END	