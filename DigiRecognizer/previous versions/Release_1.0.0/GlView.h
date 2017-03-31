#if !defined(AFX_GLVIEW_H__6A408C2D_B713_4D84_8500_C4FD27AB2713__INCLUDED_)
#define AFX_GLVIEW_H__6A408C2D_B713_4D84_8500_C4FD27AB2713__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// GlView.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CGlView window

#include <gl/gl.h> 
#include <gl/glu.h> 
#include "mex.h"
#include <list>



typedef struct {
	Matrix *pts;
	Matrix *bndry;
	Matrix *spn;
	Matrix *center;
} WormPos;

class CGlView : public CWnd
{
// Construction
public:
	CGlView(CWnd *pclWnd);

// Attributes
public:

	HDC  m_hDC;		// GDI Device Context 
    HGLRC	m_hglRC;		// Rendering Context

    CWnd *m_pclWnd;
    HWND m_hWnd;
	CRect rect;
	unsigned int imgw, imgh;
	COleSafeArray *DispArray;
	COleSafeArray *SegArray;
	std::list<WormPos> wormPosList;
	bool m_drawSegmentation;
	
	//*** off-screen rendering variables
	BITMAPINFO	m_bmi;
	LPVOID		m_pBitmapBits;
	HBITMAP		m_hDib;
	HDC			m_hOldDC;
	HDC			m_hMemDC;
	HGLRC		m_hOldRC;
	HGLRC		m_hMemRC;

// Operations
public:
	BOOL SetPixelformat(HDC hdc);
	GLvoid ReSizeGLScene(GLsizei width, GLsizei height);
	int InitGL(GLvoid);	
	int DrawGLScene();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CGlView)
	protected:
//	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CGlView();

	// Generated message map functions
protected:

public:
	bool SetDCPixelFormat(HDC hDC, DWORD dwFlags);
	void SaveBitmap(char *filename);
	void ClearWormPosList();
	void AddWormPos(Matrix *center, Matrix *bndry, Matrix *spn, Matrix *pts);
	COleSafeArray* GetDisplayArray(unsigned int w, unsigned int h);
	COleSafeArray* GetSegArray(unsigned int w, unsigned int h);
	void DrawWorm(Matrix *center, Matrix *bndry, Matrix *spn, Matrix *pts);
	int OnCreate();
	//{{AFX_MSG(CGlView)
//	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
//	afx_msg void OnDestroy();
//	afx_msg void OnSize(UINT nType, int cx, int cy);
//	afx_msg BOOL OnEraseBkgnd(CDC* pDC);
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_GLVIEW_H__6A408C2D_B713_4D84_8500_C4FD27AB2713__INCLUDED_)
