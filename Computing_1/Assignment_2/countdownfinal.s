	AREA	Countdown, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R1, =cdWord	; Load start address of word
	LDR	R2, =cdLetters	; Load start address of letters
	LDR R5, =9; number of letters in the countdown random set
	LDR R6, =0; wordlenght count;
	
	LDR R7, =1;
	LDR R0, =0; our boolean for the answer
	
	LDRB R3, [R1] ; first letter of WORD is stored in r3
	LDRB R4, [R2] ; first letter of letters set is stored in r4.
	
wordLength
	CMP R3, #0
	BEQ endLength
	ADD R6, R6,#1 ; wordLenght++
	ADD R1, R1,#1 ; word addr ++
	LDRB R3, [R1] ; first letter of WORD is stored in r3
	
	B wordLength
endLength
	MOV R11, R6; storing the original lenght in r11

	;now we have the length of the word in r11, we can reset all the addresses now
	
	
	
whileWord
	CMP R6,#0  ; while lenghtWord > 0
	BEQ exitWord
	SUB R6, R6, #1
	
whileLetter
	CMP R5, #0 ; while countLetter > 0
	BEQ exitLetter
	SUB R5, R5, #1  ; countLetter--
	
	CMP R3, R4 ; compare the first letter in the word to the first letter
	BNE continue
	; we found a match
	MOV R4, #'$' ; if value is 0x24 // $ this means there is a match
	ADD R7, R7, #1 ; $count++
	STRB R4, [R2] ; store the 111 value in memory
	
	CMP R7, R11
	BEQ yes
	
continue
	ADD R2, R2, #1 ; addr letter++
	LDRB R4, [R2] ; move onto next value of letter
	
	B whileLetter	
exitLetter

	LDR	R2, =cdLetters	; Load start address of letters
	LDRB R4, [R2]
	LDR R5,=9;
	
	ADD R1, R1, #1 ; move onto next word letter value
	LDRB R3, [R1] ; move onto next value of letter
	B whileWord
exitWord
	
	CMP R7, R11 ; comparing the length of the WORD in r11 to the number of $ signs in r7 in the 9 letter sequence
	BEQ yes

	MOV R0, #0
	B stop

yes
	MOV R0, #1



stop	B	stop



	AREA	TestData, DATA, READWRITE
	
cdWord
	DCB	"daetebz",0

cdLetters
	DCB	"daetebzsb",0
	
	END	
