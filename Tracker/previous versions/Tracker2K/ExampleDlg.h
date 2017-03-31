// MDoubleBufferingLite example

// This example does double buffered grab with real time processing.     
// It also times to see if some frames are not processed using hooks.    
//                                                                       
// Note: This assumes that the processing operation is shorter than a grab
//       and that the PC has sufficient bandwith to support the 2        
//       operations simultaneously. Also if the target processing buffer 
//       is not on the display, the processing speed is augmented.       

// ExampleDlg.h : header file
//
//{{AFX_INCLUDES()
#include "Buffer.h"
#include "Digitizer.h"
#include "Display.h"
#include "System.h"
#include "Application.h"
#include "GraphicContext.h"
//}}AFX_INCLUDES

#if !defined(AFX_EXAMPLEDLG_H_MDoubleBufferingLite_INCLUDED_)
#define AFX_EXAMPLEDLG_H_MDoubleBufferingLite_INCLUDED_

#include "resource.h"		// main symbols
#include "TableCtrl.h"
#include "VCRCtrl.h"
#include <mil.h>           // include for MIL native definitions

/////////////////////////////////////////////////////////////////////////////
// CExampleDlg dialog
//
class CExampleDlg : public CDialog
{
// Construction
public:
	CExampleDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CExampleDlg)
	enum { IDD = IDD_EXAMPLE_DIALOG };
	CButton	m_QuitButton;
	CButton m_RestartButton;
	CButton	m_UpButton;
	CButton	m_DownButton;
	CButton	m_LeftButton;
	CButton	m_RightButton;
	CButton m_AutoButton;
	CButton m_ImageButton;
	CButton m_PowerButton;
	CButton m_StartButton;
	CButton m_PrevButton;
	CButton m_NextButton;
	CButton m_RecordButton;
	CSliderCtrl m_Slider;
	CString m_strCommentText;
	CDisplay	    m_Display;
	CDigitizer	    m_Digitizer;
	CSystem	        m_System;
	CApplication	m_Application;
    CBuffer	m_DisplayBuffer;
	CBuffer	m_CurrentBuffer;
	CBuffer	m_PreviousBuffer;
	CBuffer m_EmptyBuffer;
	CGraphicContext	m_GraphicContext;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CExampleDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
   Table *table;				 // Table structure
   VCR   *vcr;
   long m_nStepCount;            // Keeps track of the current example step 
   long m_restart;				 // Restart the system
   long m_image;				 // Display the image
   long m_track;				 // Enable tracking
   void AdjustDialog();          // Resizes the dialog to fit any font size and digitizer resolution
   
   long m_nProcessingCount;      // number of processing iterations performed
   double m_dTime;               // time elapsed
   double recTime;				 // time since recording started
   int    record;				 // flag to determine if recording is in progress

   // processing thread related members
   long     m_bStopProcessing;   // flag for processing thread termination
   long     m_bKillProcessing;   // flag for processing thread termination	

   static UINT ProcessingThreadFunction(LPVOID pParam); // processing thread control function
   void ProcessingWorkFunction();    // processing thread working function
   afx_msg LONG OnProcessingWorkFunctionEnd( UINT, LONG ); // Custom Windows message handler  

	// Generated message map functions
	//{{AFX_MSG(CExampleDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnQuitbutton();
	afx_msg void OnClose();
	afx_msg void OnRestartbutton();
	afx_msg void OnImagebutton();
	afx_msg void OnUpbutton();
	afx_msg void OnDownbutton();
	afx_msg void OnLeftbutton();
	afx_msg void OnRightbutton();
	afx_msg void OnAutobutton();
	afx_msg void OnMagSlider(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnPowerbutton();
	afx_msg void OnRecbutton();
	afx_msg void OnStartbutton();
	afx_msg void OnPrevbutton();
	afx_msg void OnNextbutton();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
// CExampleApp:
// See Example.cpp for the implementation of this class
//
class CExampleApp : public CWinApp
{
public:
   CExampleApp() {};

	//{{AFX_VIRTUAL(CExampleApp)
	inline virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

};


/////////////////////////////////////////////////////////////////////////////
// CExampleApp initialization
//
BOOL CExampleApp::InitInstance()
{
	AfxEnableControlContainer();

	CExampleDlg dlg;
	m_pMainWnd = &dlg;
	dlg.DoModal();

	return FALSE;
}


//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif 
