#include <stdlib.h>
#include "stdafx.h"
#include "mex.h"

// ***********************************************************************************
// Function prototypes
// ***********************************************************************************

extern Matrix *segment(Matrix *im, int ms, double threshold);
extern Matrix *extract(Matrix *im, int cx, int cy, int wx, int wy, int *offx, int *offy);
extern Matrix *subsample(Matrix *im, int facx, int facy);
extern Matrix *interpolate_closest(Matrix *y, int n);

// ***********************************************************************************
// Function for labelling connected components
// ***********************************************************************************

unsigned int
labelh(Matrix *im, Matrix **lab)
{
  unsigned int **labp;
  unsigned int **imp;
  int m, n, i, j, k, l;

  int nlabel;
  unsigned int result;

  /* get size of the image */
  m = mxGetM(im);
  n = mxGetN(im);
  
  /* allocate memory for labelling */
  *lab = mxCreateFull(m, n, INT);

  /* set up for two dimensional indexing */
  imp = (unsigned int **) mxGetPr(im);
  labp = (unsigned int **) mxGetPr(*lab);

  /* now start the labelling process */
  nlabel = 1;
  for( j = 0; j < m; j++ )
    for( i = 0; i < n; i++ )
    {
      if( imp[i][j] > 0 )
      {
		if( (labp[i-1][j] == 0) && (labp[i][j-1] == 0) )
		{
		  labp[i][j] = nlabel;
		  nlabel = nlabel + 1;
		}
		else if( labp[i-1][j] == 0 )
		{
		  labp[i][j] = labp[i][j-1];
		}  
		else if( labp[i][j-1] == 0 )
		{
		  labp[i][j] = labp[i-1][j];
		}
		else
		{
		  labp[i][j] = __min(labp[i-1][j], labp[i][j-1]);
		}
	  }
	  else
	  {
		 labp[i][j] = 0;
	  }
    }

  /* zero doesn't count as a label */
  nlabel = nlabel - 1;

  /* now check for error */
  if( nlabel == 0 )
	return(0);

  /* now do the second pass if necessary */
  Matrix *table;
  unsigned int **tablep;
  unsigned int *eqv1, *eqv2;
  unsigned int *area;

  /* allocate space for tables */
  table = mxCreateFull(nlabel, nlabel, INT);
  tablep = (unsigned int **) mxGetPr(table);
  eqv1 = (unsigned int *) mxCalloc(nlabel, sizeof(unsigned int));  
  eqv2 = (unsigned int *) mxCalloc(nlabel, sizeof(unsigned int));

  /* initialize diagonal entries to ones */
  for( i = 0; i < nlabel; i++ )
	for( j = 0; j < nlabel; j++ )
	  if( i == j )
		tablep[i][j] = 1;
	  else
		tablep[i][j] = 0;

  /* now update equivalency table */
  for( j = 1; j < m-1; j++ )
	for( i = 1; i < n-1; i++ )
	{
	  if( labp[i][j] > 0 )
	  {
		 if( (labp[i-1][j] != 0) &&
			 (labp[i][j-1] != 0) )
		 {
		   if( labp[i][j-1] != labp[i-1][j] )
		   {
			  tablep[labp[i][j-1]-1][labp[i-1][j]-1] = 1;
			  tablep[labp[i-1][j]-1][labp[i][j-1]-1] = 1;
		   }  
		 }
	   }
	}

  /* now generate equivalency table */
  for( i = 0; i < nlabel; i++ )
	eqv1[i] = (unsigned int) i;

  for( i = 0; i < nlabel; i++ )
	if( (int) eqv1[i] == i )
	  for( j = 0; j < nlabel; j++ )
		for( k = 0; k < nlabel; k++ )
		  if( (int) eqv1[k] == i )
			for( l = 0; l < nlabel; l++ )
			  if( tablep[k][l] == 1 )
				eqv1[l] = i;

  /* now generate the new equivalency table */
  for( i = 0; i < nlabel; i++ )
	eqv2[i] = 0;
  
  for( i = 0; i < nlabel; i++ )
	eqv2[eqv1[i]] = 1;

  for( i = 1; i < nlabel; i++ )
	eqv2[i] = eqv2[i-1] + eqv2[i];
  
  for( i = 0; i < nlabel; i++ )
	eqv2[i] = eqv2[i] - 1;
  
  /* now fix the original equivalency table */
  for( i = 0; i < nlabel; i++ )
	eqv1[i] = eqv2[eqv1[i]];

  /* correct number of labels */
  nlabel = (int) eqv2[nlabel-1] + 1;
  
  /* allocate memories to hold areas */
  area = (unsigned int *) mxCalloc(nlabel, sizeof(unsigned int));
  for( i = 0; i < nlabel; i++ )
	area[i] = 0;

  /* relabel and compute areas */
  for( i = 1; i < n-1; i++ )
	for( j = 1; j < m-1; j++ )
	{
	  if( labp[i][j] > 0 )
	  {
		labp[i][j] = eqv1[labp[i][j]-1] + 1;
		area[labp[i][j]-1]++;
	  }
	}

  /* find the largest area */
  unsigned int maxarea = 0;
  result = 0;
  for( i = 0; i < nlabel; i++ )
	if( area[i] > maxarea )
	{
		maxarea = area[i];
		result = i;
	}

  /* free the relabeling buffer */
  mxFreeMatrix(table);
  mxFree(eqv1); 
  mxFree(eqv2);
  mxFree(area);

  /* return the number of labels */
  return(result+1);
}

unsigned int
label(Matrix *im, Matrix **lab)
{
  *lab = NULL;

  /* now do some error checking */
  if( im == NULL )
	return(0);

  if( mxGetM(im) * mxGetN(im) == 0 )
	return(0);

  /* now do the computation */
  return(labelh(im, lab));
}

// ***********************************************************************************
// Function for computing the bounding polygon 
// ***********************************************************************************

Matrix *
chaincodeh(Matrix *im, int transx, int transy, unsigned int id)
{
  int m, n;
  int i, j;
  unsigned int **imp;
  Matrix *res;
  unsigned int **resp;

  int found;
  int stx, sty;
  int curx, cury;
  int stsrch;
  int npoints = 0;

  int offx[8] = {+1,  0, -1, -1, -1,  0, +1, +1};
  int offy[8] = {-1, -1, -1,  0, +1, +1, +1,  0};
  int next[8] = {1, 2, 3, 4, 5, 6, 7, 0};
  int strt[8] = {5, 6, 7, 0, 1, 2, 3, 4};

  /* read in the size of the matrix */
  m = mxGetM(im);
  n = mxGetN(im);
  
  /* set up for two dimensional indexing */
  imp = (unsigned int **) mxGetPr(im);

  /* look for the starting position */
  found = 0;
  for( i = 0; (i < n) && (!found); i++ )
    for( j = 0; (j < m) && (!found); j++ )
      if( imp[i][j] == id )
      {
		stx = i;
		sty = j;
		found = 1;
      }

  /* check to see if we found something */
  if( !found )
    return(NULL);

  /* now look for the rest of the chaincode */
  curx = stx;
  cury = sty;
  stsrch = 5;
  npoints = 1;

  do
  {
    /* locate the next position */
    int nxtx = curx + offx[stsrch];
    int nxty = cury + offy[stsrch];

    while( imp[nxtx][nxty] != id )
    {
      stsrch = next[stsrch];
      nxtx = curx + offx[stsrch];
      nxty = cury + offy[stsrch];
    }

    /* move to the next position */
    curx = nxtx;
    cury = nxty;
    stsrch = strt[stsrch];

    /* increment counter */
    npoints = npoints + 1;

  } while( (curx != stx) || (cury != sty) );

  /* allocate memory for output */
  res = mxCreateFull(2, npoints, INT);

  /* set up for two dimensional indexing */
  resp = (unsigned int **) mxGetPr(res);

  /* now find the chaincode again */
  curx = stx;
  cury = sty;
  stsrch = 5;

  npoints = 0;
  resp[npoints][0] = curx + 1 + transx;
  resp[npoints][1] = cury + 1 + transy;

  do
  {
    /* locate the next position */
    int nxtx = curx + offx[stsrch];
    int nxty = cury + offy[stsrch];

    while( imp[nxtx][nxty] != id )
    {
      stsrch = next[stsrch];
      nxtx = curx + offx[stsrch];
      nxty = cury + offy[stsrch];
    }

    /* move to the next position */
    curx = nxtx;
    cury = nxty;
    stsrch = strt[stsrch];

    /* increment counter */
    npoints = npoints + 1;

    /* store the current position */
    resp[npoints][0] = curx + 1 + transx;
    resp[npoints][1] = cury + 1 + transy;
	 
  } while( (curx != stx) || (cury != sty) );

  /* return the result */
  return(res);
}

Matrix *
chaincode(Matrix *im, int transx, int transy, unsigned char id)
{
  /* now do some error checking */
  if( im == NULL )
	return(NULL);

  if( mxGetM(im) * mxGetN(im) == 0 )
	return(NULL);
  
  /* now do the computation */
  return(chaincodeh(im, transx, transy, id));
}

// ***********************************************************************************
// Function for checking a valid boundary
// ***********************************************************************************

int 
intersecth(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4)
{
  /* quick rejection */
  int x1p, x2p, x3p, x4p, y1p, y2p, y3p, y4p;
	
  x1p = min(x1, x2); y1p = min(y1, y2);
  x2p = max(x1, x2); y2p = max(y1, y2);
  x3p = min(x3, x4); y3p = min(y3, y4);
  x4p = max(x3, x4); y4p = max(y3, y4);

  if( ! ((x2p >= x3p) && (x4p >= x1p) && (y2p >= y3p) && (y4p >= y1p)) )
	return(0);

  /* straddle test */
  int v2x, v2y, v3x, v3y, v4x, v4y;

  /* check if p3p4 straddles p1p2 */
  v2x = x2 - x1; v2y = y2 - y1;
  v3x = x3 - x1; v3y = y3 - y1;
  v4x = x4 - x1; v4y = y4 - y1;

  if( (v3x * v2y - v2x * v3y) * (v4x * v2y - v2x * v4y) > 0 )
	return(0);

  /* check if p1p2 straddles p3p4 */
  v2x = x4 - x3; v2y = y4 - y3;
  v3x = x1 - x3; v3y = y1 - y3;
  v4x = x2 - x3; v4y = y2 - y3;

  if( (v3x * v2y - v2x * v3y) * (v4x * v2y - v2x * v4y) > 0 )
	return(0);	
  
  /* segments do intersect */
  return(1);	
}

int 
intersect(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4)
{
  /* both endpoints are coincident, segments intersect */
  if( ((x1 == x3) && (y1 == y3) && (x2 == x4) && (y2 == y4)) ||
	  ((x1 == x4) && (y1 == y4) && (x2 == x3) && (y2 == y3)) )
	return(1);

  /* none of the endpoints are coincident */
  if( ((x1 != x3) || (y1 != y3)) && ((x1 != x4) || (y1 != y4)) &&
	  ((x2 != x3) || (y2 != y3)) && ((x2 != x4) || (y2 != y4)) )
	return( intersecth(x1, y1, x2, y2, x3, y3, x4, y4) );

  /* at this point we have one coincident point */
  int v1x, v1y, v2x, v2y;

  if( (x1 == x3) && (y1 == y3) )
  {
	v1x = x2 - x1; v1y = y2 - y1;
	v2x = x4 - x1; v2y = y4 - y1;
  }

  if( (x1 == x4) && (y1 == y4) )
  {
	v1x = x2 - x1; v1y = y2 - y1;
	v2x = x3 - x1; v2y = y3 - y1;	
  }

  if( (x2 == x3) && (y2 == y3) )
  {
	v1x = x1 - x2; v1y = y1 - y2;
	v2x = x4 - x2; v2y = y4 - y2;
  }

  if( (x2 == x4) && (y2 == y4) )
  {
	v1x = x1 - x2; v1y = y1 - y2;
	v2x = x3 - x2; v2y = y3 - y2;
  }
  
  if( (v1x * v2x + v1y * v2y) * (v1x * v2x + v1y * v2y)
	  == (v1x * v1x + v1y * v1y) * (v2x * v2x + v2y * v2y) )
  {
	if( v1x * v2x + v1y * v2y > 0 )
	  return(1);
  }

  /* return ok */
  return(0);
}

int
validboundaryh(Matrix *bndry)
{
  int res = 1;
  int npoints, i, j;
  unsigned int **bndryp;	

  bndryp = (unsigned int **) mxGetPr(bndry);
  npoints = mxGetN(bndry);

  /* check for repeated points */
  if( npoints > 1 )
	for( i = 0; i < npoints - 1; i++ )
	   for( j = i+1; j < npoints - 1; j++ )
		  if( (bndryp[i][0] == bndryp[j][0]) && (bndryp[i][1] == bndryp[j][1]) )
			  res = 0;

  /* check first and last are equal */
  if( (bndryp[0][0] != bndryp[npoints-1][0]) || (bndryp[0][1] != bndryp[npoints-1][1]) )
	  res = 0;

  /* check for intersecting segments */
  if( npoints > 2 )
	for( i = 0; i < npoints - 1; i++ )
	   for( j = i+1; j < npoints - 1; j++ )
		  if( intersect( bndryp[i][0], bndryp[i][1], bndryp[i+1][0], bndryp[i+1][1],
						 bndryp[j][0], bndryp[j][1], bndryp[j+1][0], bndryp[j+1][1] ) )
			res = 0;

  return(res);
}

int
validboundary(Matrix *bndry)
{
  /* some error checking */
  if( bndry == NULL )
	return(0);

  if( mxGetM(bndry) * mxGetN(bndry) == 0 )
	return(0);

  if( mxGetM(bndry) != 2 )
	return(0);
	
  /* return the solution */
  return(validboundaryh(bndry));
}

// ***********************************************************************************
// Function for computing the boundary 
// ***********************************************************************************

Matrix *
boundary(Matrix *im, Matrix *center, int cs, int ms, double t, int npoints)
{	
  Matrix *chip = NULL;
  Matrix *seg = NULL;
  Matrix *lab = NULL;
  Matrix *bndry = NULL;
  Matrix *sbndry = NULL;

  int cx, cy;
  double *centerp;
  int offx, offy; 
  unsigned int nlabel;

  /* read in the center */
  centerp = (double *) mxGetP(center);

  if( centerp != NULL )
  {
	  cx = (int) centerp[0]; cy = (int) centerp[1];

	  /* extract a chip */
	  chip = extract(im, cx, cy, cs, cs, &offx, &offy);

	  /* now segment it out */
	  seg = segment(chip, ms, t);

	  /* label the chip */
	  nlabel = label(seg, &lab);
	
	  /* now find the worm */
	  if( nlabel > 0 )
	  {
	      bndry = chaincode(lab, offx, offy, nlabel);
		  sbndry = interpolate_closest(bndry, npoints);
	  }

	  /* now check if it is valid */
	  if( !validboundary(sbndry) )
	  {
		  mxFreeMatrix(sbndry);
		  sbndry = NULL;
	  }

	  /* free all allocated memory */
	  mxFreeMatrix(chip);
  	  mxFreeMatrix(seg);
      mxFreeMatrix(lab);
	  mxFreeMatrix(bndry);
  }

  /* return the result */
  return(sbndry);
}





