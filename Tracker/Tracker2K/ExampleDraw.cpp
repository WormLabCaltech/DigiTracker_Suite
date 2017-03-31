#include "stdafx.h"
#include "ExampleDlg.h"

/////////////////////////////////////////////////////////////////////////////
// 
// Drawing Routines
//
void
DrawBox(CGraphicContext *gc, int cenx, int ceny, int width, int height)
{
	IRegionOfInterest DrawingRegion = gc->GetDrawingRegion();

	DrawingRegion.SetCenterX(cenx);
	DrawingRegion.SetCenterY(ceny);
	DrawingRegion.SetSizeX(width);
	DrawingRegion.SetSizeY(height);

	gc->SetForegroundShade(0);
	gc->Rectangle(FALSE);	
}
