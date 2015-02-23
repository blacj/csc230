@ File: A2csc120.s
@ Jaimee Blackwood, 
@ Template in ARM for the program based on a subset of
@ the C program written for Assignment 1 
@ The original program in C reads a 2D image from an input file, applies
@ to it some image processing transformation upon request and
@ prints the output both to the screen and to a file.
@ The 2D image is stored and handled as a 2D array of characters. */

@@@@@@ REVISED PSEUDO CODE FOR THE ARM PROGRAM  *******
@Initialization:
@	Open the input file
@		if problems, print message and exit program
@	Print a header message to screen
@Obtain the input data:
@	Read row size (Rsize1) and column size (Csize1) of image from the input file
@	Read exactly (Rsize1)x(Csize1) integers as elements for an image,
@		convert to characters, and store as 2D char array
@	Print image as characters with headings to screen
@Processing the image:
@	Construct the Horizontal Mirror of the image into a second image
@		and print the resulting image with headings to screen
@	Construct the Vertical Mirror of the image into a second image
@		and print the resulting image with headings to screen
@BONUS: 	Construct the Diagonal Right of the image into a second image
@		and print the resulting image with headings (note that this
@		is the equivalent of constructing the transpose of a matrix)
@Closure:
@	Print a final message to screen
@	Close the input file
@	Exit the program */

@ Code for File I/O taken from IO_Example2a.s 

	.equ	MAXROW, 10 @ Maximum of 10 rows
	.equ	MAXCOL, 10 @ Maximum of 10 columns
@ We use nicer labels for the hex SWI codes:
	.equ	SWI_Open,  	0x66	@ open a file
	.equ	SWI_Close, 	0x68	@ close a file
	.equ	FileInputMode,  0	@ Input mode for file
	.equ	SWI_RdInt,	0x6c	@ Read an Integer from a file
	.equ	SWI_PrChr,	0x00  	@ Write a byte as an ASCII char to Output View
	.equ	SWI_PrStr, 	0x69  	@ Write a null-ending string 
	.equ	SWI_PrInt,	0x6b	@ Write an Integer
	.equ	Stdout,		1	@ Set output mode to be Output View
	.equ	SWI_Exit, 	0x11  	@ Stop execution
	
	.equ	AMP_CHAR,  0x26
	.equ	PLUS_CHAR, 0x2B
	.global _start
	.text	
_start:

@@@ Refer to IO Primer in ARMSim# and to Lab 5: IO_Example2a.s and to QUIZ 3 
@@@ Refer also to the C code from Assignment 1 (answer from instructor posted)
@ ===============================================================
@	Open the input file for reading
@		if problems, print message to screen and exit
	ldr	r0,=InputFileName		@ set Name for input file
	mov	r1,#0				@ mode is input
	swi	SWI_Open			@ open file for input
	bcs	InFileError 		@ Check Carry-Bit (C): if= 1 then ERROR
	ldr	r1,=InputFileHandle	@ if OK, load input file handle
	str	r0,[r1]				@ save the file handle	

@ ===============================================================
@ 	Print a header message with your name and student number
@@@@@ 
	mov	r0, #Stdout
	ldr	r1, =HelloMsg
	swi	SWI_PrStr 	@ R0:target, R1:msg


@ ===============================================================
@ 	Print an initial message for the program opening
@@@@@	'Starting...' is printed with HelloMsg above

@ =================================================
@ 	Read row size and column size of image from the input file
@@@@@ This is given to you as a further example of how to read
@@@@@ integers from a file. Use it as a guide to read the
@@@@@ image elements below
	ldr	r1, =InputFileHandle	@get file name
	ldr	r1, [r1]
	mov	r0, r1		@ R0 has file handle
	swi	SWI_RdInt 	@ Read and result in R0
	mov	r2, r0    	@ R2=rows
	mov	r0, r1		@ R0 has file handle
	swi	SWI_RdInt 	@ Read and result in R0
	mov	r3, r0    	@ R3=cols

	ldr	r1, =Rsize1
	str	r2, [r1]    	@ store rows
	ldr	r1, =Csize1
	str	r3, [r1]    	@ store cols

@ =================================================
@	Read exactly (Rsize1)x(Csize1) integers as elements for an image, 
@	convert each correctly to characters, and store as 2D char array
@@@@@ YOUR CODE HERE: Read exactly (Rsize1)x(Csize1) integers 
@@@@@ as elements for an image,convert to characters, and store as 2D char array

	mul	r4,r2,r3	@ R4 = rows x cols
	ldr	r1, =InputFileHandle	@get file name
	ldr	r1, [r1]
	ldr	r7, =IM1
	
LOOP:	mov	r0, r1		@ R0 has file handle
	swi	SWI_RdInt 	@ Read and result in R0
	mov	r5, r0    	@ R5=0 or 1
	cmp 	r5, #0		@ check what was read
	beq	ZERO		@ if 0 branch to ZERO
	cmp	r5, #1		@ check - should be 1 if not 0
	beq	ONE		@ if 1 branch to ONE	

BACK:	sub 	r4,r4, #1	@ countdown num elements left
	add	r7, r7, #1	@ add 4 to adress of IM
	cmp 	r4, #0		@ is there still elements left?
	bne	LOOP		@ if yes, continue
	bal 	NEXT		@ if not, move on
	
ZERO:	mov	r0, #'- 	@ change to char and store
	strb	r0, [r7]
	bal 	BACK		@ back to loop
	
ONE:	mov	r0, #'O		@ change to char and store
	strb	r0, [r7]
	bal 	BACK		@ back to loop
	

@ =================================================
@	Print original image as characters with headings 

@ Print heading message for the original image
@@@@@ 
NEXT:	mov	r0, #Stdout
	ldr	r1, =OrIm
	swi	SWI_PrStr 	@ R0:target, R1:msg
	
	
@ Set up the imput parameters to call PrImage to print the image
	ldr	r7,=IM1		@ R7 = address of IM1
	ldr	r2,=Rsize1
	ldr	r2,[r2]		@ R2 = Rsize1
	ldr	r3,=Csize1
	ldr	r3,[r3]		@ R3 = Csize1
@@@@@ choose the correct routine according to your storage choices
	BL	PrImage		@ PrImage(&Im2:R7,Rsize1:R2,Csize1:R3)
	@BL	PrImage2	@ PrImage(&Im2:R7,Rsize1:R2,Csize1:R3)
	
@ =================================================
@ Horizontal Mirror

	
	ldr	r1, =IM1	@ R1 = address of IM1
	ldr	r2, =IM2	@ R2 = address of IM2
		
@@@@@ YOUR CODE HERE to produce the horizontal mirror 
@ 	of IM1 in IM2
	
	
	
	ldr 	r9, =Rsize1	@ R9 =  number of cols
	ldr	r9, [r9]
	ldr 	r10, =Csize1	@ R10 = number of rows
	ldr	r10, [r10]
	
	ldr 	r8, =Rsize1	@ will count current row
	ldr	r8, [r8]	@ and used to offset pointer for IM1
	sub	r8, r8, #1
	
HLOOP:	ldr 	r10, =Csize1	@ R10 = cols/elems in a row
	ldr	r10, [r10]
	
	ldr	r1, =IM1	@ R1 = address of IM1
	mul	r6, r10, r8	@ calclulate which row to load from
	add	r1, r1, r6	@ offset pointer, will load from this address
	
CHLOOP: ldrb 	r6, [r1], #1	@ load what's in IM1
	strb 	r6, [r2], #1	@ store in IM2
	
	subs 	r10, r10, #1	@ do this for the length of the row
	bne	CHLOOP
	
	sub	r8, r8, #1	@ continue until R8 = -1
	cmp	r8, #-1		
	bne	HLOOP
	
		
@ =================================================
@ Print IM2 as characters with headings

@ Print heading message for the original image
@@@@@ YOUR CODE HERE
	
	mov	r0, #Stdout
	ldr	r1, =HrIm
	swi	SWI_PrStr 	@ R0:target, R1:msg
	
@ set up to call routine to print the image
	ldr	r7,=IM2		@ R7 = address of IM2
	ldr	r2,=Rsize1
	ldr	r2,[r2]		@ R2 = Rsize1
	ldr	r3,=Csize1
	ldr	r3,[r3]		@ R3 = Csize1
@@@@@ choose the correct routine according to your storage choices
	BL	PrImage		@ PriImage(&Im2:R7,Rsize1:R2,Csize1:R3)
	@ BL	PrImage2	@ PriImage(&Im2:R7,Rsize1:R2,Csize1:R3)
@ =================================================
@ Vertical Mirror

	ldr	r1, =IM1	@ R1 = address of IM1
	ldr	r2, =IM2	@ R2 = address of IM2
	
@@@@@ YOUR CODE HERE to produce the vertical mirror 
@ 	of IM1 in IM2

	ldr 	r9, =Rsize1	@ R9 =  rows
	ldr	r9, [r9]
	ldr 	r10, =Csize1	@ R10 = cols
	ldr	r10, [r10]
	
	mov	r7,#1		@ used as counter - holds current row
	
VLOOP:	ldr 	r1, =IM1	@ load adress of IM1 for each loop
	sub	r1, r1, #1	@ subtract one to prepare for offsetting
	ldr 	r6, =Csize1	@ R6 = number of columns
	ldr	r6, [r6]
	mul	r5,r6,r7	@ R5 = (# elements in a row) x (current row)
	add	r1, r1, r5	@ used to offset pointer
	
	
CVLOOP:	ldrb 	r8, [r1]	@ load from r1/IM1
	strb 	r8, [r2]	@ store in r2/IM2
	sub 	r1, r1, #1	@ decrement address pointer of IM1 to load next 
	add	r2, r2, #1	@ increment address pointer of IM2 to store next
	sub	r6, r6, #1	@ decrement current column
	cmp	r6, #0		@ if still more columns, continue
	BNE 	CVLOOP

	add	r7, r7, #1	@ increment current row
	cmp	r7, r9		@ if equal all rows completed
	BNE	VLOOP
	
	


	
@ =================================================
@ Print IM2 as characters with headings

@ Print heading message for the original image
@@@@@ YOUR CODE HERE

	mov	r0, #Stdout
	ldr	r1, =VrIm
	swi	SWI_PrStr 	@ R0:target, R1:msg
	
@ set up to call routine to print the image
	ldr	r7,=IM2		@ R7 = address of IM2
	ldr	r2,=Rsize1
	ldr	r2,[r2]		@ R2 = Rsize1
	ldr	r3,=Csize1
	ldr	r3,[r3]		@ R3 = Csize1
@@@@@ choose the correct routine according to your storage choices
	BL	PrImage		@ PriImage(&Im2:R7,Rsize1:R2,Csize1:R3)
	@ BL	PrImage2	@ PriImage(&Im2:R7,Rsize1:R2,Csize1:R3)
		
@ =================================================
@ Print a final message to screen  
@@@@@ YOUR CODE HERE

@ =================================================
@ Close the input file
	ldr	R0, =InputFileHandle  @ get address of file handle
	ldr	R0, [R0]              @ get value at address
	
	
	
	swi	SWI_Close
	
Exit:
	mov	r0, #Stdout
	ldr	r1, =EndMsg
	swi	SWI_PrStr 	@ R0:target, R1:msg
	
	swi	SWI_Exit
	
InFileError:
	mov	R0,#Stdout		@ to screen	
	ldr	R1, =FileOpenInpErrMsg  
	swi	SWI_PrStr  		@ display error message
	bal	Exit            @ give up, exit
	
@ =================================================
@ PriImage(&ImageChar:R7,RowSize:R2,ColSize:R3)
@ Print a 2D array of char row by row
@ R7 = address of 2D array, R2 = # rows, R3 = # columns
@ Assumptions: elements are stored consecutively
PrImage:
	STMFD	sp!,{r0-r5,lr}	;save registers
	mov	r4,r7		@ R4 is pointer to array elements
ROWLOOP:
	mov	r5,r3		@ set column counter
COLLOOP:
	ldrb	r0,[r4],#1		@ get char to be printed
	swi	SWI_PrChr		@ print it
	subs	r5,r5,#1		@ next element, same row?
	bne	COLLOOP
	mov	R0,#Stdout		@ mode is Output view
	ldr	r1, =EOL		@ end of line
	swi	SWI_PrStr
	subs	r2,r2,#1		@ next row?
	bne	ROWLOOP
	
DonePrImage:
	LDMFD	sp!,{r0-r5,pc}	;load registers and return
	
@ =================================================
@ PrImage2(&Im1:R7,RowSize:R2,ColSize:R3)
@ Print a 2D array of char row by row
@ R7 = address of 2D array, R2 = # rows, R3 = # columns
@ Assumption: 2D char array has size [MAXROW][MAXCOL]
@ and here only elemnts in R2 x R3 size are printed
PrImage2:
	STMFD	sp!,{r0-r7,lr}	;save registers
		
	mov	r6,#-MAXCOL	@ R6= distance to current row being printed
ROWLOOP2:
	mov	r4,r7		@ R4 is pointer to array base
	add	r6,r6,#MAXCOL	@ increase offset to next row start
	mov	r5,r3		@ R5= # elements to be printed in each row
COLLOOP2:
	ldrb	r0,[r4,r6]	@ get char to be printed
	add	r4,r4,#1	@ ready to point to next char
	swi	SWI_PrChr	@ print it
	subs	r5,r5,#1	@ next element, same row?
	bne	COLLOOP2	
	ldr	r1, =EOL	@ end of line
	mov	R0,#Stdout	@ mode is Output view
	swi	SWI_PrStr	
	subs	r2,r2,#1	@ next row?
	bne	ROWLOOP2
	
DonePrImage2:
	LDMFD	sp!,{r0-r7,pc}	;load registers and return
	
	.data
Rsize1:	.word	0
Csize1:	.word	0
InputFileHandle:	.skip	4
IM1:	.skip	MAXROW*MAXCOL
IM2:	.skip	MAXROW*MAXCOL
InputFileName:  	.asciz	"A2inF2.txt"
FileOpenInpErrMsg: 	.asciz	"Failed to open input file \n"
OrIm: 	.asciz	"\nThe original image contains: \n"
VrIm: 	.asciz	"\nThe vertical mirror image contains: \n"
HrIm: 	.asciz	"\nThe horizontal mirror image contains: \n"
EOL:	.asciz	"\n"
HelloMsg:	
	.ascii	"\n Jaimee Blackwood - Student Number V00755181 \n"
	.ascii	"\n File = A2csc230.s - February 2013 \n"
	.ascii	"\n CSC 230, Assignment 2 \n\n"
	.asciz	"Starting: \n"
EndMsg:	.asciz	"\n\nFile closed. Program completed. Bye!"
	.end
