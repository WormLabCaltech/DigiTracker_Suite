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

// ***********************************************************************************
// Function prototypes
// ***********************************************************************************

extern Matrix *foa(Matrix *im, int ms, int ws, int ss, double threshold);
extern Matrix *boundary(Matrix *im, Matrix *center, int cs, int ms, double threshold, int npoints);
extern void centerline(Matrix *bndry, Matrix **spn, Matrix **pts, int npoints);

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
  *bndry = boundary(im, *center, bndryws, bndryms, bndrythreshold, bndrysize);
  if( *bndry == NULL )
	return;

  /* now compute the spine */
  centerline(*bndry, spn, pts, spnsize);  
}
