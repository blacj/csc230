/* V00755181 Jaimee Blackwood
A1csc230.c January 31
CSC 230, Assignment 1, Programming */
/* This program reads in a small text file including an array of MAX 50 size vertically
and horizontally. It also reads in a variety of commands to modify and reprint the array
in several ways, mimicking image processing.*/
/*Learning aspects: Writing C, File I/O, manipulating arrays, printing arrays, function calls*/

#include <stdio.h>

#define MAXROW 50	/*set maximum sizes for image 2D array */
#define MAXCOL 50

/* Global variables */
FILE *fp_in;
FILE *fp_out;


/****** void VMirror(Image1, Image2, Nrows, Ncols) ******/
/* Given the 2D char array of Image1 and its dimensions,
	construct the vertical mirror image in Image 2 as in:
		copy columns (0,1,...,Ncols-1) of Image1
		to columns (Ncols-1,Ncols-2,...,1,0) respectively of Image2 */
	/*INPUT PARAMETERS:
		Image1 and Image2: 2D arrays of characters (initial and processed images)
		Nrows, Ncols: integers, number of rows and columns for given array.
	RETURN PARAMETER:
		None*/
void VMirror( char Image1[MAXROW][MAXCOL], char Image2[MAXROW][MAXCOL],
	int Nrows, int Ncols)
	{

		printf("Starting Vertical Mirror: \n");
		fprintf(fp_out, "Starting Vertical Mirror:\n");
		int i,j;

		for(i=0; i<Nrows; i++)
		{
			for(j=0; j<Ncols; j++)
			{
				Image2[i][j] = Image1[i][Ncols-1-j];
			}
		}

}/*End of VMirror*/


/****** void HMirror(Image1, Image2, Nrows, Ncols) ******/
/* Given the 2D char array of Image1 and its dimensions,
	construct the horizontal mirror image in Image 2 as in:
		copy rows (0,1,...,Nrows-1) of Image1
		to rows (Nrows-1,Nrows-2,...,1,0) respectively of Image2 */
	/*INPUT PARAMETERS:
		Image1 and Image2: 2D arrays of characters (initial and processed images)
		Nrows, Ncols: integers, number of rows and columns for given array.
	RETURN PARAMETER:
		None*/
void HMirror( char Image1[MAXROW][MAXCOL], char Image2[MAXROW][MAXCOL],
	int Nrows, int Ncols)
{

		printf("Starting Horizontal Mirror: \n");
		fprintf(fp_out, "Starting Horizontal Mirror:\n");

		int i,j;

			for(i=0; i<Nrows; i++)
			{
				for(j=0; j<Ncols; j++)
				{
						Image2[i][j] = Image1[Nrows-1-i][j];
				}
			}

}/*End of HMirror*/


/****** void DiagR(Image1, Image2, Nrows, Ncols) ******/
/*Given the 2D char array of Image1 and its dimensions,
	construct the flipped image in Image2 along the top
	left to bottom right diagonal as in:
		 copy col 0 of Image1 -> row 0 of Image2
		 copy col 1 of Image1 -> row 1 of Image2
		......................................
		 copy col (Ncols-1) of Image1 to row (Ncols-1) of Image2
		 NOTE: sizes of Image2 are inverted from Image1 */
	/*INPUT PARAMETERS:
		Image1 and Image2: 2D arrays of characters (initial and processed images)
		Nrows, Ncols: integers, number of rows and columns for given array.
	RETURN PARAMETER:
		None*/
void DiagR( char Image1[MAXROW][MAXCOL], char Image2[MAXROW][MAXCOL],
	int Nrows, int Ncols)
{

		printf("Starting Right Diagonal: \n");
		fprintf(fp_out, "Starting Right Diagonal:\n");

		int i,j;

				for(i=0; i<Nrows; i++)
				{
					for(j=0; j<Ncols; j++)
					{
						Image2[i][j] = Image1[j][i];
					}
				}

}/*End of DiagR*/


/****** void DiagL(Image1, Image2, Nrows, Ncols) ******/
/*Given the 2D char array of Image1 and its dimensions,
	construct the flipped image in Image2 along the top
	right to bottom left diagonal as in:
		copy col (Ncols-1) of Image1 -> row 0 of Image2
		copy col (Ncols-2) of Image1 -> row 1 of Image2
		......................................
		copy col 0 of Image1 -> row (Ncols-1) of Image2
		NOTE: sizes of Image2 are inverted from Image1 */
	/*INPUT PARAMETERS:
		Image1 and Image2: 2D arrays of characters (initial and processed images)
		Nrows, Ncols: integers, number of rows and columns for given array.
	RETURN PARAMETER:
		None*/
void DiagL( char Image1[MAXROW][MAXCOL], char Image2[MAXROW][MAXCOL],
	int Nrows, int Ncols)
{
		printf("Starting Left Diagonal: \n");
		fprintf(fp_out, "Starting Left Diagonal:\n");

		int i,j;

		for(i=0; i<Nrows; i++)
		{
			for(j=0; j<Ncols; j++)
			{
				Image2[i][j] = Image1[Ncols-1-j][Nrows-1-i];
			}
		}



}/*End of DiagL*/


/****** void RotR(Image1, Image2, Nrows, Ncols) ******/
/*Given the 2D char array of Image1 and its dimensions,
	construct the rotated by 90 degree image in Image2
	NOTE: sizes of Image2 are inverted from Image1 */
	/*INPUT PARAMETERS:
		Image1 and Image2: 2D arrays of characters (initial and processed images)
		Nrows, Ncols: integers, number of rows and columns for given array.
	RETURN PARAMETER:
		None*/
void RotR( char Image1[MAXROW][MAXCOL], char Image2[MAXROW][MAXCOL],
	int Nrows, int Ncols)
{
		printf("Starting Right Rotation: \n");
		fprintf(fp_out, "Starting Right Rotation:\n");

	int i,j;

		for(i=0; i<Nrows; i++)
		{
			for(j=0; j<Ncols; j++)
			{
				Image2[i][j] = Image1[Ncols-1-j][i];
			}
		}


}/*End of RotR*/


/****** void PrImage(Image, Nrows,Ncols) ******/
/* This procedure prints a 2D char array row by row
	both to the screen and to an output file (global) */
	/*INPUT PARAMETERS:
		Image1 and Image2: 2D arrays of characters (initial and processed images)
		Nrows, Ncols: integers, number of rows and columns for given array.
	RETURN PARAMETER:
		None*/
void PrImage( char Image[MAXROW][MAXCOL], int Nrows, int Ncols)
{
	int i,j;

	for(i=0; i<Nrows; i++)
	{
		for(j=0; j<Ncols; j++)
		{
			printf( "%c", Image[i][j] );
			fprintf(fp_out, "%c", Image[i][j] );
		}
		printf("\n");
		fprintf(fp_out,"\n");
	}
	printf("\n");
	fprintf(fp_out,"\n");


}/*End of PrImage*/


/****** void RdSize(*Nrows,*Ncols) ******/
/*Read from an input file two integers for the number of rows and
	number of columns of the image to be processed*/
	/*INPUT PARAMETERS:
		Nrows, Ncols: pointers to integers (number of rows and columns for given array.)
	RETURN PARAMETER:
		None*/
void RdSize(int *Nrows, int *Ncols)
{
	fscanf(fp_in, "%d", Nrows);
	fscanf(fp_in, "%d", Ncols);

}/*End of RdSize*/


/****** void RdImage(Image,Nrows,Ncols) ******/
/*Read from an input file the integers describing the image to
	be processed and store the corresponding character in the 2D array.
	all 0s turned into +s and all 1s turned into &s*/
/*INPUT PARAMETERS:
	Image1 and Image2: 2D arrays of characters (initial and processed images)
	Nrows, Ncols: integers, number of rows and columns for given array.
RETURN PARAMETER:
	None*/
void RdImage(char Image1[MAXROW][MAXCOL],int Nrows, int Ncols)
{
		int i, j, temp;
		for(i=0; i<Nrows; i++)
		{
			for(j=0; j<Ncols; j++)
			{
				/*read individual character*/
				fscanf(fp_in, "%d", &temp);

				/*change 1/0 into "image"*/
				if(temp == 0)
					{Image1[i][j] = '+';}
				else
					{Image1[i][j] = '&';}
			}
		}

}/*End of RdImage*/


/**** int RdDoTask(Image1,Image2,Nrows,Ncols) ****/
/*This function is called by main to read one integer from an
open input file. Based on the value read, it calls the
appropriate image processing routine and then prints the
new image. It returns to main with a 0, unless end of file
was encountered, in which case it returns a 1, without
doing any processing */
/*INPUT PARAMETERS:
Image1 and Image2: 2D arrays of characters (initial and processed images)
Nrows, Ncols: integers, number of rows and columns for given array.
 RETURN PARAMETER:
1 when end of file encountered, 0 otherwise*/
int RdDoTask(char Image1[MAXROW][MAXCOL],
			char Image2[MAXROW][MAXCOL],int Nrows, int Ncols)
{
	int end, temp, rowsize, colsize;

	end = fscanf(fp_in, "%d", &temp);

	/*if end of file, return 1 and end while loop in main*/
	if(end != 1)
	{
		return 1;
	}

	rowsize = Nrows; /*for later functions that flip dimensions*/
	colsize = Ncols;


	if(temp == 1)/*command 1 corresponds to VMirror*/
		{
			VMirror(Image1, Image2, rowsize, colsize);
		}

	if(temp == 2)/*command 2 corresponds to hMirror*/
		{
			HMirror(Image1, Image2, rowsize, colsize);
		}
	if(temp == 3)/*command 3 corresponds to DiagR*/
		{
			rowsize = Ncols;/*rows&columnds must be switched*/
			colsize = Nrows; /*because array size/demention changes*/
			DiagR(Image1, Image2, rowsize, colsize);

		}
	if(temp == 4)/*command 4 corresponds to DiagL*/
		{
			rowsize = Ncols; /*rows&columnds must be switched*/
			colsize = Nrows; /*because array size/demention changes*/
			DiagL(Image1, Image2, rowsize, colsize);

		}
	if(temp == 5)/*command 5 corresponds to RotR*/
		{
			rowsize = Ncols; /*rows&columnds must be switched*/
			colsize = Nrows; /*because array size/demention changes*/
			RotR(Image1, Image2, rowsize, colsize);

		}

	/*print modified array*/
	PrImage(Image2, rowsize, colsize);

	return 0;
	
} /*End RdDoTask*/


/***********Main*********/
int main()
{

	int Rsize1, Csize1;	/*image sizes*/
	char IMchr1[MAXROW][MAXCOL]; /*original image*/
	char IMchr2[MAXROW][MAXCOL]; /*resulting image after processing*/


	/*open input file*/
	fp_in = fopen("A1In.txt", "r");
	if(fp_in == NULL) {
		/* Error opening the file, print a message and return.*/
		fprintf(stdout, "Error: Cannot open input file  - Bye\n");
		return -1;
	}

	/*open output file*/
	fp_out = fopen("A1Out.txt", "w");
	if (fp_out == NULL) {
	        /* Error opening the file, print a message and return.*/
	        fprintf(stdout, "Error: Cannot open output file - Bye\n");
        	return -1;
     }

     /*hello message to screen and output file*/
	 	fprintf(stdout, "\n Jaimee Blackwood - Student Number V00755181 \n");
	 	fprintf(stdout, "\n File = A1csc230.c	- Winter/Spring 2013 \n");
	 	fprintf(stdout, "\n Welcome to CSC 230, Assignment 1 \n\n");
	 	fprintf(fp_out, "\n Jaimee Blackwood - Student Number V00755181 \n");
	 	fprintf(fp_out, "\n File = A1csc230.c	- Winter/Spring 2013 \n");
		fprintf(fp_out, "\n Welcome to CSC 230, Assignment 1 \n\n");

        	fprintf(stdout,"Starting: \n");
    		fprintf(fp_out,"Starting: \n");


	/*Read in the sizes for the image*/
	RdSize(&Rsize1, &Csize1);

	/*Read in the image*/
	RdImage(IMchr1, Rsize1, Csize1);

	/*print initial array before image proccssing takes place*/
	PrImage(IMchr1, Rsize1, Csize1);

 	int eof, i;
	eof = 0;

	/*while the end of file is not reached, call RdDoTask*/
	while(eof==0)
	{
		eof = RdDoTask(IMchr1, IMchr2, Rsize1, Csize1);
	}

	return 0;

}/*End of main*/