// OptionsDlg.cpp : implementation file
//

#include "stdafx.h"
#include "MWRecognizer.h"
#include "OptionsDlg.h"
#include <math.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

extern int multiworm;
extern int lightSeg;
extern int lsms;
extern int pixelcthres;
extern double lsthreshold;

//Spine points
extern int spnsize;
extern int saveimages;
extern char pointsname[255];

//Focus of Attention
extern int foams;
extern int foaws;
extern int foass;
extern double foathreshold;

//Segmentation Boundary
extern int bndryms;
extern int bndryws;
extern double bndrythreshold;
extern int bndrysize;

///////////////////////////////////////////////////////
//Function Prototypes
//
extern void RestoreDefaultParams();
//
///////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
// COptionsDlg dialog


COptionsDlg::COptionsDlg(CWnd* pParent /*=NULL*/)
	: CDialog(COptionsDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(COptionsDlg)
	//}}AFX_DATA_INIT
}


void COptionsDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(COptionsDlg)
	DDX_Control(pDX, IDC_BNDRYSIZE, m_bndrysizeEdit);
	DDX_Control(pDX, IDC_RESTOREDEFAULTS, m_RestoredefaultsButton);
	DDX_Control(pDX, IDC_BNDRYWS, m_bndrywsEdit);
	DDX_Control(pDX, IDC_BNDRYTHRESHOLD, m_bndrythresholdEdit);
	DDX_Control(pDX, IDC_BNDRYMS, m_bndrymsEdit);
	DDX_Control(pDX, IDC_FOATHRESHOLD, m_foathresholdEdit);
	DDX_Control(pDX, IDC_FOASS, m_foassEdit);
	DDX_Control(pDX, IDC_FOAWS, m_foawsEdit);
	DDX_Control(pDX, IDC_FOAMS, m_foamsEdit);
	DDX_Control(pDX, IDC_POINTSNAME, m_PointsnameEdit);
	DDX_Control(pDX, IDC_SAVEIMAGES, m_SaveimagesEdit);
	DDX_Control(pDX, IDC_SPINESIZE, m_SpinesizeEdit);
	DDX_Control(pDX, IDC_MWPCOUNT, m_mwPixelCountEdit);
	DDX_Control(pDX, IDC_SLIDER2, m_lsThresholdSlider);
	DDX_Control(pDX, IDC_LSTHRES, m_lsThresholdEdit);
	DDX_Control(pDX, IDC_SLIDER1, m_lsmsSlider);
	DDX_Control(pDX, IDC_LSMS, m_lsmsEdit);
	DDX_Control(pDX, IDC_SEGCHECK, m_segCheck);
	DDX_Control(pDX, IDC_CHECK1, m_multiwormCheck);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(COptionsDlg, CDialog)
	//{{AFX_MSG_MAP(COptionsDlg)
	ON_BN_CLICKED(IDC_CHECK1, OnCheck1)
	ON_BN_CLICKED(IDC_SEGCHECK, OnSegcheck)
	ON_EN_CHANGE(IDC_LSMS, OnChangeLsms)
	ON_WM_HSCROLL()
	ON_EN_CHANGE(IDC_LSTHRES, OnChangeLsthres)
	ON_EN_CHANGE(IDC_MWPCOUNT, OnChangeMwpcount)
	ON_EN_CHANGE(IDC_SPINESIZE, OnChangeSpinesize)
	ON_EN_CHANGE(IDC_SAVEIMAGES, OnChangeSaveimages)
	ON_EN_CHANGE(IDC_POINTSNAME, OnChangePointsname)
	ON_EN_CHANGE(IDC_FOAMS, OnChangeFoams)
	ON_EN_CHANGE(IDC_FOAWS, OnChangeFoaws)
	ON_EN_CHANGE(IDC_FOASS, OnChangeFoass)
	ON_EN_CHANGE(IDC_FOATHRESHOLD, OnChangeFoathreshold)
	ON_EN_CHANGE(IDC_BNDRYMS, OnChangeBndryms)
	ON_EN_CHANGE(IDC_BNDRYSIZE, OnChangeBndrysize)
	ON_EN_CHANGE(IDC_BNDRYTHRESHOLD, OnChangeBndrythreshold)
	ON_EN_CHANGE(IDC_BNDRYWS, OnChangeBndryws)
	ON_BN_CLICKED(IDC_RESTOREDEFAULTS, OnRestoredefaults)
	//}}AFX_MSG_MAP
#ifdef SHOWTOOLTIPS
	ON_NOTIFY_EX(TTN_NEEDTEXT,0,OnToolTipNotify)	/* CJC 2010-07-07 */ 
#endif // #ifdef SHOWTOOLTIPS
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// COptionsDlg message handlers

void COptionsDlg::OnCheck1() 
{
	// TODO: Add your control notification handler code here
	multiworm=m_multiwormCheck.GetCheck();
	m_mwPixelCountEdit.EnableWindow(multiworm);
}

void COptionsDlg::OnSegcheck() 
{
	// TODO: Add your control notification handler code here
	lightSeg=m_segCheck.GetCheck();
	m_lsmsEdit.EnableWindow(lightSeg);
	m_lsmsSlider.EnableWindow(lightSeg);
	m_lsThresholdEdit.EnableWindow(lightSeg);
	m_lsThresholdSlider.EnableWindow(lightSeg);
}

BOOL COptionsDlg::OnInitDialog() 
{
	CDialog::OnInitDialog();

	EnableToolTips(TRUE);		/* CJC 2010-07-07 */ 
	
	// TODO: Add extra initialization here
	char buf[10];
//	bool recognizing;

	// initialize check boxes
	m_multiwormCheck.SetCheck(multiworm);
	m_segCheck.SetCheck(lightSeg);	

	// initialize filter window slider
	m_lsmsEdit.SetLimitText(3);
	m_lsmsSlider.SetBuddy(&m_lsmsEdit, FALSE);
	m_lsmsSlider.SetRange(11, 201);
	m_lsmsSlider.SetPos(lsms);	
	m_lsmsEdit.SetWindowText(_itoa(lsms, buf, 10));

	// initialize segmentation threshold
	m_lsThresholdEdit.SetLimitText(3);
	m_lsThresholdSlider.SetBuddy(&m_lsThresholdEdit, FALSE);
	m_lsThresholdSlider.SetRange(0, 255);
	m_lsThresholdSlider.SetPos(floor(-lsthreshold/5.0*255.));
	m_lsThresholdEdit.SetWindowText(_itoa(m_lsThresholdSlider.GetPos(), buf, 10));

	// initialize pixel count threshold
	m_mwPixelCountEdit.SetLimitText(5);
	m_mwPixelCountEdit.SetWindowText(_itoa(pixelcthres, buf, 10));

	// initialize Spine Size
	m_SpinesizeEdit.SetLimitText(3);
	m_SpinesizeEdit.SetWindowText(_itoa(spnsize, buf, 10));

	// initialize save images
	m_SaveimagesEdit.SetLimitText(5);
	m_SaveimagesEdit.SetWindowText(_itoa(saveimages, buf, 10));

	// initialize pointsfile name
	m_PointsnameEdit.SetLimitText(253);	// two bytes less than 255 byte array size
	m_PointsnameEdit.SetWindowText(pointsname);

//Initialize Focus of Attention
	// initialize foams
	m_foamsEdit.SetLimitText(3);
	m_foamsEdit.SetWindowText(_itoa(foams, buf, 10));

	// initialize foaws
	m_foawsEdit.SetLimitText(3);
	m_foawsEdit.SetWindowText(_itoa(foaws, buf, 10));

	// initialize foass
	m_foassEdit.SetLimitText(3);
	m_foassEdit.SetWindowText(_itoa(foass, buf, 10));

	// initialize foathreshold
	m_foathresholdEdit.SetLimitText(5);
	m_foathresholdEdit.SetWindowText(_gcvt(foathreshold, 2, buf));


//Initialize Segmentation Boundary
	// initialize bndryms
	m_bndrymsEdit.SetLimitText(3);
	m_bndrymsEdit.SetWindowText(_itoa(bndryms, buf, 10));

	// initialize bndryws
	m_bndrywsEdit.SetLimitText(3);
	m_bndrywsEdit.SetWindowText(_itoa(bndryws, buf, 10));

	// initialize bndrysize
	m_bndrysizeEdit.SetLimitText(3);
	m_bndrysizeEdit.SetWindowText(_itoa(bndrysize, buf, 10));

	// initialize bndrythreshold
	m_bndrythresholdEdit.SetLimitText(5);
	m_bndrythresholdEdit.SetWindowText(_gcvt(bndrythreshold, 2, buf));



	// Enable & diable windows
	m_lsmsEdit.EnableWindow(lightSeg);
	m_lsmsSlider.EnableWindow(lightSeg);
	m_lsThresholdEdit.EnableWindow(lightSeg);
	m_lsThresholdSlider.EnableWindow(lightSeg);

	m_mwPixelCountEdit.EnableWindow(multiworm);

	//These are unnecessary
//	m_SpinesizeEdit.EnableWindow(TRUE);
//	m_SaveimagesEdit.EnableWindow(TRUE);
//	m_PointsnameEdit.EnableWindow(TRUE);


	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

#ifdef SHOWTOOLTIPS
BOOL COptionsDlg::OnToolTipNotify(UINT id, NMHDR* pNMHDR, LRESULT* pResult)	/* CJC 2010-07-07 */ 
{
	TOOLTIPTEXT * pTTT = (TOOLTIPTEXT *) pNMHDR;
	::SendMessage(pNMHDR->hwndFrom, TTM_SETMAXTIPWIDTH, 0, 300);		/* CJC 2010-07-08 To enable multiline tooltips */
	UINT nID = pNMHDR->idFrom;

	char strTipChar[999];

	if(pTTT->uFlags & TTF_IDISHWND)
	{
		// idFrom is actually the HWND of the tool
		nID = ::GetDlgCtrlID((HWND)nID);	/* Get controlID to locate a particular control */
		switch(nID)
		{
			case IDC_FOAMS:
				strcpy_s(strTipChar, "Size of window for binarizing image, used along with foathreshold.\n-->Value should be ODD<-- \n(e.g. 3)");
				pTTT->lpszText = strTipChar;
				break;
			case IDC_FOAWS:
				strcpy_s(strTipChar, "Size of window (width and height) for finding focus of attention 'centroid'.\n-->Value should be ODD<--  \n(e.g. 51)");
				pTTT->lpszText = strTipChar;
				break;
			case IDC_FOASS:
				strcpy_s(strTipChar, "Subsampling factor for binarizing image: subsample every FOASS'th pixel.\n(e.g. 4)");
				pTTT->lpszText = strTipChar;
				break;
			case IDC_FOATHRESHOLD:
				strcpy_s(strTipChar, "Threshold  to identify worm vs background.\nValue should be between 0 and 1.\n(e.g. 0.7)");
				pTTT->lpszText = strTipChar;
				break;

			case IDC_BNDRYMS:
				strcpy_s(strTipChar, "Smoothing window width.  Elements in window are combined together to establish center element value.\n-->Value should be ODD<--\n(e.g. 15)");
				pTTT->lpszText = strTipChar;
				break;
			case IDC_BNDRYWS:
				strcpy_s(strTipChar, "Size of window (width and height) in which to look for a worm.\n-->Value should be ODD<--\n(e.g. 251)");
				pTTT->lpszText = strTipChar;
				break;
			case IDC_BNDRYSIZE:
				strcpy_s(strTipChar, "How many points to distribute around the worm's boundary.  Determines the number of triangles (as n-2).\n(e.g. 50)");
				pTTT->lpszText = strTipChar;
				break;
			case IDC_BNDRYTHRESHOLD:
				strcpy_s(strTipChar, "Threshold value for finding worm edge.\nValue should be between 0 and 1.  (e.g. 0.8)");
				pTTT->lpszText = strTipChar;
				break;

			case IDC_SPINESIZE:
				strcpy_s(strTipChar, "Number of points to distribute along the 'spine' of the worm.\r\n(e.g. 13)");
				pTTT->lpszText = strTipChar;
				break;
			case IDC_SAVEIMAGES:
				strcpy_s(strTipChar, "How frequently to save a reference image.\r\n(e.g. 100)");
				pTTT->lpszText = strTipChar;
				break;
			case IDC_POINTSNAME:
				strcpy_s(strTipChar, "File name for xy point coordinate data...  \r\nProbably should be 'points' (unless you know something the program doesn't).");
				pTTT->lpszText = strTipChar;
				break;
		}
		return TRUE;
	}
	return FALSE;
}
#endif // #ifdef SHOWTOOLTIPS



void COptionsDlg::OnChangeLsms() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_lsmsEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	m_lsmsSlider.SetPos(atoi(buf));

	if (m_lsmsSlider.GetPos() % 2) 
		lsms=m_lsmsSlider.GetPos();
	else
		lsms=m_lsmsSlider.GetPos()+1;
}



void COptionsDlg::OnChangeLsthres() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_lsThresholdEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	m_lsThresholdSlider.SetPos(atoi(buf));
	lsthreshold=-(double) m_lsThresholdSlider.GetPos()/255.0*5.;
}

void COptionsDlg::OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
	// TODO: Add your message handler code here and/or call default

	char buf[10];
	CSliderCtrl *ctrl=(CSliderCtrl*) pScrollBar;
	CEdit *edit=(CEdit*) ctrl->GetBuddy(FALSE);

	if (edit) 
	{
		edit->SetWindowText(_itoa(ctrl->GetPos(), buf, 10));
		if (m_lsmsSlider.GetPos() % 2) 
			lsms=m_lsmsSlider.GetPos();
		else
			lsms=m_lsmsSlider.GetPos()+1;

// CJC was NEGATIVE: lsthreshold=-(double) m_lsThresholdSlider.GetPos()/255.0*5.;
		lsthreshold=(double) m_lsThresholdSlider.GetPos()/255.0*5.;
	}
	CDialog::OnHScroll(nSBCode, nPos, pScrollBar);
}



void COptionsDlg::OnChangeMwpcount() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_mwPixelCountEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	pixelcthres=atoi(buf);
}


void COptionsDlg::OnChangeSpinesize() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_SpinesizeEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	spnsize=atoi(buf);
}

void COptionsDlg::OnChangeSaveimages() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_SaveimagesEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	saveimages=atoi(buf);
}

void COptionsDlg::OnChangePointsname() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	/* m_PointsnameEdit.GetLine(0, pointsname); */
	int len = m_PointsnameEdit.GetLine(0, pointsname, 254);
	pointsname[len] = 0;	/* manually null terminate */
}

void COptionsDlg::OnChangeFoams() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_foamsEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	foams=atoi(buf);
}

void COptionsDlg::OnChangeFoaws() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10] = "";		// CJC 2010-06-22 Added initialization to null
	int len = m_foawsEdit.GetLine(0, buf, 10);	// <--- CJC 2010-06-22 Corruption happening here [suffixing 0]  
	buf[len] = 0;	/* manually null terminate */
	foaws=atoi(buf);
}

void COptionsDlg::OnChangeFoass() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_foassEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	foass=atoi(buf);
}

void COptionsDlg::OnChangeFoathreshold() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_foathresholdEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	foathreshold=atof(buf);
}



//Segmentation Boundary attributes
void COptionsDlg::OnChangeBndryms() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_bndrymsEdit.GetLine(0, buf, 10);	// 7 being suffixed HERE  CJC 2010-06-30; fix by manually null-terminating
	buf[len] = 0;	/* manually null terminate */
	bndryms=atoi(buf);
}

void COptionsDlg::OnChangeBndryws() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_bndrywsEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	bndryws=atoi(buf);
}

void COptionsDlg::OnChangeBndrysize() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_bndrysizeEdit.GetLine(0, buf, 10);	// <-- CJC 2010-06-22 Corruption here, suffixed 1
	buf[len] = 0;	/* manually null terminate */
	bndrysize=atoi(buf);
}

void COptionsDlg::OnChangeBndrythreshold() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	int len = m_bndrythresholdEdit.GetLine(0, buf, 10);
	buf[len] = 0;	/* manually null terminate */
	bndrythreshold=atof(buf);
}

void COptionsDlg::OnRestoredefaults() 
{
	// TODO: Add your control notification handler code here
	RestoreDefaultParams();
	OnInitDialog();		// CJC 4-01-05 Try this as a means of updating the text in the edit boxes automatically(?)
	AfxMessageBox("Restored");
	//AfxMessageBox("Sorry, not implemented yet");
}


