@ CSC230 --  Traffic Light simulation program
@ Latest edition: Fall 2011
@ Author:  Micaela Serra 
@ Modified by: Jaimee Blackwood V00755181 

@===== STAGE 0
@  	Sets initial outputs and screen for INIT
@ Calls StartSim to start the simulation,
@	polls for left black button, returns to main to exit simulation

        .equ    SWI_EXIT, 		0x11		@terminate program
        @ swi codes for using the Embest board
        .equ    SWI_SETSEG8, 		0x200	@display on 8 Segment
        .equ    SWI_SETLED, 		0x201	@LEDs on/off
        .equ    SWI_CheckBlack, 	0x202	@check press Black button
        .equ    SWI_CheckBlue, 		0x203	@check press Blue button
        .equ    SWI_DRAW_STRING, 	0x204	@display a string on LCD
        .equ    SWI_DRAW_INT, 		0x205	@display an int on LCD  
        .equ    SWI_CLEAR_DISPLAY, 	0x206	@clear LCD
        .equ    SWI_DRAW_CHAR, 		0x207	@display a char on LCD
        .equ    SWI_CLEAR_LINE, 	0x208	@clear a line on LCD
        .equ 	SEG_A,	0x80		@ patterns for 8 segment display
		.equ 	SEG_B,	0x40
		.equ 	SEG_C,	0x20
		.equ 	SEG_D,	0x08
		.equ 	SEG_E,	0x04
		.equ 	SEG_F,	0x02
		.equ 	SEG_G,	0x01
		.equ 	SEG_P,	0x10                
        .equ    LEFT_LED, 	0x02	@patterns for LED lights
        .equ    RIGHT_LED, 	0x01
        .equ    BOTH_LED, 	0x03
        .equ    NO_LED, 	0x00       
        .equ    LEFT_BLACK_BUTTON, 	0x02	@ bit patterns for black buttons
        .equ    RIGHT_BLACK_BUTTON, 0x01
        @ bit patterns for blue keys 
        .equ    Ph1, 		0x0100	@ =8
        .equ    Ph2, 		0x0200	@ =9
        .equ    Ps1, 		0x0400	@ =10
        .equ    Ps2, 		0x0800	@ =11

		@ timing related
		.equ    SWI_GetTicks, 		0x6d	@get current time 
		.equ    EmbestTimerMask, 	0x7fff	@ 15 bit mask for Embest timer
											@(2^15) -1 = 32,767        										
        .equ	OneSecond,	1000	@ Time intervals
        .equ	TwoSecond,	2000
	@define the 2 streets
	@	.equ	MAIN_STREET		0
	@	.equ	SIDE_STREET		1
 
       .text           
       .global _start

@===== The entry point of the program
_start:		
	@ initialize all outputs
	BL Init				@ void Init ()
	@ Check for left black button press to start simulation
RepeatTillBlackLeft:
	swi     SWI_CheckBlack
	cmp     r0, #LEFT_BLACK_BUTTON	@ start of simulation
	beq		StrS
	cmp     r0, #RIGHT_BLACK_BUTTON	@ stop simulation
	beq     StpS
	bne     RepeatTillBlackLeft
StrS:	
	BL StartSim		@else start simulation: void StartSim()
	@ on return here, the right black button was pressed
StpS:
	BL EndSim		@clear board: void EndSim()
EndTrafficLight:
	swi	SWI_EXIT
	
@ === Init ( )-->void
@   Inputs:	none	
@   Results:  none 
@   Description:
@ 		both LED lights on
@		8-segment = point only
@		LCD = ID only
Init:
	stmfd	sp!,{r1-r10,lr}
	@ LCD = ID on line 1
	mov	r1, #0			@ r1 = row
	mov	r0, #0			@ r0 = column 
	ldr	r2, =lineID		@ identification
	swi	SWI_DRAW_STRING
	@ both LED on
	mov	r0, #BOTH_LED	@LEDs on
	swi	SWI_SETLED
	@ display point only on 8-segment
	mov	r0, #10			@8-segment pattern off
	mov	r1,#1			@point on
	BL	Display8Segment

DoneInit:
	LDMFD	sp!,{r1-r10,pc}

@===== EndSim()
@   Inputs:  none
@   Results: none
@   Description:
@      Clear the board and display the last message
EndSim:	
	stmfd	sp!, {r0-r2,lr}
	mov	r0, #10				@8-segment pattern off
	mov	r1,#0
	BL	Display8Segment		@Display8Segment(R0:number;R1:point)
	mov	r0, #NO_LED
	swi	SWI_SETLED
	swi	SWI_CLEAR_DISPLAY
	mov	r0, #5
	mov	r1, #7
	ldr	r2, =Goodbye
	swi	SWI_DRAW_STRING  	@ display goodbye message on line 7
	ldmfd	sp!, {r0-r2,pc}
	
@ === StartSim ( )-->void
@   Inputs:	none	
@   Results:  none 
@   Description:
@ 		XXX
StartSim:
	stmfd	sp!,{r1-r10,lr}
	
SLoop:	
	mov	r7, #0			@used as counter/time for S1/S2
SS1:
	mov	r0, #LEFT_LED 	@turn on left LED
	swi	SWI_SETLED

	mov	r10, #1			@draw state and screen S1.1
	BL DrawState
	BL DrawScreen
	mov r1, #1			@display point on 8 seg
	mov r0, #10
	BL Display8Segment
	mov	r10,#TwoSecond	@ display screen for 2 sec
	BL Wait 
	
	mov	r10, #2			@ draw screen S1.2
	BL DrawScreen		
	mov	r10,#OneSecond	@ display for 1 sec
	BL Wait
	
	add	r7,r7,#3		@ add 3 to timer
	cmp	r7, #12			@ until 12 second is reached
	bne SS1
	
	mov r7, #0			@ reset timer for S2 
	
	swi     SWI_CheckBlack	@ if black button is pressed...
	cmp     r0, #RIGHT_BLACK_BUTTON	@ stop simulation
	beq     StpS
	
	swi     SWI_CheckBlue	@check for buttons 8-11
	cmp     r0, #Ph1
	beq PEDP1
	cmp     r0, #Ph2
	beq PEDP1
	cmp     r0, #Ps1
	beq PEDP1
	cmp     r0, #Ps2
	beq PEDP1				@ if any have been pushed, start ped. at p1 (since called from s1)

SS2:	
	mov	r10, #2				@ display state S2
	BL DrawState
	mov	r10, #1				@ display state S2.1 (also S1.1)
	BL DrawScreen
	mov r6, #40				@ r6 = 40 used as a countdown -- polling (40 x 50 = 2000 = 2 sec)
SS21wait:	
	mov	r10, #50			@ used to wait 1/20th of a second
	BL Wait		

	swi     SWI_CheckBlack	@ end instantly if black right pushed
	cmp     r0, #RIGHT_BLACK_BUTTON	@ stop simulation
	beq     StpS
	swi     SWI_CheckBlue	@ if a blue (8-11) has been pressed, interrupt & jump to PEDP1 
	cmp     r0, #Ph1
	beq PEDP1
	cmp     r0, #Ph2
	beq PEDP1
	cmp     r0, #Ps1
	beq PEDP1
	cmp     r0, #Ps2
	beq PEDP1
	sub	r6,r6,#1			@ counts down from 40 -> 0
	cmp r6, #0
	bne SS21wait			@ continues S2.1 for 2 seconds this way
	
	mov r6, #20				@ sets r6 to 20 for S2.2 ( 20 x 50 = 1000 = 1sec)
	mov	r10, #2				@ draw screen S2.2 (same as S1.2)
	BL DrawScreen
	mov	r10, #50			

SS22wait:	
	BL Wait
	
	swi     SWI_CheckBlack	@ end instantly if black right pushed
	cmp     r0, #RIGHT_BLACK_BUTTON	@ stop simulation
	beq     StpS
	swi     SWI_CheckBlue	@ continue polling for blue buttons
	cmp     r0, #Ph1
	beq PEDP1
	cmp     r0, #Ph2
	beq PEDP1
	cmp     r0, #Ps1
	beq PEDP1
	cmp     r0, #Ps2
	beq PEDP1
	
	sub	r6,r6,#1		@ count down 20 -> 0
	cmp r6, #0			@ until then, repeat  S2.2
	bne SS22wait
		
	add	r7,r7,#3		@ add 3 secs to time
	cmp	r7, #6			@ when timer = 6s, move on to S3
	bne SS2
	
	mov r7, #0			
	
SS3:
	mov	r10, #3			@ display screen/state for S3
	BL DrawState
	BL DrawScreen
	mov r10,#TwoSecond	@ display for 2 sec
	mov r0, #10			@ 8 seg display = blank
	mov r1, #0
	BL Display8Segment
	BL Wait
	
SS4:
	mov	r0, #BOTH_LED	@ light up both LED
	swi	SWI_SETLED		
	
	mov	r10, #4			@ display screen/state for S4
	BL DrawState
	BL DrawScreen
	mov r10,#OneSecond	@ display for 1sec
	BL Wait
	
SS5:
	mov	r0, #RIGHT_LED	@ light up just right LED
	swi	SWI_SETLED
	
	mov	r10, #5			@ display screen/state for S5
	BL DrawState
	BL DrawScreen
	mov r0, #10			@ display point on 8seg
	mov r1, #1
	BL Display8Segment
	mov r10,#TwoSecond	@ display for 6 seconds
	BL Wait
	BL Wait
	BL Wait
	
SS6:
	mov	r10, #6			@ display screen/state for S6
	BL DrawState
	BL DrawScreen
	mov r10,#TwoSecond	@ display for two seconds
	mov r0, #10			@ blank 8seg
	mov r1, #0
	BL Display8Segment
	BL Wait
	
SS7: 
	mov r7, #0
	mov	r0, #BOTH_LED	@ turn on both LED
	swi	SWI_SETLED	
	
	mov r10, #7			@ display state S7
	BL DrawState
	mov r10, #4			@ display screen S7 ( = S4)
	BL DrawScreen
	mov r10,#OneSecond
	BL Wait
	
	swi     SWI_CheckBlack		@ end if black right pushed
	cmp     r0, #RIGHT_BLACK_BUTTON	@ stop simulation
	beq     StpS
	swi     SWI_CheckBlue		@ ped cycle if blue (8-11) pushed
	cmp     r0, #Ph1
	beq PEDP3
	cmp     r0, #Ph2
	beq PEDP3
	cmp     r0, #Ps1
	beq PEDP3
	cmp     r0, #Ps2
	beq PEDP3
	
	bal     SLoop		@ do this forever. and ever. until black right ends it

PEDP1:
	mov	r7, #1			@ used as boolean, determines where PED was called (S1, S2 -> P1 | S7 -> P3)
@STATE P1	
	mov	r0, #LEFT_LED	@ turn on left LED only
	swi	SWI_SETLED
	mov	r10, #8			@ display P1 state/screen
	BL DrawState
	BL DrawScreen
	mov r1, #0			@ display blank 8seg
	mov r0, #10
	BL Display8Segment
	mov r10,#TwoSecond	@ display for 2 sec
	BL Wait
	
@STATE P2
	mov	r0, #BOTH_LED	@ turn on both LED
	swi	SWI_SETLED
	mov	r10, #9			@ display state P2/screen P3 ( = S4)
	BL DrawState
	mov r10, #4
	BL DrawScreen
	mov r10,#OneSecond	@ display for 1 sec
	BL Wait
	
PEDP3:	@STATE P3
	mov	r10, #10
	BL DrawState		@ draw state/screen for P3
	BL DrawScreen
	mov r5, #6			@ r5 used as countdown timer
PP3SEG:	
	mov r10,#OneSecond	@ for each second,
	mov r0, r5			@ display r0 (r5 as it counts down) on the 8Seg
	BL Display8Segment
	BL Wait
	sub r5, r5, #1		@ subtract to countdown
	cmp r5, #2			@ show P3 until 2 sec remain
	bne PP3SEG

	@P4
	mov	r10, #11		@ display state/screen for P4
	BL DrawState
	BL DrawScreen
	mov	r0, #2			@ display 2 on 8 seg 
	BL Display8Segment
	mov r10,#OneSecond	@ wait one second
	BL Wait				
	mov r0, #1			@ display 1 on 8 seg
	BL Display8Segment
	BL Wait				@ wait one second
	
	@P5
	mov	r10, #12		@ draw state/screen for P5
	BL DrawState
	mov r10, #4			@ screen P5 == S4
	BL DrawScreen
	mov	r0, #0			@ display 0 on 8seg
	BL Display8Segment
	mov r10,#OneSecond	@ wait one sec
	BL Wait
	mov r0, #10			@ make 8seg display show point
	mov r1, #1
	BL Display8Segment
	
	swi     SWI_CheckBlack		@check for end press
	cmp     r0, #RIGHT_BLACK_BUTTON	@ stop simulation
	beq     StpS
	
	cmp r7, #1			@ determine where to return based on "boolean"
	beq SS5
	bal SS1	
	
DoneStartSim:
	LDMFD	sp!,{r1-r10,pc}
		
@ ==== void Wait(Delay:r10) 
@   Inputs:  R8 = delay in milliseconds
@   Results: none
@   Description:
@      Wait for r10 milliseconds using a 15-bit timer 
Wait:
	stmfd	sp!, {r0-r2,r7-r10,lr}
	ldr     r7, =EmbestTimerMask
	swi     SWI_GetTicks		@get time T1
	and		r1,r0,r7			@T1 in 15 bits
WaitLoop:
	swi SWI_GetTicks			@get time T2
	and		r2,r0,r7			@T2 in 15 bits
	cmp		r2,r1				@ is T2>T1?
	bge		simpletimeW
	sub		r9,r7,r1			@ elapsed TIME= 32,676 - T1
	add		r9,r9,r2			@    + T2
	bal		CheckIntervalW
simpletimeW:
		sub		r9,r2,r1		@ elapsed TIME = T2-T1
CheckIntervalW:
	cmp		r9,r10				@is TIME < desired interval?
	blt		WaitLoop
WaitDone:
	ldmfd	sp!, {r0-r2,r7-r10,pc}	

@ *** void Display8Segment (Number:R0; Point:R1) ***
@   Inputs:  R0=bumber to display; R1=point or no point
@   Results:  none
@   Description:
@ 		Displays the number 0-9 in R0 on the 8-segment
@ 		If R1 = 1, the point is also shown
Display8Segment:
	STMFD 	sp!,{r0-r2,lr}
	ldr 	r2,=Digits
	ldr 	r0,[r2,r0,lsl#2]
	tst 	r1,#0x01 @if r1=1,
	orrne 	r0,r0,#SEG_P 			@then show P
	swi 	SWI_SETSEG8
	LDMFD 	sp!,{r0-r2,pc}
	
@ *** void DrawScreen (PatternType:R10) ***
@   Inputs:  R10: pattern to display according to state
@   Results:  none
@   Description:
@ 		Displays on LCD screen the 5 lines denoting
@		the state of the traffic light
@	Possible displays:
@	1 => S1.1 or S2.1- Green High Street
@	2 => S1.2 or S2.2	- Green blink High Street
@	3 => S3 or P1 - Yellow High Street   
@	4 => S4 or S7 or P2 or P5 - all red
@	5 => S5	- Green Side Road
@	6 => S6 - Yellow Side Road
@	7 => P3 - all pedestrian crossing
@	8 => P4 - all pedestrian hurry
DrawScreen:
	STMFD 	sp!,{r0-r2,lr}
	
	@ S7, P2, P5 skipped because they equal S4. 4 is passed rather than 7, 9, 12
	cmp	r10,#1	@ S1
	beq	S11
	cmp	r10,#2	@ S2
	beq	S12
	cmp	r10,#3	@ S3
	beq	S3
	cmp	r10,#4	@ S4
	beq	S4
	cmp	r10,#5	@ S5
	beq	S5
	cmp	r10,#6	@ S6
	beq	S6
	cmp	r10,#8	@ P1
	beq	S3
	cmp	r10,#10	@ P3
	beq	P3
	cmp	r10,#11	@ P4
	beq	P4
	bal	EndDrawScreen
	
S11:
	ldr	r2,=line1S11
	mov	r1, #6			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line3S11
	mov	r1, #8			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line5S11
	mov	r1, #10			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawScreen
S12:
	ldr	r2,=line1S12
	mov	r1, #6			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line3S12
	mov	r1, #8			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line5S12
	mov	r1, #10			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawScreen
S3:
	ldr	r2,=line1S3
	mov	r1, #6			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line3S3
	mov	r1, #8			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line5S3
	mov	r1, #10			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawScreen

S4:
	ldr	r2,=line1S4
	mov	r1, #6			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line3S4
	mov	r1, #8			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line5S4
	mov	r1, #10			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawScreen
S5:
	ldr	r2,=line1S5
	mov	r1, #6			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line3S5
	mov	r1, #8			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line5S5
	mov	r1, #10			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawScreen
S6:
	ldr	r2,=line1S6
	mov	r1, #6			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line3S6
	mov	r1, #8			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line5S6
	mov	r1, #10			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawScreen
P3:
	ldr	r2,=line1P3
	mov	r1, #6			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line3P3
	mov	r1, #8			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line5P3
	mov	r1, #10			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawScreen
P4:
	ldr	r2,=line1P4
	mov	r1, #6			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line3P4
	mov	r1, #8			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	ldr	r2,=line5P4
	mov	r1, #10			@ r1 = row
	mov	r0, #11			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawScreen

EndDrawScreen:
	LDMFD 	sp!,{r0-r2,pc}
	
@ *** void DrawState (PatternType:R10) ***
@   Inputs:  R10: number to display according to state
@   Results:  none
@   Description:
@ 		Displays on LCD screen the state number
@		on top right corner
DrawState:
	STMFD 	sp!,{r0-r2,lr}
	cmp	r10,#1
	beq	S1draw
	cmp	r10,#2
	beq	S2draw
	cmp	r10,#3
	beq	S3draw
	cmp	r10,#4
	beq	S4draw
	cmp	r10,#5
	beq	S5draw
	cmp	r10,#6
	beq	S6draw
	cmp	r10,#7
	beq	S7draw
	cmp	r10,#8
	beq	P1draw
	cmp	r10,#9
	beq	P2draw
	cmp	r10,#10
	beq	P3draw
	cmp	r10,#11
	beq	P4draw
	cmp	r10,#12
	beq	P5draw

	bal	EndDrawScreen
S1draw:
	ldr	r2,=S1label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
S2draw:
	ldr	r2,=S2label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
S3draw:
	ldr	r2,=S3label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
S4draw:
	ldr	r2,=S4label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
S5draw:
	ldr	r2,=S5label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState

S6draw:
	ldr	r2,=S6label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
S7draw:
	ldr	r2,=S7label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
P1draw:
	ldr	r2,=P1label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
P2draw:
	ldr	r2,=P2label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
P3draw:
	ldr	r2,=P3label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
P4draw:
	ldr	r2,=P4label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState
P5draw:
	ldr	r2,=P5label
	mov	r1, #2			@ r1 = row
	mov	r0, #30			@ r0 = column
	swi	SWI_DRAW_STRING
	bal	EndDrawState

EndDrawState:
	LDMFD 	sp!,{r0-r2,pc}
	
@@@@@@@@@@@@=========================
	.data
	.align
Digits:							@ for 8-segment display
	.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_G 	@0
	.word SEG_B|SEG_C 							@1
	.word SEG_A|SEG_B|SEG_F|SEG_E|SEG_D 		@2
	.word SEG_A|SEG_B|SEG_F|SEG_C|SEG_D 		@3
	.word SEG_G|SEG_F|SEG_B|SEG_C 				@4
	.word SEG_A|SEG_G|SEG_F|SEG_C|SEG_D 		@5
	.word SEG_A|SEG_G|SEG_F|SEG_E|SEG_D|SEG_C 	@6
	.word SEG_A|SEG_B|SEG_C 					@7
	.word SEG_A|SEG_B|SEG_C|SEG_D|SEG_E|SEG_F|SEG_G @8
	.word SEG_A|SEG_B|SEG_F|SEG_G|SEG_C 		@9
	.word 0 									@Blank 
	.align
lineID:		.asciz	"TrafficLight: Jaimee Blackwood V00755181"
@ patterns for all states on LCD
line1S11:		.asciz	"        R W        "
line3S11:		.asciz	"GGG W         GGG W"
line5S11:		.asciz	"        R W        "

line1S12:		.asciz	"        R W        "
line3S12:		.asciz	"  W             W  "
line5S12:		.asciz	"        R W        "

line1S3:		.asciz	"        R W        "
line3S3:		.asciz	"YYY W         YYY W"
line5S3:		.asciz	"        R W        "

line1S4:		.asciz	"        R W        "
line3S4:		.asciz	" R W           R W "
line5S4:		.asciz	"        R W        "

line1S5:		.asciz	"       GGG W       "
line3S5:		.asciz	" R W           R W "
line5S5:		.asciz	"       GGG W       "

line1S6:		.asciz	"       YYY W       "
line3S6:		.asciz	" R W           R W "
line5S6:		.asciz	"       YYY W       "

line1P3:		.asciz	"       R XXX       "
line3P3:		.asciz	"R XXX         R XXX"
line5P3:		.asciz	"       R XXX       "

line1P4:		.asciz	"       R !!!       "
line3P4:		.asciz	"R !!!         R !!!"
line5P4:		.asciz	"       R !!!       "

S1label:		.asciz	"S1"
S2label:		.asciz	"S2"
S3label:		.asciz	"S3"
S4label:		.asciz	"S4"
S5label:		.asciz	"S5"
S6label:		.asciz	"S6"
S7label:		.asciz	"S7"
P1label:		.asciz	"P1"
P2label:		.asciz	"P2"
P3label:		.asciz	"P3"
P4label:		.asciz	"P4"
P5label:		.asciz	"P5"

Goodbye:
	.asciz	"*** Traffic Light program ended ***"

	.end