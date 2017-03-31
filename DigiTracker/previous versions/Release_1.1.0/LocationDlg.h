#if !defined(AFX_LOCATIONDLG_H__D59D42C8_912B_4CD4_A233_E00AC4A4521D__INCLUDED_)
#define AFX_LOCATIONDLG_H__D59D42C8_912B_4CD4_A233_E00AC4A4521D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// LocationDlg.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CLocationDlg dialog

class CLocationDlg : public CDialog
{
// Construction
public:
	CLocationDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CLocationDlg)
	enum { IDD = IDD_LOCATIONSELECTOR };
	CComboBox	m_LocationCombo;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CLocationDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CLocationDlg)
	virtual void OnOK();
	virtual BOOL OnInitDialog();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_LOCATIONDLG_H__D59D42C8_912B_4CD4_A233_E00AC4A4521D__INCLUDED_)
