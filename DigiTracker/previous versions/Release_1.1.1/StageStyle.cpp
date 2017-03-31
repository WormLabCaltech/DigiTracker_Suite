// StageStyle.cpp : implementation file
//

#include "stdafx.h"
//#include "mdoublebufferinglite.h"
#include "ExampleDlg.h"
#include "StageStyle.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// External variables
extern int stagestyle;		// Code for stage type
							// Used to define, e.g. which move-code is 
							// sent to motorized stage,


/////////////////////////////////////////////////////////////////////////////
// CStageStyle dialog


CStageStyle::CStageStyle(CWnd* pParent /*=NULL*/)
	: CDialog(CStageStyle::IDD, pParent)
{
	//{{AFX_DATA_INIT(CStageStyle)
		// NOTE: the ClassWizard will add member initialization here
	//}}AFX_DATA_INIT
}


void CStageStyle::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CStageStyle)
	DDX_Control(pDX, IDC_STAGESTYLE, m_stageStyleCombo);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CStageStyle, CDialog)
	//{{AFX_MSG_MAP(CStageStyle)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CStageStyle message handlers

void CStageStyle::OnOK() 
{
	// TODO: Add extra validation here
	
	stagestyle = m_stageStyleCombo.GetCurSel();     // CJC 9-05-06
//===> PUT STAGE STYLE TEXT INTO m_stageStyleString display (edit box)

	CDialog::OnOK();
}

int CStageStyle::DoModal() 
{
	// TODO: Add your specialized code here and/or call the base class

	return CDialog::DoModal();
}

BOOL CStageStyle::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	// TODO: Add extra initialization here

// CJC 9-05-06 Try adding this initialization here, once and for all 
stagestyle = stagestyle;
	m_stageStyleCombo.SetCurSel(stagestyle);

//Don't Need: CJC 9-08-06 int numitems; 
//Don't Need: CJC 9-08-06numitems = m_stageStyleCombo.GetCount();

//char stageNames[5][20];
CString stageName;

m_stageStyleCombo.GetLBText(stagestyle, stageName);



		
	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}
