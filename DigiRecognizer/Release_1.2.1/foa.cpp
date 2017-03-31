#include "stdafx.h"
#include "mex.h"

// ***********************************************************************************
// Function prototypes
// ***********************************************************************************

extern Matrix *sum(Matrix *image, int size);
extern Matrix *segment(Matrix *im, int ms, double threshold);
extern Matrix *subsample(Matrix *im, int facx, int facy);
extern Matrix *centroid(Matrix *im);
extern Matrix *mw_segment(Matrix *im, int ms, double threshold);

// ***********************************************************************************
// Functions for locating the focus of attention 
// ***********************************************************************************

//Returns the XY coordinates of centroid of biggest worm blob.
Matrix *
foa(Matrix *im, int ms, int ws, int ss, double threshold)
{

// where:
//	ms			= foams			(default = 3  ) Binarization window size. (s/b odd)
//	ws			= foaws			(default = 51 ) Centroid blurring window size. (s/b odd)
//	ss			= foass			(default = 4  )	Image subsample size (i.e. sample every ss'th element from image).
//	threshold	= foathreshold	(default = 0.7) Contrast threshold for blob-edge detection.

  Matrix *imsmall = NULL;
  Matrix *count = NULL;
  Matrix *center = NULL;
  Matrix *worm = NULL;
  double *centerp = NULL;	

  /*******************/
  /* locate the worm */
  /*******************/
  // Subsample image into imsmall subsampled version of im, only taking every 
  // ss'th element in the X and Y directions
  imsmall = subsample(im, ss, ss);

  // Segment imsmall into binary version where 1=high gradient regions (worm edges), 0=background
  worm = segment(imsmall, ms, threshold);
  
  // Map showing pixels with most worm neighbors
  count = sum(worm, ws);

  // "center" is coordinates of centroid of worm: mean position 
  // of pixels with most worm neighbors
  center = centroid(count);
	
  // restore centroid coordinates to full-image coordinate [from imsmall coordinates]
  // Note: coordinates are offset by 1 in X & Y (as in: 0 is listed as 1)
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






