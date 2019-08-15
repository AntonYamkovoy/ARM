	AREA	BubbleSort, CODE, READONLY
	IMPORT	main
	EXPORT	start

start
	LDR	R4, =testarr
	LDR	R5, =N

	;
	; call sort(testarr, N)
	;


sort
	;
	; sort subroutine
	;


swap
	;
	; swap subroutine
	;


stop	B	stop


	AREA	TestData, DATA, READWRITE
N	EQU	10
testarr	SPACE	3,9,2,1,8,0,7,4,9,6
	END
