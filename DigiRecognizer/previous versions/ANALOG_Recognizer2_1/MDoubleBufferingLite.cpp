// MDoubleBufferingLite.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "MDoubleBufferingLite.h"
#include "MDoubleBufferingLiteDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CMDoubleBufferingLiteApp

BEGIN_MESSAGE_MAP(CMDoubleBufferingLiteApp, CWinApp)
	//{{AFX_MSG_MAP(CMDoubleBufferingLiteApp)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code!
	//}}AFX_MSG
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMDoubleBufferingLiteApp construction

CMDoubleBufferingLiteApp::CMDoubleBufferingLiteApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CMDoubleBufferingLiteApp object

CMDoubleBufferingLiteApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CMDoubleBufferingLiteApp initialization

BOOL CMDoubleBufferingLiteApp::InitInstance()
{
	AfxEnableControlContainer();

	// Standard initialization
	// If you are not using these features and wish to reduce the size
	//  of your final executable, you should remove from the following
	//  the specific initialization routines you do not need.

#ifdef _AFXDLL
	Enable3dControls();			// Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();	// Call this when linking to MFC statically
#endif

	CMDoubleBufferingLiteDlg dlg;
	m_pMainWnd = &dlg;
	int nResponse = dlg.DoModal();
	if (nResponse == IDOK)
	   {
		// TODO: Place code here to handle when the dialog is
		//  dismissed with OK
	   }
	else if (nResponse == IDCANCEL)
	   {
		// TODO: Place code here to handle when the dialog is
		//  dismissed with Cancel
	   }

	// Since the dialog has been closed, return FALSE so that we exit the
	//  application, rather than start the application's message pump.
	return FALSE;
}


/////////////////////////////////////////////////////////////////////////////
// ActiveMIL function: default exception handling
 
LRESULT CMDoubleBufferingLiteApp::ProcessWndProcException(CException* e, const MSG* pMsg)
{
   e->ReportError();
   static_cast<CDialog*>(m_pMainWnd)->EndDialog(IDCANCEL);
 
   return 1;
}


/////////////////////////////////////////////////////////////////////////////
// _com_raise_error
//   This function causes the compiler to throw COleDispatchExceptions instead
//   of _com_error.  This means that MFC catch statements will work.
//

#ifdef ACTIVEMIL_USE_COM_CLASS

void __stdcall _com_raise_error(HRESULT hr, IErrorInfo* perrinfo)
{
   if (perrinfo != NULL)
      {
	   COleDispatchException* pException = new COleDispatchException(NULL, 0, HRESULT_CODE(hr));

      BSTR bstrSource ;
      perrinfo->GetSource(&bstrSource) ;
	   if (bstrSource != NULL)
	      {
		   pException->m_strSource = bstrSource;
		   SysFreeString(bstrSource);
	      }

      BSTR bstrDescription;
      perrinfo->GetDescription(&bstrDescription) ;
	   if (bstrDescription != NULL)
	      {
		   pException->m_strDescription = bstrDescription;
		   SysFreeString(bstrDescription);
	      }

      BSTR bstrHelpFile;
      perrinfo->GetHelpFile(&bstrHelpFile) ;
	   if (bstrHelpFile != NULL)
	      {
		   pException->m_strHelpFile = bstrHelpFile;
		   SysFreeString(bstrHelpFile);
	      }

      perrinfo->GetHelpContext(&pException->m_dwHelpContext);
	   pException->m_scError = hr;

	   // then throw the exception
	   throw pException ;
      }
   else
      {
		// non-exception error code
		AfxThrowOleException(hr);
      }
}
//**************************************
// FROM Jason Grant at MATROX...
//// COM
//void PassGC(IGraphicContext *gc)
//{
//	gc->Text("Hello");
//}
//
//void CActiveMIL_GraphicContextDlg::OnButtonPassGc()
//{
//	PassGC(m_GraphicContext1);
//}
//
//#else
//// MFC
//{
	// FILL THIS IN!!!
//}
//**************************************

#endif // ACTIVEMIL_USE_COM_CLASS
