#include "stdafx.h"
#include "ExampleDlg.h"


#define IMAGEX 320					  // size of image x dim
#define IMAGEY 240					  // size of image y dim

/////////////////////////////////////////////////////////////////////////////
// 
// Drawing Routines
//
void
DrawBox(CGraphicContext *gc, int cenx, int ceny, int width, int height, BYTE cval)
{
	IRegionOfInterest DrawingRegion = gc->GetDrawingRegion();

	DrawingRegion.SetCenterX(cenx);
	DrawingRegion.SetCenterY(ceny);
	DrawingRegion.SetSizeX(width);
	DrawingRegion.SetSizeY(height);

	gc->SetForegroundColor(RGB(cval,cval,cval));
	//gc->SetForegroundShade(0);
	gc->Rectangle(FALSE);

}


void
DrawText(CGraphicContext *gc, int x, int y, const char *text, BYTE cval)
{
	IRegionOfInterest DrawingRegion = gc->GetDrawingRegion();

	DrawingRegion.SetStartX(x);
	DrawingRegion.SetStartY(y);
	DrawingRegion.SetEndX(IMAGEX);
	DrawingRegion.SetEndY(IMAGEY);

	//gc->SetForegroundShade(0);
	gc->SetForegroundColor(RGB(cval,cval,cval));
	gc->SetBackgroundMode(graTransparent);
	gc->Text(text);
}