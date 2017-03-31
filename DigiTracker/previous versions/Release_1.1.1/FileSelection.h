#if !defined(AFX_FILESELECTION_H__6B7C13DD_AA74_4D30_8234_8B81F77ADFDA__INCLUDED_)
#define AFX_FILESELECTION_H__6B7C13DD_AA74_4D30_8234_8B81F77ADFDA__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// FileSelection.h : header file
//

#include <stdio.h>
#include <direct.h>
#include "resource.h"

/////////////////////////////////////////////////////////////////////////////
// FileSelection dialog

class FileSelection : public CDialog
{
// Construction
public:
	FileSelection(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(FileSelection)
	enum { IDD = IDD_FILESOURCE };
	CButton	m_save_as_default;
	CString	m_file_path_name;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(FileSelection)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(FileSelection)
	virtual void OnCancel();
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
// DeviceNotReady dialog

class DeviceNotReady : public CDialog
{
// Construction
public:
	DeviceNotReady(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(DeviceNotReady)
	enum { IDD = IDD_DEVICENOTREADY };
	CString	m_device_not_ready;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(DeviceNotReady)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(DeviceNotReady)
	afx_msg void OnRetry();
	afx_msg void OnQuit();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
/////////////////////////////////////////////////////////////////////////////
// No_Source_Dir dialog

class No_Source_Dir : public CDialog
{
// Construction
public:
	No_Source_Dir(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(No_Source_Dir)
	enum { IDD = IDD_DIRECTORYNOT };
	CString	m_no_directory;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(No_Source_Dir)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(No_Source_Dir)
	virtual void OnCancel();
	afx_msg void OnCreatedir();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
/////////////////////////////////////////////////////////////////////////////
// FileNotSelection dialog

class FileNotSelection : public CDialog
{
// Construction
public:
	FileNotSelection(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(FileNotSelection)
	enum { IDD = IDD_FILENOT };
	CString	m_file_nogo;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(FileNotSelection)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(FileNotSelection)
	afx_msg void OnFilenotok();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
/////////////////////////////////////////////////////////////////////////////
// DirCreateError dialog

class DirCreateError : public CDialog
{
// Construction
public:
	DirCreateError(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(DirCreateError)
	enum { IDD = IDD_NOCREATEDIR };
	CString	m_dir_fail;
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(DirCreateError)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(DirCreateError)
	afx_msg void OnNoDirOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.
    int get_available_space(void);
    bool set_record_file(SYSTEMTIME *current_time);
	void close_record_file(void);

#endif // !defined(AFX_FILESELECTION_H__6B7C13DD_AA74_4D30_8234_8B81F77ADFDA__INCLUDED_)
