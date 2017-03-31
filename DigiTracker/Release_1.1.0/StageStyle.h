#if !defined(AFX_STAGESTYLE_H__0B71B8B0_B144_4692_9A28_1336ED16D154__INCLUDED_)
#define AFX_STAGESTYLE_H__0B71B8B0_B144_4692_9A28_1336ED16D154__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// StageStyle.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CStageStyle dialog

class CStageStyle : public CDialog
{
// Construction
public:
	CStageStyle(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CStageStyle)
	enum { IDD = IDD_STAGESTYLEDLG };
	CComboBox	m_stageStyleCombo;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CStageStyle)
	public:
	virtual int DoModal();
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:



	// Generated message map functions
	//{{AFX_MSG(CStageStyle)
	virtual void OnOK();
	virtual BOOL OnInitDialog();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STAGESTYLE_H__0B71B8B0_B144_4692_9A28_1336ED16D154__INCLUDED_)
