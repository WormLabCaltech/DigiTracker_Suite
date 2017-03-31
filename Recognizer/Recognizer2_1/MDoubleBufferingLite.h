// MDoubleBufferingLite.h : main header file for the MDOUBLEBUFFERINGLITE application
//

#if !defined(AFX_MDOUBLEBUFFERINGLITE_H__700A8FFA_B028_4BC5_9BB9_734D136A5F8E__INCLUDED_)
#define AFX_MDOUBLEBUFFERINGLITE_H__700A8FFA_B028_4BC5_9BB9_734D136A5F8E__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols
//--------------- CJC ----start------------------------------------------
//#include "vcr.h"		//Move to __Dlg.h
//#include <mil.h>           // include for MIL native definitions
//--------------- CJC -----end-------------------------------------------

/////////////////////////////////////////////////////////////////////////////
// CMDoubleBufferingLiteApp:
// See MDoubleBufferingLite.cpp for the implementation of this class
//

class CMDoubleBufferingLiteApp : public CWinApp
{
public:
	CMDoubleBufferingLiteApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMDoubleBufferingLiteApp)
	public:
	virtual BOOL InitInstance();
   inline virtual LRESULT ProcessWndProcException(CException* e, const MSG* pMsg);
	//}}AFX_VIRTUAL

// Implementation

	//{{AFX_MSG(CMDoubleBufferingLiteApp)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MDOUBLEBUFFERINGLITE_H__700A8FFA_B028_4BC5_9BB9_734D136A5F8E__INCLUDED_)
