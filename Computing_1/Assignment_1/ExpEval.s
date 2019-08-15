	AREA	DisplayResult, CODE, READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT	sendchar
	EXPORT	start
	PRESERVE8

start   

		MOV R4,#0    ; set initial result to 0
		MOV R7,#0    ; set initial result to 0
		LDR R6,=10  ; load 10 into r6 for later use
		LDR R11, =0   ; negative boolean
		LDR R10,=0   ; value1/value2 boolean
		LDR R12,=0   ; operator sign value
		LDR R9,=0  ; first digit entered boolean
		LDR R8,=0

readWhile
		BL getkey    ;  read key from input
		CMP R0,#0x0D  ;  while key != enter, this loops for every number inputed
		BEQ endReadWhile  ;   
		BL sendchar   ;   send to console
		
		CMP R0, #0x20 ; space entered
		BEQ readWhile ; goto readwhile start (ignore spaces)
		
		CMP R9, #0   ; if first digit is entered
		BEQ fistDigitCheck	
		
operatorCheck

		CMP R0, #0x25    ; checking for % modulus sign
		BEQ operatorAssign
		CMP R0, #0x2A    ; check for multiplication *
		BEQ operatorAssign
		CMP R0, #0x2B   ; check for addition op +
		BEQ operatorAssign
		CMP R0, #0x2D  ; check for subtraction -
		BEQ operatorAssign
		CMP R0, #0x2F  ; check for division /
		BEQ operatorAssign
		
fistDigitCheck	

		CMP R0, #0x2D   ;   if key = "-"
		BEQ enterNegSign  ;  set negative boolean to true 
		CMP R0,#0x30      ; 
		BLO invalidinput  ;  if the input doesn't fall into the 0-9 range it is invalid
		CMP R0, #0x39     ;
		BHI invalidinput   ;
		MOV R9, #1    ; expecting second digit to enter
		CMP R10, #0   ; if entering value of first operand 
		BNE secondOperand ; else go to second operand
;firstOperand
		MUL R4, R6, R4   ;  result = result*10
		SUB R5, R0,#0x30  ;  convert to ascii
		ADD R4, R4, R5   ;  result += value
		B readWhile
secondOperand

		MUL R7, R6, R7   ;  result = result*10
		SUB R5, R0,#0x30  ;  convert to ascii
		ADD R7, R7, R5   ;  result += value
		B readWhile
enterNegSign
		MOV R11, #1     ;  set the negative value boolean to TRUE			
		B readWhile

operatorAssign

;possibleNegativeTransformOfChainOperand
		CMP R11, #1    ; if number is negative
		BNE continueCalcAfterNegativeNumberProcessed ;  
		MOV R11, #0
		CMP R10,#1  ; if it is second number
	    BEQ negativeTransformOfChainSecondOperand		
;negativeTransformOfChainFirstOperand				
		MVN R4, R4   ;   the number is bit inverted
		ADD R4, R4, #1   ; 1 is added to complete the 2s complement form
		; debug
		;MOV R6, R0 
		;MOV R0, #0x3E   
		;BL sendchar			
		;MOV R0, R4  
		;RSB R0, R0, #0
		;BL sendchar
		; end of debug
		;MOV R0, R6
		;LDR R6, = 10	
		B continueCalcAfterNegativeNumberProcessed	
negativeTransformOfChainSecondOperand				
		MVN R7, R7  ;   the number is bit inverted
		ADD R7, R7, #1   ; 1 is added to complete the 2s complement form
		
continueCalcAfterNegativeNumberProcessed
		CMP R12, #0
		BNE calc
continueChainOfOperators		
		MOV R12, R0   ; operation symbol stored in R12
		MOV R10, #1  ; second operand mode
		MOV R9, #0  ; expecting first digit to enter
		B readWhile    ;

endReadWhile
		
calc
;possible negativeTransform of Last Operand
		CMP R11, #1    ; if number is negative
		BNE continueCalcAfterLastNegativeNumberProcessed ;  
		MOV R11, #0
		CMP R10,#1  ; if it is second number
	    BEQ negativeTransformOfLastOperand		
;negativeTransformOfLast????FirstOperand				
		MVN R4, R4   ;   the number is bit inverted
		ADD R4, R4, #1   ; 1 is added to complete the 2s complement form
		
		B continueCalcAfterLastNegativeNumberProcessed	
negativeTransformOfLastOperand				
		MVN R7, R7  ;   the number is bit inverted
		ADD R7, R7, #1   ; 1 is added to complete the 2s complement form
		
continueCalcAfterLastNegativeNumberProcessed
                         ; if the symbol = %
		CMP R12, #0x25  ; goto modulus path
		BEQ gotoModulus   ; if the symbol = *
		CMP R12, #0x2A  ; goto multiplication path
		BEQ gotoMult
		CMP R12, #0x2B ; if the symbol = + goto addition path
		BEQ gotoAdd
		CMP R12, #0x2D ; if the symbol = - goto subtraction path
		BEQ gotoSub
		CMP R12, #0x2F  ;if the symbol is divison goto div path
		BEQ gotoDiv
		B invalidinput  ; else goto invalid input


 ; so far we have the 1st input in R4, R7 and know operator branch
 
gotoSub 	
		
		SUB R4, R4, R7 ; stores result in r4 of r4-r7, to be ready for next operator in chain
		LDR R7, =0
		CMP R0,#0x0D  ;  if key != enter, return to the reading loop
		BNE continueChainOfOperators
		B displaystep
		

gotoAdd 
		ADD R4, R4, R7 ; stores result in r4 of r4+r7  to be ready for next operator in chain
		LDR R7, =0
		CMP R0,#0x0D  ;  if key != enter, return to the reading loop
		BNE continueChainOfOperators
		B displaystep

gotoMult 
		MUL R4, R7, R4 ; stores in r4 r4 x r7
		LDR R7, =0
		CMP R0,#0x0D  ;  if key != enter, return to the reading loop
		BNE continueChainOfOperators		

B displaystep
		
gotoModulus	
		LDR R5, =0
		CMP R4, #0
		BGE checkSecondModNumberSign
		MVN R5, R5
		RSB R4, R4,#0
checkSecondModNumberSign
		CMP R7, #0
		BGE exitModNegativeCheck
		RSB R7, R7, #0 ; now R7 is postitive
		;MVN R5, R5 ; flip the negativeflag from previous val, now negative flag has been flipped twice ie positive 
		; if both values negative = positive result
		; if one value negative = negative result
		; if none negative = positive result		
exitModNegativeCheck

		LDR R9, =0   ; remainder = R9
		LDR R8, =0   ; quotient = R8
		MOV R9, R4    ; a = remainder
		CMP R7, #0   ; if b = 0 ie division by 0 exit the division loop
		BEQ divisionByZero
modwhile 
		CMP R9, R7   ; while remainder >= b
		BLO exitModWhile   ; if remainder < b exit the loop        stores the remainder in R9 
		ADD R8, R8, #1  ; quotient = quotient +1
		SUB R9, R9, R7  ; remainder = remainder - b
		B modwhile
	
exitModWhile
		CMP R5, #0
		BEQ storeModResult
		RSB R9, R9, #0
storeModResult
		MOV R4, R9    ; moves remainder (result for %) into R4
		LDR R7, =0
		CMP R0,#0x0D  ;  if key != enter, return to the reading loop
		BNE continueChainOfOperators
		B displaystep
      ; where r4 = a
	  ; and r7 = b

	
gotoDiv
;       check first number sign
		LDR R5, =0; ; load 0 into negativeflag for division as initial val
		CMP R4, #0
		BGE checkSecondNumberSign
		RSB R4, R4, #0 ; now R4 is positive
		MVN R5, R5 ; flip the negativeflag from initial val
checkSecondNumberSign
		CMP R7, #0
		BGE continueDivision
		RSB R7, R7, #0 ; now R7 is postitive
		MVN R5, R5 ; flip the negativeflag from previous val, now negative flag has been flipped twice ie positive 
		; if both values negative = positive result
		; if one value negative = negative result
		; if none negative = positive result
continueDivision

		LDR R9, =0
		LDR R8, =0   ; quotient = R8
		MOV R9, R4    ; a = remainder
		CMP R7, #0   ; if b = 0 ie division by 0 exit the division loop
		BEQ divisionByZero
		

divwhile 
		CMP R9, R7   ; while remainder >= b
		BLO exitDivWhile   ; if remainder < b exit the loop        stores the remainder in R9  (modulus operator action can be transfered here and given the remainder as output) 
		ADD R8, R8, #1  ; quotient = quotient +1
		SUB R9, R9, R7  ; remainder = remainder - b
		B divwhile
	
exitDivWhile
		CMP R5, #0  ; if negative flag is set flip result
		BEQ storedivisionresult ; else go as normal
		;flip the R8 value
		RSB R8, R8, #0 ; r8 = 0-r8
		
storedivisionresult
		MOV R4, R8    ; moves quotient (result for /) into R4
		LDR R7, =0
		CMP R0,#0x0D  ;  if key != enter, return to the reading loop
		BNE continueChainOfOperators
		B displaystep
		
displaystep

		
stop	B	stop

	END	
		