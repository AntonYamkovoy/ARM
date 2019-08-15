	AREA	Lotto, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	
	
	LDR	R1, =TICKETS
	LDR R2, =COUNT ; number of tickets = 3
	LDR R3, =0 ; ticketCounter overall
	LDR R4, =0; value at COUNT // number of tickets
	LDR R5,=0;
	LDR R6, =6; holds the number of ticketss (18)
	LDR R7,=0 ; ticket value
	;r8 = draw value
	LDR R10,=1; counter for draw
	LDR R11, =0 ;dollar sign counter
	LDR R9, =0 ; 6 counter // number in ticket
	
	LDRB R4, [R2]
	MUL R6, R4, R6 ; total number of tickets = 18
	; 18 = 6 x count
	
whileTickets
	CMP R3, R6 
	BEQ endWhileTickets ; while ( numTickets < 18) {
	
	LDRB R7, [R1] ; load in the first ticket
	
	LDR R10,=0
	LDR R0, =DRAW

whileDraw
	CMP R10, #6 ; 
	BEQ exitDraw
	LDRB R8, [R0] ; load in next draw value
	
	CMP R8, R7 ; compare the first letter in the word to the first letter
	BNE continue
	; we found a match
	MOV R7, #'$' ; 
	ADD R11, R11, #1  ; $ amoutn ++
	STRB R7, [R1] ; store the dollar sign into memory into tickets
	
continue

	ADD R0, R0, #1 ; addr draw++
	ADD R10 ,R10 ,#1 ; drawCount++
	B whileDraw	
exitDraw
	
	; now we have compared each element in the draw to the given range for the loop run
	; we need to check if the amount of $ signs is 4 or 5 or 6 and if so put it into the memory location
	
	;CMP R11, #4
	;BEQ matchFour
	
	;CMP R11, #5 
	;BEQ matchFive

	;CMP R11, #6 
	;BEQ matchSix
	
;nextLoop
	ADD R3, R3, #1 ; ticketCounter++
	ADD R1, R1, #1 ; next addr for ticket
	;6 counter
	ADD R9 , R9 ,#1 ; next number in ticket
	CMP R9, #6
	BNE contWhileTicket
	
	MOV R9, #0
	
	CMP R11, #4
	BEQ matchFour
	
	CMP R11, #5 
	BEQ matchFive

	CMP R11, #6 
	BEQ matchSix
returnFromMatch
	MOV R11, #0 ; resetting match counter for next ticket
contWhileTicket

	B whileTickets
endWhileTickets

	B stop

matchFour
	LDR R5, =MATCH4
	LDR R2, [R5]
	ADD R2, R2, #1
	STR R2, [R5]
	B returnFromMatch
matchFive
	LDR R5, =MATCH5
	LDR R2, [R5]
	ADD R2, R2, #1
	STR R2, [R5]
	B returnFromMatch
matchSix
	LDR R5, =MATCH6
	LDR R2, [R5]
	ADD R2, R2, #1
	STR R2, [R5]
	B returnFromMatch

stop	B	stop 



	AREA	TestData, DATA, READWRITE

COUNT	DCD	3			; Number of Tickets
TICKETS	DCB	13, 12, 11, 21, 26, 30	; Tickets
		DCB	3, 10, 11, 21, 26, 24
		DCB	3, 10, 11, 21, 26, 18
	

DRAW	DCB	3, 10, 11, 21, 26, 30	; Lottery Draw

MATCH4	DCD	0
MATCH5	DCD	0
MATCH6	DCD	0

	END	

