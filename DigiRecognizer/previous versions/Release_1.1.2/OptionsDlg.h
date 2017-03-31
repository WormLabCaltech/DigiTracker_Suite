#if !defined(AFX_OPTIONSDLG_H__966D7082_B32D_4A2C_B353_53AD2D8F6852__INCLUDED_)
#define AFX_OPTIONSDLG_H__966D7082_B32D_4A2C_B353_53AD2D8F6852__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// OptionsDlg.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// COptionsDlg dialog

class COptionsDlg : public CDialog
{
// Construction
public:
	COptionsDlg(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(COptionsDlg)
	enum { IDD = IDD_OPTIONSBOX };
	CEdit	m_bndrysizeEdit;
	CButton	m_RestoredefaultsButton;
	CEdit	m_bndrywsEdit;
	CEdit	m_bndrythresholdEdit;
	CEdit	m_bndrymsEdit;
	CEdit	m_foathresholdEdit;
	CEdit	m_foassEdit;
	CEdit	m_foawsEdit;
	CEdit	m_foamsEdit;
	CEdit	m_PointsnameEdit;
	CEdit	m_SaveimagesEdit;
	CEdit	m_SpinesizeEdit;
	CEdit	m_mwPixelCountEdit;
	CSliderCtrl	m_lsThresholdSlider;
	CEdit	m_lsThresholdEdit;
	CSliderCtrl	m_lsmsSlider;
	CEdit	m_lsmsEdit;
	CButton	m_segCheck;
	CButton	m_multiwormCheck;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(COptionsDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(COptionsDlg)
	afx_msg void OnCheck1();
	afx_msg void OnSegcheck();
	virtual BOOL OnInitDialog();
	afx_msg void OnChangeLsms();
	afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnChangeLsthres();
	afx_msg void OnChangeMwpcount();
	afx_msg void OnChangeSpinesize();
	afx_msg void OnChangeSaveimages();
	afx_msg void OnChangePointsname();
	afx_msg void OnChangeFoams();
	afx_msg void OnChangeFoaws();
	afx_msg void OnChangeFoass();
	afx_msg void OnChangeFoathreshold();
	afx_msg void OnChangeBndryms();
	afx_msg void OnChangeBndrysize();
	afx_msg void OnChangeBndrythreshold();
	afx_msg void OnChangeBndryws();
	afx_msg void OnRestoredefaults();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_OPTIONSDLG_H__966D7082_B32D_4A2C_B353_53AD2D8F6852__INCLUDED_)
