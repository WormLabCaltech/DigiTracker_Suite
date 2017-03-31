#if !defined(AFX_SETTINGSDLG_H__5A32E095_4125_4492_9F3F_DC6C14B5FE22__INCLUDED_)
#define AFX_SETTINGSDLG_H__5A32E095_4125_4492_9F3F_DC6C14B5FE22__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// SettingsDlg.h : header file
//

#include "resource.h"		// main symbols

#include "LocationDlg.h"	// CJC 8-29-06 Try this
#include "StageStyle.h"		// CJC 9-05-06

#include "Digitizer.h"
#include <mil.h>           // include for MIL native definitions

/////////////////////////////////////////////////////////////////////////////
// External variables
//extern CDigitizer m_Digitizer;


/////////////////////////////////////////////////////////////////////////////
//
	struct  CHECKSTATETYPE
	{
		char brightnessCheck;
		char gainCheck;
		char shutterCheck;
		char autoExposureCheck;
		char gammaCheck;
		char sharpnessCheck;
	};


/////////////////////////////////////////////////////////////////////////////
//
	struct  CHECKREVERSETYPE
	{
		char reverseX;
		char reverseY;
	};



/////////////////////////////////////////////////////////////////////////////
// TEST SPACE
struct addr
{
	char name[30];
	char street[40];
	char city[20];
	char state[3];
	unsigned long int zip;
};
//} addr_info3, binfo, cinfo;



/////////////////////////////////////////////////////////////////////////////
// CSettingsDlg dialog

class CSettingsDlg : public CDialog
{
// Construction
public:
	CSettingsDlg(CWnd* pParent = NULL);   // standard constructor

	void CSettingsDlg::passDigitizerHandle (CDigitizer *camera);
	void CSettingsDlg::passAutoExposureState(CHECKSTATETYPE *AutoExpState);
	void CSettingsDlg::passReverseStageState(CHECKREVERSETYPE* CheckReverseState, int* XDirection, int* YDirection);
// CJC 3-01-06 WAS	void CSettingsDlg::passReverseStageState(CHECKREVERSETYPE* CheckReverseState);
	void CSettingsDlg::passDiffThresholdValue(int *m_diffThresholdValue);
	void CSettingsDlg::passUpdateDelayValue(int *m_updateDelayValue);
	void CSettingsDlg::passStageStyle(int *stageStyleCode);
//CJC 9-08-06//	void CSettingsDlg::passSettingsDialogButtonHandle(CButton *m_SettingsDialogButton);
//CJC 9-08-06	void CSettingsDlg::passSettingsDialogButtonHandle(CButton *m_SettingsDialogButton);

	// Dialog Data
	//{{AFX_DATA(CSettingsDlg)
	enum { IDD = IDD_SETTINGS };
	CComboBox	m_StageComboValue;
	CButton	m_autoSharpnessCheck;
	CButton	m_autoGammaCheck;
	CButton	m_autoAutoExposureCheck;
	CButton	m_autoShutterCheck;
	CButton	m_autoGainCheck;
	CButton	m_autoBrightnessCheck;
	CEdit	m_sharpnessEdit;
	CSliderCtrl	m_sharpness;
	CEdit	m_gammaEdit;
	CSliderCtrl	m_gamma;
	CSpinButtonCtrl	m_updateDelaySpinner;
	CEdit	m_diffThresholdEdit;
	CSliderCtrl	m_diffThreshold;
	CButton	m_reverseY;
	CButton	m_reverseX;
	CEdit	m_autoExposureEdit;
	CSliderCtrl	m_autoExposure;
	CEdit	m_shutterEdit;
	CSliderCtrl	m_shutter;
	CEdit	m_gainEdit;
	CSliderCtrl	m_gain;
	CEdit	m_brightnessEdit;
	CSliderCtrl	m_brightness;
	int		m_updateDelay;
	CString	m_stageStyleString;
	//}}AFX_DATA

	void CSettingsDlg::InitializeControls();
	void CSettingsDlg::InitializeBrightness();
	void CSettingsDlg::InitializeGain();
	void CSettingsDlg::InitializeShutter();
	void CSettingsDlg::InitializeAutoExposure();
	void CSettingsDlg::InitializeGamma();
	void CSettingsDlg::InitializeSharpness();
	void CSettingsDlg::InitializeDiffThreshold();
	void CSettingsDlg::InitializeUpdateDelay();
	void CSettingsDlg::InitializeReverseX();
	void CSettingsDlg::InitializeReverseY();
	void CSettingsDlg::UpdateCheckState();
	void CSettingsDlg::EnableSettingsButton();



// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CSettingsDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	CLocationDlg *locationDlg;
	CStageStyle  *stagestyleDlg;	// CJC 9-05-06 to allow stage style dialog at startup if no program.data file


	// Generated message map functions
	//{{AFX_MSG(CSettingsDlg)
	afx_msg void OnReleasedcaptureBrightnessSlider(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnChangeBrightnessEdit();
	afx_msg void OnReleasedcaptureGainSlider(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnChangeGainEdit();
	afx_msg void OnReleasedcaptureShutterSlider(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnChangeShutterEdit();
	afx_msg void OnReleasedcaptureAutoExposureSlider(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnChangeAutoExposureEdit();
	afx_msg void OnReverseX();
	afx_msg void OnReverseY();
	afx_msg void OnReleasedcaptureDiffThresholdSlider(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnChangeDiffThresholdEdit();
	afx_msg void OnDeltaposDelaySpin(NMHDR* pNMHDR, LRESULT* pResult);
	virtual BOOL OnInitDialog();
	afx_msg void OnReleasedcaptureGamma(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnChangeGammaEdit();
	afx_msg void OnReleasedcaptureSharpness(NMHDR* pNMHDR, LRESULT* pResult);
	afx_msg void OnChangeSharpnessEdit();
	afx_msg void OnBrightnessCheck();
	afx_msg void OnGainCheck();
	afx_msg void OnShutterCheck();
	afx_msg void OnAutoExposureCheck();
	afx_msg void OnGammaCheck();
	afx_msg void OnSharpnessCheck();
	virtual void OnOK();
	afx_msg void OnChangeStage();
	afx_msg void OnCloseupStageCombo();
	afx_msg void OnClose();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_SETTINGSDLG_H__5A32E095_4125_4492_9F3F_DC6C14B5FE22__INCLUDED_)
