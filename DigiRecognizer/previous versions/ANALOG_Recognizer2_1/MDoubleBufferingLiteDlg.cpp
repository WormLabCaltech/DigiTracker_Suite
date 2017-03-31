// MDoubleBufferingLite example
           
// Synopsis:   This example does double buffered grab with real time 
//             processing. It also times to see if some frames are not 
//             processed using hooks.
//
//             Note this assumes that the processing operation is shorter 
//             than a grab and that the PC has sufficient bandwith 
//             to support the 2 operations simultaneously. Also if the 
//             target processing image is not on the display, the 
//             processing speed is augmented.

// NOTE: Check the history logs to determine which properties were set a
//       design time. Search for the word "ActiveMIL" to determine
//       which code is added.


// MDoubleBufferingLiteDlg.cpp : implementation file
//

#include "stdafx.h"
#include "resource.h"
#include "MDoubleBufferingLite.h"
#include "MDoubleBufferingLiteDlg.h"
//--------------- CJC ----start------------------------------------------
#include "mex.h"
#include <direct.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
//--------------- CJC -----end-------------------------------------------

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

//--------------- CJC ----start------------------------------------------
/////////////////////////////////////////////////////////////////////////////
// These are the global parameters
//

long memLeaks = 0;
int debug = 0;

// CMemoryState oldMemState, newMemState, diffMemState;

int foams = 3;
int foaws = 51;
int foass = 4;
double foathreshold = 0.7;

int bndryms = 15;
int bndryws = 251;
double bndrythreshold = 0.75;
int bndrysize = 50;

int spnsize = 13;

char outdir[255] = "D:\\Data";
int saveimages = 100;
int savepoints = 1;
char pointsname[255] = "points";

char outsubdir[255];

/////////////////////////////////////////////////////////////////////////////
// These are some function prototypes
//

extern void findworm(Matrix *im, 
					 Matrix **center, Matrix **bndry, 
		             Matrix **spn, Matrix **pts);

//CJC_3-4-03 ORIGINAL PROTOTYPE:  extern void drawworm(CGraphicContext *gc, void *center, void *bndry, void *spn, void *pts);
//CJC UNCHANGED, FOR NOW...
//extern void drawworm(CGraphicContext *gc, void *center, void *bndry, void *spn, void *pts);

//CJC 3-31-03 FROM Jason Grant AT Matrox:
void drawworm(IGraphicContextPtr gc, void *center, void *bndry, void *spn, void *pts);

extern void save(Matrix *pts);
//--------------- CJC -----end-------------------------------------------


///////
// ActiveMIL constant

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
// CMDoubleBufferingLiteDlg dialog

CMDoubleBufferingLiteDlg::CMDoubleBufferingLiteDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CMDoubleBufferingLiteDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CMDoubleBufferingLiteDlg)
	m_CommentText = _T("");
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);

   ///////
   // ActiveMIL variable initialization
   m_StepCount = 1;
   m_ProcessingCount = 0;
}

void CMDoubleBufferingLiteDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CMDoubleBufferingLiteDlg)
	DDX_Control(pDX, IDC_NEXTBUTTON, m_NextButton);
   DDX_Control(pDX, IDC_SYSTEM1, m_System1);
   DDX_Control(pDX, IDC_IMAGE1, m_Image1);
   DDX_Control(pDX, IDC_DISPLAY1, m_Display1);
	DDX_Text(pDX, IDC_COMMENTTEXT, m_CommentText);
	DDX_Control(pDX, IDC_DIGITIZER1, m_Digitizer1);
	DDX_Control(pDX, IDC_APPLICATION1, m_Application1);
	DDX_Control(pDX, IDC_GRAPHICCONTEXT1, m_GraphicContext1);
	DDX_Control(pDX, IDC_GRAPHICCONTEXT2, m_GraphicContext2);
	DDX_Control(pDX, IDC_EMPTY_IMAGE, m_EmptyImage);
	DDX_Control(pDX, IDC_GRABIMAGE1, m_GrabImage1);
	DDX_Control(pDX, IDC_GRABIMAGE2, m_GrabImage2);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CMDoubleBufferingLiteDlg, CDialog)
	//{{AFX_MSG_MAP(CMDoubleBufferingLiteDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_NEXTBUTTON, OnNextbutton)
   ON_MESSAGE(WM_PROCESSINGWORKFUNCTIONEND, OnProcessingWorkFunctionEnd)
	ON_WM_CLOSE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


//--------------- CJC ----start------------------------------------------
BOOL ReadGlobals()
{
	FILE *fp;

	fp = fopen("C:\\params.txt", "r");
//	fp = fopen("C:\\Documents and Settings\\saleem\\Desktop\\params.txt", "r");

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
//--------------- CJC -----end-------------------------------------------


/////////////////////////////////////////////////////////////////////////////
// CMDoubleBufferingLiteDlg message handlers

BOOL CMDoubleBufferingLiteDlg::OnInitDialog()
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

   ///////
   // ActiveMIL example initialization

   // Resize the dialog 
   AdjustDialog();

//--------------- CJC ----start------------------------------------------
   // Initialize the VCR
   vcr = new VCR(2);

   // Read in the global parameters
   ReadGlobals();
//--------------- CJC -----end-------------------------------------------
	
   ///////
   // Step 1: Resize and allocate the Image1, and start the grab.
   m_Image1->SizeX = (long) (m_Digitizer1->SizeX * m_Digitizer1->ScaleX);
   m_Image1->SizeY = (long) (m_Digitizer1->SizeY * m_Digitizer1->ScaleY);
   m_Image1->Allocate();
//CJC   m_Digitizer1->GrabContinuous();

//CJC   // Print message
//CJC   m_CommentText = "This program demonstrates double buffered processing.  "
//CJC                   "Click Next to continue.  ";

   UpdateData(FALSE);

//--------------- CJC ----start------------------------------------------
   m_StopProcessing = FALSE;
   m_KillProcessing = FALSE;
   AfxBeginThread(ProcessingThreadFunction, this);
//--------------- CJC -----end-------------------------------------------
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CMDoubleBufferingLiteDlg::OnSysCommand(UINT nID, LPARAM lParam)
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

void CMDoubleBufferingLiteDlg::OnPaint() 
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
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CMDoubleBufferingLiteDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}


/////////////////////////////////////////////////////////////////////////////
// ActiveMIL procedure: Drives the example through each step, performing 
// appropriate actions
//
void CMDoubleBufferingLiteDlg::OnNextbutton() 
{
/* //--------------- CJC ----start------------------------------------------
// CJC- Comment out this version of OnNextbutton.
// CJC- Consider converting function to be a Cancel button.

  // Increments the step counter and updates text in the dialog 
   AdjustStepNumber();

   switch (m_StepCount)
      {
      ///////
      // Step 2: Grab the sequence
      case 2:
         {
         // Stop continuous grab 
         m_Digitizer1->Halt();
         
         // Start processing thread
         m_StopProcessing = FALSE;
         m_KillProcessing = FALSE;
         AfxBeginThread(ProcessingThreadFunction, this);

         // Print message
         m_CommentText = "Double buffered processing (annotate and copy) in progress... "
                         "Click Next to continue. ";
         break;
         }

      ///////
      // Step 3: Print statistics
      case 3:
         {
         // Instruct the processing thread to stop its loop
         m_StopProcessing = TRUE;

         // Disable Next button and print waiting message
         m_NextButton.EnableWindow(FALSE);
         m_CommentText = "Waiting for processing to complete...  ";

         // To be continued in OnProcessingWorkFunctionEnd...
         break;
         }

      ///////
      // Last Step: End the application
      default:
         {
         // Close dialog application
         EndDialog(IDOK);
         break;
         }
      }

	UpdateData(FALSE);
*/ //--------------- CJC -----end-------------------------------------------
}	// OnNextButton


/////////////////////////////////////////////////////////////////////////////
// ActiveMIL function: Controls the processing thread
//
UINT CMDoubleBufferingLiteDlg::ProcessingThreadFunction(LPVOID pParam)
{
   CMDoubleBufferingLiteDlg *pthis = (CMDoubleBufferingLiteDlg *) pParam;

   // Call CMDoubleBufferingLiteDlg's processing loop
   //
   // Enclose ActiveMIL calls in a try-catch statement in order
   // to prevent ActiveMIL errors to cause an uncaught 
   // exception message.  MFC does not catch exceptions thrown by
   // ActiveX controls outside of the message loop.
   try
      {
      pthis->ProcessingWorkFunction();
      }
   catch (COleDispatchException *e)
      {
      // Display error message
      e->ReportError();

      // Always call Delete() on caught exceptions
      e->Delete();

      // Kill application
      ExitProcess(1);
      }

   // Post a custom Windows message to inform the main UI thread of
   // the processing completion.
   //
   // A custom message handler will then be triggered and 
   // perform the remaining tasks of the current example step.
   //
   // This is the preferred way of communicating with worker threads in
   // MFC. An alternative way would be to use synchronised wait functions
   // such as WaitForSingleObject(MyThreadHandle) to wait for thread 
   // termination. But this way, UI components would be frozen and the 
   // application would stop responding. 
   //
   // Hence, we recommend that all lengthy processing be performed in a work 
   // thread in such a way as not to block the main UI thread.
   pthis->PostMessage(WM_PROCESSINGWORKFUNCTIONEND);
   
   return 0;
}


/* //--------------- CJC ----start------------------------------------------
//CJC- Comment out this ProcessingWorkFunction and replace with 
//CJC- copy/paste/modified version from Recognizer2.0's ExampleDlg.cpp
/////////////////////////////////////////////////////////////////////////////
// ActiveMIL procedure: Performs the real work of the processing thread
//
void CMDoubleBufferingLiteDlg::ProcessingWorkFunction()
{

   // Adjust sizes of grab images to that of effective digitizer size
   // and allocate them
   m_GrabImage1->SizeX = m_Image1->SizeX;
   m_GrabImage1->SizeY = m_Image1->SizeY;
   m_GrabImage1->Allocate();

   m_GrabImage2->SizeX = m_Image1->SizeX;
   m_GrabImage2->SizeY = m_Image1->SizeY;
   m_GrabImage2->Allocate();

   // Grab the first image
   m_Digitizer1->Image = m_GrabImage1;
   m_Digitizer1->Grab();

   // Start the timer
   m_Application1->Timer->Reset();

   // Process one image while grabbing the other
   CString str;
   while (! m_StopProcessing && ! m_KillProcessing)
      {
      // Grab second image while processing first image
      m_Digitizer1->Image = m_GrabImage2;
      m_Digitizer1->Grab();

      // Synchronize and start the timer
      if (m_ProcessingCount == 0)
         m_Application1->Timer->Reset();

      // Process first image already grabbed
      // NOTE: Real time only if PC is fast enough
      str.Format("%d",m_ProcessingCount + 1);
      m_GraphicContext1->Text((LPCTSTR)str);
      m_Image1->Copy(m_GrabImage1, imAllBands);

      // Count processed images
      m_ProcessingCount++;

      // Grab first image while processing second image
      m_Digitizer1->Image = m_GrabImage1;
      m_Digitizer1->Grab();

      // Process second image already grabbed
      // NOTE: Real time only if PC is fast enough
      str.Format("%d",m_ProcessingCount + 1);
      m_GraphicContext2->Text((LPCTSTR)str);
      m_Image1->Copy(m_GrabImage2, imAllBands);

      // Count processed images
      m_ProcessingCount++;
      }

   if (! m_KillProcessing)
      {

      // Wait for the last grab end and stop the timer.
      m_Digitizer1->GrabWait(digGrabEnd);

      // Get the time elapsed in processing loop
      m_Time = m_Application1->Timer->Read();
   
      // Get the time elapsed in processing loop
      m_Time = m_Application1->Timer->Read();
      }
}
*/ //--------------- CJC -----end-------------------------------------------
//--------------- CJC ----start------------------------------------------
//CJC- Here's the replacement ProcessingWorkFunction...
/////////////////////////////////////////////////////////////////////////////
// ProcessingWorkFunction
// This function performs the real work of the processing thread
//
void
CMDoubleBufferingLiteDlg::ProcessingWorkFunction()
{
   int count = 1;
   FILE *fp;
   int hrs, min, sec, frm, leng;
   CString commentstr;
   CWnd *pStepNumber;

//CJC - copied from example
   // Adjust sizes of grab images to that of effective digitizer size
   // and allocate them
   m_GrabImage1->SizeX = m_Image1->SizeX;
   m_GrabImage1->SizeY = m_Image1->SizeY;
   m_GrabImage1->Allocate();

   m_GrabImage2->SizeX = m_Image1->SizeX;
   m_GrabImage2->SizeY = m_Image1->SizeY;
   m_GrabImage2->Allocate();
//CJC - END copied from example


   // open the index file
   fp = fopen("C:\\index.txt", "r");
//   fp = fopen("C:\\Documents and Settings\\saleem\\Desktop\\index.txt", "r");

   if( fp != NULL )
   {
	  int status;

	  status = fscanf(fp, "%d:%d:%d:%d %d\n", &hrs, &min, &sec, &frm, &leng);
	  while( (!m_StopProcessing) && (!m_KillProcessing) && (status != EOF) )
	  {
		// create an output directory
	    sprintf(outsubdir, "%s\\worm%d", outdir, count);
		_mkdir(outsubdir);			

//CJC- Consider adding text here:  Try...
//CJC-This one doesn't work:		m_CommentText = ("Finding ''worm%d''", count);
//		m_CommentText = "Finding worm";
//CJC-------------------START---------------------------------
   // Write the step count in the comment frame
//   CString commentstr;  //Defined at start of function
   commentstr.Format("Finding worm%d...", count);
//   CWnd *pStepNumber = GetDlgItem(IDC_COMMENTTEXT);
   pStepNumber = GetDlgItem(IDC_COMMENTTEXT);
   pStepNumber->SetWindowText(commentstr);

//CJC--------------------END----------------------------------


	    // goto the desired position
	    vcr->Goto(1, hrs, min, sec, frm);

  	    // play the vcr
	    vcr->Play();

//CJC- Consider adding text here:  Try...
//CJC-This one doesn't work:		m_CommentText = ("Processing ''worm%d''", count);
		m_CommentText = "Processing worm";      
//CJC-------------------START---------------------------------
   // Write the step count in the comment frame
//   CString commentstr;		//Defined at start of function
   commentstr.Format("Processing worm%d...", count);
//   CWnd *pStepNumber = GetDlgItem(IDC_COMMENTTEXT);
   pStepNumber = GetDlgItem(IDC_COMMENTTEXT);
   pStepNumber->SetWindowText(commentstr);

//CJC--------------------END----------------------------------

	    // start processing images
	    this->ProcessingWorkFunctionHelper(leng);

	    // get the time elapsed in processing loop
	    vcr->Stop();	

		// increment counter
		count = count + 1;

	    // scan in the next entry
	    status = fscanf(fp, "%d:%d:%d:%d %d\n", &hrs, &min, &sec, &frm, &leng);
	  }
	  // display closing message.
	  m_CommentText = "Processing complete.  Have a nice day.";
   }

   // close the index file
   fclose(fp);
}
//--------------- CJC -----end-------------------------------------------



//--------------- CJC ----start------------------------------------------
//CJC- Add in the ProcessingWorkFunctionHelper copied and modified from
//CJC- Recognizer2.0's ExampleDlg.cpp
/////////////////////////////////////////////////////////////////////////////
// ProcessingWorkFunctionHelper: Continues the real work of the processing thread
//
void 
CMDoubleBufferingLiteDlg::ProcessingWorkFunctionHelper(int leng)
{
   DWORD dim[2];
   int x, y;
   int GrabImage2Success = 0, GrabImage1Success = 0;
   Matrix *GrabImage2Mat = NULL;
   Matrix *GrabImage1Mat = NULL;
	   
   COleSafeArray *empty = new COleSafeArray();
   COleSafeArray *GrabImage2Array = new COleSafeArray();
   COleSafeArray *GrabImage1Array = new COleSafeArray();

   int counter = 1;
   char imagename[255];

   // Allocate the arrays
   dim[0] = 640; dim[1] = 480;
   empty->Create(VT_I1, (DWORD) 2, dim); 

   GrabImage2Array->Create(VT_I1, (DWORD) 2, dim);
   GrabImage1Array->Create(VT_I1, (DWORD) 2, dim);

   GrabImage2Mat = mxCreateFull(480, 640, INT);	
   GrabImage1Mat = mxCreateFull(480, 640, INT);

   // Initialize empty array to all zeros
   for( x = 0; x < 640; x++ )
	  for( y = 0; y < 480; y++ )
	  {
		long ind[2]; 
		unsigned char data;  
 		
		ind[0] = x; ind[1] = y;
		data = 0;

		empty->PutElement(ind, &data);
	  }

   // Save the user array	
//CJC   m_EmptyImage->Put(*empty, imSingleBand, 0, 0, 0, 640, 480);
   m_EmptyImage->Put(*empty, imPlanar, imAllBands, 0, 0, 640, 480);
//CJC   m_Image1->Copy(m_EmptyImage, 0);
   m_Image1->Copy(m_EmptyImage, imAllBands);

   // start the timer
   m_Application1->Timer->Reset();

//$$$$$$$$$$
//
/* //CJC - Diagnostics
CString TimeoutValueString;
//double deleteme = 3.14159;
//m_Digitizer.SetGrabTimeout(10000);
m_Digitizer.SetGrabTimeout(mDefault);
double TimeoutValue = m_Digitizer.GetGrabTimeout();
TimeoutValueString.Format("Timeout value = %.4f msec", TimeoutValue);
//AfxMessageBox( TimeoutValueString );

CString GrabModeValueString;
//m_Digitizer.SetGrabMode(mSynchronous);
long GrabModeValue = m_Digitizer.GetGrabMode();
GrabModeValueString.Format("%3d", GrabModeValue);
//AfxMessageBox( GrabModeValueString ); 
//
//$$$$$$$$$$
*/ //CJC - End Diagnostics

//-------------------------------------------------------------------
//CJC- Consider adding "first" image grab here with a grab wait to follow...

   // Process one buffer while grabbing the other
   while ( (!m_StopProcessing) && (!m_KillProcessing) && (m_Application1->Timer->Read() <= leng*60) )
   {
		try
		{
			// Start the "second" image grab
		    m_Digitizer1->Image = m_GrabImage2;
			m_Digitizer1->Grab();

			// Process the First image
			if( GrabImage1Success )
			{
				// now tranfer data into an array
//CJC				m_FirstImage->Get(*FirstImageArray, imSingleBand, 0, 0, 0, 640, 480);
				m_GrabImage1->Get(*GrabImage1Array, imPlanar, imAllBands, 0, 0, 640, 480);

				// now transfer data from array to matrix
				ArrayToMatrix(GrabImage1Array, GrabImage1Mat);

				// process the "first" image
				{
					// Initialize variables			
				    Matrix *center = NULL, *bndry = NULL, *spn = NULL, *pts = NULL;
	
					// process the matrix 
					findworm(GrabImage1Mat, 
							 &center, &bndry, &spn, &pts);

					// now save points if needed 
					if( savepoints )
						save(pts);

					// now save the images
					if( saveimages )
					{
						if( ((counter - 1) % saveimages) == 0 )
						{
							sprintf(imagename, "%s\\file.%d.bmp", outsubdir, counter);
							m_GrabImage1->Save(imagename);
						}
					}

					// now draw the worm	
//CJC_3-4-03					drawworm(&m_GraphicContext1, center, bndry, spn, pts);

//CJC 3-31-03  FROM Jason Grant AT Matrox
drawworm(m_GraphicContext1, center, bndry, spn, pts);



//ORIGINAL CALL (COPIED FROM WORKING ActiveMIL 5.1 VERSION):
//drawworm(&m_GraphicContext1, center, bndry, spn, pts);		
		//YIELDS: error C2664: 'drawworm' : cannot convert parameter 1 from 'struct IGraphicContext ** ' to 'class CGraphicContext *'
		//Types pointed to are unrelated; conversion requires reinterpret_cast, C-style cast or function-style cast

//For grins, trying other syntaxes:
//drawworm(m_GraphicContext1, center, bndry, spn, pts);
		//YIELDS: error C2664: 'drawworm' : cannot convert parameter 1 from 'class CGraphicContext' to 'class CGraphicContext *'
        //No user-defined-conversion operator available that can perform this conversion, or the operator cannot be called

//drawworm((IGraphicContextPtr) m_GraphicContext1, center, bndry, spn, pts);
		//YIELDS: error C2664: 'drawworm' : cannot convert parameter 1 from 'class _com_ptr_t<class _com_IIID<struct IGraphicContext,&struct __s_GUID  _GUID_f2e7bde4_b006_11d0_9162_00a024d24992> >' 
		     //to 'class CGraphicContext *'
        //No user-defined-conversion operator available that can perform this conversion, or the operator cannot be called

//drawworm((CGraphicContext*) (&m_GraphicContext1), center, bndry, spn, pts);
		//COMPILES, BUT PROGRAM CRASHES AT FIRST CALL, INDICATING MEMORY COULD NOT BE "READ"
//***************************************************************************
// FOR INTEREST I'VE TRIED ADDING THE draw.cpp CODE INLINE...  
// REPLACING   gc (FROM draw.cpp)   WITH   m_GraphicContext1, THE CODE WORKS FINE...
//*******************
//*******************
//*******************
//*******************
//*******************
//*******************
/*
{
	// variables for drawing
	IRegionOfInterestPtr roi;
	roi = m_GraphicContext1->DrawingRegion;
//	roi = ((IGraphicContext*) gc)->DrawingRegion;
//ORIGINALLY WAS:
//	IRegionOfInterest roi = gc->GetDrawingRegion();

	int npoints, i;

	// draw focus of attention box	
	if( center != NULL )
	{
		double *centerp; long cx, cy;

		centerp = (double *) mxGetP((Matrix *) center);
		cx = (long) centerp[0]; cy = (long) centerp[1];
			
		roi->CenterX = cx-1;
		roi->CenterY = (cy-1);
		roi->SizeX = (bndryws);
		roi->SizeY = (bndryws);
// ORIGINALLY WAS:
//		roi.SetCenterX(cx-1);
//		roi.SetCenterY(cy-1);
//		roi.SetSizeX(bndryws);
//		roi.SetSizeY(bndryws);

	    m_GraphicContext1->Rectangle(FALSE, 0);
//	    ((IGraphicContext*) gc)->Rectangle(FALSE, 0);
//	ORIGINALLY WAS:
//		gc->Rectangle(FALSE, 0);
	}


	// now draw the worm boundary
	if( bndry != NULL )
	{
		unsigned int **bndryp = (unsigned int **) mxGetPr((Matrix *) bndry); 

		npoints = mxGetN((Matrix *) bndry);
		if( npoints > 1 )
		{
			long startx, starty, endx, endy;
			for( i = 1; i < npoints; i++ )
			{					
				startx = (long) bndryp[i-1][0];
				starty = (long) bndryp[i-1][1];
				endx = (long) bndryp[i][0];
				endy = (long) bndryp[i][1];

			    roi->StartX = (startx-1);
				roi->StartY = (starty-1);
				roi->EndX = (endx-1);
				roi->EndY = (endy-1);
// ORIGINALLY WAS:
//			    roi.SetStartX(startx-1);
//				roi.SetStartY(starty-1);
//				roi.SetEndX(endx-1);
//				roi.SetEndY(endy-1);

				m_GraphicContext1->LineSegment();
//				((IGraphicContext*) gc)->LineSegment();
// ORIGINALLY WAS:
//				gc->LineSegment();
			}
		}
	}

	// now draw the spine
	if( pts !=  NULL )
	{
		double **ptsp = (double **) mxGetPr((Matrix *) pts); 

		npoints = mxGetN((Matrix *) pts);

		if( npoints > 1 )
		for( i = 1; i < npoints; i++ )
		{		
			long startx, starty, endx, endy;

			startx = (long) ptsp[i-1][0];
			starty = (long) ptsp[i-1][1];
			endx = (long) ptsp[i][0];
			endy = (long) ptsp[i][1];

		    roi->StartX = (startx-1);
			roi->StartY = (starty-1);
			roi->EndX = (endx-1);
			roi->EndY = (endy-1);
//ORIGINALLY WAS:
//		    roi.SetStartX(startx-1);
//			roi.SetStartY(starty-1);
//			roi.SetEndX(endx-1);
//			roi.SetEndY(endy-1);


			m_GraphicContext1->LineSegment();
//			((IGraphicContext*) gc)->LineSegment();
//ORIGINALLY WAS:
//			gc->LineSegment();
		}	
	}

	// now draw the points
	if( pts != NULL )
	{
		double **ptsp = (double **) mxGetPr((Matrix *) pts);

		npoints = mxGetN((Matrix *) pts);
		for( i = 0; i < npoints; i++ )
		{
			long centerx, centery;
						
			centerx = (long) ptsp[i][0];
			centery = (long) ptsp[i][1];

			roi->CenterX = (centerx-1);
			roi->CenterY = (centery-1);
			roi->SizeX = ((long) 5);
			roi->SizeY = ((long) 5);
//ORIGINALLY WAS:
//			roi.SetCenterX(centerx-1);
//			roi.SetCenterY(centery-1);
//			roi.SetSizeX((long) 5);
//			roi.SetSizeY((long) 5);

			m_GraphicContext1->Arc(0, 360, 1);
//			((IGraphicContext*) gc)->Arc(0, 360, 1);
//ORIGINALLY WAS:
//			gc->Arc(0, 360, 1);
		}
	}
}
*/
//*******************
//*******************
//*******************
//*******************
//*******************
//*******************
//***************************************************************************


					// increment counter
					counter = counter + 1;

					// free all allocated memory
					mxFreeMatrix(center); mxFreeMatrix(bndry); mxFreeMatrix(spn); mxFreeMatrix(pts);
				}

				// display the image
//CJC				m_Image1->Copy(m_FirstImage, 0);
				m_Image1->Copy(m_GrabImage1, imAllBands);
			}

			// Increment counter
			m_ProcessingCount++;

/*
//$$$$$$$$$$
//	Adding these GrabWait's stops the program from hanging
//  on a GrabWait Timeout
   if (! m_bKillProcessing)
   {
     // Wait for the last grab end and stop the timer.
      m_Digitizer.GrabWait(mGrabEnd);

     // Get the time elapsed in processing loop
      m_dTime = m_Application.GetTimer().Read();
   }
//
//$$$$$$$$$$
*/

			// Set successful flag
			GrabImage2Success = 1;
		} 
		catch( COleDispatchException *e )
		{
			// Get rid of the error message
			e->Delete();

			// Set failure flag
			GrabImage2Success = 0;

			// Display the blank image
//CJC			m_Image1->Copy(m_EmptyImage, 0);
			m_Image1->Copy(m_EmptyImage, imAllBands);

//$$$$$$$$$$
   AfxMessageBox( "catch from Grab Second/Process First");
//$$$$$$$$$$

		}

		try
		{
////////////////////////////////////////////////////////
// start the timer
//m_Application.GetTimer().Reset();
//
////////////////////////////////////////////////////////
			// Start the "First" image grab
			m_Digitizer1->Image = m_GrabImage1;
			m_Digitizer1->Grab();

/////////////////////////////////////////////////////////
//
//if ( m_Digitizer.GetGrabInProgress() )
//   AfxMessageBox( "Grab in Progress");
//else
//   AfxMessageBox( "No grab in Progress, expect crash!");
//
//m_Digitizer.GrabWait(mGrabEnd);
//
/////////////////////////////////////////////////////////

			// Process the "Second" image
			if( GrabImage2Success )
			{			
				// now tranfer data into an array
//CJC				m_SecondImage->Get(*SecondImageArray, imSingleBand, 0, 0, 0, 640, 480);
				m_GrabImage2->Get(*GrabImage2Array, imPlanar, imAllBands, 0, 0, 640, 480);

				// now transfer data from array to matrix
				ArrayToMatrix(GrabImage2Array, GrabImage2Mat);

//////////////////////////////////////////////////////////
// Get the time elapsed during a grab 
//m_dTime = m_Application.GetTimer().Read();
//CString m_dTimeString;
//m_dTimeString.Format("Grab time = %8.4f msec", m_dTime);
//AfxMessageBox( m_dTimeString );
//
//////////////////////////////////////////////////////////

				// process the image
////////////////////////////////////////////////////////
// start the timer
//m_Application.GetTimer().Reset();
//
////////////////////////////////////////////////////////

				{
					// Initialize variables	
					Matrix *center = NULL, *bndry = NULL, *spn = NULL, *pts = NULL;

					// process the matrix 
					findworm(GrabImage2Mat, 
							 &center, &bndry, &spn, &pts);
					
					// now save points if needed 
					if( savepoints )
						save(pts);

					// now save the images
					if( saveimages )
					{
						if( ((counter - 1) % saveimages) == 0 )
						{
							sprintf(imagename, "%s\\file.%d.bmp", outsubdir, counter);
							m_GrabImage2->Save(imagename);
						}
					}

					// now draw the worm
//CJC COMMENTING THIS ONE OUT FOR SANITY'S SAKE:	drawworm(&m_GraphicContext2, center, bndry, spn, pts);

//CJC 3-31-03  FROM Jason Grant AT Matrox
drawworm(m_GraphicContext2, center, bndry, spn, pts);

					// increment counter
					counter = counter + 1;

					// free all allocated memory
					mxFreeMatrix(center); mxFreeMatrix(bndry); mxFreeMatrix(spn); mxFreeMatrix(pts);	
				}				

//////////////////////////////////////////////////////////
// Get the time elapsed in processing loop
//m_dTime = m_Application.GetTimer().Read();
//CString m_dTimeString;
//m_dTimeString.Format("Processing time = %8.4f msec", m_dTime);
//AfxMessageBox( m_dTimeString );
//
//////////////////////////////////////////////////////////

				// display the image
//CJC				m_Image1->Copy(m_SecondImage, 0);
				m_Image1->Copy(m_GrabImage2, imAllBands);
			}

			// Increment counter
			m_ProcessingCount++;

/*
//$$$$$$$$$$
//	Adding these GrabWait's stops the program from hanging
//  on a GrabWait Timeout
   if (! m_bKillProcessing)
   {
     // Wait for the last grab end and stop the timer.
      m_Digitizer.GrabWait(mGrabEnd);

     // Get the time elapsed in processing loop
      m_dTime = m_Application.GetTimer().Read();
   }
//
//$$$$$$$$$$
*/

			// Set successful flag
			GrabImage1Success = 1;
		}
		catch( COleDispatchException *e )
		{
			// Get rid of the error message
			e->Delete();

			// Set failure flag
			GrabImage1Success = 0;

			// Display the blank image
//CJC			m_Image1->Copy(m_EmptyImage, 0);
			m_Image1->Copy(m_EmptyImage, imAllBands);

//$$$$$$$$$$
   AfxMessageBox( "catch from Grab First/Process Second");
//$$$$$$$$$$

		}
   }

/*  ///////////////////////////////////////////////////////////
//HERE'S THE OLD KILLPROCESSING STATEMENT THAT GENERATESTHE GRABWAIT TIMEOUT:  
//(REPLACED BY THE ONE BELOW)
   if (! m_bKillProcessing)
   {
     // Wait for the last grab end and stop the timer.
      m_Digitizer.GrabWait(mGrabEnd);

     // Get the time elapsed in processing loop
      m_dTime = m_Application.GetTimer().Read();
   }
*/ /////////////////////////////////////////////////////////////

/*  ///////////////////////////////////////////////////////////
//HERE'S THE OLD KILLPROCESSING STATEMENT THAT GENERATESTHE GRABWAIT TIMEOUT:  
//(REPLACED BY THE ONE BELOW)
   if (! m_bKillProcessing)
   {
	   if ( m_Digitizer.GetGrabInProgress() )
	   {
		   AfxMessageBox( "Grab in Progress");
     // Wait for the last grab end and stop the timer.
      m_Digitizer.GrabWait(mGrabEnd);
	   }

	   else
		   AfxMessageBox( "No grab in Progress, expect crash!");

//     // Wait for the last grab end and stop the timer.
//      m_Digitizer.GrabWait(mGrabEnd);

     // Get the time elapsed in processing loop
      m_dTime = m_Application.GetTimer().Read();
   }
*/ /////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
// Try this instead: enclose GrabWait in its own Try-Catch
// (with a message box indicating where the timeout occured)
//
// IT WORKS!  But the message box holds up processing...
// So, bag the message box and just use the exception handling 
// of the Try-Catch!

   // Should only get here when Application.GetTimer exceeds 
   // recording length (in minutes) * 60sec/min 
   // (OR m_bStopProcessing == TRUE, but can't find any operator 
   // that would set that flag).

//////////////////////////////////////////////////////
//
   if (! m_KillProcessing)   
   {
	   try
	   {
     // Wait for the last grab end and stop the timer.
//CJC      m_Digitizer1->GrabWait(mGrabEnd);
      m_Digitizer1->GrabWait(digGrabEnd);

     // Get the time elapsed in processing loop
      m_Time = m_Application1->Timer->Read();
	   }

	   catch( COleDispatchException *e )
	   {
	   
			// Get rid of the error message
			e->Delete();

			// Set failure flag
			GrabImage1Success = 0;

			// Display the blank image
//CJC			m_Image1->Copy(m_EmptyImage, 0);
			m_Image1->Copy(m_EmptyImage, imAllBands);

//  Eliminate this warning box to allow process to continue flowing
//$$$$$$$$$$
//  AfxMessageBox( "catch from StopProcesing");
//$$$$$$$$$$

		}
   }
//////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////


   // Destroy the arrays
   empty->Destroy();
   GrabImage2Array->Destroy();
   GrabImage1Array->Destroy();
   mxFreeMatrix(GrabImage2Mat);
   mxFreeMatrix(GrabImage1Mat);
}
//--------------- CJC -----end-------------------------------------------



/////////////////////////////////////////////////////////////////////////////
// ActiveMIL function: OnProcessingWorkFunctionEnd message handler
// This function handles WM_PROCESSINGWORKFUNCTIONEND custom Windows message
// posted by the processing thread control function at end of processing
//
LONG CMDoubleBufferingLiteDlg::OnProcessingWorkFunctionEnd(UINT, LONG)
{
   // ...sequel of Step 3: Print statistics
   if (! m_KillProcessing)
      {

/* //--------------- CJC ----start------------------------------------------
      // Reenable Next button
      m_NextButton.EnableWindow(TRUE);
      m_NextButton.SetFocus();

      // Print message
      m_CommentText.Format("%ld frames grabbed, at a frame rate of %.2f frames/sec (%.2f ms/frame). "
                           "Click Next to end. ",
                           m_ProcessingCount, 
                           m_ProcessingCount / m_Time, 
                           1000.0 * m_Time / m_ProcessingCount);
*/ //--------------- CJC -----end-------------------------------------------
      CString str;
	  if( debug )
	  {
		  if( memLeaks )
			str.Format("Memory Leaked. Click Quit to End");
		  else
			str.Format("No Memory Leaks. Click Quit to End");
	  }
	  else
	  {
	      str = "Done.";
	  }

      UpdateData(FALSE);
      }

//--------------- CJC ----start------------------------------------------
   // Delete the VCR
   delete vcr;
//--------------- CJC -----end-------------------------------------------

  return 0;
}


/////////////////////////////////////////////////////////////////////////////
// ActiveMIL procedure: Indicate the processing is kill
//
void CMDoubleBufferingLiteDlg::OnClose() 
{
   // Instruct the processing thread to terminate if necessary
   m_KillProcessing = TRUE;
	
	CDialog::OnClose();
}


/////////////////////////////////////////////////////////////////////////////
// ActiveMIL procedure: Increments the step counter and updates text in 
// the dialog according to the new value
//
//void CMDoubleBufferingLiteDlg::AdjustStepNumber()
//{
//   // Increment the step count
//   m_StepCount++;
//
//   // Write the step count in the comment frame
//   CString str;
//   str.Format("Step %d:", m_StepCount);
//   CWnd *pStepNumber = GetDlgItem(IDC_STEPNUMBER);
//   pStepNumber->SetWindowText(str);
//}


/////////////////////////////////////////////////////////////////////////////
// ActiveMIL procedure: Calculate how to resize the dialog in order to view 
// all elements in all resolutions and font sizes
//
void CMDoubleBufferingLiteDlg::AdjustDialog()
{

	// Set the icon for this dialog.  The framework does this automatically
	// when the application's main window is not a dialog
   HICON hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
	SetIcon(hIcon, TRUE);			// Set big icon
	SetIcon(hIcon, FALSE);		   // Set small icon

   // Retrieve the relevant dialog controls
   CWnd *pNextButton = GetDlgItem(IDC_NEXTBUTTON);
   CWnd *pStepNumber = GetDlgItem(IDC_STEPNUMBER);

   long nMaxDisplayWidth;
   long nMaxNextStepWidth;
   CRect rectNextButton;
   CRect rectCommentFrame;
   CRect rectDisplay;
   CRect rectDialog;

   // Adjust the size of the Display 
   m_Display1.SetWindowPos(NULL,                               // pWndInsertAfter
                           0,                                  // x  
                           0,                                  // y
                           (int) (m_Digitizer1->SizeX * m_Digitizer1->ScaleX), // cx
                           (int) (m_Digitizer1->SizeY * m_Digitizer1->ScaleX), // cy
                           SWP_NOMOVE | SWP_NOOWNERZORDER);    // flags
                   
   // Get the sizes of relevant elements and calculate how to resize the
   // dialog in order to view all elements, in all resolutions and font sizes
   pNextButton->GetWindowRect(&rectNextButton);
   pStepNumber->GetWindowRect(&rectCommentFrame);
   m_Display1.GetWindowRect(&rectDisplay);
   GetWindowRect(&rectDialog);

   nMaxDisplayWidth  = rectDisplay.Width() + 
                       2 * abs(rectDialog.left - rectDisplay.left);

   nMaxNextStepWidth = rectNextButton.left - rectDialog.left + 
                       rectNextButton.Width() + 
                       rectCommentFrame.left - rectDialog.left;
   
   if (nMaxNextStepWidth > nMaxDisplayWidth)
      {
      SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxNextStepWidth,                             // cx
                   rectDisplay.Height() + 
                   rectDisplay.top - rectDialog.top + 
                   rectDisplay.left - rectDialog.left,            // cy
                   SWP_SHOWWINDOW);                               // flags
      }
   else
      {
      SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxDisplayWidth,                              // cx
                   rectDisplay.Height() + 
                   rectDisplay.top - rectDialog.top + 
                   abs (rectDisplay.left - rectDialog.left),      // cy
                   SWP_SHOWWINDOW);                               // flags
      }

}
