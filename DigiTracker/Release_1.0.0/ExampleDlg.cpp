#include "stdafx.h"
#include "ExampleDlg.h"
#include "mex.h"
#include "ExampleImage.h"
#include "ExampleDraw.h"
#include "FileSelection.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define IMAGEX 640					  // size of image x dim
#define IMAGEY 480					  // size of image y dim
#define CENX (IMAGEX / 2)			  // x coord of center
#define CENY (IMAGEY / 2)			  // y coord of center
#define WX 480						  // width of window (220)
#define WY 320						  // height of window (140)	
#define MOVEX 320					  // number of x pixels to move when buttons are pressed
#define MOVEY 240					  // number of y pixels to move when buttons are pressed

/* ORIGINALS
#define IMAGEX 320					  // size of image x dim
#define IMAGEY 240					  // size of image y dim
#define CENX (IMAGEX / 2)			  // x coord of center
#define CENY (IMAGEY / 2)			  // y coord of center
#define WX 240						  // width of window (220)
#define WY 160						  // height of window (140)	
#define MOVEX 160					  // number of x pixels to move when buttons are pressed
#define MOVEY 120					  // number of y pixels to move when buttons are pressed
ORIGINALS */

#define RECTIME 240					  // seconds to record for
#define FPS_MIN 1                     // min record rate (frames per second)
#define FPS_MAX 30                    // max record rate (frames per second)
//#define FPS_MAX 60	// CJC 2-20-06 Should try this.  Not sure how slower cameras would react though.                    // max record rate (frames per second)
#define RECFPS 15                     // initial record rate 
#define IMG_BRIGHTNESS 128            // initial image brightness
#define IMG_GAIN 128                  // initial image gain
#define UPDATE_DELAY 5				  // initial update delay count
#define MIN_PIXEL_DIFF 75		
#define MM_PER_STEP 0.000628          // mm per step for the platform

#define MAXIMUM_NUMBER_OF_FRAMES 1000

//#define UPDATE_DELAY_MIN 1            // min update delay (count)
//#define UPDATE_DELAY_MAX 30           // max update delay (count)

// Define bit masks for keys held down during a mouse click
#define SHIFT_KEY	1	// right-most bit set
#define CTRL_KEY	2	// 2nd to right-most bit set
#define ALT_KEY		4	// 3rd to right-most bit set


// NOTE: locationcode being replaced by stagestyle
int locationcode = 0;	// Code for "Caltech" configuration.
						// Set via <Ctrl-Alt> l (lowercase L) dialog's combo box
int stagestyle = 0;		// Code for "Ludl BioPoint" style stage

int m_diffThresholdValue = MIN_PIXEL_DIFF;	// CJC 2-20-06 Local copy of Difference Threshold value

//CHECKSTATE autoExp;		// Declare autoExp variable as type CHECKSTATE (structure)
						// Plan to populate in LoadParams
CHECKSTATETYPE AutoExposureState;
CHECKREVERSETYPE ReverseStageState;

struct addr dinfo;


// Camera Serial Number
_variant_t serialNumber;						// Camera serial number as _variant_t
long CurrentCameraSN, PreviousCameraSN;		// Camera serial numbers as int's


/////////////////////////////////////////////////////////////////////////////
// These are the global parameters
//
int MAGS[4] = {6, 12, 25, 50};		  // different magnification levels
int SPP[4] = {16, 8, 4, 2};		  // different steps per pixel	DIGITRACKER
//int SPP[4] = {50, 25, 12, 6};		  // different steps per pixel	ANALOG

// CJC 12-14-05 recent wait--> int WAIT[4] = {30,22,20,20};		  // different waiting periods 
int WAIT[4] = {60,45,40,40};		  // CJC 12-14-05 OLD WAIT different waiting periods 

// Custom Windows message 
const int WM_PROCESSINGWORKFUNCTIONEND = WM_USER + 1;
const int WM_RECORDEND = WM_USER + 2;
const int WM_RECORDERROR = WM_USER + 3;
const int WM_UPDATEDLG = WM_USER + 4;

BEGIN_MESSAGE_MAP(CExampleDlg, CDialog)
	//{{AFX_MSG_MAP(CExampleDlg)
	ON_BN_CLICKED(IDC_QUITBUTTON, OnQuitbutton)
	ON_WM_CLOSE()
	ON_BN_CLICKED(IDC_RESTARTBUTTON, OnRestartbutton)
	ON_BN_CLICKED(IDC_IMAGEBUTTON, OnImagebutton)
	ON_BN_CLICKED(IDC_UPBUTTON, OnUpbutton)
	ON_BN_CLICKED(IDC_DOWNBUTTON, OnDownbutton)
	ON_BN_CLICKED(IDC_LEFTBUTTON, OnLeftbutton)
	ON_BN_CLICKED(IDC_RIGHTBUTTON, OnRightbutton)
	ON_BN_CLICKED(IDC_AUTOBUTTON, OnAutobutton)
	ON_BN_CLICKED(IDC_RECBUTTON, OnRecbutton)
	ON_NOTIFY(UDN_DELTAPOS, IDC_SPIN1, OnDeltaposSpin1)
	ON_WM_HSCROLL()
	ON_BN_CLICKED(IDC_AUTOSHUT, OnAutoshut)
	ON_NOTIFY(NM_RELEASEDCAPTURE, IDC_SLIDER, OnReleasedcaptureMagSlider)
	ON_BN_CLICKED(IDC_HOMEBUTTON, OnHomeButton)
	ON_BN_CLICKED(IDC_HOMERESETBUTTON, OnHomeresetbutton)
	ON_BN_CLICKED(IDC_SETTINGS_DIALOG, OnSettingsDialog)
	ON_MESSAGE(WM_PROCESSINGWORKFUNCTIONEND, OnProcessingWorkFunctionEnd)
	ON_MESSAGE(WM_RECORDERROR, OnRecordError)
	//}}AFX_MSG_MAP
	ON_MESSAGE(WM_RECORDEND, OnRecbutton)
	ON_MESSAGE(WM_HOTKEY, OnHotKey)
	ON_MESSAGE(WM_UPDATEDLG, OnUpdatedlg)
END_MESSAGE_MAP()
	
/////////////////////////////////////////////////////////////////////////////
// The one and only CExampleApp object
//
CExampleApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CExampleDlg dialog
//
CExampleDlg::CExampleDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CExampleDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CExampleDlg)
	m_strCommentText = _T("");
	m_fps_display = 0;
	m_strMagnification = _T("");
	//}}AFX_DATA_INIT

    m_nStepCount = 1;
	m_nProcessingCount = 0;
	m_restart = 90;
	m_track = 0;
	m_image = 1;

//	m_updateDelay = 5;		//CJC 3-15-05 Ensures non-zero default to prevent divide-by-zero unhandled exception

	// Calibration Setup
	stepsPerPixel=0.60*SPP[2];
	m_isCalibrating=false;

	//m_imageSeq.SetSize(MAXIMUM_NUMBER_OF_FRAMES);


}


/////////////////////////////////////////////////////////////////////////////
// CExampleDlg data exchange
//
void CExampleDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CExampleDlg)
	DDX_Control(pDX, IDC_SETTINGS_DIALOG, m_SettingsDialogButton);
	DDX_Control(pDX, IDC_STATIC_HOMERESET, m_HomeResetLabel);
	DDX_Control(pDX, IDC_HOMERESETBUTTON, m_HomeResetButton);
	DDX_Control(pDX, IDC_HOMEBUTTON, m_HomeButton);
	DDX_Control(pDX, IDC_EDIT5, m_autoShutOffEdit);
	DDX_Control(pDX, IDC_STATIC_ASO, m_autoShutOffLabel);
	DDX_Control(pDX, IDC_AUTOSHUT, m_autoShutOffCheck);
	DDX_Control(pDX, IDC_SPIN3, m_autoShutOffSpinner);
	DDX_Control(pDX, IDC_SPIN1, m_spinner);
	DDX_Control(pDX, IDC_QUITBUTTON, m_QuitButton);
	DDX_Control(pDX, IDC_RESTARTBUTTON, m_RestartButton);
	DDX_Control(pDX, IDC_UPBUTTON, m_UpButton);
	DDX_Control(pDX, IDC_DOWNBUTTON, m_DownButton);
	DDX_Control(pDX, IDC_LEFTBUTTON, m_LeftButton);
	DDX_Control(pDX, IDC_RIGHTBUTTON, m_RightButton);
	DDX_Control(pDX, IDC_AUTOBUTTON, m_AutoButton);
	DDX_Control(pDX, IDC_IMAGEBUTTON, m_ImageButton);
	DDX_Control(pDX, IDC_RECBUTTON, m_RecordButton);
	DDX_Control(pDX, IDC_SLIDER, m_Slider);
	DDX_Text(pDX, IDC_COMMENTTEXT, m_strCommentText);
	DDX_Control(pDX, IDC_DISPLAY, m_Display);
	DDX_Control(pDX, IDC_DIGITIZER, m_Digitizer);
	DDX_Control(pDX, IDC_SYSTEM, m_System);
	DDX_Control(pDX, IDC_APPLICATION, m_Application);
	DDX_Control(pDX, IDC_DISPLAY_BUFFER, m_DisplayBuffer);
	DDX_Control(pDX, IDC_CURRENT_BUFFER, m_CurrentBuffer);
	DDX_Control(pDX, IDC_PREVIOUS_BUFFER, m_PreviousBuffer);
	DDX_Control(pDX, IDC_EMPTY_BUFFER, m_EmptyBuffer);
	DDX_Control(pDX, IDC_GRAPHICCONTEXT, m_GraphicContext);
	DDX_Text(pDX, IDC_EDIT1, m_fps_display);
	DDX_Text(pDX, IDC_MAGNIFICATION, m_strMagnification);
	//}}AFX_DATA_MAP
}


/////////////////////////////////////////////////////////////////////////////
// CExampleDlg message handlers
//
BOOL CExampleDlg::OnInitDialog()
{
   CDialog::OnInitDialog();

   // Initialize the table
   table = new Table((int) 1);	//CJC: COM1 --> Stage("table") controller
   record = 0;


   m_threadEnded=FALSE;



////////////////////////////////////////////////
try
{
	serialNumber = m_Digitizer.Inquire(digSerialNumber0);
	CurrentCameraSN = serialNumber.operator long();
	
}
catch( COleDispatchException *e )
{
	// Get rid of the error message
	e->Delete();

	CurrentCameraSN = NULL;
}



   // Initialize gain slider
// CJC 2-20-06   m_gain.SetRangeMin(0);
// CJC 2-20-06   m_gain.SetRangeMax(255);
// CJC 2-20-06   m_gain.SetPos(IMG_GAIN);

   // Initialize slider edit boxes
// CJC 2-20-06   char buf[10];
// CJC 2-6-06   m_brightnessEdit.SetLimitText(4);	// CJC 12-13-05  WAS 3
// CJC 2-6-06   m_brightness.SetBuddy(&m_brightnessEdit, FALSE);
// CJC 2-6-06   m_brightnessEdit.SetWindowText(_itoa(m_brightness.GetPos(), buf, 10));

// CJC 2-20-06   m_gainEdit.SetLimitText(3); 
// CJC 2-20-06   m_gain.SetBuddy(&m_gainEdit, FALSE);   
// CJC 2-20-06   m_gainEdit.SetWindowText(_itoa(m_gain.GetPos(), buf, 10));

///////////////////////////////////////////////////////////////////////////
// CJC 2-16-06	THIS NEEDS TO MOVE TO SETTINGS DIALOG //////////////////////
// CJC 2-20-06   // Initialize difference threshold slider
// CJC 2-20-06   m_diffThreshold.SetRange(0, 255);
// CJC 2-20-06   m_diffThreshold.SetPos(MIN_PIXEL_DIFF);
// CJC 2-20-06
// CJC 2-20-06   m_diffThresholdEdit.SetLimitText(3); 
// CJC 2-20-06   m_diffThreshold.SetBuddy(&m_diffThresholdEdit, FALSE);   
// CJC 2-20-06   m_diffThresholdEdit.SetWindowText(_itoa(m_diffThreshold.GetPos(), buf, 10));
///////////////////////////////////////////////////////////////////////////

   // Initialize Magnification Slider
   m_Slider.SetRangeMin(1);
   m_Slider.SetRangeMax(4);
   m_Slider.SetPos(3);

   // Initialize Magnification Text Box
   m_strMagnification.Format(" %d X", MAGS[m_Slider.GetPos()-1]);
   
   // Initialize FPS spinner
   m_spinner.SetRange(FPS_MIN,FPS_MAX);
   m_spinner.SetPos(RECFPS);
   m_fps_display = m_spinner.GetPos();
   frames_per_second = m_spinner.GetPos();

///////////////////////////////////////////////////////////////////////////
// CJC 2-16-06	THIS NEEDS TO MOVE TO SETTINGS DIALOG //////////////////////
// CJC 2-20-06   m_updateDelaySpinner.SetRange(1, 30);
// CJC 2-20-06   m_updateDelaySpinner.SetPos(UPDATE_DELAY);
   m_updateDelayValue = UPDATE_DELAY;		// Set default value
///////////////////////////////////////////////////////////////////////////

   m_autoShutOffSpinner.SetRange(1, UD_MAXVAL);
   m_autoShutOffSpinner.SetPos(RECTIME); 
   m_autoShutOffCheck.SetCheck(1);
	

	// Set Default AutoExposure values
	AutoExposureState.brightnessCheck	= 0;
	AutoExposureState.gainCheck		= 0;
	AutoExposureState.shutterCheck	= 0;
	AutoExposureState.autoExposureCheck= 0;
	AutoExposureState.gammaCheck		= 0;
	AutoExposureState.sharpnessCheck	= 0;

	// Set Default Stage Reversal values
	ReverseStageState.reverseX = 0;
	ReverseStageState.reverseY = 0;


   // load and update persistent data from program.data file
   LoadParam();
   OnAutoshut();


   // Calculate stage direction multiplier
   CalculateStageDirections();

// DELETE THIS or leave as debug only:
#ifdef _DEBUG
   if (PreviousCameraSN ==CurrentCameraSN) AfxMessageBox("Same camera");
   else AfxMessageBox("Hey, this camera is different!");
#endif

   // Initialize Locationselector dialog
//   locationDlg = new CLocationDlg;
//   locationDlg->Create(IDD_LOCATIONSELECTOR);


	UINT modifier = MOD_ALT;
	RegisterHotKey(this->m_hWnd, 100, MOD_ALT | MOD_CONTROL, 'L');

// CJC 4-04-05 for later...	   
//   UnregisterHotKey(this->m_hWnd, 100);



   // RE-Initialize Magnification Text Box
   m_strMagnification.Format(" %d X", MAGS[m_Slider.GetPos()-1]);

   UpdateData(FALSE);


// CJC 10-12-04
   // Resize the Dialog
   AdjustDialog();
// CJC 10-12-04

   // Start processing thread		// CJC 4-05-05 looks like Worker Thread
   m_bStopProcessing = FALSE;
   m_bKillProcessing = FALSE;
   AfxBeginThread(ProcessingThreadFunction, this);	

   // Return the answer
   return TRUE;  
}

/////////////////////////////////////////////////////////////////////////////
// Calculate how to resize the dialog in order to view all elements
// in all resolutions and font sizes
//
void CExampleDlg::AdjustDialog()
{
	// Set the icon for this dialog.  The framework does this automatically
	// when the application's main window is not a dialog
   HICON hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
   SetIcon(hIcon, TRUE);			// Set big icon
   SetIcon(hIcon, FALSE);		    // Set small icon

   // Retrieve the relevant dialog controls
   CWnd *pQuitButton = GetDlgItem(IDC_QUITBUTTON);
   CWnd *pStepNumber = GetDlgItem(IDC_STEP_NUMBER);
   CWnd *pStaticFrame = GetDlgItem(IDC_STATIC);			// NEW CJC

   long nMaxDisplayWidth;
//   long nMaxNextStepWidth;
   long nMaxButtonWidth;		// NEW CJC
   CRect rectQuitButton;
   CRect rectCommentFrame;
   CRect rectDisplay;
   CRect rectDialog;
   CRect rectStaticFrame;			// NEW CJC

   // Adjust the size of the ActiveMIL Display 
   m_Display.SetWindowPos(NULL,                               // pWndInsertAfter
                          0,                                  // x  
                          0,                                  // y
                          (int) (m_Digitizer.GetSizeX() * m_Digitizer.GetScaleX()), // cx
                          (int) (m_Digitizer.GetSizeY() * m_Digitizer.GetScaleX()), // cy
                          SWP_NOMOVE | SWP_NOOWNERZORDER);    // flags
                   
   // Get the sizes of relevant elements and calculate how to resize the
   // dialog in order to view all elements, in all resolutions and font sizes
   pQuitButton->GetWindowRect(&rectQuitButton);
   pStepNumber->GetWindowRect(&rectCommentFrame);
   pStaticFrame->GetWindowRect(&rectStaticFrame);		// NEW CJC

   m_Display.GetWindowRect(&rectDisplay);
   GetWindowRect(&rectDialog);

   nMaxDisplayWidth  = rectDisplay.Width();
//   nMaxDisplayWidth  = rectDisplay.Width() + 
//                       2 * abs(rectDisplay.left - rectDialog.left);
//   nMaxDisplayWidth  = rectDisplay.Width() + 
//                       2 * abs(rectDisplay.right - rectDialog.right);

/*   nMaxNextStepWidth = rectQuitButton.left - rectDialog.left + 
                       rectQuitButton.Width() + 
                       rectCommentFrame.left - rectDialog.left;
*/   
   nMaxButtonWidth =   (rectQuitButton.left   - rectDialog.left) + 
                       (rectStaticFrame.right - rectQuitButton.left) + 
                       (rectDialog.right      - rectStaticFrame.right);
   
   if(nMaxButtonWidth > nMaxDisplayWidth)
   {
      SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxButtonWidth,								  // cx
                   rectDisplay.Height() + 
                   abs (rectDisplay.top    - rectDialog.top) + 
                   abs (rectQuitButton.left   - rectDialog.left),      // cy
                   SWP_SHOWWINDOW);								  // flags
/*      SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxButtonWidth,								  // cx
                   rectDisplay.Height() + 
                   abs (rectDisplay.top    - rectDialog.top) + 
                   abs (rectDisplay.left - rectDialog.left),      // cy
                   SWP_SHOWWINDOW);								  // flags
*/
   }
   else
   {
      SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxDisplayWidth,                              // cx
                   rectDisplay.Height() + 
                   abs (rectDisplay.top - rectDialog.top) + 
                   abs (rectDisplay.left - rectDialog.left),      // cy
                   SWP_SHOWWINDOW);								  // flags

/*       SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxDisplayWidth,                             // cx
                   rectDisplay.Height() + 
                   abs (rectDisplay.right - rectDialog.right),      // cy
                   SWP_SHOWWINDOW);								  // flags
*/
   }
}

/////////////////////////////////////////////////////////////////////////////
// ProcessingThreadFunction
// This function controls the processing thread
//
UINT CExampleDlg::ProcessingThreadFunction(LPVOID pParam)
{
   CExampleDlg *pthis = (CExampleDlg *) pParam;

   // Call CExampleDlg's processing loop
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

/////////////////////////////////////////////////////////////////////////////
// ProcessingWorkFunction
// This function performs the real work of the processing thread
//
void 
CExampleDlg::ProcessingWorkFunction()
{
   DWORD dim[2];
   int PreviousSuccess = 0, CurrentSuccess = 0;
   int x = -1, y = -1;

   unsigned char *framePtr;        // pointer to 
   char str[100];                  // string to display text on image
   double recordFrameRate=0;       // actual record frame rate  
   BYTE boxColor=0;	               // gray scale color for box and text

   Matrix *DataMatrix = NULL;
   Matrix *OldMatrix = NULL;
   Matrix *DiffMatrix = NULL;   
   Matrix *EmptyMatrix = NULL;

   COleSafeArray *DataArray = new COleSafeArray();
   COleSafeArray *DispArray = new COleSafeArray();	

   // Allocate the arrays
   dim[0] = IMAGEX; dim[1] = IMAGEY;
	
   DataMatrix = mxCreateFull(IMAGEY, IMAGEX, CHAR);
   OldMatrix = mxCreateFull(IMAGEY, IMAGEX, CHAR);   
   DiffMatrix = mxCreateFull(IMAGEY, IMAGEX, CHAR);   
   EmptyMatrix = mxCreateFull(IMAGEY, IMAGEX, CHAR);

   DataArray->Create(VT_I1, (DWORD) 2, dim);
   DispArray->Create(VT_I1, (DWORD) 2, dim);   

   // Start the timer
   m_Application.GetTimer().Reset();
 

   // Process one buffer while grabbing the other
   while (! m_bStopProcessing && ! m_bKillProcessing)
   {

		try
		{			
		
			// Start the grab
		    m_Digitizer.SetImage(m_PreviousBuffer);
			m_Digitizer.Grab();

			// Process the current buffer
			if( CurrentSuccess )
			{
				// Now tranfer data into an array
				m_CurrentBuffer.Get(*DataArray, mSingleBand, 0, 0, 0, IMAGEX, IMAGEY);
				
				// Now transfer data from array to matrix
				ArrayToMatrix(DataArray, DataMatrix);

				// Process images
				if( m_restart > 0 )
				{
					Initialize(OldMatrix, DataMatrix, &x, &y, DiffMatrix); 
					m_restart = m_restart - 1;
				}
//				else if ((m_nProcessingCount % m_updateDelay) == 0)
				else if ((m_nProcessingCount % m_updateDelayValue) == 0)
				{
					// Update(OldMatrix, DataMatrix, &x, &y, DiffMatrix, m_diffThreshold.GetPos());
					Update(OldMatrix, DataMatrix, &x, &y, DiffMatrix, m_diffThresholdValue);
				}

				// Display the image
				if( m_image )
				{
					boxColor=0;
					m_DisplayBuffer.Copy(m_CurrentBuffer, 0);
				
				}
				else
				{
					boxColor=255;
					MatrixToArray(DispArray, DiffMatrix);
					m_DisplayBuffer.Put(*DispArray, mSingleBand, 0, 0, 0, IMAGEX, IMAGEY);
				}

				// Draw the boxes
				
				DrawBox(&m_GraphicContext, CENX, CENY, WX, WY, boxColor);
				if( (x != -1) && (y != -1) )
					DrawBox(&m_GraphicContext, x, y, 30, 30, boxColor);
				
				// Recenter the table
				if( m_track )
					if( (x != -1) && (y != -1) )
						if( ((abs(x - CENX) > WX/2) || (abs(y - CENY) > WY/2)) )
						{
						   int mag = m_Slider.GetPos()-1;
						   m_restart = m_restart + WAIT[mag];
						   table->MoveRel((int) (XDirection*0.6*stepsPerPixel*(x - CENX)), 
										  (int) (YDirection*0.6*stepsPerPixel*(y - CENY)));
// CJC 3-01-06 WAS						   table->MoveRel((int) (0.6*stepsPerPixel*(x - CENX)), 
// CJC 3-01-06 WAS										  (int) (0.6*stepsPerPixel*(y - CENY)));
////						   table->MoveRel((int) (stepsPerPixel*(x - CENX)), 
////										  (int) (stepsPerPixel*(y - CENY)));
						}			
			}

			// Set successful flag
			PreviousSuccess = 1;
		} 
		catch( COleDispatchException *e )
		{
			// Get rid of the error message
			e->Delete();

			// Need to restart
			m_restart = 1;

			// Set failure flag
			PreviousSuccess = 0;

			// Display Empty Image
			MatrixToArray(DispArray, EmptyMatrix);
			m_DisplayBuffer.Put(*DispArray, mSingleBand, 0, 0, 0, IMAGEX, IMAGEY);
		}

		// Increment counter
		m_nProcessingCount++;  

		m_dTime = m_Application.GetTimer().Read();
		if (record) {	

			// show rec time
			recordFrameRate=m_nRecordedCount/(m_dTime - recTime);
			sprintf(str,"REC  %.3lf sec.  FPS: %.2lf", m_dTime - recTime, recordFrameRate);
			DrawText(&m_GraphicContext, 0, 0, str, boxColor);


			if (recordFrameRate < frames_per_second) {
				// time is up, write the frame
				DataArray->AccessData((void**) &framePtr);
				fwrite(&m_dTime, sizeof(m_dTime), 1, fp);
				fwrite(framePtr, IMAGEX*IMAGEY, 1, fp);
				
				if (ferror(fp))
					PostMessage(WM_RECORDERROR);

				DataArray->UnaccessData();
				
				m_nRecordedCount++;
			}

				
		} 

		try
		{

			// Start the grab
			m_Digitizer.SetImage(m_CurrentBuffer);
			m_Digitizer.Grab();

			// Process the previous image
			if( PreviousSuccess )
			{			
				// Now tranfer data into an array
				m_PreviousBuffer.Get(*DataArray, mSingleBand, 0, 0, 0, IMAGEX, IMAGEY);

				// Now transfer data from array to matrix
				ArrayToMatrix(DataArray, DataMatrix);

				// Process images
				if( m_restart > 0 )
				{
					Initialize(OldMatrix, DataMatrix, &x, &y, DiffMatrix); 
					m_restart = m_restart - 1;
				}
//				else if ((m_nProcessingCount % m_updateDelay) == 0)
				else if ((m_nProcessingCount % m_updateDelayValue) == 0)
				{
					// Update(OldMatrix, DataMatrix, &x, &y, DiffMatrix, m_diffThreshold.GetPos());
					Update(OldMatrix, DataMatrix, &x, &y, DiffMatrix, m_diffThresholdValue);
				}

				// Display the image
				if( m_image )
				{
					boxColor=0;
					m_DisplayBuffer.Copy(m_PreviousBuffer, 0);
				}
				else
				{
					boxColor=255;
					MatrixToArray(DispArray, DiffMatrix);
					m_DisplayBuffer.Put(*DispArray, mSingleBand, 0, 0, 0, IMAGEX, IMAGEY);
				}

				// Draw the boxes
				DrawBox(&m_GraphicContext, CENX, CENY, WX, WY, boxColor);
				if( (x != -1) && (y != -1) )
					DrawBox(&m_GraphicContext, x, y, 30, 30, boxColor);												

				// Recenter the table
				if( m_track )
					if( (x != -1) && (y != -1) )
						if( ((abs(x - CENX) > WX/2) || (abs(y - CENY) > WY/2)) )
						{
						   int mag = m_Slider.GetPos()-1;
						   m_restart = m_restart + WAIT[mag];
						   table->MoveRel((int) (XDirection*0.6*stepsPerPixel*(x - CENX)), 
							              (int) (YDirection*0.6*stepsPerPixel*(y - CENY)));
// CJC 3-01-06 WAS						   table->MoveRel((int) (0.6*stepsPerPixel*(x - CENX)), 
// CJC 3-01-06 WAS							              (int) (0.6*stepsPerPixel*(y - CENY)));
////						   table->MoveRel((int) (stepsPerPixel*(x - CENX)), 
////							              (int) (stepsPerPixel*(y - CENY)));
						}

			}

			// Set successful flag
			CurrentSuccess = 1;
		}
		catch( COleDispatchException *e )
		{
			// Get rid of the error message
			e->Delete();

			// Need to restart	
			m_restart = 1;

			// Set failure flag
			CurrentSuccess = 0;

			// Display Empty Image
			MatrixToArray(DispArray, EmptyMatrix);
			m_DisplayBuffer.Put(*DispArray, mSingleBand, 0, 0, 0, IMAGEX, IMAGEY);		
		}  

		// Increment counter
		m_nProcessingCount++;

		m_dTime = m_Application.GetTimer().Read();

		if (record) 
		{			
			//if( (m_dTime - recTime) > (RECTIME * 60) )
			if( m_autoShutOffCheck.GetCheck() &&
				(m_dTime - recTime) > m_autoShutOffSpinner.GetPos())
			{	
				record=0;
				m_strCommentText = "Finished Recording.";
				m_RecordButton.SetWindowText("Record");

#ifndef _DEBUG				//CJC Causes Debug Assertion---> Haven't figureed out why
							// except for clues just after line 884 in WINCORE.CPP
				UpdateData(FALSE);	// NB: without this call, "Finished Recording" doesn't display
#endif

				// So instead, post a custom Windows message handled
				// by a function solely to Update dialog box Data:
				PostMessage(WM_UPDATEDLG);	// maps to OnUpdatedlg()   CJC 4-07-05

				MessageBeep(MB_ICONASTERISK);

				fclose(fp);

			   //PostMessage(WM_RECORDEND);			  				
			} 
			else 
			{
		
				recordFrameRate=m_nRecordedCount/(m_dTime - recTime);
				sprintf(str,"REC  %.3lf sec.  FPS: %.2lf", m_dTime - recTime, recordFrameRate);
				DrawText(&m_GraphicContext, 0, 0, str, boxColor);

				if (recordFrameRate < frames_per_second) 
				{		
					// time is up, write the frame
					DataArray->AccessData((void**) &framePtr);
	
					fwrite(&m_dTime, sizeof(m_dTime), 1, fp);
					fwrite(framePtr, IMAGEX*IMAGEY, 1, fp);

					if (ferror(fp))
						PostMessage(WM_RECORDERROR);

					DataArray->UnaccessData();
					
					m_nRecordedCount++;
				
				}
			}

				
		}
				

   }

   if (! m_bKillProcessing)
   {
     // Wait for the last grab end and stop the timer.
      m_Digitizer.GrabWait(mGrabEnd);

     // Get the time elapsed in processing loop
      m_dTime = m_Application.GetTimer().Read();
   }

   // Destroy the arrays
   DataArray->Destroy();   
   DispArray->Destroy();
   mxFreeMatrix(DataMatrix);
   mxFreeMatrix(OldMatrix);
   mxFreeMatrix(DiffMatrix);
   mxFreeMatrix(EmptyMatrix);


}

/////////////////////////////////////////////////////////////////////////////
// OnProcessingWorkFunctionEnd message handler
// This function handles WM_PROCESSINGWORKFUNCTIONEND custom Windows message
// posted by the processing thread control function at end of processing
//
LONG CExampleDlg::OnProcessingWorkFunctionEnd( UINT, LONG )
{
   // Print statistics
   if (! m_bKillProcessing)
   {
      // Reenable Next button
      m_QuitButton.EnableWindow(TRUE);

	  m_strCommentText.Format("%ld frames grabbed, at a frame rate of %.2f frames/sec (%.2f ms/frame). "
		         "Click Quit to end. ",
			      m_nProcessingCount, 
				  m_nProcessingCount / m_dTime, 
				  1000.0 * m_dTime / m_nProcessingCount);


	  m_threadEnded=TRUE;
      UpdateData(FALSE);
   } else
	   EndDialog(IDOK);
	
   // Return the answer
   return 0;
}

/////////////////////////////////////////////////////////////////////////////
// OnClose message handler
// Here in case the thread is running while the program exists.
// Instructs the thread to exit unconditionally at the first chance.
void CExampleDlg::OnClose() 
{
	if (m_threadEnded)
		CDialog::OnClose();
	// Instruct the processing thread to terminate if necessary
	m_bKillProcessing = TRUE;

	// CJC 4-04-05 I *hope* this is the right spot for dumping the <CTRL-ALT>l hot key...
	UnregisterHotKey(this->m_hWnd, 100);

	SaveParam();
}

/////////////////////////////////////////////////////////////////////////////
// 
// Quit Button Handler 
//
void CExampleDlg::OnQuitbutton() 
{
	// Process request	
	switch (m_nStepCount)
	{
		case 1:
		{
			// Instruct the processing thread to stop its loop
			m_bStopProcessing = TRUE;

	        // Disable Next button and print waiting message
		    m_QuitButton.EnableWindow(FALSE);
			m_strCommentText = "Waiting for processing to complete...  ";

			// Disable all other buttons
			m_RestartButton.EnableWindow(FALSE);
			m_ImageButton.EnableWindow(FALSE);
			m_AutoButton.EnableWindow(FALSE);
			m_UpButton.EnableWindow(FALSE);
			m_DownButton.EnableWindow(FALSE);
		    m_LeftButton.EnableWindow(FALSE);
		    m_RightButton.EnableWindow(FALSE);
		    m_RightButton.EnableWindow(FALSE);
			m_HomeButton.EnableWindow(FALSE);
			m_HomeResetButton.EnableWindow(FALSE);
			m_HomeResetLabel.EnableWindow(FALSE);
			m_RecordButton.EnableWindow(FALSE);
			m_Slider.EnableWindow(FALSE);         

			SaveParam();
			// To be continued in OnProcessingWorkFunctionEnd...
			break;
		}

		case 2:
		{	
			// Close dialog application		 
			EndDialog(IDOK);
			break;
		}
	}

	// Increments the step counter and updates text in the dialog 
	m_nStepCount++;
	
	UpdateData(FALSE);
}

/////////////////////////////////////////////////////////////////////////////
// 
// Restart Button Handler 
//
void CExampleDlg::OnRestartbutton() 
{
   m_strCommentText = "Restarting the process";

   m_restart = 1;	

   UpdateData(FALSE);
}

/////////////////////////////////////////////////////////////////////////////
// 
// Image Button Handler 
//
void CExampleDlg::OnImagebutton() 
{
   if( m_image )
   {
	  m_strCommentText = "Displaying the difference";

	  m_ImageButton.SetWindowText("Display Image");

	  m_image = 0;
   }
   else
   {
	  m_strCommentText = "Displaying the image";

	  m_ImageButton.SetWindowText("Display Difference");

	  m_image = 1;	
   }

   UpdateData(FALSE);
}

/////////////////////////////////////////////////////////////////////////////
// 
// Up Button Handler 
//
void CExampleDlg::OnUpbutton() 
{
   int mag = m_Slider.GetPos()-1;

   m_restart = m_restart + WAIT[mag];	//WAS (still same as) m_Slider.GetPos()-1

// CJC 3-01-06   if( table->MoveRel(0, SPP[mag] * MOVEY) )
   if( table->MoveRel(0, SPP[mag] * MOVEY * YDirection) )
	   m_strCommentText = "Scrolling Up ...";
   else
	   m_strCommentText = "Unable to send command\r";
   
   UpdateData(FALSE);		
}

/////////////////////////////////////////////////////////////////////////////
// 
// Down Button Handler 
//
void CExampleDlg::OnDownbutton() 
{
   int mag = m_Slider.GetPos()-1;

   m_restart = m_restart + WAIT[mag];

// CJC 3-01-06   if( table->MoveRel(0, -SPP[mag] * MOVEY) )
   if( table->MoveRel(0, -SPP[mag] * MOVEY * YDirection) )
	   m_strCommentText = "Scrolling Down ...";
   else
	   m_strCommentText = "Unable to send command\r";
   
   UpdateData(FALSE);	
}

/////////////////////////////////////////////////////////////////////////////
// 
// Left Button Handler 
//
void CExampleDlg::OnLeftbutton() 
{
   int mag = m_Slider.GetPos()-1;

   m_restart = m_restart + WAIT[mag];

// CJC 3-01-06   if( table->MoveRel(SPP[mag] * MOVEX, 0) )
   if( table->MoveRel(SPP[mag] * MOVEX * XDirection, 0) )
	   m_strCommentText = "Scrolling Left ...";
   else
	   m_strCommentText = "Unable to send command\r";
   
   UpdateData(FALSE);				
}

/////////////////////////////////////////////////////////////////////////////
// 
// Right Button Handler 
//
void CExampleDlg::OnRightbutton() 
{
   int mag = m_Slider.GetPos()-1;

   m_restart = m_restart + WAIT[mag];

// CJC 3-01-06   if( table->MoveRel(-SPP[mag] * MOVEX, 0) )
   if( table->MoveRel(-SPP[mag] * MOVEX * XDirection, 0) )
	   m_strCommentText = "Scrolling Right ...";
   else
	   m_strCommentText = "Unable to send command\r";
   
   UpdateData(FALSE);		
}

/////////////////////////////////////////////////////////////////////////////
// 
// Auto Tracking Button Handler 
//
void CExampleDlg::OnAutobutton() 
{
   if( m_track )
   {
//	  m_strCommentText = "Disabled tracking";
//	  m_strCommentText.Format("Disabled tracking (Mag = %d)", MAGS[m_Slider.GetPos()-1]);
	  m_strCommentText.Format("Tracking disabled (Mag = %dx)", MAGS[m_Slider.GetPos()-1]);

	  m_UpButton.EnableWindow(TRUE);
	  m_DownButton.EnableWindow(TRUE);
	  m_LeftButton.EnableWindow(TRUE);
	  m_RightButton.EnableWindow(TRUE);
	  m_HomeButton.EnableWindow(TRUE);
	  m_HomeResetButton.EnableWindow(TRUE);
	  m_HomeResetLabel.EnableWindow(TRUE);
	  m_Slider.EnableWindow(TRUE);
	  m_AutoButton.SetWindowText("Enable Tracking");

	  m_track = 0;
   }
   else
   {
//	  m_strCommentText.Format("Enabled tracking (Mag = %d)", MAGS[m_Slider.GetPos()-1]);
	  m_strCommentText.Format("Tracking (Mag = %dx)", MAGS[m_Slider.GetPos()-1]);

	  m_UpButton.EnableWindow(FALSE);
	  m_DownButton.EnableWindow(FALSE);
	  m_LeftButton.EnableWindow(FALSE);
	  m_RightButton.EnableWindow(FALSE);
	  m_HomeButton.EnableWindow(FALSE);
	  m_HomeResetButton.EnableWindow(FALSE);
	  m_HomeResetLabel.EnableWindow(FALSE);
	  m_Slider.EnableWindow(FALSE);
	  m_AutoButton.SetWindowText("Disable Tracking");	  

	  m_track = 1;
   }

   UpdateData(FALSE);
}

/////////////////////////////////////////////////////////////////////////////
// 
// Home Button Handler 
//
void CExampleDlg::OnHomeButton() 
{
   if( table->Home() )
	   m_strCommentText = "Moving stage to Home position ...";
   else
	   m_strCommentText = "Unable to send command\r";
   
   UpdateData(FALSE);		
	
}

/////////////////////////////////////////////////////////////////////////////
// 
// HomeReset Button Handler 
//
void CExampleDlg::OnHomeresetbutton() 
{
   if( table->HomeReset() )
	   m_strCommentText = "Resetting stage Home position ...";
   else
	   m_strCommentText = "Unable to send command\r";
   
   UpdateData(FALSE);		
	
}

void CExampleDlg::OnRecbutton() 
{
	
	if( record == 0 )
	{
	
		CFileDialog dlg(FALSE, _T("dat"), _T("*.dat"),OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT, 
			_T("DAT files (*.dat)|*.dat|All files (*.*)|*.*||"));

		if(dlg.DoModal() == IDOK) 
		{
			record_filename = dlg.GetPathName();
			fp=fopen(record_filename, "wb");
		
			unsigned int dimx=IMAGEX, dimy=IMAGEY;
			
			// write image dimension
			fwrite(&dimx, sizeof(unsigned int), 1, fp);
			fwrite(&dimy, sizeof(unsigned int), 1, fp);

			m_RecordButton.SetWindowText("Stop Rec");
			m_strCommentText = "Recording.";			
			// set the starting record time
			recTime=m_dTime;
			record = 1;
			m_nRecordedCount=0;
		}
	}
	else
	{
   
		record = 0;
		m_RecordButton.SetWindowText("Record");
		m_strCommentText = "Finished Recording.";

		fclose(fp);
	}
	   
   UpdateData(FALSE);
}


void CExampleDlg::OnDeltaposSpin1(NMHDR* pNMHDR, LRESULT* pResult)	// frames/sec spinner
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;
	int local_ipos = pNMUpDown->iPos;
	int local_idelta = pNMUpDown->iDelta;
	
	if (pNMHDR->idFrom != IDC_SPIN1) return;
	// TODO: Add your control notification handler code here
  
	if (((local_ipos + local_idelta) > FPS_MAX) ||
		((local_ipos + local_idelta) < FPS_MIN))
		return;
	
 	frames_per_second = local_ipos + local_idelta;
    m_fps_display = local_ipos + local_idelta;
    UpdateData(FALSE);
	*pResult = 0;
}


/*void CExampleDlg::OnDeltaposSpin2(NMHDR* pNMHDR, LRESULT* pResult) // Delay spinner
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;
	int local_ipos = pNMUpDown->iPos;
	int local_idelta = pNMUpDown->iDelta;
	
	if (pNMHDR->idFrom != IDC_SPIN2) return;
	// TODO: Add your control notification handler code here
	
	if (((local_ipos + local_idelta) > UPDATE_DELAY_MAX) ||
		((local_ipos + local_idelta) < UPDATE_DELAY_MIN))
		return;
	
 	//frames_per_second = local_ipos + local_idelta;
    m_updateDelay = local_ipos + local_idelta;
    UpdateData(FALSE);
	*pResult = 0;
}
*/

/*void CExampleDlg::OnKillfocusEdit1() 
{
	// TODO: Add your control notification handler code here
	if m_fps_display.GetModify()
	{
		if(	(m_fps_display > FPS_MAX) ||
			(m_fps_display < FPS_MIN)	)		// outside of acceptable range
		{
			m_fps_display = m_spinner.GetPos();
			frames_per_second = m_spinner.GetPos();
			return;
		}
		else
		{
			//
			m_spinner.SetPos(m_fps_display);
			frames_per_second = m_fps_display;
		}
}
*/


BEGIN_EVENTSINK_MAP(CExampleDlg, CDialog)
    //{{AFX_EVENTSINK_MAP(CExampleDlg)
	ON_EVENT(CExampleDlg, IDC_DISPLAY, -605 /* MouseDown */, OnMouseDownDisplay, VTS_I2 VTS_I2 VTS_I4 VTS_I4)
	//}}AFX_EVENTSINK_MAP
END_EVENTSINK_MAP()


/*
void CExampleDlg::OnReleasedcaptureSlider1(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_brightnessEdit.SetWindowText(_itoa(m_brightness.GetPos(), buf, 10));

	_variant_t Brightness(static_cast<long>(m_brightness.GetPos()), VT_I4); 
	m_Digitizer.Control(digBrightness, Brightness);

//	m_Digitizer.SetBrightness(m_brightness.GetPos());
	*pResult = 0;
}
*/

/*void CExampleDlg::OnReleasedcaptureSlider2(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_gainEdit.SetWindowText(_itoa(m_gain.GetPos(), buf, 10));

	m_Digitizer.SetInputGain(m_gain.GetPos());
	*pResult = 0;
}
*/

void CExampleDlg::OnRecordError(UINT, LONG)
{
	OnRecbutton();

	AfxMessageBox("Recording Error: Disk Full!  ");

}

/*void CExampleDlg::OnChangeEdit2() 
{

	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here	
	char buf[10];
	m_brightnessEdit.GetLine(0, buf);
	m_brightness.SetPos(atoi(buf));

	_variant_t Brightness(static_cast<long>(atoi(buf)), VT_I4); // or try static_cast<long>(atoi(buf))???// CJC 12-13-05 _variant_t Brightness(static_cast<long>(IMG_BRIGHTNESS), VT_I4); 
//THIS ONE WORKS!--->	_variant_t Brightness(static_cast<long>(m_brightness.GetPos()), VT_I4); // or try static_cast<long>(atoi(buf))???// CJC 12-13-05 _variant_t Brightness(static_cast<long>(IMG_BRIGHTNESS), VT_I4); 
	m_Digitizer.Control(digBrightness, Brightness);
//	m_Digitizer.SetBrightness(m_brightness.GetPos());
}
*/

/*void CExampleDlg::OnChangeEdit3() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	m_gainEdit.GetLine(0, buf);
	m_gain.SetPos(atoi(buf));
	m_Digitizer.SetInputGain(m_gain.GetPos());

}
*/


/*
void CExampleDlg::OnReleasedcaptureSlider3(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_diffThresholdEdit.SetWindowText(_itoa(m_diffThreshold.GetPos(), buf, 10));

	*pResult = 0;
}
*/

/*void CExampleDlg::OnChangeEdit4() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	m_diffThresholdEdit.GetLine(0, buf);
	m_diffThreshold.SetPos(atoi(buf));

}
*/

void CExampleDlg::OnReleasedcaptureMagSlider(NMHDR* pNMHDR, LRESULT* pResult) 
{	// TODO: Add your control notification handler code here
//	char buf[10];
//	m_sliderEdit.SetWindowText(_itoa(m_Slider.GetPos(), buf, 10));
  m_strMagnification.Format(" %d X", MAGS[m_Slider.GetPos()-1]);
//  m_strCommentText.Format("Disabled tracking (Mag = %d)", MAGS[m_Slider.GetPos()-1]);
    UpdateData(FALSE);

	*pResult = 0;
}

void CExampleDlg::OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar) 
{
/*
	// TODO: Add your message handler code here and/or call default
		
	char buf[10];
	CSliderCtrl *ctrl=(CSliderCtrl*) pScrollBar;
	CEdit *edit=(CEdit*) ctrl->GetBuddy(FALSE);

	if (edit) {
		edit->SetWindowText(_itoa(ctrl->GetPos(), buf, 10));

		_variant_t Brightness(static_cast<long>(m_brightness.GetPos()), VT_I4); 
		m_Digitizer.Control(digBrightness, Brightness);
//		m_Digitizer.SetBrightness(m_brightness.GetPos());

		m_Digitizer.SetInputGain(m_gain.GetPos());

	}

	CDialog::OnHScroll(nSBCode, nPos, pScrollBar);
*/
}



void CExampleDlg::OnMouseDownDisplay(short Button, short Shift, long x, long y) 
{
//	if ((Button & MK_LBUTTON) && (Shift & 2)) {
	if ((Button & MK_LBUTTON) && (Shift & CTRL_KEY)) {
		int mag = m_Slider.GetPos()-1;

		if (m_isCalibrating) {
//			long distance;	
			double distance;	// taking distance as a double forces the mm/pixel calculation to be a double
			distance=sqrt((m_startx-x)*(m_startx-x)+(m_starty-y)*(m_starty-y));

			CString str;
//			str.Format("Pixel distance measured: %d\n\nNumber of steps the table has moved: %d\n\nSteps per pixel calculated: %d\n\nmm per pixel calculated: %f", 
//						distance, SPP[mag] * MOVEX, (int) (SPP[mag] * MOVEX/ distance),
//						(SPP[mag] * MOVEX/ distance)*MM_PER_STEP);

//			str.Format("mag position: %d\nSPP[mag]: %d\nMOVEX: %d\nMM_PER_STEP: %f\n\nPixel distance measured: %d\n\nNumber of steps the table has moved: %d\n\nSteps per pixel calculated: %d\n\nmm per pixel calculated: %f", 
			str.Format("mag position: %d\nSPP[mag]: %d\nMOVEX: %d\nMM_PER_STEP: %f\n\nPixel distance measured: %f\n\nNumber of steps the table has moved: %d\n\nSteps per pixel calculated: %d\n\nmm per pixel calculated: %f", 
						mag, SPP[mag], MOVEX, MM_PER_STEP,		
						distance, SPP[mag] * MOVEX, (int) (SPP[mag] * MOVEX/ distance),
						(SPP[mag] * MOVEX/ distance) * MM_PER_STEP);
//						( (float) SPP[mag] * (float) MOVEX/ (float) distance) * (float) MM_PER_STEP);
			
			if (MessageBox(str, "Calibration", MB_OKCANCEL)==IDOK) {
				stepsPerPixel=(long) (SPP[mag] * MOVEX/ distance);
				// Make this number persistent, serialize to disk
				SaveParam();
			}


			m_isCalibrating=false;
		} else {
			m_startx=x;
			m_starty=y;
			//DrawBox(&m_GraphicContext, m_startx, m_starty, 2, 2, 255);
			
			//move the table
// CJC 3-01-06 WAS			if( table->MoveRel(SPP[mag] * MOVEX, 0) )
			if( table->MoveRel(SPP[mag] * MOVEX * XDirection, 0) )
				m_strCommentText = "Scrolling Left ...";
			else
				m_strCommentText = "Unable to send command\r";
   
			UpdateData(FALSE);	

			m_isCalibrating=true;
		}
	}	
}



void CExampleDlg::OnAutoshut() 
{
	// TODO: Add your control notification handler code here
	if (m_autoShutOffCheck.GetCheck()) {
		m_autoShutOffSpinner.EnableWindow(TRUE);
		m_autoShutOffLabel.EnableWindow(TRUE);
		m_autoShutOffEdit.EnableWindow(TRUE);
	} else {
		m_autoShutOffSpinner.EnableWindow(FALSE);
		m_autoShutOffLabel.EnableWindow(FALSE);
		m_autoShutOffEdit.EnableWindow(FALSE);
	}
	UpdateData(FALSE);
}

void CExampleDlg::LoadParam()
{
	int tmp;
//	char buf[10];

	CFile file;
	if (file.Open(_T("program.data"), CFile::modeRead)) 
	{
		// Remember where params.data file came from (should be from
		// same directory where .exe was)
		m_csProgramdataFilePath = file.GetFilePath();	


		CArchive ar (&file, CArchive::load);
		try 
		{
			ar >> stepsPerPixel;

//			ar >> tmp;
//			m_brightness = tmp;	// WAS m_brightness.SetPos(tmp);
//			m_brightnessEdit.SetWindowText(_itoa(tmp, buf, 10));
////			m_brightnessEdit.SetWindowText(_itoa(m_brightness.GetPos(), buf, 10));

//			ar >> tmp;
//			m_gain.SetPos(tmp);
//			m_gainEdit.SetWindowText(_itoa(m_gain.GetPos(), buf, 10));

			ar >> m_diffThresholdValue;
//			m_diffThreshold.SetPos(tmp);
//			m_diffThresholdEdit.SetWindowText(_itoa(m_diffThreshold.GetPos(), buf, 10));

			ar >> tmp;
			m_Slider.SetPos(tmp);		// magnification slider position
   
		    ar >> tmp;
			m_spinner.SetPos(tmp);		// frames per second spinner control
			m_fps_display = tmp;
			frames_per_second = tmp;

			ar >> m_updateDelayValue;	// CJC 2-20-06
// CJC 2-20-06			ar >> tmp;
// CJC 2-20-06			m_updateDelaySpinner.SetPos(tmp);	// update delay
// CJC 2-20-06			if (tmp)
// CJC 2-20-06				m_updateDelay=tmp;
// CJC 2-20-06			else
// CJC 2-20-06				m_updateDelay=5;	//CJC 3-15-05 -- must be non-zero to prevent divide-by-zero run-time error

			ar >> tmp;
		    m_autoShutOffSpinner.SetPos(tmp);	// auto shutoff spinner (# seconds)

			ar >> tmp;
			m_autoShutOffCheck.SetCheck(tmp);	// auto shutoff check state

//			ar >> locationcode;		// CJC 4-04-05	// location code
			ar >> stagestyle;			// Code indicating syntax to use for stage move commands

			ar >> ReverseStageState.reverseX;	// Flags indicating reverse X stage direction
			ar >> ReverseStageState.reverseY;	// Flags indicating reverse X stage direction


			ar >> PreviousCameraSN;		// saved as long

			if (PreviousCameraSN == CurrentCameraSN)
			{
				// Populate AutoExposureState structure only if re-using same camera
				ar >> AutoExposureState.brightnessCheck; 
				ar >> AutoExposureState.gainCheck;
				ar >> AutoExposureState.shutterCheck;
				ar >> AutoExposureState.autoExposureCheck;
				ar >> AutoExposureState.gammaCheck;
				ar >> AutoExposureState.sharpnessCheck;
			}
		} 
		catch (CArchiveException e) 
		{
		} 
		catch ( CFileException e) 
		{
		}

		file.Close();
	}	  
	else	// if file-open operation unsuccessful...
	{
		char buf[255];

		// Prompt user for location code:
			// Initialize Locationselector dialog
//		locationDlg = new CLocationDlg;
//		locationDlg->DoModal();

		stagestyleDlg = new CStageStyle;
		stagestyleDlg->DoModal();


		AfxMessageBox(
			"Don't forget to calibrate! \n"
			"\n"
			"To calibrate: \nHold the 'Ctrl' key and use the mouse to left-click on a fixed feature toward the right side of the Tracker display.\n"
			"After the stage shifts, click on the same feature, again while holding the 'Ctrl' key.\n"
			"\n"
			"Re-calibration should not be necessary, but can be repeated at any time using the same procedure."
			);

		// Remember path to Current Directory for SaveParam()
		if(GetCurrentDirectory(255, buf))
		{
			//AfxMessageBox("Successfully found current directory");
			//AfxMessageBox(buf);

			m_csProgramdataFilePath = buf; 
			m_csProgramdataFilePath += "\\program.data";	// Concatenate file name onto current directory path
		}
		else
		{
			AfxMessageBox("Sorry, the Current Directory is inaccessible so Recognizer will not be able to archive customizations.");
			return;
		}
	}


}

void CExampleDlg::SaveParam()
{
	
	CFile file;
//	if (file.Open(_T("program.data"), CFile::modeReadWrite| CFile::modeCreate)) {
	if (file.Open(m_csProgramdataFilePath, CFile::modeReadWrite| CFile::modeCreate)) 
	{
#ifdef _DEBUG
	int breakpointfodder;	// This is a place where I can 
	breakpointfodder = 0;	// insert a breakpoint for debugging
#endif



		CArchive ar (&file, CArchive::store);		
		ar << stepsPerPixel;
// Save in Camera		ar << m_brightness;		// WAS ar << m_brightness.GetPos();
// Save in Camera		ar << m_gain.GetPos();

		ar << m_diffThresholdValue;	// converted to int; WAS ar << m_diffThreshold.GetPos();
		ar << m_Slider.GetPos();	// Magnification (slider position)
		ar << m_spinner.GetPos();	// Frames per second (spinner position)
		ar << m_updateDelayValue;	// WAS m_updateDelaySpinner.GetPos();
		ar << m_autoShutOffSpinner.GetPos();
		ar << m_autoShutOffCheck.GetCheck();

		ar << stagestyle;			// Code indicating syntax to use for stage move commands
									//   (replaces location code in earlier versions)
		
		ar << ReverseStageState.reverseX;	// Flags indicating reverse X stage direction
		ar << ReverseStageState.reverseY;	// and Y stage direction

		ar << CurrentCameraSN;	// save as type long

		ar << AutoExposureState.brightnessCheck; 
		ar << AutoExposureState.gainCheck;
		ar << AutoExposureState.shutterCheck;
		ar << AutoExposureState.autoExposureCheck;
		ar << AutoExposureState.gammaCheck;
		ar << AutoExposureState.sharpnessCheck;

// Change this to stagestyle		ar << locationcode;
		ar.Flush();
		file.Close();
		
	}

}


/* WAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
void CExampleDlg::SaveParam()
{
	
	CFile file;
//	if (file.Open(_T("program.data"), CFile::modeReadWrite| CFile::modeCreate)) {
	if (file.Open(m_csProgramdataFilePath, CFile::modeReadWrite| CFile::modeCreate)) 
	{
		CArchive ar (&file, CArchive::store);		
		ar << stepsPerPixel;
		ar << m_brightness;		// WAS ar << m_brightness.GetPos();
		ar << m_gain.GetPos();
		ar << m_diffThreshold.GetPos();
		ar << m_Slider.GetPos();	// Magnification (slider position)
		ar << m_spinner.GetPos();	// Frames per second (spinner position)
		ar << m_updateDelaySpinner.GetPos();
		ar << m_autoShutOffSpinner.GetPos();
		ar << m_autoShutOffCheck.GetCheck();
		ar << locationcode;
		ar.Flush();
		file.Close();
		
	}

}
WAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/


LRESULT CExampleDlg::OnHotKey(WPARAM wparam, LPARAM lparam)
{
	// Initialize Locationselector dialog
	locationDlg = new CLocationDlg;
//	locationDlg->Create(IDD_LOCATIONSELECTOR);	// CJC 8-29-06 Temporay
//	locationDlg->ShowWindow(SW_SHOW);	// CJC 8-29-06 Temporay
	locationDlg->DoModal();

	return 0;
}


void CExampleDlg::OnUpdatedlg()		// CJC 4-07-05 message handler to force dialog data update
{
	UpdateData(FALSE);
}


void CExampleDlg::CalculateStageDirections(void)
{
	XDirection = 1-( ReverseStageState.reverseX * 2);	// Calculate multiplier to set positive direction
	YDirection = 1-( ReverseStageState.reverseY * 2);	// Calculate multiplier to set positive direction

}



void CExampleDlg::OnSettingsDialog() 
{
	// TODO: Add your control notification handler code here

	// Disable Settings button
	m_SettingsDialogButton.EnableWindow(FALSE);

	// Initialize Settings dialog
	settingsDlg = new CSettingsDlg;

	settingsDlg->passDigitizerHandle(&m_Digitizer);
	settingsDlg->passAutoExposureState(&AutoExposureState);
	settingsDlg->passReverseStageState(&ReverseStageState, &XDirection, &YDirection);
// CJC 3-01-05 WAS	settingsDlg->passReverseStageState(&ReverseStageState);
	settingsDlg->passDiffThresholdValue(&m_diffThresholdValue);
	settingsDlg->passUpdateDelayValue(&m_updateDelayValue);


//CJC 9-08-06// CButton* pButton = (CButton*)GetDlgItem(ID_BUTTON1); 
//CJC 9-08-06	CButton* pButton = (CButton*)GetDlgItem(IDC_SETTINGS_DIALOG); 
//CJC 9-08-06	settingsDlg->passSettingsDialogButtonHandle(&m_SettingsDialogButton);
//CJC 9-08-06	settingsDlg->passSettingsDialogButtonHandle(pButton;

// CJC 9-05-06	settingsDlg->passStageStyle(&stagestyle);	// CJC 8-30-06 Adding

	//Create modal dialog for now - later change to Modeless dialog box
//	settingsDlg->DoModal();

	// the Modeless version:
	settingsDlg = new CSettingsDlg;
	settingsDlg->Create(IDD_SETTINGS);	// CJC 8-29-06
	settingsDlg->ShowWindow(SW_SHOW);	// CJC 8-29-06

	
}
