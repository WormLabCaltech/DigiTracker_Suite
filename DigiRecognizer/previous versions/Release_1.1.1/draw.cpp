#include "stdafx.h"
#include "displaytest.h"
#include "displaytestDlg.h"
#include "mex.h"

//CJC 3-20-03: THESE ARE UNNECESSARY:
//CJC 3-20-03	#define __ACTIVEMIL_REGIONOFINTEREST_CPLUSPLUS
//CJC #include "ExampleDlg.h"
//CJC 3-20-03	#include "resource.h"
//CJC 3-20-03	#include "Digitizer.h"
//CJC 3-20-03	#include "Display.h"
//CJC 3-20-03	#include "System.h"
//CJC 3-20-03	#include "Application.h"
//CJC 3-20-03	#include "RegionOfInterest.h"
//CJC 3-20-03	#include "GraphicContext.h"

extern int foaws;
extern int bndryws;
extern int bndrysize;
extern int spnsize;

void     
drawworm(IGraphicContextPtr gc, void *center, void *bndry, void *spn, void *pts)
//ORIGINALLY WAS:
//drawworm(CGraphicContext *gc, void *center, void *bndry, void *spn, void *pts)
{
	// variables for drawing
	IRegionOfInterestPtr roi;
	roi = ((IGraphicContext*) gc)->DrawingRegion;
//ORIGINALLY WAS:
//	IRegionOfInterest roi = gc->GetDrawingRegion();

	int npoints, i;

	// draw focus of attention box	
	if( center != NULL )
	{
		double *centerp; long cx, cy;

		centerp = (double *) mxGetP((Matrix *) center);
		cx = (long) centerp[0]; cy = (long) centerp[1];
			
		roi->CenterX = cx-1;
		roi->CenterY = (cy-1);
		roi->SizeX = (bndryws);
		roi->SizeY = (bndryws);
// ORIGINALLY WAS:
//		roi.SetCenterX(cx-1);
//		roi.SetCenterY(cy-1);
//		roi.SetSizeX(bndryws);
//		roi.SetSizeY(bndryws);

	    ((IGraphicContext*) gc)->Rectangle(FALSE, 0);
//	ORIGINALLY WAS:
//		gc->Rectangle(FALSE, 0);
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

			    roi->StartX = (startx-1);
				roi->StartY = (starty-1);
				roi->EndX = (endx-1);
				roi->EndY = (endy-1);
// ORIGINALLY WAS:
//			    roi.SetStartX(startx-1);
//				roi.SetStartY(starty-1);
//				roi.SetEndX(endx-1);
//				roi.SetEndY(endy-1);

				((IGraphicContext*) gc)->LineSegment();
// ORIGINALLY WAS:
//				gc->LineSegment();
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

		    roi->StartX = (startx-1);
			roi->StartY = (starty-1);
			roi->EndX = (endx-1);
			roi->EndY = (endy-1);
//ORIGINALLY WAS:
//		    roi.SetStartX(startx-1);
//			roi.SetStartY(starty-1);
//			roi.SetEndX(endx-1);
//			roi.SetEndY(endy-1);

			((IGraphicContext*) gc)->LineSegment();
//ORIGINALLY WAS:
//			gc->LineSegment();
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

			roi->CenterX = (centerx-1);
			roi->CenterY = (centery-1);
			roi->SizeX = ((long) 5);
			roi->SizeY = ((long) 5);
//ORIGINALLY WAS:
//			roi.SetCenterX(centerx-1);
//			roi.SetCenterY(centery-1);
//			roi.SetSizeX((long) 5);
//			roi.SetSizeY((long) 5);

			((IGraphicContext*) gc)->Arc(0, 360, 1);
//ORIGINALLY WAS:
//			gc->Arc(0, 360, 1);
		}
	}
}
