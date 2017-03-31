////////////////////////////////////////////////////////////////////////////////
//
// ExampleHelpers Functions:
//    These functions implement utilities used by all examples
//    They have been put in a separate source file in order to keep 
//    the example dialog source file (ExampleDlg.cpp) as simple as possible
//
////////////////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include "ExampleDlg.h"

#include <math.h>


/////////////////////////////////////////////////////////////////////////////
// Increments the step counter and updates text in the dialog 
// according to the new value
//
void CExampleDlg::AdjustStepNumber()
{
   // Increment the step count
   m_nStepCount++;

   // Write the step count in the comment frame
//   CString str;
//   str.Format("Step %d:",m_nStepCount);
//   CWnd *pStepNumber = GetDlgItem(IDC_STEP_NUMBER);
//   pStepNumber->SetWindowText(str);
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
	SetIcon(hIcon, FALSE);		   // Set small icon

   // Retrieve the relevant dialog controls
   long nMaxDisplayWidth;
   long nMaxNextStepWidth;
   CRect rectNextButton;
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
   m_Display.GetWindowRect(&rectDisplay);
   GetWindowRect(&rectDialog);

   nMaxDisplayWidth  = rectDisplay.Width() + 
                       2 * abs(rectDisplay.left - rectDialog.left);
   nMaxNextStepWidth = rectNextButton.left - rectDialog.left + 
                       rectNextButton.Width() + 
                       rectCommentFrame.left - rectDialog.left;
   
   if(nMaxNextStepWidth > nMaxDisplayWidth)
   {
      SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxNextStepWidth,                             // cx
                   rectDisplay.Height() + 
                   abs (rectDisplay.top - rectDialog.top) + 
                   abs (rectDisplay.left - rectDialog.left),            // cy
                   SWP_SHOWWINDOW);               // flags
   }
   else
   {
      SetWindowPos(NULL,                                          // pWndInsertAfter
                   0,                                             // x  
                   0,                                             // y
                   nMaxDisplayWidth,                              // cx
                   rectDisplay.Height() + 
                   abs (rectDisplay.top - rectDialog.top) + 
                   abs (rectDisplay.left - rectDialog.left),            // cy
                   SWP_SHOWWINDOW);               // flags
   }
}
