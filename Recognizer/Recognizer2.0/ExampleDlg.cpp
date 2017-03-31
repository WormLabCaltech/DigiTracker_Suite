#include "stdafx.h"
#include "ExampleDlg.h"
#include "mex.h"
#include <direct.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

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
int saveimages = 0;
int savepoints = 0;
char pointsname[255] = "points";

char outsubdir[255];

/////////////////////////////////////////////////////////////////////////////
// These are some function prototypes
//

extern void findworm(Matrix *im, 
					 Matrix **center, Matrix **bndry, 
		             Matrix **spn, Matrix **pts);

extern void drawworm(CGraphicContext *gc, void *center, void *bndry, void *spn, void *pts);
extern void save(Matrix *pts);

// Custom Windows message 
const int WM_PROCESSINGWORKFUNCTIONEND = WM_USER + 1;

BEGIN_MESSAGE_MAP(CExampleDlg, CDialog)
	//{{AFX_MSG_MAP(CExampleDlg)
	ON_WM_CLOSE()
	ON_MESSAGE(WM_PROCESSINGWORKFUNCTIONEND, OnProcessingWorkFunctionEnd)
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
	//}}AFX_DATA_INIT

   m_nStepCount = 1;
   m_nProcessingCount = 0;
}


/////////////////////////////////////////////////////////////////////////////
// CExampleDlg data exchange
//
void CExampleDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CExampleDlg)
	DDX_Control(pDX, IDC_DISPLAY, m_Display);
	DDX_Control(pDX, IDC_DIGITIZER, m_Digitizer);
	DDX_Control(pDX, IDC_SYSTEM, m_System);
	DDX_Control(pDX, IDC_APPLICATION, m_Application);
	DDX_Control(pDX, IDC_DISPLAY_BUFFER, m_DisplayBuffer);
	DDX_Control(pDX, IDC_CURRENT_BUFFER, m_CurrentBuffer);
	DDX_Control(pDX, IDC_PREVIOUS_BUFFER, m_PreviousBuffer);
	DDX_Control(pDX, IDC_EMPTY_BUFFER, m_EmptyBuffer);
	DDX_Control(pDX, IDC_GRAPHICCONTEXT_1, m_GraphicContext1);
	DDX_Control(pDX, IDC_GRAPHICCONTEXT_2, m_GraphicContext2);
	//}}AFX_DATA_MAP
}

BOOL ReadGlobals()
{
	FILE *fp;

	fp = fopen("C:\\WINNT\\Profiles\\saleem\\Desktop\\params.txt", "r");

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

/////////////////////////////////////////////////////////////////////////////
// CExampleDlg message handlers
//
BOOL CExampleDlg::OnInitDialog()
{
   CDialog::OnInitDialog();

	// Resize the dialog 
//   AdjustDialog();

   // Initialize the VCR
   vcr = new VCR(2);

   // Read in the global parameters
   ReadGlobals();

   UpdateData(FALSE);	
   
   m_bStopProcessing = FALSE;
   m_bKillProcessing = FALSE;
   AfxBeginThread(ProcessingThreadFunction, this);

   // Return the answer
   return TRUE;  
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
   int count = 1;
   FILE *fp;
   int hrs, min, sec, frm, leng;

   // open the index file
   fp = fopen("C:\\WINNT\\Profiles\\saleem\\Desktop\\index.txt", "r");

   if( fp != NULL )
   {
	  int status;

	  status = fscanf(fp, "%d:%d:%d:%d %d\n", &hrs, &min, &sec, &frm, &leng);
	  while( (!m_bStopProcessing) && (!m_bKillProcessing) && (status != EOF) )
	  {
		// create an output directory
	    sprintf(outsubdir, "%s\\worm%d", outdir, count);
		_mkdir(outsubdir);			

	    // goto the desired position
	    vcr->Goto(1, hrs, min, sec, frm);

  	    // play the vcr
	    vcr->Play();
      
	    // start processing images
	    this->ProcessingWorkFunctionHelper(leng);

	    // get the time elapsed in processing loop
	    vcr->Stop();	

		// increment counter
		count = count + 1;

	    // scan in the next entry
	    status = fscanf(fp, "%d:%d:%d:%d %d\n", &hrs, &min, &sec, &frm, &leng);
	  }
   }

   // close the index file
   fclose(fp);
}

void 
CExampleDlg::ProcessingWorkFunctionHelper(int leng)
{
   DWORD dim[2];
   int x, y;
   int PreviousSuccess = 0, CurrentSuccess = 0;
   Matrix *PreviousImageMat = NULL;
   Matrix *CurrentImageMat = NULL;
	   
   COleSafeArray *empty = new COleSafeArray();
   COleSafeArray *PreviousImageArray = new COleSafeArray();
   COleSafeArray *CurrentImageArray = new COleSafeArray();

   int counter = 1;
   char imagename[255];

   // Allocate the arrays
   dim[0] = 640; dim[1] = 480;
   empty->Create(VT_I1, (DWORD) 2, dim); 

   PreviousImageArray->Create(VT_I1, (DWORD) 2, dim);
   CurrentImageArray->Create(VT_I1, (DWORD) 2, dim);

   PreviousImageMat = mxCreateFull(480, 640, INT);	
   CurrentImageMat = mxCreateFull(480, 640, INT);

   // Initialize to all zeros
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
   m_EmptyBuffer.Put(*empty, mSingleBand, 0, 0, 0, 640, 480);
   m_DisplayBuffer.Copy(m_EmptyBuffer, 0);

   // start the timer
   m_Application.GetTimer().Reset();

   // Process one buffer while grabbing the other
   while ( (!m_bStopProcessing) && (!m_bKillProcessing) && (m_Application.GetTimer().Read() <= leng*60) )
   {
		try
		{
			// Start the grab
		    m_Digitizer.SetBuffer(m_PreviousBuffer);
			m_Digitizer.Grab();

			// Process the current buffer
			if( CurrentSuccess )
			{
				// now tranfer data into an array
				m_CurrentBuffer.Get(*CurrentImageArray, mSingleBand, 0, 0, 0, 640, 480);

				// now transfer data from array to matrix
				ArrayToMatrix(CurrentImageArray, CurrentImageMat);

				// process the image
				{
					// Initialize variables			
				    Matrix *center = NULL, *bndry = NULL, *spn = NULL, *pts = NULL;
	
					// process the matrix 
					findworm(CurrentImageMat, 
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
							m_CurrentBuffer.Save(imagename);
						}
					}

					// now draw the worm	
					drawworm(&m_GraphicContext1, center, bndry, spn, pts);

					// increment counter
					counter = counter + 1;

					// free all allocated memory
					mxFreeMatrix(center); mxFreeMatrix(bndry); mxFreeMatrix(spn); mxFreeMatrix(pts);
				}

				// display the image
				m_DisplayBuffer.Copy(m_CurrentBuffer, 0);
			}

			// Increment counter
			m_nProcessingCount++;

			// Set successful flag
			PreviousSuccess = 1;
		} 
		catch( COleDispatchException *e )
		{
			// Get rid of the error message
			e->Delete();

			// Set failure flag
			PreviousSuccess = 0;

			// Display the blank image
			m_DisplayBuffer.Copy(m_EmptyBuffer, 0);
		}

		try
		{
			// Start the grab
			m_Digitizer.SetBuffer(m_CurrentBuffer);
			m_Digitizer.Grab();

			// Process the previous image
			if( PreviousSuccess )
			{			
				// now tranfer data into an array
				m_PreviousBuffer.Get(*PreviousImageArray, mSingleBand, 0, 0, 0, 640, 480);

				// now transfer data from array to matrix
				ArrayToMatrix(PreviousImageArray, PreviousImageMat);

				// process the image
				{
					// Initialize variables	
					Matrix *center = NULL, *bndry = NULL, *spn = NULL, *pts = NULL;

					// process the matrix 
					findworm(PreviousImageMat, 
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
							m_PreviousBuffer.Save(imagename);
						}
					}

					// now draw the worm
					drawworm(&m_GraphicContext2, center, bndry, spn, pts);

					// increment counter
					counter = counter + 1;

					// free all allocated memory
					mxFreeMatrix(center); mxFreeMatrix(bndry); mxFreeMatrix(spn); mxFreeMatrix(pts);	
				}				

				// display the image
				m_DisplayBuffer.Copy(m_PreviousBuffer, 0);
			}

			// Increment counter
			m_nProcessingCount++;

			// Set successful flag
			CurrentSuccess = 1;
		}
		catch( COleDispatchException *e )
		{
			// Get rid of the error message
			e->Delete();

			// Set failure flag
			CurrentSuccess = 0;

			// Display the blank image
			m_DisplayBuffer.Copy(m_EmptyBuffer, 0);
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
   empty->Destroy();
   PreviousImageArray->Destroy();
   CurrentImageArray->Destroy();
   mxFreeMatrix(PreviousImageMat);
   mxFreeMatrix(CurrentImageMat);
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
   }

   // Delete the VCR
   delete vcr;

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


