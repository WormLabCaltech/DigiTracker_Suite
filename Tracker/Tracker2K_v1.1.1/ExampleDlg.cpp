#include "stdafx.h"
#include "ExampleDlg.h"
#include "mex.h"
#include "ExampleImage.h"
#include "ExampleDraw.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define IMAGEX 320					  // size of image x dim
#define IMAGEY 240					  // size of image y dim
#define CENX (IMAGEX / 2)			  // x coord of center
#define CENY (IMAGEY / 2)			  // y coord of center
#define WX 240						  // width of window (220)
#define WY 160						  // height of window (140)	
#define MOVEX 160					  // number of x pixels to move when buttons are pressed
#define MOVEY 120					  // number of y pixels to move when buttons are pressed
#define RECTIME 16					  // minutes to record for

/////////////////////////////////////////////////////////////////////////////
// These are the global parameters
//
int MAGS[4] = {6, 12, 25, 50};		  // different magnification levels
int SPP[4] = {50, 25, 12, 6};		  // different steps per pixel
int WAIT[4] = {60,45,40,40};		  // different waiting periods

// Custom Windows message 
const int WM_PROCESSINGWORKFUNCTIONEND = WM_USER + 1;

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
	ON_BN_CLICKED(IDC_POWERBUTTON, OnPowerbutton)
	ON_BN_CLICKED(IDC_RECBUTTON, OnRecbutton)
	ON_BN_CLICKED(IDC_STARTBUTTON, OnStartbutton)
	ON_BN_CLICKED(IDC_PREVBUTTON, OnPrevbutton)
	ON_MESSAGE(WM_PROCESSINGWORKFUNCTIONEND, OnProcessingWorkFunctionEnd)
	ON_BN_CLICKED(IDC_NEXTBUTTON, OnNextbutton)
	//}}AFX_MSG_MAP
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
	//}}AFX_DATA_INIT

   m_nStepCount = 1;
   m_nProcessingCount = 0;
   m_restart = 90;
   m_track = 0;
   m_image = 1;
}


/////////////////////////////////////////////////////////////////////////////
// CExampleDlg data exchange
//
void CExampleDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CExampleDlg)
	DDX_Control(pDX, IDC_QUITBUTTON, m_QuitButton);
	DDX_Control(pDX, IDC_RESTARTBUTTON, m_RestartButton);
	DDX_Control(pDX, IDC_UPBUTTON, m_UpButton);
	DDX_Control(pDX, IDC_DOWNBUTTON, m_DownButton);
	DDX_Control(pDX, IDC_LEFTBUTTON, m_LeftButton);
	DDX_Control(pDX, IDC_RIGHTBUTTON, m_RightButton);
	DDX_Control(pDX, IDC_AUTOBUTTON, m_AutoButton);
	DDX_Control(pDX, IDC_IMAGEBUTTON, m_ImageButton);
	DDX_Control(pDX, IDC_POWERBUTTON, m_PowerButton);
	DDX_Control(pDX, IDC_STARTBUTTON, m_StartButton);
	DDX_Control(pDX, IDC_PREVBUTTON, m_PrevButton);
	DDX_Control(pDX, IDC_NEXTBUTTON, m_NextButton);
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
	//}}AFX_DATA_MAP
}


/////////////////////////////////////////////////////////////////////////////
// CExampleDlg message handlers
//
BOOL CExampleDlg::OnInitDialog()
{
   CDialog::OnInitDialog();

   // Initialize the table
   table = new Table((int) 1);
   vcr = new VCR((int) 2);
   record = 0;

   // Initialize Slider
   m_Slider.SetRangeMin(1);
   m_Slider.SetRangeMax(4);
   m_Slider.SetPos(3);	

   UpdateData(FALSE);

   // Start processing thread
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

   long nMaxDisplayWidth;
   long nMaxNextStepWidth;
   CRect rectQuitButton;
   CRect rectCommentFrame;
   CRect rectDisplay;
   CRect rectDialog;

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
   m_Display.GetWindowRect(&rectDisplay);
   GetWindowRect(&rectDialog);

   nMaxDisplayWidth  = rectDisplay.Width() + 
                       2 * abs(rectDisplay.left - rectDialog.left);
   nMaxNextStepWidth = rectQuitButton.left - rectDialog.left + 
                       rectQuitButton.Width() + 
                       rectCommentFrame.left - rectDialog.left;
   
   if(nMaxNextStepWidth > nMaxDisplayWidth)
   {
      SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxNextStepWidth,                             // cx
                   rectDisplay.Height() + 
                   abs (rectDisplay.top - rectDialog.top) + 
                   abs (rectDisplay.left - rectDialog.left),      // cy
                   SWP_SHOWWINDOW);								  // flags
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
//		    m_Digitizer.SetBuffer(m_PreviousBuffer);
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
				else
				{
					Update(OldMatrix, DataMatrix, &x, &y, DiffMatrix);
				}

				// Display the image
				if( m_image )
				{
					m_DisplayBuffer.Copy(m_CurrentBuffer, 0);
				}
				else
				{
					MatrixToArray(DispArray, DiffMatrix);
					m_DisplayBuffer.Put(*DispArray, mSingleBand, 0, 0, 0, IMAGEX, IMAGEY);
				}

				// Draw the boxes
				DrawBox(&m_GraphicContext, CENX, CENY, WX, WY);
				if( (x != -1) && (y != -1) )
					DrawBox(&m_GraphicContext, x, y, 30, 30);

				// Recenter the table
				if( m_track )
					if( (x != -1) && (y != -1) )
						if( ((abs(x - CENX) > WX/2) || (abs(y - CENY) > WY/2)) )
						{
						   int mag = m_Slider.GetPos()-1;
						   m_restart = m_restart + WAIT[mag];
						   table->MoveRel((int) (0.60*SPP[mag]*(x - CENX)), (int) (0.60*SPP[mag]*(y - CENY)));
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

		try
		{
			// Start the grab
			m_Digitizer.SetImage(m_CurrentBuffer);
//			m_Digitizer.SetBuffer(m_CurrentBuffer);
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
				else
				{
					Update(OldMatrix, DataMatrix, &x, &y, DiffMatrix);
				}

				// Display the image
				if( m_image )
				{
					m_DisplayBuffer.Copy(m_PreviousBuffer, 0);
				}
				else
				{
					MatrixToArray(DispArray, DiffMatrix);
					m_DisplayBuffer.Put(*DispArray, mSingleBand, 0, 0, 0, IMAGEX, IMAGEY);
				}

				// Draw the boxes
				DrawBox(&m_GraphicContext, CENX, CENY, WX, WY);
				if( (x != -1) && (y != -1) )
					DrawBox(&m_GraphicContext, x, y, 30, 30);				

				// Recenter the table
				if( m_track )
					if( (x != -1) && (y != -1) )
						if( ((abs(x - CENX) > WX/2) || (abs(y - CENY) > WY/2)) )
						{
						   int mag = m_Slider.GetPos()-1;
						   m_restart = m_restart + WAIT[mag];
						   table->MoveRel((int) (0.60*SPP[mag]*(x - CENX)), (int) (0.60*SPP[mag]*(y - CENY)));
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

		// Stop recording
		if( record )
		{
			if( (m_Application.GetTimer().Read() - recTime) > (RECTIME * 60) )
			{
			   char string[255];

			   record = 0;
			   wsprintf(string, "%c%s%c", 0x02, "OSP", 0x03);
			   vcr->Clear();   
			   vcr->Send(string);				
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

      UpdateData(FALSE);
   }

   // Return the answer
   return 0;
}

/////////////////////////////////////////////////////////////////////////////
// OnClose message handler
// Here in case the thread is running while the program exists.
// Instructs the thread to exit unconditionally at the first chance.
void CExampleDlg::OnClose() 
{
	// Instruct the processing thread to terminate if necessary
	m_bKillProcessing = TRUE;

	CDialog::OnClose();
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
	     m_PowerButton.EnableWindow(FALSE);
	     m_StartButton.EnableWindow(FALSE);
	     m_PrevButton.EnableWindow(FALSE);
	     m_NextButton.EnableWindow(FALSE);
		 m_RecordButton.EnableWindow(FALSE);
	     m_Slider.EnableWindow(FALSE);         

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

   m_restart = m_restart + WAIT[m_Slider.GetPos()-1];

   if( table->MoveRel(0, SPP[mag] * MOVEY) )
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

   if( table->MoveRel(0, -SPP[mag] * MOVEY) )
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

   if( table->MoveRel(SPP[mag] * MOVEX, 0) )
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

   if( table->MoveRel(-SPP[mag] * MOVEX, 0) )
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
	  m_strCommentText = "Disabled tracking";

	  m_UpButton.EnableWindow(TRUE);
	  m_DownButton.EnableWindow(TRUE);
	  m_LeftButton.EnableWindow(TRUE);
	  m_RightButton.EnableWindow(TRUE);
	  m_PowerButton.EnableWindow(TRUE);
	  m_StartButton.EnableWindow(TRUE);
	  m_PrevButton.EnableWindow(TRUE);
	  m_NextButton.EnableWindow(TRUE);
	  m_Slider.EnableWindow(TRUE);
	  m_AutoButton.SetWindowText("Enable Tracking");

	  m_track = 0;
   }
   else
   {
	  m_strCommentText.Format("Enabled tracking (Mag = %d)", MAGS[m_Slider.GetPos()-1]);

	  m_UpButton.EnableWindow(FALSE);
	  m_DownButton.EnableWindow(FALSE);
	  m_LeftButton.EnableWindow(FALSE);
	  m_RightButton.EnableWindow(FALSE);
	  m_PowerButton.EnableWindow(FALSE);
	  m_StartButton.EnableWindow(FALSE);
	  m_PrevButton.EnableWindow(FALSE);
	  m_NextButton.EnableWindow(FALSE);
	  m_Slider.EnableWindow(FALSE);
	  m_AutoButton.SetWindowText("Disable Tracking");	  

	  m_track = 1;
   }

   UpdateData(FALSE);
}

void CExampleDlg::OnPowerbutton() 
{
   char string[255];

   record = 0;

   wsprintf(string, "%c%s%c", 0x02, "POW", 0x03);
   vcr->Clear();   
   vcr->Send(string);
	
   m_strCommentText = "Power.";
   UpdateData(FALSE);   	
}

void CExampleDlg::OnStartbutton() 
{
   char string[255];

   wsprintf(string, "%c%s%c", 0x02, "CCL", 0x03);
   vcr->Clear();   
   vcr->Send(string);
	
   m_strCommentText = "Moving to Start.";
   UpdateData(FALSE);   		
}

void CExampleDlg::OnPrevbutton() 
{ 		
}

void CExampleDlg::OnNextbutton() 
{
	int pos = vcr->GetPosition();
	int hrs, min;
    char string[255];

	hrs = (int) (pos / (30 * 60 * 60)); 
	pos = pos - (hrs*60*60*30);

	if( pos < 15*60*30 )
	{
		min = 15;
	}
	else if( pos < 30*60*30 )
	{
		min = 30;
	}
	else if( pos < 45*60*30 )
	{
		min = 45;
	}
	else
	{
		min = 0;
		hrs = hrs + 1;
	}

	wsprintf(string, "%cSPT: %1.1d%2.2d%2.2d%2.2d%c", '\x02', hrs, min, 0, 0, '\x03');
    vcr->Clear();   
    vcr->Send(string);
	
    m_strCommentText.Format("Moving to %d:%02d:00 00", hrs, min);
    UpdateData(FALSE);  

	// Get Status
	do
	{
		vcr->Clear();
		wsprintf(string, "%cQOP%c", '\x02', '\x03');

		if( vcr->Send(string) )		
			vcr->Read(string, 255);
	} while( string[1] == 'S' && string[2] == 'P' && string[3] == 'T' );

	// Stop the VCR
	vcr->Stop();
}

void CExampleDlg::OnRecbutton() 
{
   char string[255];

   if( record == 0 )
   {
	   wsprintf(string, "%c%s%c", 0x02, "ORC", 0x03);
	   vcr->Clear();   
	   if( vcr->Send(string) )
	   {
		   record = 1;
		   recTime = m_Application.GetTimer().Read();
		   m_strCommentText = "Recording.";
	   }
   }
   else
   {
	   wsprintf(string, "%c%s%c", 0x02, "OSP", 0x03);
	   vcr->Clear();   
	   if( vcr->Send(string) )
	   {
		   record = 0;
		   m_strCommentText = "Finished Recording.";
	   }
   }
	   
   UpdateData(FALSE);
}

