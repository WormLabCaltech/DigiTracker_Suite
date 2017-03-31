#include "stdafx.h"
#include "mex.h"

// ***********************************************************************************
// Function prototypes
// ***********************************************************************************

extern Matrix *sum(Matrix *image, int size);
extern Matrix *segment(Matrix *im, int ms, double threshold);
extern Matrix *subsample(Matrix *im, int facx, int facy);
extern Matrix *centroid(Matrix *im);

// ***********************************************************************************
// Functions for locating the focus of attention 
// ***********************************************************************************

Matrix *
foa(Matrix *im, int ms, int ws, int ss, double threshold)
{
  Matrix *imsmall = NULL;
  Matrix *count = NULL;
  Matrix *center = NULL;
  Matrix *worm = NULL;
  double *centerp = NULL;	

  /* locate the worm */
  imsmall = subsample(im, ss, ss);
  worm = segment(imsmall, ms, threshold);
  count = sum(worm, ws);
  center = centroid(count);
	
  /* recenter */
  centerp = (double *) mxGetP(center);
  if( centerp )
  {
	centerp[0] = ss * centerp[0];
	centerp[1] = ss * centerp[1];
  }

  /* now free all allocated memory */
  mxFreeMatrix(imsmall);	
  mxFreeMatrix(count);
  mxFreeMatrix(worm);

  /* return the answer */
  return(center);	
}






