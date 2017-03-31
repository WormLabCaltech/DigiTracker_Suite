// MWRecognizer.h : main header file for the MWRECOGNIZER application
//

#if !defined(AFX_MWRECOGNIZER_H__D18D299D_4A0D_4EBF_8E93_BF9AD7324A35__INCLUDED_)
#define AFX_MWRECOGNIZER_H__D18D299D_4A0D_4EBF_8E93_BF9AD7324A35__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols

/////////////////////////////////////////////////////////////////////////////
// CMWRecognizerApp:
// See MWRecognizer.cpp for the implementation of this class
//

class CMWRecognizerApp : public CWinApp
{
public:
	CMWRecognizerApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMWRecognizerApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CMWRecognizerApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWRECOGNIZER_H__D18D299D_4A0D_4EBF_8E93_BF9AD7324A35__INCLUDED_)
