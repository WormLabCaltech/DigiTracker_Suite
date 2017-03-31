// MWRecognizerDlg.h : header file
//

#if !defined(AFX_MWRECOGNIZERDLG_H__32DA89CC_29DE_4C9D_9489_0DF6BEB972AD__INCLUDED_)
#define AFX_MWRECOGNIZERDLG_H__32DA89CC_29DE_4C9D_9489_0DF6BEB972AD__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

# include "GlView.h"
#include "OptionsDlg.h"

/////////////////////////////////////////////////////////////////////////////
// CMWRecognizerDlg dialog

class CMWRecognizerDlg : public CDialog
{
// Construction
public:
	CString csCh;
	CString m_csParamsFilePath;
	void LoadParams(void);
	void SaveParams(void);
	void DisplayFrame(CString filename, int frameId);
	void BatchProcessingWorkFunction();
	int ProcessSequence(CString filename);
	afx_msg LONG OnProcessingWorkFunctionEnd(UINT, LONG);
	void ProcessingWorkFunction();
	static UINT ProcessingThreadFunction(LPVOID pParam);
	CMWRecognizerDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CMWRecognizerDlg)
	enum { IDD = IDD_MWRECOGNIZER_DIALOG };
	CButton	m_segDisplayCheck;
	CProgressCtrl	m_progressBar;
	CButton	m_stopButton;
	CButton	m_recognizeButton;
	CButton	m_removeButton;
	CButton	m_clearButton;
	CButton	m_addButton;
	CListBox	m_videoListBox;
	CStatic	m_staticView;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMWRecognizerDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;
	CGlView *m_glView;
	COptionsDlg *optionsDlg;

	FILE *fp;
	bool batchProcess, killProcess, inProgress;

	// Generated message map functions
	//{{AFX_MSG(CMWRecognizerDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnAdd();
	afx_msg void OnRemove();
	afx_msg void OnClear();
	afx_msg void OnRecognize();
	afx_msg void OnStop();
	virtual void OnOK();
	afx_msg void OnClose();
	afx_msg void OnSelchangeList2();
	afx_msg void OnCheck1();
	afx_msg void OnOptions();
	afx_msg int OnVKeyToItem(UINT nKey, CListBox* pListBox, UINT nIndex);
	afx_msg void OnSort();
	afx_msg void OnMoveUp();
	afx_msg void OnMoveDown();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWRECOGNIZERDLG_H__32DA89CC_29DE_4C9D_9489_0DF6BEB972AD__INCLUDED_)
