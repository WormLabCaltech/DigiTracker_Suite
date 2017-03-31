// MDoubleBufferingLite example

// This example does double buffered grab with real time processing.     
// It also times to see if some frames are not processed using hooks.    
//                                                                       
// Note: This assumes that the processing operation is shorter than a grab
//       and that the PC has sufficient bandwith to support the 2        
//       operations simultaneously. Also if the target processing buffer 
//       is not on the display, the processing speed is augmented.       

// ExampleDlg.h : header file
//
//{{AFX_INCLUDES()
#include "Buffer.h"
#include "Digitizer.h"
#include "Display.h"
#include "System.h"
#include "Application.h"
#include "GraphicContext.h"
#include "Image.h"
//}}AFX_INCLUDES

#if !defined(AFX_EXAMPLEDLG_H_MDoubleBufferingLite_INCLUDED_)
#define AFX_EXAMPLEDLG_H_MDoubleBufferingLite_INCLUDED_

#include "resource.h"		// main symbols
#include "TableCtrl.h"
// CJC 2-18-05 NO LONGER APPLICABLE   #include "XXXXXVCRCtrl.h"
#include <mil.h>           // include for MIL native definitions


#include "SettingsDlg.h"
#include "LocationDlg.h"
#include "StageStyle.h"

/////////////////////////////////////////////////////////////////////////////
// CExampleDlg dialog
//
class CExampleDlg : public CDialog
{
// Construction
public:
	void OnUpdatedlg();
	CString m_csProgramdataFilePath;
	CString m_csParamsFilePath;
	LRESULT OnHotKey(WPARAM wparam, LPARAM lparam);
	void SaveParam(void);
	void LoadParam(void);
	void OnRecordError(UINT, LONG);
	CExampleDlg(CWnd* pParent = NULL);	// standard constructor

	void CalculateStageDirections(void);

// Dialog Data
	//{{AFX_DATA(CExampleDlg)
	enum { IDD = IDD_EXAMPLE_DIALOG };
	CButton	m_SettingsDialogButton;
	CStatic	m_HomeResetLabel;
	CButton	m_HomeResetButton;
	CButton	m_HomeButton;
	CEdit	m_autoShutOffEdit;
	CStatic	m_autoShutOffLabel;
	CButton	m_autoShutOffCheck;
	CSpinButtonCtrl	m_autoShutOffSpinner;
	CEdit	m_diffThresholdEdit;
	CSpinButtonCtrl	m_spinner;
	CButton	m_QuitButton;
	CButton m_RestartButton;
	CButton	m_UpButton;
	CButton	m_DownButton;
	CButton	m_LeftButton;
	CButton	m_RightButton;
	CButton m_AutoButton;
	CButton m_ImageButton;
	CButton m_RecordButton;
	CSliderCtrl m_Slider;
	CString m_strCommentText;
	CDisplay	    m_Display;
	CDigitizer	    m_Digitizer;
	CSystem	        m_System;
	CApplication	m_Application;
    CImage	m_DisplayBuffer;
	CImage	m_CurrentBuffer;
	CImage	m_PreviousBuffer;
	CImage m_EmptyBuffer;
	CGraphicContext	m_GraphicContext;
	int		m_fps_display;
	CString	m_strMagnification;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CExampleDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

	int	m_brightness;		// int value to hold brightness for CExampleDlg
	int	m_updateDelayValue;	// CJC 2-20-06, value of update delay for archiving

/*	typedef struct  
	{
		char brightnessCheck;
		char gainCheck;
		char shutterCheck;
		char autoExposureCheck;
		char gammaCheck;
		char sharpnessCheck;
	}	CHECKSTATE;
*/




// Implementation
//  SYSTEMTIME current_file_time;      // time used for file and frame labeling
protected:
	
   Table *table;				 // Table structure
   //VCR   *vcr;
   long m_nStepCount;            // Keeps track of the current example step 
   long m_restart;				 // Restart the system
   long m_image;				 // Display the image
   long m_track;				 // Enable tracking
   void AdjustDialog();          // Resizes the dialog to fit any font size and digitizer resolution
   
   long m_nProcessingCount;      // number of processing iterations performed
   double m_dTime;               // time elapsed
   double recTime;				 // time since recording started
   int    record;				 // flag to determine if recording is in progress
   int    frames_per_second;     // record rate
   // processing thread related members
   long     m_bStopProcessing;   // flag for processing thread termination
   long     m_bKillProcessing;   // flag for processing thread termination

   static UINT ProcessingThreadFunction(LPVOID pParam); // processing thread control function
   void ProcessingWorkFunction();    // processing thread working function
   afx_msg LONG OnProcessingWorkFunctionEnd( UINT, LONG ); // Custom Windows message handler  


	CString record_filename;      // file name of the recorded video sequence
	FILE *fp;                     // file handle  
	bool m_threadEnded;           // indication of the thread ended
	long m_nRecordedCount;        // number of frames recorded

	long m_startx;				  // start x position clicked for calibration
	long m_starty;                // start y position clicked for calibration
	bool m_isCalibrating;		  // calibration mode on
	double stepsPerPixel;          // Calibration variable: table steps per pixel

	CLocationDlg *locationDlg;
	CSettingsDlg *settingsDlg;
	CStageStyle  *stagestyleDlg;	// CJC 8-30-06 to allow stage style dialog at startup if no program.data file
	
	int XDirection;		// Multiplier to set positive stage direction
	int YDirection;		// Multiplier to set positive stage direction


	// Generated message map functions
	//{{AFX_MSG(CExampleDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnQuitbutton();
	afx_msg void OnClose();
	afx_msg void OnRestartbutton();
	afx_msg void OnImagebutton();
	afx_msg void OnUpbutton();
	afx_msg void OnDownbutton();
	afx_msg void OnLeftbutton();
	afx_msg void OnRightbutton();
	afx_msg void OnAutobutton();
	afx_msg void OnRecbutton();
	afx_msg void OnDeltaposSpin1(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnHScroll(UINT nSBCode, UINT nPos, CScrollBar* pScrollBar);
	afx_msg void OnMouseDownDisplay(short Button, short Shift, long x, long y);
	afx_msg void OnAutoshut();
	afx_msg void OnReleasedcaptureMagSlider(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnHomeButton();
	afx_msg void OnHomeresetbutton();
	afx_msg void OnSettingsDialog();
	DECLARE_EVENTSINK_MAP()
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
// CExampleApp:
// See Example.cpp for the implementation of this class
//
class CExampleApp : public CWinApp
{
public:
   CExampleApp() {};

	//{{AFX_VIRTUAL(CExampleApp)
	inline virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

};


/////////////////////////////////////////////////////////////////////////////
// CExampleApp initialization
//
BOOL CExampleApp::InitInstance()
{
	AfxEnableControlContainer();

// CJC 4-05-05	CExampleDlg dlg;
CExampleDlg dlg( AfxGetMainWnd() );
	m_pMainWnd = &dlg;
	dlg.DoModal();

	return FALSE;
}


//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif 
