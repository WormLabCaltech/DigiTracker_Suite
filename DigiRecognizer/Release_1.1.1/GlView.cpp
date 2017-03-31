// GlView.cpp : implementation file
//

#include "stdafx.h"
//#include "MWRecognizerDlg.h"
#include "GlView.h"
//#include "ImgOps.h"
#include "jpegUtil.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

extern int bndryws;

/////////////////////////////////////////////////////////////////////////////
// CGlView

CGlView::CGlView(CWnd *pclWnd)
{
	
	pclWnd->GetClientRect(&rect);
    m_pclWnd = pclWnd;
    m_hWnd   = pclWnd->m_hWnd;
    m_hDC    = ::GetDC(m_hWnd);

	
	// default to 640x480 image  -- was320x240 image
	imgw=640;	// was 320;
	imgh=480;	// was 240;
	
	DWORD dim[2];
	dim[0] = imgw; dim[1] = imgh;

	DispArray = new COleSafeArray();	
	DispArray->Create(VT_I1, (DWORD) 2, dim);   

	SegArray = new COleSafeArray();	
	SegArray->Create(VT_I1, (DWORD) 2, dim);   
	m_drawSegmentation=FALSE;

}

CGlView::~CGlView()
{

    wglMakeCurrent(NULL,NULL);
    wglDeleteContext(m_hglRC);	

	::wglDeleteContext(m_hMemRC);


	// clean up
	DeleteObject(m_hDib);
	DeleteDC(m_hMemDC);
}


BEGIN_MESSAGE_MAP(CGlView, CWnd)
	//{{AFX_MSG_MAP(CGlView)
//	ON_WM_DESTROY()
//	ON_WM_ERASEBKGND()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CGlView message handlers


int CGlView::OnCreate() 
{

    m_hDC = ::GetDC(this->m_hWnd);

    if(!SetPixelformat(m_hDC))
    {
	::MessageBox(::GetFocus(),"SetPixelformat Failed!","Error",MB_OK);
	return -1;
    }

    m_hglRC = wglCreateContext(m_hDC);
    int i= wglMakeCurrent(m_hDC,m_hglRC);

	InitGL();	

	// setup off-screen rendering context
	CSize szDIB;
	szDIB.cx = rect.Width();
	szDIB.cy = rect.Height();

	TRACE("Buffer size: %d x %d = %6.2f MB\n", szDIB.cx, szDIB.cy, szDIB.cx*szDIB.cy*0.000001);
	
	// 2. Create DIB Section
	memset(&m_bmi, 0, sizeof(BITMAPINFO));
	m_bmi.bmiHeader.biSize			= sizeof(BITMAPINFOHEADER);
	m_bmi.bmiHeader.biWidth			= szDIB.cx;
	m_bmi.bmiHeader.biHeight		= szDIB.cy;
	m_bmi.bmiHeader.biPlanes		= 1;
	m_bmi.bmiHeader.biBitCount		= 24;
	m_bmi.bmiHeader.biCompression	= BI_RGB;
	m_bmi.bmiHeader.biSizeImage		= szDIB.cx * szDIB.cy * 3;


	//HDC	hDC = ::GetDC(this->m_hWnd);
	m_hDib = ::CreateDIBSection(m_hDC, &m_bmi, DIB_RGB_COLORS, &m_pBitmapBits, NULL, (DWORD)0);
	//::ReleaseDC(this->m_hWnd, hDC);

	// 3. Create memory DC, and associate it with the DIB.
	m_hMemDC = ::CreateCompatibleDC(NULL);
	if (!m_hMemDC)
	{
		DeleteObject(m_hDib);
		m_hDib = NULL;
		return 0;
	}
	SelectObject(m_hMemDC, m_hDib);

	// 4. Setup memory DC's pixel format.
	if (!SetDCPixelFormat(m_hMemDC, PFD_DRAW_TO_BITMAP | PFD_SUPPORT_OPENGL | PFD_STEREO_DONTCARE))
	{
		DeleteObject(m_hDib);
		m_hDib = NULL;
		DeleteDC(m_hMemDC);
		m_hMemDC = NULL;
		return 0;
	}

	// 5. Create memory RC
	m_hMemRC = ::wglCreateContext(m_hMemDC);
	if (!m_hMemRC)
	{
		DeleteObject(m_hDib);
		m_hDib = NULL;
		DeleteDC(m_hMemDC);
		m_hMemDC = NULL;
		return 0;
	}

	return 0;
}

/*
void CGlView::OnDestroy() 
{
	CWnd::OnDestroy();
	
	// TODO: Add your message handler code here
    wglMakeCurrent(NULL,NULL);
    wglDeleteContext(m_hglRC);	

	::wglDeleteContext(m_hMemRC);


	// clean up
	DeleteObject(m_hDib);
	DeleteDC(m_hMemDC);	
	
}
*/
/*

BOOL CGlView::OnEraseBkgnd(CDC* pDC) 
{
	// TODO: Add your message handler code here and/or call default
    return TRUE;	
//	return CWnd::OnEraseBkgnd(pDC);
}
*/

BOOL CGlView::SetPixelformat(HDC hdc)
{

    PIXELFORMATDESCRIPTOR *ppfd; 
    int pixelformat; 
 
    PIXELFORMATDESCRIPTOR pfd = { 
    sizeof(PIXELFORMATDESCRIPTOR),  //  size of this pfd 
    1,                     // version number 
    PFD_DRAW_TO_WINDOW |   // support window 
	PFD_DRAW_TO_BITMAP |
    PFD_SUPPORT_OPENGL |   // support OpenGL 
    PFD_GENERIC_FORMAT |
    PFD_DOUBLEBUFFER,      // double buffered 
    PFD_TYPE_RGBA,         // RGBA type 
    32,                    // 24-bit color depth 
    0, 0, 0, 0, 0, 0,      // color bits ignored 
    8,                     // no alpha buffer 
    0,                     // shift bit ignored 
    8,                     // no accumulation buffer 
    0, 0, 0, 0,            // accum bits ignored 
    64,                    // 32-bit z-buffer	 
    8,                     // no stencil buffer 
    8,                     // no auxiliary buffer 
    PFD_MAIN_PLANE,        // main layer 
    0,                     // reserved 
    0, 0, 0                // layer masks ignored 
    }; 

   
    ppfd = &pfd;

 
    if ( (pixelformat = ChoosePixelFormat(hdc, ppfd)) == 0 ) 
    { 
        ::MessageBox(NULL, "ChoosePixelFormat failed", "Error", MB_OK); 
        return FALSE; 
    } 
 
    if (SetPixelFormat(hdc, pixelformat, ppfd) == FALSE) 
    { 
        ::MessageBox(NULL, "SetPixelFormat failed", "Error", MB_OK); 
        return FALSE; 
    } 
 
    return TRUE; 

}


GLvoid CGlView::ReSizeGLScene(GLsizei width, GLsizei height)	// Resize And Initialize The GL Window
{

	if (height==0)										// Prevent A Divide By Zero By
	{
		height=1;										// Making Height Equal One
	}

	glViewport(0,0,rect.Width(),rect.Height());	// Reset The Current Viewport
	glMatrixMode(GL_PROJECTION);		// Select The Projection Matrix
	glLoadIdentity();					// Reset The Projection Matrix

	gluOrtho2D(0.0, (GLdouble) rect.Width(), 0.0, (GLdouble) rect.Height());

	glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
	glLoadIdentity();									// Reset The Modelview Matrix

}


int CGlView::InitGL(GLvoid)							// All Setup For OpenGL Goes Here
{
	glShadeModel(GL_FLAT);							// Enable Smooth Shading
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);				// Black Background
	glBlendFunc(GL_ONE, GL_ONE);
	return TRUE;										// Initialization Went OK
}


int CGlView::DrawGLScene()					// Here's Where We Do All The Drawing
{
	unsigned char *raster, *seg;

	DispArray->AccessData((void**) &raster);
	SegArray->AccessData((void**) &seg);

	glClear(GL_COLOR_BUFFER_BIT );	// Clear Screen And Depth Buffer

	glRasterPos2f(0.0, (float) rect.Height());
	glPixelZoom((float) rect.Width()/imgw, -(float)rect.Height()/imgh);


	if (raster) {	
		// draw the image		
		glDrawPixels(imgw, imgh, GL_LUMINANCE, GL_UNSIGNED_BYTE, raster);
		
		// draw worms
		std::list<WormPos>::iterator i;	
		for (i=wormPosList.begin(); i != wormPosList.end(); i++) {
			DrawWorm(i->center,i->bndry, i->spn, i->pts);
		}

		// draw segmentation result
		if (m_drawSegmentation) {
			glEnable(GL_BLEND);
			glDrawPixels(imgw, imgh, GL_BLUE, GL_UNSIGNED_BYTE, seg);
			glDisable(GL_BLEND);
		}

		
		glFlush();
		SwapBuffers(m_hDC);	
	}

	DispArray->UnaccessData();
	SegArray->UnaccessData();
		
	
	return TRUE;									
}

void CGlView::DrawWorm(Matrix *center, Matrix *bndry, Matrix *spn, Matrix *pts)
{
	glPushMatrix();

	glTranslatef(0.0, (float) rect.Height(), 0.);
	glScalef((float) rect.Width()/imgw, -(float)rect.Height()/imgh, 1.);
	
	glColor3f(1., 0., 0.);

	int npoints, i;

		// draw focus of attention box	
	if( center != NULL )
	{
		double *centerp; long cx, cy;

		centerp = (double *) mxGetP((Matrix *) center);
		cx = (long) centerp[0]; cy = (long) centerp[1];
			
		glBegin(GL_LINE_LOOP);
			glVertex2f(cx-bndryws/2.f, cy-bndryws/2.f);
			glVertex2f(cx+bndryws/2.f, cy-bndryws/2.f);
			glVertex2f(cx+bndryws/2.f, cy+bndryws/2.f);
			glVertex2f(cx-bndryws/2.f, cy+bndryws/2.f);

		glEnd();

	}


	// now draw the worm boundary
	if( bndry != NULL )
	{
		unsigned int **bndryp = (unsigned int **) mxGetPr((Matrix *) bndry); 

		npoints = mxGetN((Matrix *) bndry);

		if( npoints > 1 ) {
			glBegin(GL_LINE_STRIP);
			for( i = 0; i < npoints; i++ )
			{								
				glVertex2f((float) bndryp[i][0], (float) bndryp[i][1]);
			}
			glEnd();
		}
	}

	// now draw the spine
	
	if( pts !=  NULL )
	{
		double **ptsp = (double **) mxGetPr((Matrix *) pts); 

		npoints = mxGetN((Matrix *) pts);

		if( npoints > 1 ) {
			glBegin(GL_LINE_STRIP);
	
			for(i = 0; i < npoints; i++ )
			{		
				glVertex2f((float) ptsp[i][0], (float) ptsp[i][1]);

			}	
			glEnd();
		}


		// now draw the points
		glPointSize(3.);
		glBegin(GL_POINTS);		
		for( i = 0; i < npoints; i++ )
		{
			glVertex2f((float)  ptsp[i][0], (float) ptsp[i][1]);

		}
		glEnd();

	}

	glPopMatrix();

}

COleSafeArray* CGlView::GetDisplayArray(unsigned int w, unsigned int h)
{

	if (w!=imgw || h!=imgh) {
		// size doesn't match, reallocate

		imgw=w;
		imgh=h;

		DWORD dim[2];
		dim[0] = imgw; dim[1] = imgh;
		DispArray->Create(VT_I1, (DWORD) 2, dim); 
		SegArray->Create(VT_I1, (DWORD) 2, dim);   

	}

	return DispArray;

}
COleSafeArray* CGlView::GetSegArray(unsigned int w, unsigned int h)
{
	return SegArray;

}

void CGlView::AddWormPos(Matrix *center, Matrix *bndry, Matrix *spn, Matrix *pts)
{
	WormPos wormPos;

	wormPos.center=center;
	wormPos.bndry=bndry;
	wormPos.pts=pts;
	wormPos.spn=spn;

	wormPosList.push_back(wormPos);

}

void CGlView::ClearWormPosList()
{
	std::list<WormPos>::iterator i;

	// go into each individual wormPost struct and free the matrices.
	for (i=wormPosList.begin(); i != wormPosList.end(); i++) {
		if (i->bndry)  delete i->bndry;
		if (i->center) delete i->center;
		if (i->pts)    delete i->pts;
		if (i->spn)    delete i->spn;
	}

	// now clear the list
	wormPosList.clear();
}


bool CGlView::SetDCPixelFormat(HDC hDC, DWORD dwFlags)
{
	PIXELFORMATDESCRIPTOR pixelDesc;
	
	pixelDesc.nSize = sizeof(PIXELFORMATDESCRIPTOR);
	pixelDesc.nVersion = 1;
	
	pixelDesc.dwFlags = dwFlags;
	pixelDesc.iPixelType = PFD_TYPE_RGBA;
	pixelDesc.cColorBits = 24;
	pixelDesc.cRedBits = 8;
	pixelDesc.cRedShift = 16;
	pixelDesc.cGreenBits = 8;
	pixelDesc.cGreenShift = 8;
	pixelDesc.cBlueBits = 8;
	pixelDesc.cBlueShift = 0;
	pixelDesc.cAlphaBits = 0;
	pixelDesc.cAlphaShift = 0;
	pixelDesc.cAccumBits = 64;
	pixelDesc.cAccumRedBits = 16;
	pixelDesc.cAccumGreenBits = 16;
	pixelDesc.cAccumBlueBits = 16;
	pixelDesc.cAccumAlphaBits = 0;
	pixelDesc.cDepthBits = 32;
	pixelDesc.cStencilBits = 8;
	pixelDesc.cAuxBuffers = 0;
	pixelDesc.iLayerType = PFD_MAIN_PLANE;
	pixelDesc.bReserved = 0;
	pixelDesc.dwLayerMask = 0;
	pixelDesc.dwVisibleMask = 0;
	pixelDesc.dwDamageMask = 0;
	
	int nPixelIndex = ::ChoosePixelFormat(hDC, &pixelDesc);
	if (nPixelIndex == 0) // Choose default
	{
		nPixelIndex = 1;
		if (::DescribePixelFormat(hDC, nPixelIndex, 
			sizeof(PIXELFORMATDESCRIPTOR), &pixelDesc) == 0)
			return false;
	}

	if (!::SetPixelFormat(hDC, nPixelIndex, &pixelDesc))
		return false;

	return true;
}


void CGlView::SaveBitmap(char *filename)
{
	// 6. Store old DC and RC
	m_hOldDC = ::wglGetCurrentDC();
	m_hOldRC = ::wglGetCurrentContext(); 

	// 7. Make the memory RC current
	::wglMakeCurrent(m_hMemDC, m_hMemRC);

	// Draw *********************
	InitGL();
	ReSizeGLScene(imgw, imgh);
	DrawGLScene();
	// **************************

	// Now save to bitmap
	FILE *fs;
	BITMAPFILEHEADER bmFileHeader;

	fs = fopen( filename, "wb" );
	if ( NULL == fs )
		return;

	memset( &bmFileHeader, 0, sizeof(BITMAPFILEHEADER) );
	bmFileHeader.bfType = 0x4D42;
	bmFileHeader.bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
	bmFileHeader.bfSize = bmFileHeader.bfOffBits
				+ m_bmi.bmiHeader.biSizeImage;

	fwrite( &bmFileHeader, 1, sizeof(BITMAPFILEHEADER), fs );
	fwrite( &(m_bmi.bmiHeader), 1, sizeof(BITMAPINFOHEADER), fs );
	fwrite( m_pBitmapBits, 1, m_bmi.bmiHeader.biSizeImage, fs );
	fclose( fs );
			 
	//  Release memory RC, and restore the old DC and RC.
	::wglMakeCurrent(NULL, NULL);	

	// Restore last DC and RC
	::wglMakeCurrent(m_hOldDC, m_hOldRC);	
	
}


