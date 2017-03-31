#include "stdafx.h"
#include "mex.h"
#include <math.h>

//#define MIN_PIXEL_DIFF 75		
#define MIN_IMAGE_DIFF 50

#define IMAGEX 640					  // size of image x dim
#define IMAGEY 480					  // size of image y dim
#define CENX (IMAGEX / 2)			  // x coord of center
#define CENY (IMAGEY / 2)			  // y coord of center
#define WX 480						  // width of window (220)
#define WY 320						  // height of window (140)	
#define MOVEX 320					  // number of x pixels to move when buttons are pressed
#define MOVEY 240					  // number of y pixels to move when buttons are pressed

/* // ORIGINALS
#define IMAGEX 320					  // size of image x dim
#define IMAGEY 240					  // size of image y dim
#define CENX (IMAGEX / 2)			  // x coord of center
#define CENY (IMAGEY / 2)			  // y coord of center
#define WX 160						  // width of window
#define WY 120						  // height of window	
#define MOVEX 160					  // number of x pixels to move when buttons are pressed
#define MOVEY 120					  // number of y pixels to move when buttons are pressed
//ORIGINALS */

/////////////////////////////////////////////////////////////////////////////
// 
// Image Processing Functions
//
void
Initialize(Matrix *Old, Matrix *Image, int *x, int *y, Matrix *Diff)
{	
   int i, j, m, n;
   unsigned char **oldp;
   unsigned char **imagep;
   unsigned char **diffp;	

   /* get data pointer */
   oldp = (unsigned char **) mxGetPr(Old);
   imagep = (unsigned char **) mxGetPr(Image);
   diffp = (unsigned char **) mxGetPr(Diff);

   /* get size */
   m = mxGetM(Image);
   n = mxGetN(Image);

   /* initialize entries */
   for( i = 5; i < n-5; i++ )
	 for( j = 5; j < m-5; j++ )
	 {
		oldp[i][j] = imagep[i][j];
		diffp[i][j] = (unsigned char) 255;
	 }

   /* set x and y */
   *x = -1;
   *y = -1;
}	

void
Update(Matrix *Old, Matrix *Image, int *x, int *y, Matrix *Diff, int min_pixel_diff)
{
   int i, j, k, l, m, n;
   int count, ngh;
   double dst, dstmin;
   unsigned char **oldp = (unsigned char **) mxGetPr(Old);
   unsigned char **imagep = (unsigned char **) mxGetPr(Image);
   unsigned char **diffp = (unsigned char **) mxGetPr(Diff);

   /* get sizes */
   m = (int) mxGetM(Image);
   n = (int) mxGetN(Image);

   /* count number of pixels that have changed */
   count = 0;
   for( i = 5; i < n-5; i++ )
	 for( j = 5; j < m-5; j++ )

		if( abs( (int)(oldp[i][j]-imagep[i][j]) ) > min_pixel_diff ) //CJC 3-01-05 This finds pixels newly occupied OR vacated
//		if(      (int)(oldp[i][j]-imagep[i][j]  ) > min_pixel_diff ) // This finds only newly occupied (i.e. in direction of travel)
		{
			count = count + 1;
			diffp[i][j] = (unsigned char) 255;
		}
		else
		{
			diffp[i][j] = (unsigned char) 0;
		}

   /* if worm moved, get its new position */
   dstmin = 0;	
   if( count > MIN_IMAGE_DIFF )
   {
	 for( i = 5; i < n-5; i++ )
		for( j = 5; j < m-5; j++ )	  	
			oldp[i][j] = imagep[i][j];

	 for( i = 6; i < n-6; i++ )
		for( j = 6; j < m-6; j++ )
		{
			if( diffp[i][j] == 255 )
			{
				ngh = 0;
				for( k=i-1; k <=i+1; k++ )
				   for( l=j-1; l <= j+1; l++ )
					  if( diffp[k][l] == 255 )
						  ngh = ngh + 1;

				if( ngh >= 4 )
				{
					dst = fabs((double)(i-CENX)/IMAGEX) + fabs((double)(j-CENY)/IMAGEY);

					if( dst > dstmin )
					{
						*x = i; *y = j;
						dstmin = dst;
					}
				}
			}	
		}
   }
}
