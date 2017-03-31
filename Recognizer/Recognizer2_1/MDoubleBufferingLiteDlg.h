// MDoubleBufferingLiteDlg.h : header file
//
//{{AFX_INCLUDES()
#include "Application.h"
#include "System.h"
#include "Image.h"
#include "Digitizer.h"
#include "Display.h"
#include "GraphicContext.h"
//}}AFX_INCLUDES
//--------------- CJC ----start------------------------------------------
#include "vcr.h"		//Move to __Dlg.h
#include <mil.h>           // include for MIL native definitions - prevents draw errors ?drawworm based on MIL?
#include "resource.h"
//--------------- CJC -----end-------------------------------------------


#if !defined(AFX_MDOUBLEBUFFERINGLITEDLG_H__F9CCFC7D_1EE3_4D48_8E56_EB6EBD964655__INCLUDED_)
#define AFX_MDOUBLEBUFFERINGLITEDLG_H__F9CCFC7D_1EE3_4D48_8E56_EB6EBD964655__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/////////////////////////////////////////////////////////////////////////////
// CMDoubleBufferingLiteDlg dialog

class CMDoubleBufferingLiteDlg : public CDialog
{
// Construction
public:
	CMDoubleBufferingLiteDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CMDoubleBufferingLiteDlg)
	enum { IDD = IDD_MDOUBLEBUFFERINGLITE_DIALOG };
	CButton	m_NextButton;
	CSystem	m_System1;
	CImage	m_Image1;
	CDisplay	m_Display1;
	CString	m_CommentText;
	CDigitizer	m_Digitizer1;
	CApplication	m_Application1;
	CGraphicContext	m_GraphicContext1;
	CGraphicContext	m_GraphicContext2;
	CImage	m_EmptyImage;
	CImage	m_GrabImage1;
	CImage	m_GrabImage2;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMDoubleBufferingLiteDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;
//--------------- CJC ----start------------------------------------------
   VCR  *vcr;					 // This is the VCR
//--------------- CJC -----end-------------------------------------------
   
   long m_StepCount;
   long m_ProcessingCount;
   double m_Time;

   // processing thread related members
   long m_StopProcessing;     // Flag for processing thread termination
   long m_KillProcessing;     // Flag for processing thread termination

   static UINT ProcessingThreadFunction(LPVOID pParam); // Processing thread control function
   void ProcessingWorkFunction();      // Processing thread working function
//--------------- CJC ----start------------------------------------------
   void ProcessingWorkFunctionHelper(int leng);    // processing thread working function
//--------------- CJC -----end-------------------------------------------

   // Custom Windows message handler
   afx_msg LONG OnProcessingWorkFunctionEnd(UINT, LONG);

   void AdjustStepNumber();   // Increments the step number and updates text in the dialog
   void AdjustDialog();    // Resizes the dialog to fit any font size and digitizer resolution

	// Generated message map functions
	//{{AFX_MSG(CMDoubleBufferingLiteDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnNextbutton();
	afx_msg void OnClose();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MDOUBLEBUFFERINGLITEDLG_H__F9CCFC7D_1EE3_4D48_8E56_EB6EBD964655__INCLUDED_)
