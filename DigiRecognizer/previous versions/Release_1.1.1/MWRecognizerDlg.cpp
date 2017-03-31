// MWRecognizerDlg.cpp : implementation file
//

#include "stdafx.h"
#include "MWRecognizer.h"
#include "MWRecognizerDlg.h"
#include "jpegUtil.h"
#include <string.h>

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

//--------------- CJC ----start------------------------------------------
#include "mex.h"
#include <direct.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
//--------------- CJC -----end-------------------------------------------

#define IMAGEX 320
#define IMAGEY 240
#define JPEG_QUALITY 70 // Quality of jpeg compression: 0 to 100.
//--------------- CJC ----start------------------------------------------
/////////////////////////////////////////////////////////////////////////////
// These are the global parameters
//

long memLeaks = 0;
int debug = 0;

// CMemoryState oldMemState, newMemState, diffMemState;

int foams;	// = 3;
int foaws;	// = 51;
int foass;	// = 4;
double foathreshold;	// = 0.7;

int bndryms;	// = 15;
int bndryws = 451;
double bndrythreshold = 0.8;//0.75;
int bndrysize = 50;

int spnsize = 13;

CString m_csLastFolderBrowsed;		// CJC 3-31-05
CString csPointsname;				// CJC 4-01-05

static char ch[1000];	// CJC 4-06-05
//CString csCh;			// CJC 4-06-05


char outdir[255] = "";
int saveimages = 0;
int savepoints = 1;
char pointsname[255] = "points";

char outsubdir[255];

// new parameters for the enhanced segmentation routine
int lightSeg=0;   //CJC 11-04-04 Change segmentation routine default to 'off'  (was) 1;          // switch to turn the new segmentation routine on
double lsthreshold=-0.7;     // threshold for the new segmentation routine
int lsms;	//=51;             // neigborhood region used by the new segmentation routine   
int multiworm=0;         // multiworm switch
int pixelcthres=60;      // pixel count threshold to enable tracking of worms

/////////////////////////////////////////////////////////////////////////////
// These are some function prototypes
//
extern Matrix *
mw_segment(Matrix *im, int ms, double threshold);

extern Matrix *
segment(Matrix *im, int ms, double threshold);
extern void findworm(Matrix *im, 
					 Matrix **center, Matrix **bndry, 
		             Matrix **spn, Matrix **pts);
extern Matrix** findmwboundry(Matrix *im, Matrix **center, int pixel_thres, int *count);
extern void centerline(Matrix *bndry, Matrix **spn, Matrix **pts, int npoints);

//CJC_3-4-03 ORIGINAL PROTOTYPE:  extern void drawworm(CGraphicContext *gc, void *center, void *bndry, void *spn, void *pts);
//CJC UNCHANGED, FOR NOW...
//extern void drawworm(CGraphicContext *gc, void *center, void *bndry, void *spn, void *pts);

//CJC 3-31-03 FROM Jason Grant AT Matrox:
//void drawworm(IGraphicContextPtr gc, void *center, void *bndry, void *spn, void *pts);

extern void save(Matrix *pts, double);

extern BOOL FolderBrowser(CWnd *pWnd, CString& title, CString& dir, CString 
&initial, BOOL bAll, BOOL bCreate);

void RestoreDefaultParams();



// External variables
//extern CEdit m_SpinesizeEdit, m_SaveimagesEdit, m_PointsnameEdit;


//--------------- CJC -----end-------------------------------------------


// Custom Windows message 
const int WM_PROCESSINGWORKFUNCTIONEND = WM_USER + 1;

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP

END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMWRecognizerDlg dialog

CMWRecognizerDlg::CMWRecognizerDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMWRecognizerDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CMWRecognizerDlg)
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CMWRecognizerDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CMWRecognizerDlg)
	DDX_Control(pDX, IDC_CHECK1, m_segDisplayCheck);
	DDX_Control(pDX, IDC_PROGRESS1, m_progressBar);
	DDX_Control(pDX, IDC_STOP, m_stopButton);
	DDX_Control(pDX, IDC_RECOGNIZE, m_recognizeButton);
	DDX_Control(pDX, IDC_REMOVE, m_removeButton);
	DDX_Control(pDX, IDC_CLEAR, m_clearButton);
	DDX_Control(pDX, IDC_ADD, m_addButton);
	DDX_Control(pDX, IDC_LIST2, m_videoListBox);
	DDX_Control(pDX, IDC_OPENGLWIN, m_staticView);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CMWRecognizerDlg, CDialog)
	//{{AFX_MSG_MAP(CMWRecognizerDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_ADD, OnAdd)
	ON_BN_CLICKED(IDC_REMOVE, OnRemove)
	ON_BN_CLICKED(IDC_CLEAR, OnClear)
	ON_BN_CLICKED(IDC_RECOGNIZE, OnRecognize)
	ON_BN_CLICKED(IDC_STOP, OnStop)
	ON_WM_CLOSE()
	ON_LBN_SELCHANGE(IDC_LIST2, OnSelchangeList2)
	ON_BN_CLICKED(IDC_CHECK1, OnCheck1)
	ON_BN_CLICKED(IDC_OPTIONS, OnOptions)
	ON_WM_VKEYTOITEM()
	ON_BN_CLICKED(IDC_SORT, OnSort)
	ON_BN_CLICKED(IDC_MOVEUP, OnMoveUp)
	ON_BN_CLICKED(IDC_MOVEDOWN, OnMoveDown)
	//}}AFX_MSG_MAP
	ON_MESSAGE(WM_PROCESSINGWORKFUNCTIONEND, OnProcessingWorkFunctionEnd)

END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CMWRecognizerDlg message handlers

//--------------- CJC ----start------------------------------------------
/*BOOL ReadGlobals()
{
	FILE *fp;

	fp = fopen("params.txt", "r");

	if( fp != NULL )
	{
		int status;
		char name[255], value[255];

		status = fscanf(fp, "%s = %s\n", name, value);
		while( status != EOF )
		{
			if( strcmp(name, "foams") == 0 )
				sscanf(value, "%d", &foams);

			else if( strcmp(name, "foaws") == 0 )
				sscanf(value, "%d", &foaws);

			else if( strcmp(name, "foass") == 0 )
				sscanf(value, "%d", &foass);

			else if( strcmp(name, "foathreshold") == 0 )
				sscanf(value, "%lf", &foathreshold);

			else if( strcmp(name, "bndryms") == 0 )
				sscanf(value, "%d", &bndryms);

			else if( strcmp(name, "bndryws") == 0 )
				sscanf(value, "%d", &bndryws);

			else if( strcmp(name, "bndrythreshold") == 0 )
				sscanf(value, "%lf", &bndrythreshold);

			else if( strcmp(name, "bndrysize") == 0 )
				sscanf(value, "%d", &bndrysize);

			else if( strcmp(name, "spnsize") == 0 )
				sscanf(value, "%d", &spnsize);

			else if( strcmp(name, "saveimages") == 0 )
				sscanf(value, "%d", &saveimages);

			else if( strcmp(name, "outdir") == 0 )
				sscanf(value, "%s", outdir);

			else if( strcmp(name, "savepoints") == 0 )
				sscanf(value, "%d", &savepoints);

			else if( strcmp(name, "pointsname") == 0 )
				sscanf(value, "%s", pointsname);

			else if( strcmp(name, "seglighting") == 0 )
				sscanf(value, "%d", &lightSeg);

			else if( strcmp(name, "lsthreshold") == 0 )
				sscanf(value, "%lf", &lsthreshold);

			else if( strcmp(name, "lsms") == 0 )
				sscanf(value, "%d", &lsms);

			else if( strcmp(name, "multiworm") == 0 )
				sscanf(value, "%d", &multiworm);

			else if( strcmp(name, "pixelcthres") == 0 )
				sscanf(value, "%d", &pixelcthres);

			status = fscanf(fp, "%s = %s\n", name, value);		
		}

		fclose(fp);

		return(TRUE);
	}
	else
	{
		return(FALSE);
	}
}
*/
//--------------- CJC -----end-------------------------------------------


BOOL CMWRecognizerDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		CString strAboutMenu;
		strAboutMenu.LoadString(IDS_ABOUTBOX);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	
// CJC 4-01-05
RestoreDefaultParams();
	
	// Read in the global parameters
// CJC 4-01-05	ReadGlobals();
	LoadParams();	// CJC 4-01-05

//		static char ch[1000];	// CJC 4-06-05
//		strcpy(ch, m_csLastFolderBrowsed);	// CJC 4-06-05

	// initialize opengl view
	m_glView = new CGlView(&m_staticView);
	m_glView->OnCreate();
	m_glView->InitGL();	
	m_glView->ReSizeGLScene(0, 0);

	m_segDisplayCheck.SetCheck(FALSE);

	inProgress=FALSE;

	// init the Options dialog box
	optionsDlg=new COptionsDlg;
	optionsDlg->Create(IDD_OPTIONSBOX);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CMWRecognizerDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CMWRecognizerDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}

	// draw the image and lines
	m_glView->DrawGLScene();

}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CMWRecognizerDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}

UINT CMWRecognizerDlg::ProcessingThreadFunction(LPVOID pParam)
{
	CMWRecognizerDlg *pthis = (CMWRecognizerDlg *) pParam;

	try {
	
		pthis->BatchProcessingWorkFunction();

    } catch (COleDispatchException *e) {
      // Display error message
      e->ReportError();

      // Always call Delete() on caught exceptions
      e->Delete();

      // Kill application
      ExitProcess(1);
   }

   pthis->PostMessage(WM_PROCESSINGWORKFUNCTIONEND);
   
   return 0;
}

void CMWRecognizerDlg::BatchProcessingWorkFunction()
{
	// ---CJC 3-25-05 -------------------------------------------------
	CString csTempDir, csTitle, csInitial; 
	CString m_csLabelTemplateFolder; //m_csLastFolderBrowsed;		// CJC 3-25-05
	// ---CJC 3-25-05 -------------------------------------------------


/*
	// ---CJC 11-05-04-------------------------------------------------
	//
	// This code section from 
	//		http://www.mvps.org/vcfaq/sdk/20.htm
	// demonstrating how to select a folder using SHBrowseForFolder
	// in case we want to have the user select a folder -- possibly
	// starting from an archived path??? -- into which to place the 
	// newly generated worm* folders, instead of using the params file
	// which is becoming annoying.  CJC 11-05-04
	//
	//   ---> Need to find a way of converting 'path' to 'outdir'
	//
	BROWSEINFO bi = { 0 };
    bi.lpszTitle = _T("Pick a Directory");
    LPITEMIDLIST pidl = SHBrowseForFolder ( &bi );
    if ( pidl != 0 )
    {
        // get the name of the folder
        TCHAR path[MAX_PATH];
        if ( SHGetPathFromIDList ( pidl, path ) )
        {
            // printf ( "Selected Folder: %s\n", path );
			CString pathtext;
				pathtext.Format("Selected Folder: %s\n", path);
			AfxMessageBox ( pathtext );
        }

        // free memory used
        IMalloc * imalloc = 0;
        if ( SUCCEEDED( SHGetMalloc ( &imalloc )) )
        {
            imalloc->Free ( pidl );
            imalloc->Release ( );
        }
    }
	//
	// ---CJC 11-05-04-------------------------------------------------
*/

	// ---CJC 3-25-05 -------------------------------------------------
	//
    // Change the title to something appropriate 
    csTitle = "Select Folder"; 
    csInitial = m_csLastFolderBrowsed;  // Set initial folder to highlight in 
										// the browser 

//    if(FolderBrowser(this, csTitle, csTempDir, csInitial, false)) 
    if(FolderBrowser(this, csTitle, csTempDir, csInitial, false, true)) 
	{	
        m_csLabelTemplateFolder = csTempDir; 
        m_csLastFolderBrowsed = csTempDir; 
	}
 	//
	// ---CJC 3-25-05 -------------------------------------------------



	int nItem, itemCount;
	CString str;

	if (!batchProcess) {
		ProcessingWorkFunction();
		return;
	}
	itemCount=m_videoListBox.GetCount();
    nItem=0;

	int nCount, nFirst;
	while (nItem < itemCount && !killProcess) 
	{
		// create an output directory
		m_videoListBox.SetCurSel(nItem);
		m_videoListBox.GetText(nItem, str);

		// extract name from full file name path
		nFirst=str.ReverseFind('\\')+1;
		nCount=str.Find(".dat")-nFirst;

		// worm ID starts with 1

  //csTempDir
// CJC 3-28-05 TRY USING csTempDir FROM FOLDER BROWSER:
	    sprintf(outsubdir, "%s\\worm%d_%s", csTempDir, nItem+1, str.Mid(nFirst, nCount));
// CJC ORIGINAL (MODIFIED)	    sprintf(outsubdir, "%s\\worm%d_%s", outdir, nItem+1, str.Mid(nFirst, nCount));
// CJC 11-04-04 TRY ERROR HANDLING HERE:  (was)		_mkdir(outsubdir);	
		if( _mkdir(outsubdir) != 0 )
		{ 
			AfxMessageBox("Unable to create ...\\worm folder.  Check whether folder already exists.  ", MB_OK);
			killProcess=TRUE;
			return;
		}
//		else
//			AfxMessageBox(outsubdir);		

//CJC 3-11-05		//attach input file name to the output file name	
//CJC 3-11-05		sprintf(pointsname, "points_%s", str.Mid(nFirst, nCount));
		//CJC changed idea 3-11-05:
		//Having fine name attached to points file name gets annoying and, in retrospect, 
		//provides questionable value for identifying the file.
		//SO, instead, go back to just using the name 'points'.
		//  NB: 'points' should be the default value for pointsname, so just accept the default  
		//       value established above.   (But keep the next line around in case we need it.)
//		sprintf(pointsname, "points");

		if (fp=fopen(str, "rb"))
			ProcessingWorkFunction();
		nItem++;
	}


}

void CMWRecognizerDlg::ProcessingWorkFunction()
{

	double timestamp, ref_timestamp;
	int totalNFrames;
	unsigned char* raster;
	int imgh, imgw;
	int counter;
	char imagename[255];

	// set the counter for saved image sequence
	counter=1; 

	// read the frame size - width and height
	fread(&imgw, sizeof(unsigned int), 1, fp);
	fread(&imgh, sizeof(unsigned int), 1, fp);

	// find out the total number of frames
	fseek(fp, 0, SEEK_END);
	totalNFrames=(ftell(fp)-sizeof(unsigned int)*2)/(imgw*imgh+sizeof(double));
	fseek(fp, sizeof(unsigned int)*2 , SEEK_SET);

	// set progressbar
	m_progressBar.SetRange32(0, totalNFrames);
	m_progressBar.SetPos(0);

	// get the display array
	COleSafeArray *DispArray=m_glView->GetDisplayArray(imgw, imgh);
	DispArray->AccessData((void**) &raster);

	COleSafeArray *SegArray=m_glView->GetSegArray(imgw, imgh);

	Matrix *GrabImage1Mat = NULL;
	GrabImage1Mat = mxCreateFull(imgh, imgw, INT);


	// read the first time stamp, and set it as a starting reference
	fread(&ref_timestamp, sizeof(double), 1, fp);
	fseek(fp, sizeof(unsigned int)*2 , SEEK_SET);


	while (!feof(fp) && !killProcess) {

		fread(&timestamp, sizeof(double), 1, fp);
		fread(raster, sizeof(unsigned char), imgw*imgh, fp);
	
		// now transfer data from array to matrix
		ArrayToMatrix(DispArray, GrabImage1Mat);

		m_glView->ClearWormPosList();

		if (m_segDisplayCheck.GetCheck()) {
			Matrix *seg;
			if (lightSeg)
				seg = mw_segment(GrabImage1Mat, lsms, lsthreshold);
			else 
				seg = segment(GrabImage1Mat, bndryms, bndrythreshold);
			
			MatrixToArray(SegArray, seg);
			mxFreeMatrix(seg);
		}
	  

		// Initialize variables			
		Matrix *center = NULL, *bndry = NULL, *spn = NULL, *pts = NULL;


		if (multiworm) {
			// multiworm tracking
			Matrix** boundry; 
			int wcount;
			boundry=findmwboundry(GrabImage1Mat, &center, pixelcthres, &wcount);
		
			//double *centerp = (double *) mxGetP(center);

			for (int i=0; i < wcount; i++) {
				if (!boundry[i]) continue;
				centerline(boundry[i], &spn, &pts, spnsize);
		
				// now save points if needed 
				if( savepoints )
					save(pts, timestamp-ref_timestamp);
				m_glView->AddWormPos(NULL, boundry[i], spn, pts);
				
			}

		} else {

			// single worm tracking
			findworm(GrabImage1Mat, &center, &bndry, &spn, &pts);

			// now save points if needed 
			if( savepoints )
				save(pts, timestamp-ref_timestamp);
		
			m_glView->AddWormPos(center, bndry, spn, pts);
		}

		m_progressBar.OffsetPos(1);
	
		// now save the images		
		if( saveimages ) {
			if( ((counter - 1) % saveimages) == 0 ) {
				sprintf(imagename, "%s\\file.%d.jpg", outsubdir, counter);
				//m_glView->SaveBitmap(imagename);
				CString pcsMsg;
				JpegFromRaster(raster, JPEG_QUALITY, imgw, imgh, 3, imagename, &pcsMsg);
			}
		}
		counter++;

		Invalidate(FALSE);
		::Sleep(0);
	}

	fclose(fp);
    mxFreeMatrix(GrabImage1Mat);

	DispArray->UnaccessData();

}

LONG CMWRecognizerDlg::OnProcessingWorkFunctionEnd(UINT, LONG)
{
	m_addButton.EnableWindow(TRUE);
	m_removeButton.EnableWindow(TRUE);
	m_clearButton.EnableWindow(TRUE);
	m_stopButton.EnableWindow(FALSE);
	m_recognizeButton.EnableWindow(TRUE);
	m_videoListBox.EnableWindow(TRUE);

	optionsDlg->m_SpinesizeEdit.EnableWindow(TRUE);
	optionsDlg->m_SaveimagesEdit.EnableWindow(TRUE);
	optionsDlg->m_PointsnameEdit.EnableWindow(TRUE);
	optionsDlg->m_multiwormCheck.EnableWindow(TRUE);
	optionsDlg->m_RestoredefaultsButton.EnableWindow(TRUE);


	m_progressBar.SetPos(0);
	m_glView->ClearWormPosList();

	MessageBeep(MB_ICONASTERISK);

	inProgress=FALSE;
	return 0;
}

void CMWRecognizerDlg::OnAdd() 
{
	// TODO: Add your control notification handler code here
	CString str, file;
	static char ch[1000];
	CRect rect;
	CFileDialog dlg(TRUE, _T("dat"), _T("*.dat"),OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT |OFN_ALLOWMULTISELECT, 
			_T("DAT files (*.dat)|*.dat|All files (*.*)|*.*||"));

	dlg.m_ofn.lpstrFile=ch;
	dlg.m_ofn.nMaxFile=1000;
	if(dlg.DoModal() == IDOK) {	
		POSITION pos=dlg.GetStartPosition();

		while (pos) {		
			str=dlg.GetNextPathName(pos);
			//m_videoListBox.AddString(str);	
			m_videoListBox.InsertString(0, str);
			CDC *dc=m_videoListBox.GetDC();
			if (m_videoListBox.GetHorizontalExtent() < dc->GetTextExtent(str).cx)
				m_videoListBox.SetHorizontalExtent(dc->GetTextExtent(str).cx);	
		}

		OnSort();
		m_videoListBox.SetCurSel(0);
		
		m_videoListBox.GetText(0, str);
		DisplayFrame(str, 0);
	}

}


void CMWRecognizerDlg::OnRemove() 
{
	// TODO: Add your control notification handler code here
	int nItem;

	nItem=m_videoListBox.GetCurSel();
	if (nItem!=LB_ERR) {
		m_videoListBox.DeleteString(nItem);
		if (nItem) nItem--;		
		m_videoListBox.SetCurSel(nItem);
	}

}

void CMWRecognizerDlg::OnClear() 
{
	// TODO: Add your control notification handler code here
	m_videoListBox.ResetContent();
}

void CMWRecognizerDlg::OnSort() 
{
	// TODO: Add your control notification handler code here

	// Based on INSERTION SORT from "Introduction to Algorithms," 
	// Thomas Cormen, et al. 2nd edition, page 17
	// CJC 3-16-05
	CString keyStr, i_thStr;
	int keyPosition, itemCount, i; 

	itemCount=m_videoListBox.GetCount();
	if (itemCount > 0)
	{
		for (keyPosition = 1; keyPosition < itemCount; ++keyPosition)
		{
			m_videoListBox.GetText(keyPosition, keyStr);
			i = keyPosition - 1; 
			m_videoListBox.GetText(i, i_thStr);			//establish first value of i_thStr
			while( (i >= 0) && (i_thStr > keyStr) )
			{
				m_videoListBox.InsertString(i+1, i_thStr);	//copy string into new position;
				m_videoListBox.DeleteString(i+2);		//remove original, now positioned one to right;
				i--;
				if (i >= 0)
					m_videoListBox.GetText(i, i_thStr);		//re-establish i'th string on each cycle
			}
			m_videoListBox.InsertString(i+1, keyStr);	//copy string into new position;
			m_videoListBox.DeleteString(i+2);		//remove original, now positioned one to right;
		}

		m_videoListBox.SetCurSel(0); 
		m_videoListBox.GetText(0, keyStr); 
		DisplayFrame(keyStr, 0); 
	}

}


void CMWRecognizerDlg::OnMoveUp() 
{
	// TODO: Add your control notification handler code here
	int nItem, itemCount;
	CString str;

	itemCount=m_videoListBox.GetCount();
	nItem = m_videoListBox.GetCurSel();
	if (nItem>0)
	{
		m_videoListBox.GetText(nItem,str);
		m_videoListBox.InsertString(nItem-1, str);	//copy string into new position;
		m_videoListBox.DeleteString(nItem+1);

		//reset focus
		nItem--;
		m_videoListBox.SetCurSel(nItem); 
		m_videoListBox.GetText(nItem, str); 
		DisplayFrame(str, 0); 
	}
}

void CMWRecognizerDlg::OnMoveDown() 
{
	// TODO: Add your control notification handler code here
	int nItem, itemCount;
	CString str;

	itemCount=m_videoListBox.GetCount();
	nItem = m_videoListBox.GetCurSel();
	if (nItem < (itemCount-1) )
	{
		m_videoListBox.GetText(nItem+1,str);
		m_videoListBox.InsertString(nItem, str);	//copy string into new position;
		m_videoListBox.DeleteString(nItem+2);

		//reset focus
		nItem++;
		m_videoListBox.SetCurSel(nItem); 
		m_videoListBox.GetText(nItem, str); 
		DisplayFrame(str, 0); 
	}
}


void CMWRecognizerDlg::OnRecognize() 
{
	m_addButton.EnableWindow(FALSE);
	m_removeButton.EnableWindow(FALSE);
	m_clearButton.EnableWindow(FALSE);
	m_stopButton.EnableWindow(TRUE);
	m_recognizeButton.EnableWindow(FALSE);
	m_videoListBox.EnableWindow(FALSE);

	/*takao*/
	optionsDlg->m_SpinesizeEdit.EnableWindow(FALSE);
	optionsDlg->m_SaveimagesEdit.EnableWindow(FALSE);
	optionsDlg->m_PointsnameEdit.EnableWindow(FALSE);
	optionsDlg->m_multiwormCheck.EnableWindow(FALSE);
	optionsDlg->m_RestoredefaultsButton.EnableWindow(FALSE);



	batchProcess=TRUE;
	killProcess=FALSE;
	inProgress=TRUE;
	AfxBeginThread(ProcessingThreadFunction, this);
}

void CMWRecognizerDlg::OnStop() 
{
	
	if(AfxMessageBox("Recognizer in Progress. Abort?  ", MB_OKCANCEL)==IDOK) 
	{
		killProcess=TRUE;

		/*takao & CJC*/
//	optionsDlg->m_SpinesizeEdit.EnableWindow(TRUE);
//	optionsDlg->m_SaveimagesEdit.EnableWindow(TRUE);
//	optionsDlg->m_PointsnameEdit.EnableWindow(TRUE);
//	optionsDlg->m_multiwormCheck.EnableWindow(TRUE);
//	optionsDlg->m_RestoredefaultsButton.EnableWindow(TRUE);

	}

}

void CMWRecognizerDlg::OnOK() 
{
	SaveParams();

	if(inProgress) 
	{
		if (AfxMessageBox("Recognizer in Progress. Abort?  ", MB_OKCANCEL)==IDOK) 
		{
			killProcess=TRUE;
	
			CDialog::OnOK();
		}
	} 
	else
		CDialog::OnOK();
}

void CMWRecognizerDlg::OnClose() 
{
	SaveParams();

	if(inProgress) 
	{
		if (AfxMessageBox("Recognizer in Progress. Abort?  ", MB_OKCANCEL)==IDOK) 
		{
			killProcess=TRUE;
	
			CDialog::OnClose();
		}
	} 
	else
		CDialog::OnClose();
	
	
}




void CMWRecognizerDlg::OnSelchangeList2() 
{
	// TODO: Add your control notification handler code here
	CString str;
	int nItem;
	
	nItem=m_videoListBox.GetCurSel();
	if (nItem!=LB_ERR) {
		m_videoListBox.GetText(nItem, str);
		DisplayFrame(str, 0);
	}

}

void CMWRecognizerDlg::DisplayFrame(CString filename, int frameId)
{
	FILE *fp;
	double timestamp;
	int imgw, imgh;
	unsigned char *raster;


	if (!(fp=fopen(filename, "rb"))) return;
	
	// read the frame size - width and height
	fread(&imgw, sizeof(unsigned int), 1, fp);
	fread(&imgh, sizeof(unsigned int), 1, fp);

	// get the display array
	COleSafeArray *DispArray=m_glView->GetDisplayArray(imgw, imgh);
	DispArray->AccessData((void**) &raster);

	// search for the right frame to read
	fseek(fp, sizeof(unsigned int)*2+(imgh*imgw+sizeof(double))*frameId , SEEK_SET);

	fread(&timestamp, sizeof(double), 1, fp);
	fread(raster, sizeof(unsigned char), imgw*imgh, fp);

	DispArray->UnaccessData();
	fclose(fp);

	OnPaint();
}

void CMWRecognizerDlg::OnCheck1() 
{	
	m_glView->m_drawSegmentation=m_segDisplayCheck.GetCheck();
}


void CMWRecognizerDlg::OnOptions() 
{
	optionsDlg->ShowWindow(SW_SHOW);
}

int CMWRecognizerDlg::OnVKeyToItem(UINT nKey, CListBox* pListBox, UINT nIndex) 
{
	// TODO: Add your message handler code here and/or call default

	if (nKey==VK_DELETE) {
		int nItem;

		nItem=pListBox->GetCurSel();
		if (nItem!=LB_ERR) {
			pListBox->DeleteString(nItem);
			if (nItem) nItem--;
			pListBox->SetCurSel(nItem);
		}	
	}
	return CDialog::OnVKeyToItem(nKey, pListBox, nIndex);
}







void CMWRecognizerDlg::SaveParams()
{
	// Copy char array to CString for archiving
	csPointsname = pointsname;
	csCh = ch;

	CFile file;
	if (file.Open(m_csParamsFilePath, CFile::modeReadWrite| CFile::modeCreate)) 
	{ 
		CArchive ar (&file, CArchive::store);		
		ar << spnsize;			//int
		ar << saveimages;		//int
		//		ar << pointsname;		//char	Can't archive char array
		ar << csPointsname;		//CString		// but CAN archive CString

		ar << foams;			//int
		ar << foaws;			//int
		ar << foass;			//int
		ar << foathreshold;		//double

		ar << bndryms;			//int
		ar << bndryws;			//int
		ar << bndrysize;		//int
		ar << bndrythreshold;	//double

		ar << lightSeg;		//int
		ar << lsms;			//int
		ar << lsthreshold;	//double
		ar << multiworm;	//int
		ar << pixelcthres;	//int
		ar << m_csLastFolderBrowsed;	//CString
		ar << csCh;			//CString

		ar.Flush();
		file.Close();
		
	}

}

void CMWRecognizerDlg::LoadParams()		// Load back from CArchive
{
	CFile file;
	if (file.Open(_T("params.data"), CFile::modeRead)) 
	{
		// Remember where params.data file came from (should be from
		// same directory where .exe was)
		m_csParamsFilePath = file.GetFilePath();	

		CArchive ar (&file, CArchive::load);	// Associate Archive with file.
		try 
		{
			ar >> spnsize;
			ar >> saveimages;
			ar >> csPointsname;

			ar >> foams;
			ar >> foaws;
			ar >> foass;
			ar >> foathreshold;

			ar >> bndryms;
			ar >> bndryws;
			ar >> bndrysize;
			ar >> bndrythreshold;
			
			ar >> lightSeg;
			ar >> lsms;
			ar >> lsthreshold;
			ar >> multiworm;
			ar >> pixelcthres;
			ar >> m_csLastFolderBrowsed;
			
			ar >> csCh;
		} 
		catch (CArchiveException e) 
		{
		} 
		catch ( CFileException e) 
		{
		}

		file.Close();

		// Convert back from CString to char array
		strcpy(pointsname, csPointsname);	// place csPointsname string contents into pointsname char array 
		strcpy(ch, csCh);	// place  string contents into  char array CJC 4-06-05
	}
	else	// if file-open operation unsuccessful...
	{
		char buf[255];
		// Remember path to Current Directory for SaveParams()
		if(GetCurrentDirectory(255, buf))
		{
			//AfxMessageBox("Successfully found current directory");
			//AfxMessageBox(buf);

			m_csParamsFilePath = buf; 
			m_csParamsFilePath += "\\params.data";	// Concatenate file name onto current directory path
		}
		else
		{
			AfxMessageBox("Sorry, the Current Directory is inaccessible so Recognizer will not be able to archive customizations.");
			return;
		}
	}

}


void RestoreDefaultParams()		// The "FACTORY" default settings
{
	foams = 3;
	foaws = 51;
	foass = 4;
	foathreshold = 0.7;

	bndryms = 15;
	bndryws = 451;
	bndrythreshold = 0.8;
	bndrysize = 50;

	spnsize = 13;

	m_csLastFolderBrowsed = "";		// CJC 3-31-05

	// NOT USED char outdir[255] = "";
	saveimages = 100;
	// NOT USED int savepoints = 1;

	strcpy(pointsname, "points");
	//sprintf(pointsname, "points");	// ...and another way of creating pointsname
	 
	// New parameters for the enhanced segmentation routine
	lightSeg=0;   //CJC 11-04-04 Change segmentation routine default to 'off'  (was) 1;          // switch to turn the new segmentation routine on
	lsthreshold=-0.7;     // threshold for the new segmentation routine
	lsms=51;             // neigborhood region used by the new segmentation routine   
	multiworm=0;         // multiworm switch
	pixelcthres=60;      // pixel count threshold to enable tracking of worms

}
