#include "stdafx.h"
#include "ExampleDlg.h"
#include "mex.h"

extern int foaws;
extern int bndryws;
extern int bndrysize;
extern int spnsize;

void
drawworm(CGraphicContext *gc, void *center, void *bndry, void *spn, void *pts)
{
	// variables for drawing
	IRegionOfInterest roi = gc->GetDrawingRegion();
	int npoints, i;

	// draw focus of attention box	
	if( center != NULL )
	{
		double *centerp; long cx, cy;

		centerp = (double *) mxGetP((Matrix *) center);
		cx = (long) centerp[0]; cy = (long) centerp[1];
			
		roi.SetCenterX(cx-1);
		roi.SetCenterY(cy-1);
		roi.SetSizeX(bndryws);
		roi.SetSizeY(bndryws);

	    gc->Rectangle(0);
	}

	// now draw the worm boundary
	if( bndry != NULL )
	{
		unsigned int **bndryp = (unsigned int **) mxGetPr((Matrix *) bndry); 

		npoints = mxGetN((Matrix *) bndry);
		if( npoints > 1 )
		{
			long startx, starty, endx, endy;
			for( i = 1; i < npoints; i++ )
			{					
				startx = (long) bndryp[i-1][0];
				starty = (long) bndryp[i-1][1];
				endx = (long) bndryp[i][0];
				endy = (long) bndryp[i][1];

			    roi.SetStartX(startx-1);
				roi.SetStartY(starty-1);
				roi.SetEndX(endx-1);
				roi.SetEndY(endy-1);

				gc->LineSegment();
			}
		}
	}

	// now draw the spine
	if( pts !=  NULL )
	{
		double **ptsp = (double **) mxGetPr((Matrix *) pts); 

		npoints = mxGetN((Matrix *) pts);

		if( npoints > 1 )
		for( i = 1; i < npoints; i++ )
		{		
			long startx, starty, endx, endy;

			startx = (long) ptsp[i-1][0];
			starty = (long) ptsp[i-1][1];
			endx = (long) ptsp[i][0];
			endy = (long) ptsp[i][1];

		    roi.SetStartX(startx-1);
			roi.SetStartY(starty-1);
			roi.SetEndX(endx-1);
			roi.SetEndY(endy-1);

			gc->LineSegment();
		}	
	}

	// now draw the points
	if( pts != NULL )
	{
		double **ptsp = (double **) mxGetPr((Matrix *) pts);

		npoints = mxGetN((Matrix *) pts);
		for( i = 0; i < npoints; i++ )
		{
			long centerx, centery;
						
			centerx = (long) ptsp[i][0];
			centery = (long) ptsp[i][1];

			roi.SetCenterX(centerx-1);
			roi.SetCenterY(centery-1);
			roi.SetSizeX((long) 5);
			roi.SetSizeY((long) 5);

			gc->Arc(0, 360, 1);
		}
	}
}
