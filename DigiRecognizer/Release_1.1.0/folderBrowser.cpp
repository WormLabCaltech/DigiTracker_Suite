#include <stdlib.h>
#include "stdafx.h"
#include "mex.h"

//Here is some code that you can use to implement a function. I got the 
//original code a long time ago and have modified it some over the years for 
//my specific use: 


// ***********************************************************************************
// Function prototypes
// ***********************************************************************************
int CALLBACK SetSelProc( HWND hWnd, UINT uMsg, LPARAM lParam, LPARAM lpData );
BOOL FolderBrowser(CWnd *pWnd, CString& title, CString& dir, CString &initial, BOOL bAll, BOOL bCreate); 
// ***********************************************************************************



// 
// SetSelProc 
// Callback procedure to set the initial selection of the browser. 
int CALLBACK SetSelProc( HWND hWnd, UINT uMsg, LPARAM lParam, LPARAM 
lpData ) 
{ 
    switch(uMsg) { 
    case BFFM_INITIALIZED: 
    { 
         // Set start directory 
        ::SendMessage( hWnd, BFFM_SETSELECTION, TRUE, lpData ); 


        // Remove the ? from the caption 
        DWORD dwStyle = ::GetWindowLong(hWnd, GWL_EXSTYLE); 
        ::SetWindowLong(hWnd, GWL_EXSTYLE, dwStyle & ~WS_EX_CONTEXTHELP); 
    } 
    break; 
    case BFFM_SELCHANGED: 
    { 
        // Set the window text to the path 
        TCHAR szText[MAX_PATH] = {0}; 
        ::SHGetPathFromIDList(reinterpret_cast<LPITEMIDLIST>(lParam), 
szText); 
        ::SetWindowText(hWnd,szText); 
    } 
    break; 
    case BFFM_VALIDATEFAILED: 
        // Msg("\"%s\" is a wrong path name.", reinterpret_cast<LPTSTR>(lParam)); 
        return 1; 
    } 
    return 0; 
} 


// 
// FolderBrowswer 
// Display a folder browser allowing the user to browse for a directory. 
// 
BOOL FolderBrowser(CWnd *pWnd, CString& title, CString& dir, CString 
&initial, BOOL bAll, BOOL bCreate) 
{ 
    BOOL r = FALSE; 
    LPMALLOC pMalloc; 
    TCHAR buffer[MAX_PATH]; // Retrieve the task memory allocator. 
    if (SUCCEEDED(::SHGetMalloc(&pMalloc))) { 


        // Fill in a BROWSEINFO structure, setting the flag to indicate 
        // that we only want file system folders. 
        BROWSEINFO bi; 
        ZeroMemory(&bi,sizeof(BROWSEINFO)); 
        bi.hwndOwner = pWnd->GetSafeHwnd(); 
        bi.lpszTitle = (LPCTSTR) title; 
        bi.pszDisplayName = NULL; 
        bi.pidlRoot = NULL; 


        // Do we want to display the network drives or only the drives for 
		// the local system? 
        if(!bAll) 
		{ 
            bi.ulFlags = BIF_RETURNFSANCESTORS | BIF_RETURNONLYFSDIRS | 
				BIF_DONTGOBELOWDOMAIN; 
        } 
        else 
		{ 
            bi.ulFlags = BIF_RETURNFSANCESTORS | BIF_RETURNONLYFSDIRS; 
        } 


        // The flag puts the extra create folder button on and allows the 
		// dialog to be resized. 
        if(bCreate) 
		{
#define BIF_NEWDIALOGSTYLE 0x0040	// Value from:  
									// http://groups-beta.google.com/group/comp.os.ms-windows.programmer.win32/browse_thread/thread/b9885df3b9a6d1d6/a18b9f122dd123b4?q=BIF_newdialogstyle&rnum=1#a18b9f122dd123b4

            bi.ulFlags |= BIF_NEWDIALOGSTYLE; 
		}


        bi.iImage = 0; 
        bi.lpfn = SetSelProc; 
        bi.lParam = (LPARAM)(LPCTSTR)initial; 


        // Display the dialog 
        LPITEMIDLIST item_list = ::SHBrowseForFolder(&bi); 


        // Did the user select a folder 
        if (item_list) 
		{ 


            // Convert the ID to a pathname, and copy it to the 
            // buffer the user passed in 
            if (::SHGetPathFromIDList(item_list, buffer)) { 
                dir = buffer; 
                r = TRUE; 
            } 


            // Free the PIDL that the SHBrowseForFolder created 
            pMalloc->Free(item_list); 
        } 
        // Free the allocator 
        pMalloc->Release(); 
    } 
    return r; 
} 


