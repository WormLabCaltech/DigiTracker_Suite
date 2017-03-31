#include "stdafx.h"
#include "mex.h"

// ***********************************************************************************
// Global Variables
// ***********************************************************************************

extern int foams;
extern int foaws;
extern int foass;
extern double foathreshold;

extern int bndryms;
extern int bndryws;
extern double bndrythreshold;
extern int bndrysize;

extern int spnsize;

extern int lightSeg;
extern double lsthreshold;
extern int lsms;

// ***********************************************************************************
// Function prototypes
// ***********************************************************************************

extern Matrix *foa(Matrix *im, int ms, int ws, int ss, double threshold);
extern Matrix *boundary(Matrix *im, Matrix *center, int cs, int ms, double threshold, int npoints, int lightSeg);
extern void centerline(Matrix *bndry, Matrix **spn, Matrix **pts, int npoints);
extern Matrix ** mw_boundary(Matrix *im, Matrix *center, int cs, int ms, double t, int npoints, int lightSeg, int pixel_thres, int *wormcount);

// ***********************************************************************************
// Function for finding the worm
// ***********************************************************************************

void
findworm(Matrix *im, 
		 Matrix **center, Matrix **bndry, 
		 Matrix **spn, Matrix **pts)
{
  /* assign default values */
  *center = NULL;
  *bndry = NULL;
  *spn = NULL;
  *pts = NULL;

  /* compute the focus of attention */
  *center = foa(im, foams, foaws, foass, foathreshold);
  if( *center == NULL  )
	return;	

  /* now compute the boundary */
  if (lightSeg)
	 *bndry = boundary(im, *center, bndryws, lsms, lsthreshold, bndrysize, lightSeg);
  else
     *bndry = boundary(im, *center, bndryws, bndryms, bndrythreshold, bndrysize, lightSeg);
  if( *bndry == NULL )
	return;

  /* now compute the spine */
  centerline(*bndry, spn, pts, spnsize);  
}

Matrix**
findmwboundry(Matrix *im, Matrix **center, int pixel_thres, int *count)
{
  /* assign default values */
  *center = NULL;

  /* compute the focus of attention */
  //*center = foa(im, foams, foaws, foass, foathreshold);
  //if( *center == NULL  )
  //return NULL;	

   /* now generate result matrix */
    double *centerp;
  *center = mxCreateFull(1, 2, REAL);
  centerp = (double *) mxGetP(*center);
  if( centerp )
  { 
  
	centerp[0] = mxGetN(im)/2;
	centerp[1] = mxGetM(im)/2;
  }
  /* now compute the boundary */
  if (lightSeg)
	 return(mw_boundary(im, *center, bndryws, lsms, lsthreshold, bndrysize, lightSeg,  pixel_thres, count));
  else
     return(mw_boundary(im, *center, bndryws, bndryms, bndrythreshold, bndrysize, lightSeg,  pixel_thres, count));
 
}
