
T0	EQU	0xE0004000								;	Timer 0 Base Address
T1	EQU	0xE0008000								;	Timer 1 Base Address

IR	EQU	0													;	 Add this to a timer's base address to get actual register address
TCR	EQU	4 													; Timer Command Reset Register offset
MCR	EQU	0x14 											;	 Timer Mode Reset and Interrupt Offset
MR0	EQU	0x18 											;	 Match Register (counter) offset

TimerCommandReset			EQU	2					; Reset timer
TimerCommandRun				EQU	1		    	;Run timer
TimerModeResetAndInterrupt	EQU	3		;Reset timer mode and interrupt
TimerResetTimeR0Interrupt	EQU	1 		; Reset timer 0 and interrupt
TimerResetAllInterrupts		EQU	0xFF 	; Reset all timer interrupts

;VIC Stuff -- UM, Table 41
VIC	EQU	0xFFFFF000									; VIC Base Address
IntEnable	EQU	0x10 								;	Interrupt Enable
VectAddr	EQU	0x30 								;	
VectAddR0	EQU	0x100 								;Vectored Interrupt 0
VectCtrl0	EQU	0x200 								; Vectored Interrupt Control 0

TimeR0ChannelNumber	EQU	4						;/UM, Table 63
TimeR0Mask			EQU	1<<TimeR0ChannelNumber	; UM, Table 63
IRQslot_en			EQU	5								; UM, Table 58

;Labels & Values
IO0PIN EQU 0xE0028000
IO0SET EQU 0xE0028004
IO0DIR EQU 0xE0028008
IO0CLR EQU 0xE002800C



	AREA	InitialisationAndMain, CODE, READONLY
	IMPORT	main


	EXPORT	start
start





;initialisation code
	LDR R1,=IO0DIR
	LDR	R2,=0x00260000 ; selecting pins p0.17 && p0.18 && p0.21			 binary mask : 0b 0000 0000 0001 0011 0000 0000 0000 0000				
	STR	R2,[R1]												
	LDR	R6,=IO0SET		 ;r6 = OFF								
	STR	R2,[R6]												
	LDR	R7,=IO0CLR		 ; r7 = ON							

	LDR	R3,=0x00200000  ; red mask				
	LDR	R5,=0x00040000	; blue mask
	LDR R9,=0x00020000 ; green mask
	
	mov r10,#0; 0 = red, 1 = blue, 2 = green
	mov r11,#0 ; boolean
	




	LDR R1,=ticks										;Used to count to a second
	LDR R0,=0
	STR R0, [R1]
	
	



	LDR	R0,=VIC											

	LDR	R1,=irqhan									
	STR	R1,[R0,#VectAddR0] 						

	MOV	R1,#TimeR0ChannelNumber+(1<<IRQslot_en)
	STR	R1,[R0,#VectCtrl0] 						

	MOV	R1,#TimeR0Mask
	STR	R1,[R0,#IntEnable]						

	MOV	R1,#0
	STR	R1,[R0,#VectAddr]   					

; Initialise Timer 0
	LDR	R0,=T0												

	MOV	R1,#TimerCommandReset
	STR	R1,[R0,#TCR]									

	MOV	R1,#TimerResetAllInterrupts
	STR	R1,[R0,#IR]										

	LDR	R1,=(14745600/200)-1	 			
	STR	R1,[R0,#MR0]									

	MOV	R1,#TimerModeResetAndInterrupt
	STR	R1,[R0,#MCR]									

	MOV	R1,#TimerCommandRun
	STR	R1,[R0,#TCR]								

;Mainline
xloop

	LDR R1, =ticks
	LDR R0, [R1]											;R0 = ticks

	CMP R0, #200										;if(ticks == 200)
	BLT xloop

	cmp r11,#0
	bne xloop
	
	mov r11,#1
	add r10, r10,#1
	cmp r10,#3
	bne continue
	mov r10,#0;
	
continue
	; every 200 ticks i count 0,1,2,0,1,2... where the numbers represent
	
		
	; turn off all leds
	; and then turn on the required led
	str r3,[r6]
	str r5,[r6] 
	str r9,[r6]
	
	cmp r10,#0
	beq red
	cmp r10,#1
	beq blue
	cmp r10,#2
	beq green
	
	
red
	str r3,[r7] ; turn on red
	B skip

blue
	str r5,[r7] ; turn on blue
	B skip

green
	str r9,[r7] ; turn on green
	B skip

	
skip   								
	
while
	LDR R0, [R1]
	cmp r0, #200
	beq while
	mov r11, #0
		;   store new ticks val
	B	xloop


	AREA	InterruptStuff, CODE, READONLY

irqhan
	SUB LR, LR, #4									;Adjust the LR to last location
	STMFD SP!,{R0-R1,LR}							;Preserve registers on the stack

	LDR R1,=ticks
	LDR R0, [R1]
	ADD R0, R0, #1										;Ticks++
	cmp r0,#201
	bne continue2
	LDR R0, =1										;  reset t
	
continue2
	STR R0, [R1]

;RESET TIMER
	LDR	R0,=T0
	MOV	R1,#TimerResetTimeR0Interrupt
	STR	R1,[R0,#IR]	   								;Remove MR0 interrupt request from timer

	LDR	R0,=VIC
	MOV	R1,#0													;Stop VIC from making interrupt to CPU
	STR	R1,[R0,#VectAddr]							;Reset VIC

;POP  OFF STACK 
	LDMFD SP!,{R0-R1,PC}^							;Load values off stack, LR loaded into PC
																		;And also restoring the CPSR (what the ^ does)

	AREA	Subroutines, CODE, READONLY

	AREA	Stuff, DATA, READWRITE

ticks DCD 0

	END