// LocationDlg.cpp : implementation file
//

#include "stdafx.h"
//#include "mdoublebufferinglite.h"
#include "ExampleDlg.h"
#include "LocationDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


/////////////////////////////////////////////////////////////////////////////
// External variables
extern int locationcode;	// Code for Tracker configuration.
							// Defines, e.g. which move-code is sent to motorized stage,
							// stage travel dirction...



/////////////////////////////////////////////////////////////////////////////
// CLocationDlg dialog


CLocationDlg::CLocationDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CLocationDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CLocationDlg)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CLocationDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CLocationDlg)
	DDX_Control(pDX, IDC_LOCATIONCOMBO, m_LocationCombo);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CLocationDlg, CDialog)
	//{{AFX_MSG_MAP(CLocationDlg)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CLocationDlg message handlers

void CLocationDlg::OnOK() 
{
	// TODO: Add extra validation here
	
	locationcode = m_LocationCombo.GetCurSel();

	CDialog::OnOK();
}

BOOL CLocationDlg::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	// TODO: Add extra initialization here
	m_LocationCombo.SetCurSel(locationcode);
	
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}
