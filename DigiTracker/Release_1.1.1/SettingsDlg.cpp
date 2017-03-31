// SettingsDlg.cpp : implementation file
//

#include "stdafx.h"
#include "SettingsDlg.h"
#include "Digitizer.h"
#include "ExampleDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


#define UPDATE_DELAY_MIN 1            // min update delay (count)
#define UPDATE_DELAY_MAX 30           // max update delay (count)


CDigitizer*			myCamera;			// local pointer to m_Digitizer
CHECKSTATETYPE*		AutoExposureChecks;	// local pointer to AutoExpState
CHECKREVERSETYPE*	ReverseStageChecks;	// local pointer to ReverseStageState



int *DiffThresholdValue;			// local pointer to diffThresholdValue
int *UpdateDelayValue;				// local pointer to updateDelayValue

CButton	*SettingsDialogButton;		// local pointer to m_SettingsDialogButton from main dialog

// CJC 9-05-06 int *StageStyleCode;				// local pointer to stagestyle

int* xDirection;	// local pointer to XDirection multiplier
int* yDirection;	// local pointer to YDirection multiplier

_variant_t AutoMode(static_cast<long>(digDefault), VT_I4); 	// Flag for auto-exposure mode
// CJC 3-09-06	

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// External variables
//extern CDigitizer CExampleDlg::m_Digitizer;	
extern int stagestyle;

/////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////
// CSettingsDlg dialog


CSettingsDlg::CSettingsDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CSettingsDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CSettingsDlg)
	m_updateDelay = 0;
	m_stageStyleString = _T("");
	//}}AFX_DATA_INIT

	m_updateDelay = 5;	// ensure non-zero value
}


/////////////////////////////////////////////////////////////////////////////
// Receive pointers 
void CSettingsDlg::passDigitizerHandle(CDigitizer *camera)
{
	myCamera = camera;
}


void CSettingsDlg::passAutoExposureState(CHECKSTATETYPE *AutoExpState)
{
	AutoExposureChecks = AutoExpState;
}


// CJC 3-01-06 WAS void CSettingsDlg::passReverseStageState(CHECKREVERSETYPE* CheckReverseState)
void CSettingsDlg::passReverseStageState(CHECKREVERSETYPE* CheckReverseState, int* XDirection, int* YDirection)
{
	ReverseStageChecks = CheckReverseState;
	xDirection = XDirection;
	yDirection = YDirection;
}


void CSettingsDlg::passDiffThresholdValue(int *diffThresholdValue)
{
	DiffThresholdValue = diffThresholdValue;
}


void CSettingsDlg::passUpdateDelayValue(int *updateDelayValue)
{
	UpdateDelayValue = updateDelayValue;
}


/* CJC 9-05-06
void CSettingsDlg::passStageStyle(int *stageStyleCode)
{
	StageStyleCode = stageStyleCode;
}
CJC 9-05-06 */

/*void CSettingsDlg::passSettingsDialogButtonHandle(CButton* m_SettingsDialogButton)
{
	SettingsDialogButton = &m_SettingsDialogButton;	// handle to button on Main Dialog
} */




/////////////////////////////////////////////////////////////////////////////
// OnInitDialog
BOOL CSettingsDlg::OnInitDialog() 
{
	CDialog::OnInitDialog();
	
	// TODO: Add extra initialization here
	InitializeControls();	// Set inital values for each of the sliders and edits

	return TRUE;  // return TRUE unless you set the focus to a control
	              // EXCEPTION: OCX Property Pages should return FALSE
}

/////////////////////////////////////////////////////////////////////////////

void CSettingsDlg::InitializeControls()
{
	
	int foobar; 
	foobar=0;	// CJC 2-14-08 breakpoint fodder

//#ifndef _DEBUG					// CJC 2008-02-15
//		AfxMessageBox("1");		// CJC 2008-02-15
//#endif							// CJC 2008-02-15


	// Initialize camera controls
//AfxMessageBox("1.1");		// CJC 2008-02-20	
	InitializeBrightness();
//AfxMessageBox("1.2");		// CJC 2008-02-20	
	InitializeGain();
//AfxMessageBox("1.3");		// CJC 2008-02-20	
	InitializeShutter();
//AfxMessageBox("1.4");		// CJC 2008-02-20	
	InitializeAutoExposure();
//AfxMessageBox("1.5");		// CJC 2008-02-20	
	InitializeGamma();
//AfxMessageBox("1.6");		// CJC 2008-02-20	
	InitializeSharpness();
//AfxMessageBox("1.7");		// CJC 2008-02-20	

	// Initialize Tracker controls
	InitializeDiffThreshold();
	InitializeUpdateDelay();
	
	// Initialize Table Control controls
	InitializeReverseX();
	InitializeReverseY();


// CJC 3-09-05
// Move the following into its own function, if it works
OnBrightnessCheck();
OnGainCheck();
OnShutterCheck();
OnAutoExposureCheck();
OnGammaCheck();
OnSharpnessCheck();

	// Initialize Stage-style Combo Box
	m_StageComboValue.SetCurSel(stagestyle);

}


void CSettingsDlg::InitializeBrightness()
{
	_variant_t CurrentValue;
	_variant_t MaximumValue;
	_variant_t MinimumValue;

	try
	{

//#ifndef _DEBUG					// CJC 2008-02-15
//		AfxMessageBox("2");		// CJC 2008-02-20
//#endif							// CJC 2008-02-15


		// Attempt to learn values
		MinimumValue = myCamera->Inquire(digBrightness + digMinimumValue);	// use -> (arrow) operator to access member from pointer
//WAS		MinimumValue = (*myCamera).Inquire(digBrightness + digMinimumValue);	// (*myCamera). also works in place of myCamera->
		MaximumValue = myCamera->Inquire(digBrightness + digMaximumValue);
		CurrentValue = myCamera->Inquire(digBrightness);

//#ifndef _DEBUG					// CJC 2008-02-15
//		AfxMessageBox("3");		// CJC 2008-02-15
//#endif							// CJC 2008-02-15

		
		// Set Brightness Slider according to inquired values
		m_brightness.SetRangeMax(MaximumValue.operator long());
		m_brightness.SetRangeMin(MinimumValue.operator long());
//		AfxMessageBox("3.1");		// CJC 2008-02-20
		m_brightness.SetPos(CurrentValue.operator long());
//		AfxMessageBox("3.2");		// CJC 2008-02-20
		

//#ifndef _DEBUG					// CJC 2008-02-15
//		AfxMessageBox("4");		// CJC 2008-02-15
//#endif							// CJC 2008-02-15

		// Set Brightness Edit according to current value
		char buf[10];
		m_brightnessEdit.SetWindowText(_itoa(m_brightness.GetPos(), buf, 10));

		// Set automatic-mode check box 
		m_autoBrightnessCheck.SetCheck(AutoExposureChecks->brightnessCheck);

//#ifndef _DEBUG					// CJC 2008-02-15
//		AfxMessageBox("5");		// CJC 2008-02-15
//#endif							// CJC 2008-02-15


	}
	catch( COleDispatchException *e )
	{
		// Get rid of the error message
		e->Delete();

#ifndef _DEBUG				
		AfxMessageBox("Whoops! Brightness is not available on this camera.");
#endif
		m_brightness.EnableWindow(FALSE);
		m_brightnessEdit.EnableWindow(FALSE);
	}
}


void CSettingsDlg::InitializeGain()
{
	_variant_t CurrentValue;
	_variant_t MaximumValue;
	_variant_t MinimumValue;

	try
	{
		// Attempt to learn values
		MinimumValue = myCamera->Inquire(digGain + digMinimumValue);
		MaximumValue = myCamera->Inquire(digGain + digMaximumValue);
		CurrentValue = myCamera->Inquire(digGain);
		

//#ifndef _DEBUG					// CJC 2008-02-15
//		AfxMessageBox("6");		// CJC 2008-02-15
//#endif							// CJC 2008-02-15

		// Set Gain Slider according to inquired values
		m_gain.SetRangeMax(MaximumValue.operator long());
		m_gain.SetRangeMin(MinimumValue.operator long());
		m_gain.SetPos(CurrentValue.operator long());
		
		// Set Gain Edit according to current value
		char buf[10];
		m_gainEdit.SetWindowText(_itoa(m_gain.GetPos(), buf, 10));
//CJC 9-11-06 This 'auto-setting' shouldn't be here!		_variant_t Gain(static_cast<long>(digDefault), VT_I4); 
//CJC 9-11-06 This 'auto-setting' shouldn't be here!		myCamera->Control(digGain, Gain);

		// Set automatic-mode check box 
		m_autoGainCheck.SetCheck(AutoExposureChecks->gainCheck);
//		OnGainCheck();
		
//AfxMessageBox("7");		// CJC 2008-02-15

	}
	catch( COleDispatchException *e )
	{
		// Get rid of the error message
		e->Delete();

#ifndef _DEBUG				
		AfxMessageBox("Whoops! Gain is not available on this camera.");
#endif

		m_gain.EnableWindow(FALSE);
		m_gainEdit.EnableWindow(FALSE);
	}
}



void CSettingsDlg::InitializeShutter()
{
	_variant_t CurrentValue;
	_variant_t MaximumValue;
	_variant_t MinimumValue;

	try
	{

//AfxMessageBox("7.1");		// CJC 2008-02-15

		// Attempt to learn values
		MinimumValue = myCamera->Inquire(digShutter + digMinimumValue);
//AfxMessageBox("7.2");		// CJC 2008-02-15
		MaximumValue = myCamera->Inquire(digShutter + digMaximumValue);
//AfxMessageBox("7.3");		// CJC 2008-02-15
		CurrentValue = myCamera->Inquire(digShutter);
//AfxMessageBox("7.4");		// CJC 2008-02-15
		
		// Set Shutter Slider according to inquired values
		m_shutter.SetRangeMax(MaximumValue.operator long());
//AfxMessageBox("7.5");		// CJC 2008-02-15
		m_shutter.SetRangeMin(MinimumValue.operator long());
//AfxMessageBox("7.6");		// CJC 2008-02-15
		m_shutter.SetPos(CurrentValue.operator long());
//AfxMessageBox("7.7");		// CJC 2008-02-15
		
		// Set Shutter Edit according to current value
		char buf[10];
//AfxMessageBox("7.8");		// CJC 2008-02-15
		int shutterPosition = m_shutter.GetPos();							// 2008-02-19 CJC
//AfxMessageBox("7.8.1");		// CJC 2008-02-19
//CJC 2008-02-19char bufferTEMP[20];
//CJC 2008-02-19_itoa(shutterPosition, bufferTEMP, 10);		//CJC 2008-02-19
//CJC 2008-02-19AfxMessageBox("7.8.2");		// CJC 2008-02-19
//CJC 2008-02-19m_shutterEdit.SetWindowText(bufferTEMP);	// 2008-02-19 CJC
		m_shutterEdit.SetWindowText(_itoa(shutterPosition, buf, 10));	// 2008-02-19 CJC
//CJC 2008-02-19		m_shutterEdit.SetWindowText(_itoa(m_shutter.GetPos(), buf, 10));	// 2008-02-15 CJC PROBLEM SPOT
//CJC 9-11-06 This 'auto-setting' shouldn't be here!		_variant_t Shutter(static_cast<long>(digDefault), VT_I4); 
//CJC 9-11-06 This 'auto-setting' shouldn't be here!		myCamera->Control(digShutter, Shutter);
//AfxMessageBox("7.9");		// CJC 2008-02-15

		// Set automatic-mode check box 
		m_autoShutterCheck.SetCheck(AutoExposureChecks->shutterCheck);
//		OnShutterCheck;

//AfxMessageBox("8");		// CJC 2008-02-15


	}
	catch( COleDispatchException *e )
	{
		// Get rid of the error message
		e->Delete();

#ifndef _DEBUG				
		AfxMessageBox("Whoops! Shutter is not available on this camera.");
#endif
		m_shutter.EnableWindow(FALSE);
		m_shutterEdit.EnableWindow(FALSE);
	}
}



void CSettingsDlg::InitializeAutoExposure()
{
	_variant_t CurrentValue;
	_variant_t MaximumValue;
	_variant_t MinimumValue;

	try
	{
		// Attempt to learn values
		MinimumValue = myCamera->Inquire(digAutoExposure + digMinimumValue);
		MaximumValue = myCamera->Inquire(digAutoExposure + digMaximumValue);
		CurrentValue = myCamera->Inquire(digAutoExposure);
		
		// Set AutoExposure Slider according to inquired values
		m_autoExposure.SetRangeMax(MaximumValue.operator long());
		m_autoExposure.SetRangeMin(MinimumValue.operator long());
		m_autoExposure.SetPos(CurrentValue.operator long());
		
		// Set AutoExposure Edit according to current value
		char buf[10];
		m_autoExposureEdit.SetWindowText(_itoa(m_autoExposure.GetPos(), buf, 10));

			// Set automatic-mode check box 
		m_autoAutoExposureCheck.SetCheck(AutoExposureChecks->autoExposureCheck);

//AfxMessageBox("9");		// CJC 2008-02-15


}
	catch( COleDispatchException *e )
	{
		// Get rid of the error message
		e->Delete();

#ifndef _DEBUG				
		AfxMessageBox("Whoops! AutoExposure is not available on this camera.");
#endif
		m_autoExposure.EnableWindow(FALSE);
		m_autoExposureEdit.EnableWindow(FALSE);
	}
}



void CSettingsDlg::InitializeGamma()
{
	_variant_t CurrentValue;
	_variant_t MaximumValue;
	_variant_t MinimumValue;

	try
	{
		// Attempt to learn values
		MinimumValue = myCamera->Inquire(digGamma + digMinimumValue);
		MaximumValue = myCamera->Inquire(digGamma + digMaximumValue);
		CurrentValue = myCamera->Inquire(digGamma);
		
		// Set Gamma Slider according to inquired values
		m_gamma.SetRangeMax(MaximumValue.operator long());
		m_gamma.SetRangeMin(MinimumValue.operator long());
		m_gamma.SetPos(CurrentValue.operator long());
		
		// Set Gamma Edit according to current value
		char buf[10];
//AfxMessageBox("9.3");		// CJC 2008-02-15
		m_gammaEdit.SetWindowText(_itoa(m_gamma.GetPos(), buf, 10));	// 2008-02-15 CJC PROBLEM SPOT
//AfxMessageBox("9.4");		// CJC 2008-02-15

		// Set automatic-mode check box 
		m_autoGammaCheck.SetCheck(AutoExposureChecks->gammaCheck);
//AfxMessageBox("9.5");		// CJC 2008-02-15

}
	catch( COleDispatchException *e )
	{
		// Get rid of the error message
		e->Delete();

#ifndef _DEBUG				
		AfxMessageBox("Whoops! Gamma is not available on this camera.");
#endif
		m_gamma.EnableWindow(FALSE);
		m_gammaEdit.EnableWindow(FALSE);
	}
}



void CSettingsDlg::InitializeSharpness()
{
	_variant_t CurrentValue;
	_variant_t MaximumValue;
	_variant_t MinimumValue;

	try
	{
		// Attempt to learn values
		MinimumValue = myCamera->Inquire(digSharpness + digMinimumValue);
		MaximumValue = myCamera->Inquire(digSharpness + digMaximumValue);
		CurrentValue = myCamera->Inquire(digSharpness);
		
		// Set Sharpness Slider according to inquired values
		m_sharpness.SetRangeMax(MaximumValue.operator long());
		m_sharpness.SetRangeMin(MinimumValue.operator long());
		m_sharpness.SetPos(CurrentValue.operator long());
		
		// Set Sharpness Edit according to current value
		char buf[10];
		m_sharpnessEdit.SetWindowText(_itoa(m_sharpness.GetPos(), buf, 10));

		// Set automatic-mode check box 
		m_autoSharpnessCheck.SetCheck(AutoExposureChecks->sharpnessCheck);

//AfxMessageBox("10");		// CJC 2008-02-15


	}
	catch( COleDispatchException *e )
	{
		// Get rid of the error message
		e->Delete();

#ifndef _DEBUG				
		AfxMessageBox("Whoops! Sharpness is not available on this camera.");
#endif
		m_sharpness.EnableWindow(FALSE);
		m_sharpnessEdit.EnableWindow(FALSE);
	}
}


//////////////////////////////////////////////////////////////
//
void CSettingsDlg::InitializeDiffThreshold()
{
	char buf[10];

	m_diffThreshold.SetRange(0, 255);
	m_diffThreshold.SetPos(*DiffThresholdValue);

	m_diffThresholdEdit.SetLimitText(3); 
	m_diffThreshold.SetBuddy(&m_diffThresholdEdit, FALSE);   
	m_diffThresholdEdit.SetWindowText(_itoa(m_diffThreshold.GetPos(), buf, 10));

//AfxMessageBox("11");		// CJC 2008-02-15
}

void CSettingsDlg::InitializeUpdateDelay()
{
// DELETE THIS:	char buf[10];

	m_updateDelaySpinner.SetRange(1, 30);
	m_updateDelaySpinner.SetPos(*UpdateDelayValue);
//DELETE THIS
//int foo = m_updateDelaySpinner.GetPos();

//	m_diffThresholdEdit.SetLimitText(3); 
//	m_diffThreshold.SetBuddy(&m_diffThresholdEdit, FALSE);   
//	m_diffThresholdEdit.SetWindowText(_itoa(m_diffThreshold.GetPos(), buf, 10));
//AfxMessageBox("12");		// CJC 2008-02-15

}

void CSettingsDlg::InitializeReverseX()
{
	m_reverseX.SetCheck(ReverseStageChecks->reverseX);
	*xDirection = 1-(m_reverseX.GetCheck() * 2);
//AfxMessageBox("13");		// CJC 2008-02-15

}

void CSettingsDlg::InitializeReverseY()
{
	m_reverseY.SetCheck(ReverseStageChecks->reverseY);
	*yDirection = 1-(m_reverseY.GetCheck() * 2);
//AfxMessageBox("14");		// CJC 2008-02-15

}

//////////////////////////////////////////////////////////////
//
void CSettingsDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CSettingsDlg)
	DDX_Control(pDX, IDC_STAGE_COMBO, m_StageComboValue);
	DDX_Control(pDX, IDC_SHARPNESS_CHECK, m_autoSharpnessCheck);
	DDX_Control(pDX, IDC_GAMMA_CHECK, m_autoGammaCheck);
	DDX_Control(pDX, IDC_AUTO_EXPOSURE_CHECK, m_autoAutoExposureCheck);
	DDX_Control(pDX, IDC_SHUTTER_CHECK, m_autoShutterCheck);
	DDX_Control(pDX, IDC_GAIN_CHECK, m_autoGainCheck);
	DDX_Control(pDX, IDC_BRIGHTNESS_CHECK, m_autoBrightnessCheck);
	DDX_Control(pDX, IDC_SHARPNESS_EDIT, m_sharpnessEdit);
	DDX_Control(pDX, IDC_SHARPNESS, m_sharpness);
	DDX_Control(pDX, IDC_GAMMA_EDIT, m_gammaEdit);
	DDX_Control(pDX, IDC_GAMMA, m_gamma);
	DDX_Control(pDX, IDC_DELAY_SPIN, m_updateDelaySpinner);
	DDX_Control(pDX, IDC_DIFF_THRESHOLD_EDIT, m_diffThresholdEdit);
	DDX_Control(pDX, IDC_DIFF_THRESHOLD_SLIDER, m_diffThreshold);
	DDX_Control(pDX, IDC_REVERSE_Y, m_reverseY);
	DDX_Control(pDX, IDC_REVERSE_X, m_reverseX);
	DDX_Control(pDX, IDC_AUTO_EXPOSURE_EDIT, m_autoExposureEdit);
	DDX_Control(pDX, IDC_AUTO_EXPOSURE_SLIDER, m_autoExposure);
	DDX_Control(pDX, IDC_SHUTTER_EDIT, m_shutterEdit);
	DDX_Control(pDX, IDC_SHUTTER_SLIDER, m_shutter);
	DDX_Control(pDX, IDC_GAIN_EDIT, m_gainEdit);
	DDX_Control(pDX, IDC_GAIN_SLIDER, m_gain);
	DDX_Control(pDX, IDC_BRIGHTNESS_EDIT, m_brightnessEdit);
	DDX_Control(pDX, IDC_BRIGHTNESS_SLIDER, m_brightness);
	DDX_Text(pDX, IDC_DELAY, m_updateDelay);
	DDX_Text(pDX, IDC_STAGESTYLE_DISPLAY, m_stageStyleString);
	//}}AFX_DATA_MAP
}


BEGIN_MESSAGE_MAP(CSettingsDlg, CDialog)
	//{{AFX_MSG_MAP(CSettingsDlg)
	ON_NOTIFY(NM_RELEASEDCAPTURE, IDC_BRIGHTNESS_SLIDER, OnReleasedcaptureBrightnessSlider)
	ON_EN_CHANGE(IDC_BRIGHTNESS_EDIT, OnChangeBrightnessEdit)
	ON_NOTIFY(NM_RELEASEDCAPTURE, IDC_GAIN_SLIDER, OnReleasedcaptureGainSlider)
	ON_EN_CHANGE(IDC_GAIN_EDIT, OnChangeGainEdit)
	ON_NOTIFY(NM_RELEASEDCAPTURE, IDC_SHUTTER_SLIDER, OnReleasedcaptureShutterSlider)
	ON_EN_CHANGE(IDC_SHUTTER_EDIT, OnChangeShutterEdit)
	ON_NOTIFY(NM_RELEASEDCAPTURE, IDC_AUTO_EXPOSURE_SLIDER, OnReleasedcaptureAutoExposureSlider)
	ON_EN_CHANGE(IDC_AUTO_EXPOSURE_EDIT, OnChangeAutoExposureEdit)
	ON_BN_CLICKED(IDC_REVERSE_X, OnReverseX)
	ON_BN_CLICKED(IDC_REVERSE_Y, OnReverseY)
	ON_NOTIFY(NM_RELEASEDCAPTURE, IDC_DIFF_THRESHOLD_SLIDER, OnReleasedcaptureDiffThresholdSlider)
	ON_EN_CHANGE(IDC_DIFF_THRESHOLD_EDIT, OnChangeDiffThresholdEdit)
	ON_NOTIFY(UDN_DELTAPOS, IDC_DELAY_SPIN, OnDeltaposDelaySpin)
	ON_NOTIFY(NM_RELEASEDCAPTURE, IDC_GAMMA, OnReleasedcaptureGamma)
	ON_EN_CHANGE(IDC_GAMMA_EDIT, OnChangeGammaEdit)
	ON_NOTIFY(NM_RELEASEDCAPTURE, IDC_SHARPNESS, OnReleasedcaptureSharpness)
	ON_EN_CHANGE(IDC_SHARPNESS_EDIT, OnChangeSharpnessEdit)
	ON_BN_CLICKED(IDC_BRIGHTNESS_CHECK, OnBrightnessCheck)
	ON_BN_CLICKED(IDC_GAIN_CHECK, OnGainCheck)
	ON_BN_CLICKED(IDC_SHUTTER_CHECK, OnShutterCheck)
	ON_BN_CLICKED(IDC_AUTO_EXPOSURE_CHECK, OnAutoExposureCheck)
	ON_BN_CLICKED(IDC_GAMMA_CHECK, OnGammaCheck)
	ON_BN_CLICKED(IDC_SHARPNESS_CHECK, OnSharpnessCheck)
	ON_BN_CLICKED(IDC_CHANGE_STAGE, OnChangeStage)
	ON_CBN_CLOSEUP(IDC_STAGE_COMBO, OnCloseupStageCombo)
	ON_WM_CLOSE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CSettingsDlg message handlers

void CSettingsDlg::OnReleasedcaptureBrightnessSlider(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_brightnessEdit.SetWindowText(_itoa(m_brightness.GetPos(), buf, 10));

	_variant_t Brightness(static_cast<long>(m_brightness.GetPos()), VT_I4); 
	myCamera->Control(digBrightness, Brightness);
	
	*pResult = 0;
}

void CSettingsDlg::OnChangeBrightnessEdit() 
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

//-----------------------------------------
int tempdigBrightness = digBrightness;	//CJC 2008-02-19
char tempBuf[20];					//CJC 2008-02-20
_itoa(tempdigBrightness, tempBuf, 10);	//CJC 2008-02-20
//MessageBox(tempBuf, "'digBrightness' ID");				//CJC 2008-02-20
//MessageBox( _bstr_t(Brightness), "m_brightness ('Brightness') slider value");	//CJC 2008-02-20
//-----------------------------------------

	myCamera->Control(tempdigBrightness, Brightness);	//CJC 2008-02-20
//CJC 2008-02-20	myCamera->Control(digBrightness, Brightness);

	
}


////////////////////////////////////////////////////////////////////////
void CSettingsDlg::OnReleasedcaptureGainSlider(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_gainEdit.SetWindowText(_itoa(m_gain.GetPos(), buf, 10));

	_variant_t Gain(static_cast<long>(m_gain.GetPos()), VT_I4); 
	myCamera->Control(digGain, Gain);
// WAS	m_Digitizer.SetInputGain(m_gain.GetPos());

	*pResult = 0;
}

void CSettingsDlg::OnChangeGainEdit() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	
	char buf[10];
	m_gainEdit.GetLine(0, buf);
	m_gain.SetPos(atoi(buf));

	_variant_t Gain(static_cast<long>(atoi(buf)), VT_I4); // or try static_cast<long>(atoi(buf))???// CJC 12-13-05 _variant_t Brightness(static_cast<long>(IMG_BRIGHTNESS), VT_I4); 

//-----------------------------------------
int tempdigGain = digGain;	//CJC 2008-02-20
char tempBuf[20];					//CJC 2008-02-20
_itoa(tempdigGain, tempBuf, 10);	//CJC 2008-02-20
//MessageBox(tempBuf, "'digGain' ID");				//CJC 2008-02-20
//MessageBox( _bstr_t(Gain), "m_gain ('Gain') slider value");	//CJC 2008-02-20
//-----------------------------------------

	myCamera->Control(tempdigGain, Gain);	//CJC 2008-02-20
//CJC 2008-02-20	myCamera->Control(digGain, Gain);
// WAS	m_Digitizer.SetInputGain(m_gain.GetPos());

}


////////////////////////////////////////////////////////////////////////
void CSettingsDlg::OnReleasedcaptureShutterSlider(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_shutterEdit.SetWindowText(_itoa(m_shutter.GetPos(), buf, 10));
//AfxMessageBox("OnReleasedcaptureShutterSlider 1");		// CJC 2008-02-19

	_variant_t Shutter(static_cast<long>(m_shutter.GetPos()), VT_I4); 
//AfxMessageBox("OnReleasedcaptureShutterSlider 2");		// CJC 2008-02-19
	myCamera->Control(digShutter, Shutter);
//AfxMessageBox("OnReleasedcaptureShutterSlider 3");		// CJC 2008-02-19
	
	*pResult = 0;
}

void CSettingsDlg::OnChangeShutterEdit() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	m_shutterEdit.GetLine(0, buf);
//AfxMessageBox("OnChangeShutterEdit 1");		// CJC 2008-02-19
	m_shutter.SetPos(atoi(buf));
//AfxMessageBox("OnChangeShutterEdit 2");		// CJC 2008-02-19

	_variant_t Shutter(static_cast<long>(atoi(buf)), VT_I4); // or try static_cast<long>(atoi(buf))???// CJC 12-13-05 _variant_t Brightness(static_cast<long>(IMG_BRIGHTNESS), VT_I4); 
//AfxMessageBox("OnChangeShutterEdit 3");		// CJC 2008-02-19

/////////////////////////
//		shutterValueString = _bstr_t(Shutter);
//		shutterValueString.Format("Shutter value: %d", Shutter);	// CJC 2008-02-19

//-----------------------------------------
//int tempdigShutter = digShutter;	//CJC 2008-02-19  Not needed
//char tempBuf[20];					//CJC 2008-02-20
//_itoa(tempdigShutter, tempBuf, 10);	//CJC 2008-02-20  Not needed
  //_itoa(digShutter, tempBuf, 10);	//CJC 2008-02-21  Works great
	//_itoa(12345, tempBuf, 10);	//CJC 2008-02-21  Works great
//tempBuf[1] = 'a';  //Crashes
//	Sleep(1000);
//int bogus = 1*digShutter;  //Crashes
//MessageBox(tempBuf, "'digShutter' ID");				//CJC 2008-02-20
//MessageBox( _bstr_t(Shutter), "m_shutter ('Shutter') slider value");	//CJC 2008-02-20
BSTR Garbage = _bstr_t(Shutter);	//CJC 2008-02-21
//_variant_t Bogus(Shutter);
//-----------------------------------------

//AfxMessageBox( _bstr_t(Shutter) );		// CJC 2008-02-19
/////////////////////////
//CJC 2008-02-21	myCamera->Control(tempdigShutter, Shutter);
	myCamera->Control(digShutter, Shutter);
//CJC 2008-02-21	myCamera->Control(5120, Shutter);

//AfxMessageBox("OnChangeShutterEdit 4");		// CJC 2008-02-19
	
}


////////////////////////////////////////////////////////////////////////
void CSettingsDlg::OnReleasedcaptureAutoExposureSlider(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_autoExposureEdit.SetWindowText(_itoa(m_autoExposure.GetPos(), buf, 10));

	_variant_t AutoExposure(static_cast<long>(m_autoExposure.GetPos()), VT_I4); 
	myCamera->Control(digAutoExposure, AutoExposure);
	
	*pResult = 0;
}

void CSettingsDlg::OnChangeAutoExposureEdit() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	m_autoExposureEdit.GetLine(0, buf);
	m_autoExposure.SetPos(atoi(buf));

	_variant_t AutoExposure(static_cast<long>(atoi(buf)), VT_I4); // or try static_cast<long>(atoi(buf))???// CJC 12-13-05 _variant_t Brightness(static_cast<long>(IMG_BRIGHTNESS), VT_I4); 

//-----------------------------------------
int tempdigAutoExposure = digAutoExposure;	//CJC 2008-02-19
char tempBuf[20];
_itoa(tempdigAutoExposure, tempBuf, 10);	//CJC 2008-02-20
//MessageBox(tempBuf, "'digAutoExposure' ID");				//CJC 2008-02-20
//MessageBox( _bstr_t(AutoExposure), "m_autoExposure ('AutoExposure') slider value");	//CJC 2008-02-20
//-----------------------------------------

	myCamera->Control(tempdigAutoExposure, AutoExposure);
//CJC 2008-02-20	myCamera->Control(digAutoExposure, AutoExposure);
	
}



////////////////////////////////////////////////////////////////////////
void CSettingsDlg::OnReleasedcaptureGamma(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_gammaEdit.SetWindowText(_itoa(m_gamma.GetPos(), buf, 10));

	_variant_t Gamma(static_cast<long>(m_gamma.GetPos()), VT_I4); 
	myCamera->Control(digGamma, Gamma);
	
	*pResult = 0;
}

void CSettingsDlg::OnChangeGammaEdit() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	m_gammaEdit.GetLine(0, buf);
	m_gamma.SetPos(atoi(buf));

	_variant_t Gamma(static_cast<long>(atoi(buf)), VT_I4); 
//AfxMessageBox( _bstr_t(Gamma) );		// CJC 2008-02-19

//-----------------------------------------
int tempdigGamma = digGamma;	//CJC 2008-02-19
char tempBuf[20];
_itoa(tempdigGamma, tempBuf, 10);	//CJC 2008-02-20
//MessageBox(tempBuf, "'digGamma' ID");				//CJC 2008-02-20
//MessageBox( _bstr_t(Gamma), "m_gamma ('Gamma') slider value");	//CJC 2008-02-20
//-----------------------------------------

	myCamera->Control(tempdigGamma, Gamma);		// CJC 2008-02-20
// CJC 2008-02-19	myCamera->Control(digGamma, Gamma);
	
}


////////////////////////////////////////////////////////////////////////
void CSettingsDlg::OnReleasedcaptureSharpness(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_sharpnessEdit.SetWindowText(_itoa(m_sharpness.GetPos(), buf, 10));

	_variant_t Sharpness(static_cast<long>(m_sharpness.GetPos()), VT_I4); 
	myCamera->Control(digSharpness, Sharpness);
	
	*pResult = 0;
}

void CSettingsDlg::OnChangeSharpnessEdit() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	m_sharpnessEdit.GetLine(0, buf);
	m_sharpness.SetPos(atoi(buf));

	_variant_t Sharpness(static_cast<long>(atoi(buf)), VT_I4); 

//-----------------------------------------
int tempdigSharpness = digSharpness;	//CJC 2008-02-19
char tempBuf[20];					//CJC 2008-02-20
_itoa(tempdigSharpness, tempBuf, 10);	//CJC 2008-02-20
//MessageBox(tempBuf, "'digSharpness' ID");				//CJC 2008-02-20
//MessageBox( _bstr_t(Sharpness), "m_sharpness ('Sharpness') slider value");	//CJC 2008-02-20
//-----------------------------------------

	myCamera->Control(tempdigSharpness, Sharpness);		//CJC 2008-02-20
//CJC 2008-02-20	myCamera->Control(digSharpness, Sharpness);

}

////////////////////////////////////////////////////////////////////////
void CSettingsDlg::OnReverseX() 
{
	// TODO: Add your control notification handler code here
	ReverseStageChecks->reverseX = m_reverseX.GetCheck();
//	CExampleDlg::CalculateStageDirections();
	*xDirection = 1-(m_reverseX.GetCheck() * 2);

}

void CSettingsDlg::OnReverseY() 
{
	// TODO: Add your control notification handler code here
	ReverseStageChecks->reverseY = m_reverseY.GetCheck();
	*yDirection = 1-(m_reverseY.GetCheck() * 2);
	
}

void CSettingsDlg::OnReleasedcaptureDiffThresholdSlider(NMHDR* pNMHDR, LRESULT* pResult) 
{
	// TODO: Add your control notification handler code here
	char buf[10];
	m_diffThresholdEdit.SetWindowText(_itoa(m_diffThreshold.GetPos(), buf, 10));

	*DiffThresholdValue = m_diffThreshold.GetPos();
	
	*pResult = 0;
}

void CSettingsDlg::OnChangeDiffThresholdEdit() 
{
	// TODO: If this is a RICHEDIT control, the control will not
	// send this notification unless you override the CDialog::OnInitDialog()
	// function and call CRichEditCtrl().SetEventMask()
	// with the ENM_CHANGE flag ORed into the mask.
	
	// TODO: Add your control notification handler code here
	char buf[10];
	m_diffThresholdEdit.GetLine(0,buf);
	m_diffThreshold.SetPos(atoi(buf));
	
	*DiffThresholdValue = m_diffThreshold.GetPos();
	
}

void CSettingsDlg::OnDeltaposDelaySpin(NMHDR* pNMHDR, LRESULT* pResult) 
{
	NM_UPDOWN* pNMUpDown = (NM_UPDOWN*)pNMHDR;
	int local_ipos = pNMUpDown->iPos;
	int local_idelta = pNMUpDown->iDelta;
	
	if (pNMHDR->idFrom != IDC_DELAY_SPIN) return;
	// TODO: Add your control notification handler code here
	
	if (((local_ipos + local_idelta) > UPDATE_DELAY_MAX) ||
		((local_ipos + local_idelta) < UPDATE_DELAY_MIN))
		return;
	
 	//frames_per_second = local_ipos + local_idelta;
//    m_updateDelay = local_ipos + local_idelta;
//    m_updateDelay = local_ipos + local_idelta;

// DELETE THIS
/*//UpdateData(FALSE);
int foo;
foo = m_updateDelaySpinner.GetPos();	
foo = local_ipos + local_idelta;	
//    *UpdateDelayValue = m_updateDelaySpinner.GetPos();
*/
    *UpdateDelayValue = local_ipos + local_idelta;

// DELETE THIS
int bar = *UpdateDelayValue;
    
	UpdateData(FALSE);
	*pResult = 0;
}




//////////////////////////////////////////////////////////
// AutoExposure Check Boxes
//
void CSettingsDlg::OnBrightnessCheck() 
{
	// TODO: Add your control notification handler code here
	if (m_autoBrightnessCheck.GetCheck()) {
		// Disable slider and edit box
		m_brightness.EnableWindow(FALSE);
		m_brightnessEdit.EnableWindow(FALSE);

		// LET'S SEE IF WE CAN AUTO-ADJUST BRIGHTNESS
		// EVEN THOUGH CMU'S DEMO PROGRAM SAYS THERE'S 
		// NOT AUTO MODE FOR BRIGHTNESS...
// CJC 3-09-06			_variant_t AutoMode(static_cast<long>(digDefault), VT_I4); 	// Flag for auto-exposure mode
		myCamera->Control(digBrightness, AutoMode);

	} else {
		// Re-enable slider and edit box
		m_brightness.EnableWindow(TRUE);
		m_brightnessEdit.EnableWindow(TRUE);

		// Set to current value
		_variant_t CurrentBrightness;
		CurrentBrightness = myCamera->Inquire(digBrightness);
		myCamera->Control(digBrightness, CurrentBrightness);
		
		// Set Slider according to inquired values
		m_brightness.SetPos(CurrentBrightness.operator long());
		
		// Set Edit according to current value
		char buf[10];
		m_brightnessEdit.SetWindowText(_itoa(m_brightness.GetPos(), buf, 10));
	}
//AfxMessageBox("15");		// CJC 2008-02-15
	UpdateCheckState();		// to refresh master list of check states
// CJC 3-09-06	UpdateData(FALSE);
}

void CSettingsDlg::OnGainCheck() 
{
	// TODO: Add your control notification handler code here
	if (m_autoGainCheck.GetCheck()) {
		// Disable slider and edit box
		m_gain.EnableWindow(FALSE);
		m_gainEdit.EnableWindow(FALSE);

		// Set gain to auto-mode
// CJC 3-09-06			_variant_t AutoMode(static_cast<long>(digDefault), VT_I4);	// Flag for auto-exposure mode
		myCamera->Control(digGain, AutoMode);

	} else {
		// Re-enable slider and edit box
		m_gain.EnableWindow(TRUE);
		m_gainEdit.EnableWindow(TRUE);

		// Set Gain to current value
		_variant_t CurrentGain;
		CurrentGain = myCamera->Inquire(digGain);
		myCamera->Control(digGain, CurrentGain);
		
		// Set Gain Slider according to inquired values
		m_gain.SetPos(CurrentGain.operator long());
		
		// Set Gain Edit according to current value
		char buf[10];
		m_gainEdit.SetWindowText(_itoa(m_gain.GetPos(), buf, 10));
	}
	UpdateCheckState();		// to refresh master list of check states
// CJC 3-09-06	UpdateData(FALSE);
//AfxMessageBox("16");		// CJC 2008-02-15
}

void CSettingsDlg::OnShutterCheck() 
{
	// TODO: Add your control notification handler code here
	if (m_autoShutterCheck.GetCheck()) {
		// Disable slider and edit box
		m_shutter.EnableWindow(FALSE);
		m_shutterEdit.EnableWindow(FALSE);

		// Set shutter to auto-mode
// CJC 3-09-06			_variant_t AutoMode(static_cast<long>(digDefault), VT_I4); 	// Flag for auto-exposure mode
		myCamera->Control(digShutter, AutoMode);
	} else {
		// Re-enable slider and edit box
		m_shutter.EnableWindow(TRUE);
		m_shutterEdit.EnableWindow(TRUE);

		// Set Shutter to current value
		_variant_t CurrentShutter;
//AfxMessageBox("16.1");		// CJC 2008-02-15
		CurrentShutter = myCamera->Inquire(digShutter);
//AfxMessageBox("16.2");		// CJC 2008-02-15
		myCamera->Control(digShutter, CurrentShutter);	//digShutter not found CJC 2008-02-15 Not sure why I'm inquiring, then setting what was just enquired
//AfxMessageBox("16.3");		// CJC 2008-02-15
		
		// Set Shutter Slider according to inquired values
		m_shutter.SetPos(CurrentShutter.operator long());
//AfxMessageBox("16.4");		// CJC 2008-02-15
		
		// Set Shutter Edit according to current value
		char buf[10];
		m_shutterEdit.SetWindowText(_itoa(m_shutter.GetPos(), buf, 10));
//AfxMessageBox("16.5");		// CJC 2008-02-15
	}
	UpdateCheckState();		// to refresh master list of check states
// CJC 3-09-06	UpdateData(FALSE);
//AfxMessageBox("17");		// CJC 2008-02-15
}

void CSettingsDlg::OnAutoExposureCheck() 
{
	// TODO: Add your control notification handler code here
	if (m_autoAutoExposureCheck.GetCheck()) {
		// Disable slider and edit box
		m_autoExposure.EnableWindow(FALSE);
		m_autoExposureEdit.EnableWindow(FALSE);

		// Set AutoExposure to auto-mode
// CJC 3-09-06			_variant_t AutoMode(static_cast<long>(digDefault), VT_I4); 	// Flag for auto-exposure mode
		myCamera->Control(digAutoExposure, AutoMode);
	} else {
		// Re-enable slider and edit box
		m_autoExposure.EnableWindow(TRUE);
		m_autoExposureEdit.EnableWindow(TRUE);

		// Set to current value
		_variant_t CurrentAutoExposure;
		CurrentAutoExposure = myCamera->Inquire(digAutoExposure);
		myCamera->Control(digAutoExposure, CurrentAutoExposure);
		
		// Set Slider according to inquired values
		m_autoExposure.SetPos(CurrentAutoExposure.operator long());
		
		// Set Edit according to current value
		char buf[10];
		m_autoExposureEdit.SetWindowText(_itoa(m_autoExposure.GetPos(), buf, 10));
	}
	UpdateCheckState();		// to refresh master list of check states
// CJC 3-09-06	UpdateData(FALSE);
//AfxMessageBox("18");		// CJC 2008-02-15
}

void CSettingsDlg::OnGammaCheck() 
{
	// TODO: Add your control notification handler code here
	if (m_autoGammaCheck.GetCheck()) {
		// Disable slider and edit box
		m_gamma.EnableWindow(FALSE);
		m_gammaEdit.EnableWindow(FALSE);

		// Set to auto-mode
// CJC 3-09-06			_variant_t AutoMode(static_cast<long>(digDefault), VT_I4); 	// Flag for auto-exposure mode
		myCamera->Control(digGamma, AutoMode);
	} else {
		// Re-enable slider and edit box
		m_gamma.EnableWindow(TRUE);
		m_gammaEdit.EnableWindow(TRUE);

		// Set to current value
		_variant_t CurrentGamma;
		CurrentGamma = myCamera->Inquire(digGamma);
		myCamera->Control(digGamma, CurrentGamma);
		
		// Set Slider according to inquired values
		m_gamma.SetPos(CurrentGamma.operator long());
		
		// Set Edit according to current value
		char buf[10];
		m_gammaEdit.SetWindowText(_itoa(m_gamma.GetPos(), buf, 10));
	}
	UpdateCheckState();		// to refresh master list of check states
// CJC 3-09-06	UpdateData(FALSE);
//AfxMessageBox("19");		// CJC 2008-02-15
}

void CSettingsDlg::OnSharpnessCheck() 
{
	// TODO: Add your control notification handler code here
	if (m_autoSharpnessCheck.GetCheck()) {
		// Disable slider and edit box
		m_sharpness.EnableWindow(FALSE);
		m_sharpnessEdit.EnableWindow(FALSE);

		// Set to auto-mode
// CJC 3-09-06			_variant_t AutoMode(static_cast<long>(digDefault), VT_I4); 	// Flag for auto-exposure mode
		myCamera->Control(digSharpness, AutoMode);
	} else {
		// Re-enable slider and edit box
		m_sharpness.EnableWindow(TRUE);
		m_sharpnessEdit.EnableWindow(TRUE);

		// Set to current value
		_variant_t CurrentSharpness;
		CurrentSharpness = myCamera->Inquire(digSharpness);
		myCamera->Control(digSharpness, CurrentSharpness);
		
		// Set Slider according to inquired values
		m_sharpness.SetPos(CurrentSharpness.operator long());
		
		// Set Edit according to current value
		char buf[10];
		m_sharpnessEdit.SetWindowText(_itoa(m_sharpness.GetPos(), buf, 10));
	}
	UpdateCheckState();		// to refresh master list of check states
// CJC 3-09-06	UpdateData(FALSE);
//AfxMessageBox("20");		// CJC 2008-02-15
}


void CSettingsDlg::UpdateCheckState()
{
	AutoExposureChecks->brightnessCheck		= m_autoBrightnessCheck.GetCheck();
	AutoExposureChecks->gainCheck			= m_autoGainCheck.GetCheck();
	AutoExposureChecks->shutterCheck		= m_autoShutterCheck.GetCheck();
	AutoExposureChecks->autoExposureCheck	= m_autoAutoExposureCheck.GetCheck();
	AutoExposureChecks->gammaCheck			= m_autoGammaCheck.GetCheck();
	AutoExposureChecks->sharpnessCheck		= m_autoSharpnessCheck.GetCheck();
}


void CSettingsDlg::OnOK() 
{
	// TODO: Add extra validation here

// No longer necessary:	stagestyle = m_StageComboValue.GetCurSel();

	CSettingsDlg::EnableSettingsButton();

	
// CJC 8-29-06	CDialog::OnOK();
	UpdateData(TRUE);
	DestroyWindow( );

}

void CSettingsDlg::OnChangeStage() 
{
	// TODO: Add your control notification handler code here
/*
		// Initialize Locationselector dialog
stagestyle = stagestyle;	// CJC 9-05-06

	stagestyleDlg = new CStageStyle;
	stagestyleDlg->DoModal();

//	locationDlg = new CLocationDlg;
//	locationDlg->DoModal();

*/	

}


void CSettingsDlg::OnCloseupStageCombo() 
{
	// TODO: Add your control notification handler code here

	// Set stagestyle variable from Stage Style combo box
	stagestyle = m_StageComboValue.GetCurSel();
	
}

void CSettingsDlg::OnClose() 
{
	// TODO: Add your message handler code here and/or call default

	CSettingsDlg::EnableSettingsButton();

	CDialog::OnClose();
}


void CSettingsDlg::EnableSettingsButton()
{
	// Get a handle to the SettingsDlg's Parent Window (the ExampleDlg [main] window)
	// via code snippet from first item in Google groups search for "pointer to" "parent window" 
	// http://groups.google.com/group/microsoft.public.vc.mfc/browse_thread/thread/5517d283a3280c44/d773132526b4775b?lnk=st&q=%22pointer+to%22+%22parent+window%22&rnum=1#d773132526b4775b
	CExampleDlg *pWnd = (CExampleDlg*)GetParent();
	pWnd->m_SettingsDialogButton.EnableWindow(TRUE);


}

