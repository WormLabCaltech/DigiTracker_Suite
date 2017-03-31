#include <stdlib.h>
#include "stdafx.h"
#include "mex.h"
#include "math.h"

// ***********************************************************************************
// Functions for "squaring" 
// ***********************************************************************************

// Calculates the square of each element of the input matrix.
//
// Parameters:
//	im:		Pointer to Matrix
//
// Returns:
//	res:	Pointer to Matrix with each element of 'im' squared.
Matrix *
squareh(Matrix *im)
{
  Matrix *res;
  int m, n;
  int i, j;
  unsigned int **imp;
  unsigned int **resp;

  /* read in the size of the matrix */
  m = mxGetM(im);
  n = mxGetN(im);

  /* allocate space for output */
  res = mxCreateFull(m, n, INT);

  /* set up for two dimensional indexing */
  imp = (unsigned int **) mxGetPr(im);
  resp = (unsigned int **) mxGetPr(res);

  /* now perform the computation */
  if( resp != NULL )
  {
	for( i = 0; i < n; i++ )
	   for( j = 0; j < m; j++ )
		  resp[i][j] = (imp[i][j] * imp[i][j]);
  }

  /* return the answer */
  return(res);
}

Matrix *
square(Matrix *im)
{
  /* check im */ 
  if( im == NULL )
	return(NULL);

  /* return the answer */
  return(squareh(im));
}

// ***********************************************************************************
// Functions for "smoothing" 
// ***********************************************************************************

// For each element in matrix 'im', sumcol calculates the sum of the 'size' elements 
// above & below that element (including itself) (i.e. the element itself, plus the 
// (size-1)/2 elements above and below).  [Edges are treated as zeros.]
//
// Parameters:
//	im:		Pointer to Matrix
//	size:	Number of column values to sum together for each matrix element
//
// Returns:
//	col:	Pointer to Matrix with groups of column elements summed together, with 
//			(size-1)/2 zeros at the top and bottom borders
Matrix *
sumcol(Matrix *im, int size)
{
  Matrix *col;
  int m, n;
  int i, j, top, bottom;
  unsigned int **imp, **colp;
  
  /* read in the size of the matrix */
  m = mxGetM(im);
  n = mxGetN(im);

  /* allocate space for output */
  col = mxCreateFull(m, n, INT);

  /* set up for two dimensional indexing */
  imp = (unsigned int **) mxGetPr(im);
  colp = (unsigned int **) mxGetPr(col);
  
  if( colp != NULL )
  {
	for( j = 0; j <= (size-1)/2; j++ )
		for( i = 0; i < n; i++ )	
			colp[i][j] = 0;

	/* now compute the first row of column totals */
	j = (size - 1) / 2;
	for( i = 0; i < n; i++ )
		for( bottom = 0; bottom < size; bottom++ )
			colp[i][j] += imp[i][bottom];

	/* now compute all the other column totals */
	top = 0;
	j = j + 1;
	for( ; bottom < m; bottom++, top++, j++ )
		for( i = 0; i < n; i++ )
			colp[i][j] = colp[i][j-1] + imp[i][bottom] - imp[i][top];

 	/* set padding to zeros */
	for( ; j < m; j++ )
		for( i = 0; i < n; i++ )
			colp[i][j] = 0;  
  }

  /* return the result */
  return(col);
}


// For each element in matrix 'im', sumrow calculates the sum of the 'size' elements 
// right & left of  that element (including itself) (i.e. the element itself, plus 
// the (size-1)/2 elements to the right and left).  [Edges are treated as zeros.]
//
// Parameters:
//	im:		Pointer to Matrix
//	size:	Number of row values to sum together for each matrix element
//
// Returns:
//	row:	Pointer to Matrix with groups of row elements summed together, with 
//			(size-1)/2 zeros at the left and right borders
Matrix *
sumrow(Matrix *im, int size)
{
  Matrix *row;
  int m, n;
  int i, j, left, right;
  unsigned int **imp, **rowp;
  
  /* read in the size of the matrix */
  m = mxGetM(im);
  n = mxGetN(im);

  /* allocate space for output */
  row = mxCreateFull(m, n, INT);

  /* set up for two dimensional indexing */
  imp = (unsigned int **) mxGetPr(im);
  rowp = (unsigned int **) mxGetPr(row);
  
  if( rowp != NULL )
  {
    /* set padding to zeros */
	for( i = 0; i <= (size-1)/2; i++ )
		for( j = 0; j < m; j++ )
			rowp[i][j] = 0;

	/* now compute the first column of row totals */
	i = (size - 1) / 2;
	for( j = 0; j < m; j++ )
		for( right = 0; right < size; right++ )
			rowp[i][j] += imp[right][j];

	/* now compute all the other row totals */
	left = 0;
	i = i + 1;
	for( ; right < n; right++, left++, i++ )
		for( j = 0; j < m; j++ )
			rowp[i][j] = rowp[i-1][j] + imp[right][j] - imp[left][j];

    /* set padding to zeros */
	for( ; i < n; i++ )
		for( j = 0; j < m; j++ )
			rowp[i][j] = 0;
  }

  /* return the result */
  return(row);
}


// For element in matrix 'image', sum finds the sum of the size*size elements
// surrounding that element.  [Edges are treated as zeros.]
//
// Parameters:
//	image:		Pointer to Matrix
//	size:		Number of 'image' row and column values to sum together.
//
// Returns:
//	result:		Pointer to Matrix with each element as the sum of the surrounding
//				size*size elements from the input 'image' matrix.
Matrix *
sumh(Matrix *image, int size)
{
  Matrix *temp = NULL;
  Matrix *result = NULL;
  
  /* now do the smoothing */	
  temp = sumcol(image, size); 
  result = sumrow(temp, size);

  /* free all allocated memory */	
  mxFreeMatrix(temp); 

  /* return the result */	
  return(result);	
}

Matrix *
sum(Matrix *image, int size)
{
  /* now do some error checking */
  if( image == NULL )
	return(NULL);

  if( mxGetM(image) * mxGetN(image) == 0 )
	return(NULL);

  /* check size */
  if( size <= 0 ) 
	return(NULL);
	
  /* check is size of image is consistent with size of filter */
  if( (mxGetM(image) < size) || (mxGetN(image) < size) )
	return(NULL);

  /* return the result */	
  return(sumh(image, size));	
}

// ***********************************************************************************
// Functions for segmenting 
// ***********************************************************************************

// Creates a binary version of matrix 'im' with relatively homogeneous areas labeled
// zero (0) and high gradient areas labeled 255.  Smoothing window size is defined 
// by parameter 'ms' and the gradient threshold is defined via parameter 'threshold',
// but while these two parameters have different specific effects, they work together 
// in the segmentation process in determining what is identified as worm edge.
//
// Parameters:
//	im:		Pointer to image matrix.
//	ms:		'Smoothing window' size-- how many surrounding elements (in X and Y 
//			directions) to combine together for each matrix element.  Value should 
//			be ODD for symmetry. 
//	threshold:	Threshold value for finding high-gradient regions of matrix 'im'.
//
// Returns:
//	worm:	Pointer to binary version of Matrix 'im' with high value-gradient regions
//			labelled 255 and other 'background' regions labelled zero.
//
// Hints:
// The high gradient areas are at the border between light and dark, so one can consider
// the resulting binary matrix showing just the perimeter line of the worm blob.  As a result...
//
// - Higher THRESHOLD values yield longer, wider, less discriminate areas labeled 255, while 
//   lower values yield more narrow, perhaps more accurate areas that are prone gaps (i.e. being 
//   non-contiguous).  
// 
// - Higher MS values yield a thicker perimeter line, while lower values yield a
//   narrower line
Matrix *
segmenth(Matrix *im, int ms, double threshold)
{
//where
//	ms is either foams or bndryms (depending on calling function).  s/b odd.
  Matrix *numtemp = NULL;	
  Matrix *num = NULL;
  Matrix *dentemp = NULL;
  Matrix *den = NULL;
  Matrix *worm = NULL;	

  /* compute the numerator and denominator */
  numtemp = sum(im, ms);
  num = square(numtemp);
  dentemp = square(im);
  den = sum(dentemp, ms);

  /* locate the worm */ 		
  if( (num != NULL) && (den != NULL) )
  {
	int m, n;
	int i, j;
	unsigned int **nump;
	unsigned int **denp;
	unsigned int **wormp;

	/* set size of matrices */
	m = mxGetM(im);
	n = mxGetN(im);

	/* allocate space for output */
	worm = mxCreateFull(m, n, INT);

	/* setup for two dimensional indexing */
	nump = (unsigned int **) mxGetPr(num);
	denp = (unsigned int **) mxGetPr(den);
	wormp = (unsigned int **) mxGetPr(worm);

	/* now perform the computation */
	if( wormp != NULL )
	{
		threshold = threshold * ms * ms;
		for( i = 0; i < n; i++ )
			for( j = 0; j < m; j++ )
			{	
				if( nump[i][j] < threshold * denp[i][j] )
					wormp[i][j] = 255;	// worm edge (high gradient area)
				else
					wormp[i][j] = 0;	// background (homogeneous area)
			}
	}
  }

  /* now free all allocated memory */
  mxFreeMatrix(num);
  mxFreeMatrix(den);
  mxFreeMatrix(numtemp);
  mxFreeMatrix(dentemp);
    
  /* now return the answer */
  return(worm);  	
}

Matrix *
segment(Matrix *im, int ms, double threshold)
{
  /* check image */
  if( im == NULL )
	return(NULL);
  
  if( mxGetM(im) * mxGetN(im) == 0 )
	return(NULL);

  /* check ms */
  if( ms <= 0 ) 
	return(NULL);

  /* check is size of image is consistent with size of filter */
  if( (mxGetM(im) < ms) || (mxGetN(im) < ms) )
	return(NULL);

  /* check threshold */	
  if( (threshold < 0) || (threshold > 1) )
	return(NULL);

  /* return the answer */
  return(segmenth(im, ms, threshold));
}

// ***********************************************************************************
// Functions for locating the center 
// ***********************************************************************************

// Calculates the position of the maximum value element of Matrix 'im' or, if there
// is more than one element with the maximum value, calculates the mean position of 
// the maximum value elements of Matrix 'im'.
//
// Parameters:
//	im:		Pointer to Matrix
//
// Returns:
//	res:	Pointer to Matrix giving the X,Y (i.e. column,row) position of the maximum 
//			value element in im, or the centroid of all elements with the maximum value
Matrix *
centroidh(Matrix *im)
{
  int m, n;
  int i, j;
  unsigned int **imp;
  unsigned int max;
  double x, y;
  int count;
  Matrix *res;
  double *resp;

  /* read in the size of the matrix */
  m = mxGetM(im);
  n = mxGetN(im);
  
  /* set up for two dimensional indexing */
  imp = (unsigned int **) mxGetPr(im);

  /* now compute maxima */
  max = 0;
  for( i = 0; i < n; i++ )
    for( j = 0; j < m; j++ )
      if( imp[i][j] > max )
		max = imp[i][j];

  /* now compute the centroid */
  x = 0;
  y = 0;
  count = 0;
  for( i = 0; i < n; i++ )
    for( j = 0; j < m; j++ )
      if( imp[i][j] == max )
      {
		x = x + (i + 1);
		y = y + (j + 1);
		count = count + 1;
      }
  x = x / count;
  y = y / count;

  /* now generate result matrix */
  res = mxCreateFull(1, 2, REAL);
  resp = (double *) mxGetP(res);
  if( resp )
  {
	resp[0] = x;
	resp[1] = y;
  }

  /* return the result */
  return(res);
}

Matrix *
centroid(Matrix *im)
{
  /* do some error checking */
  if( im == NULL )
	return(NULL);

  if( mxGetM(im) * mxGetN(im) == 0 )
	return(NULL);

  /* now return the answer */
  return(centroidh(im));
}

// ***********************************************************************************
// Functions for "subsampling" 
// ***********************************************************************************

// Subsamples elements from Matrix object
//
// Parameters:
//	im:		Pointer to Matrix (image)
//	facx & facy:	Subsampling rate in X- and Y-directions (i.e.how many elements to skip)
//
// Returns:
//	res:	Pointer to Matrix subsampled every facx'th and facy'th element in X and Y directions
Matrix *
subsampleh(Matrix *im, int facx, int facy)
{
  // Note: From foa function, "facx" and "facy" are both called with "foass" (defaults to 4)

  Matrix *res;
  unsigned int **imp;
  unsigned int **resp;
  int i, j, m, n;

  /* get the size of the image */
  m = mxGetM(im);		// y-size: 480
  n = mxGetN(im);		// x-size: 640

  /* allocate space for output */
  res = mxCreateFull((int) (m/facy), (int) (n/facx), INT);	// m/facy = 480/4 (default) = 120; 
															// n/facx = 640/4 (default) = 160

  /* allocate space for two dimensional indexing */
  imp = (unsigned int **) mxGetPr(im);
  resp = (unsigned int **) mxGetPr(res);

  /* set up for two dimensional indexing */
  if( resp != NULL )
  {
	  for( i = 0; i < (int) (n/facx); i++ )
		for( j = 0; j < (int) (m/facy); j++ )
			resp[i][j] = imp[facx*i][facy*j];
  }

  /* return the solution */
  return(res);
} 

Matrix *
subsample(Matrix *im, int facx, int facy)
{ 
  /* some error checking */
  if( im == NULL )
	  return(NULL);

  if( mxGetM(im) * mxGetN(im) == 0 )
	  return(NULL);

  /* ensure subsampling factor is larger than zero */
  if( (facx <= 0) || (facy <= 0) )
	  return(NULL);

  /* now do the computation */
  return(subsampleh(im, facx, facy));
} 

// ***********************************************************************************
// Functions for extracting a chip
// ***********************************************************************************

// Extracts a "chip" (i.e. a region) from Matrix 'im'.
//
// Parameters:
//	im:		Pointer to Matrix
//	cx, cy: Target center point X and Y (column, row) coordinates for extracted region from matrix.
//	wx, wy:	Target "chip" size in X (column) and Y (rows).  (Note: if cx,cy are too close to an edge
//			the chip size will be less than wx or wy appropriately
//	offx, offy:		Pointer to the X and Y (column, row) coordinates of the top left corner of the "chip."
//
// Returns:
//	res:	Pointer to Matrix containing extracted "chip" from 'im'.
Matrix *
extracth(Matrix *im, int cx, int cy, int wx, int wy, int *offx, int *offy)
{
  int m, n, i, j;
  Matrix *res;
  unsigned int **imp;
  unsigned int **resp;

  int startrow, endrow;
  int startcol, endcol;

  /* read in the size of the matrix */
  m = mxGetM(im);
  n = mxGetN(im);

  /* compute start and end positions */
  startrow = __max(1, cy-(wy-1)/2) - 1;
  startcol = __max(1, cx-(wx-1)/2) - 1;
  endrow = __min(m, cy+(wy-1)/2) - 1;
  endcol = __min(n, cx+(wx-1)/2) - 1;

  /* now update offset x and y */
  *offx = startcol;
  *offy = startrow;
  
  /* set up for two dimensional indexing */
  imp = (unsigned int **) mxGetPr(im);

  /* now allocate space for output */
  res = mxCreateFull(endrow-startrow+1, endcol-startcol+1, INT);
  
  /* set up for two dimensional indexing */
  resp = (unsigned int **) mxGetPr(res);
  
  /* now do the extraction */
  if( resp != NULL )
  {
	for( i = 0; i < endcol-startcol+1; i++ )
	   for( j = 0; j < endrow-startrow+1; j++ )
		 resp[i][j] = imp[i+startcol][j+startrow];
  }

  /* return the result */
  return(res);
}

Matrix *
extract(Matrix *im, int cx, int cy, int wx, int wy, int *offx, int *offy)
{
  int m, n;
	
  /* now do some error checking */
  if( im == NULL )
	return(NULL);

  if( mxGetM(im) * mxGetN(im) == 0 )
	return(NULL);
  	
  /* read in size of image for checking centers */
  m = mxGetM(im);
  n = mxGetN(im);

  /* check centers */
  if( (cx < 1) || (cx > n) )
	return(NULL);

  if( (cy < 1) || (cy > m) )
	return(NULL);
  
  /* check window sizes */
  if( (wx <= 0) || (wy <= 0) )
	return(NULL);

  if( ((wx % 2) != 1) || ((wy % 2) != 1) )
	return(NULL);

  /* return the result */
  return(extracth(im, cx, cy, wx, wy, offx, offy)); 	
}

// ***********************************************************************************
// This is the linear interpolation function 
// ***********************************************************************************

Matrix *
interpolateh_linear(Matrix *y, int n)
{
  Matrix *res;
  double *x, *cumlen, **yp, **resp;
  double seglen;
  int i, j, npoints;

  /* read in number of points */
  npoints = mxGetN(y);

  /* allocate space for result */
  res = mxCreateFull(2, n, REAL);

  /* allocate arrays for two dimensional indexing */
  x = (double *) mxCalloc(n, sizeof(double));
  resp = (double **) mxGetPr(res);

  cumlen = (double *) mxCalloc(npoints, sizeof(double));
  yp = (double **) mxGetPr(y);
  
  /* compute the length of the spine */
  cumlen[0] = 0;
  for( i = 1; i < npoints; i++ )
	cumlen[i] = cumlen[i-1] + sqrt( (yp[i][0] - yp[i-1][0]) * (yp[i][0] - yp[i-1][0]) +
	                                (yp[i][1] - yp[i-1][1]) * (yp[i][1] - yp[i-1][1]) );

  seglen = cumlen[npoints-1] / (n-1);

  /* now initialize x */
  x[0] = 0;
  for( i = 1; i < n; i++ )
  {
	x[i] = x[i-1] + seglen;
	if( x[i] > cumlen[npoints-1] )
		x[i] = cumlen[npoints-1];
  }

  /* now do the interpolation */
  j = 1;
  for( i = 0; i < n; i++ )
  {
	while( x[i] > cumlen[j] ) j++;

	/* linear interpolation */
	if( cumlen[j] - cumlen[j-1] > 0.0001 )
	{
		resp[i][0] = (cumlen[j] - x[i]) * yp[j-1][0] + (x[i] - cumlen[j-1]) * yp[j][0];
		resp[i][1] = (cumlen[j] - x[i]) * yp[j-1][1] + (x[i] - cumlen[j-1]) * yp[j][1];
	
		resp[i][0] = resp[i][0] / (cumlen[j] - cumlen[j-1]);
		resp[i][1] = resp[i][1] / (cumlen[j] - cumlen[j-1]);
	}
	else
	{
		resp[i][0] = (yp[j-1][0] + yp[j][0]) / 2.0;
		resp[i][1] = (yp[j-1][1] + yp[j][1]) / 2.0;
	}
  }

  /* free all allocated memory */
  mxFree(x);
  mxFree(cumlen);

  /* return the result */
  return(res);	
}

Matrix *
interpolate_linear(Matrix *y, int n)
{
  /* now do some error checking */
  if( y == NULL )
	return(NULL);

  if( mxGetM(y) * mxGetN(y) == 0 )
	return(NULL);
	
  if( mxGetM(y) != 2 )
	return(NULL);

  if( (n <= 1) )
	return(NULL);

  /* now do the computation */
  return(interpolateh_linear(y, n));
}

// ***********************************************************************************
// This is the closest interpolation function 
// ***********************************************************************************

// ???
//
// Parameters:
//	y:	Pointer to Matrix of XY coordinates describing bounding polygon (circumference pixels).
//	n:	Number of points desired around bounding polygon 
//
// Returns:
//	res:	???
Matrix *
interpolateh_closest(Matrix *y, int n)
{
  Matrix *res;
  double *x, *cumlen;
  unsigned int **yp, **resp;
  double seglen;
  int i, j, npoints;

  /* read in number of points (# columns in y)*/
  npoints = mxGetN(y);

  /* allocate space for result [2 x desired number of bounding polygon vertices] */
  res = mxCreateFull(2, n, INT);

  /* allocate arrays for two dimensional indexing */
  x = (double *) mxCalloc(n, sizeof(double));
  resp = (unsigned int **) mxGetPr(res);

  cumlen = (double *) mxCalloc(npoints, sizeof(double));
  yp = (unsigned int **) mxGetPr(y);
  
  /* compute the length of the spine */ // <---Perhaps should spine be polygon or circumference?  CJC 2009-05-21
  cumlen[0] = 0;
  for( i = 1; i < npoints; i++ )
	cumlen[i] = cumlen[i-1] + sqrt( (double) ( (yp[i][0] - yp[i-1][0]) * (yp[i][0] - yp[i-1][0]) +
	                                           (yp[i][1] - yp[i-1][1]) * (yp[i][1] - yp[i-1][1]) ) );

  seglen = cumlen[npoints-1] / (n-1);

  /* now initialize x */
  x[0] = 0;
  for( i = 1; i < n; i++ )
  {
	x[i] = x[i-1] + seglen;
	if( x[i] > cumlen[npoints-1] )
		x[i] = cumlen[npoints-1];
  }
  
  /* now do the interpolation */
  j = 1;
  for( i = 0; i < n; i++ )
  {
	while( x[i] > cumlen[j] ) j++;

	/* closest neighbor interpolation */
	if( (x[i] - cumlen[j-1]) < (cumlen[j] - x[i]) )
	{
		resp[i][0] = yp[j-1][0];
		resp[i][1] = yp[j-1][1];
	}
	else
	{
		resp[i][0] = yp[j][0];
		resp[i][1] = yp[j][1];
	}
  }

  /* free all allocated memory */
  mxFree(x);
  mxFree(cumlen);

  /* return the result */
  return(res);	
}

Matrix *
interpolate_closest(Matrix *y, int n)
{
  /* now do some error checking */
  if( y == NULL )
	return(NULL);

  if( mxGetM(y) * mxGetN(y) == 0 )
	return(NULL);
	
  if( mxGetM(y) != 2 )
	return(NULL);

  if( (n <= 1) )
	return(NULL);

  /* now do the computation */
  return(interpolateh_closest(y, n));
}
