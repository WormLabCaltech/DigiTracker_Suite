#include "stdafx.h"
#include "TableCtrl.h"

//extern int locationcode;
extern int stagestyle;


BOOL Table::Initialize(int portid)
{
	char szStr[64];
	COMMTIMEOUTS cto;
	DCB dcb;
	//DWORD status;

	wsprintf(szStr, "COM%d", portid);
	port = CreateFile(szStr, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);

	if( port == INVALID_HANDLE_VALUE )
		return(FALSE);
//AfxMessageBox("1 ");   //CJC
	memset(&cto, 0, sizeof(COMMTIMEOUTS));
	cto.ReadIntervalTimeout = 1000;
	cto.ReadTotalTimeoutMultiplier = 0;
	cto.ReadTotalTimeoutConstant = 5000;
	SetCommTimeouts(port, &cto);

//AfxMessageBox("2 ");   //CJC
	memset(&dcb, 0, sizeof(DCB));

//stagestyle = stagestyle;	// CJC 9-05-06

	//if(locationcode==0)	//Caltech
	if(stagestyle==0)		//Ludl BioPoint
		wsprintf(szStr, "COM%d: baud=9600 parity=N data=8 stop=2", portid);			//CALTECH
//	else if(locationcode==1)	//University of San Diego
	else if(stagestyle==1)		//Prior ProScan
		wsprintf(szStr, "COM%d: baud=9600 parity=N data=8 stop=1", portid);			//UNIVERSITY OF SAN DIEGO
	else
		AfxMessageBox("Tracker configuration undefined.  Use <Ctrl><Alt> L (lowercase 'L') to set, then re-start Tracker.");

//AfxMessageBox("3 ");   //CJC
	dcb.DCBlength = sizeof(DCB);
	if( !BuildCommDCB(szStr, &dcb) )
	{
		CloseHandle(port);
		port = INVALID_HANDLE_VALUE;
		return(FALSE);
	}

	if( !SetCommState(port, &dcb) )
	{
		CloseHandle(port);
		port = INVALID_HANDLE_VALUE;
		return(FALSE);
	}



/*
	//--------------------------------------------
	//
	dcb.fOutxCtsFlow = FALSE;
	dcb.fOutxDsrFlow = FALSE;
	dcb.fDsrSensitivity = FALSE; 
	dcb.fDtrControl = DTR_CONTROL_DISABLE;
	dcb.fOutX = FALSE; 
	dcb.fInX = FALSE; 
	dcb.fRtsControl = RTS_CONTROL_DISABLE; 
		AfxMessageBox("established dcb info ");

	BOOL fSuccess; 
	fSuccess = SetCommState(port, &dcb); 

	if (!fSuccess)
	{
		AfxMessageBox("Failed trying to SetCommState ");
	}
	//
	//--------------------------------------------
*/


//AfxMessageBox("4 ");   //CJC

/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
	// Set DTR high and wait for DSR to go high
	EscapeCommFunction(port, SETDTR);
//AfxMessageBox("5 ");   //CJC
	SetCommMask(port, EV_DSR);
//AfxMessageBox("6 ");   //CJC
	GetCommModemStatus(port, &status);
*/	//2-17-05 CJC

/*	if( GetCommModemStatus(port, &status) == 0)
			AfxMessageBox("No Success ");   //CJC
	else
//			AfxMessageBox("SUCCESS ");   //CJC
	{
		CString statusvaluestring; 
		statusvaluestring.Format("%d", status);
		AfxMessageBox( statusvaluestring );
	}
*/
//AfxMessageBox("7 ");   //CJC

/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
	if( !(status & MS_DSR_ON) )		
		WaitCommEvent(port, &status, NULL);	
*/	//2-17-05 CJC

//11-04-04
//CJC	Since 'port' was opened without FILE_FLAG_OVERLAPPED, "WaitCommEvent
//		does not return until one of the specified events occurs." according
//		to the 'WaitCommEvent' documentation.  Check 'Serial Communications in Win32'
//		article (saved in PVC's MSVC++ MSDN Library 'Favorites' for 
//		workaround.

/*	if( WaitCommEvent(port, &status, NULL) == 0)
			AfxMessageBox("WAIT No Success ");   //CJC
	else
			AfxMessageBox("WAIT SUCCESS ");   //CJC
*/
//AfxMessageBox("8 ");   //CJC

/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
	// If DSR is low, close port and return an error
	if( !(status & MS_DSR_ON) )
	{
		CloseHandle(port);
		port = INVALID_HANDLE_VALUE;
		return(FALSE);
	}
*/	//2-17-05 CJC

/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
	// Set RTS high and wait for CTS to go high
//AfxMessageBox("9 ");   //CJC
	EscapeCommFunction(port, SETRTS);
//AfxMessageBox("10 ");   //CJC
	SetCommMask(port, EV_CTS);
//AfxMessageBox("11 ");   //CJC
	GetCommModemStatus(port, &status);
//AfxMessageBox("12 ");   //CJC
	if( !(status & MS_CTS_ON) )
		WaitCommEvent(port, &status, NULL);
*/	//2-17-05 CJC

	

/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
	// if CTS went high, initialize table
	if( status & MS_CTS_ON )
	{
		char buf[2];
		DWORD nwrote;

		// Ensure High-Level Format (uses ASCII commands)
		buf[0] = (char) 255;
		buf[1] = (char) 65;

		if( !WriteFile(port, buf, (DWORD) 2, &nwrote, NULL) )
		{
			CloseHandle(port);
			port = INVALID_HANDLE_VALUE;
			return(FALSE);
		}
	}
	else
	{
		CloseHandle(port);
		port = INVALID_HANDLE_VALUE;
		return(FALSE);
	}

	// Clear RTS 
	EscapeCommFunction(port, CLRRTS);
*/	//2-17-05 CJC


	return(TRUE);
}

void Table::Destroy()
{
	//DWORD status;

	if( port != INVALID_HANDLE_VALUE )
	{
/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
		// Set DTR low
		EscapeCommFunction(port, CLRDTR);
		SetCommMask(port, EV_DSR);
		// Check if DSR is low already
		GetCommModemStatus(port, &status);
		// If not, wait for it to go low
		if( status & MS_DSR_ON )
			WaitCommEvent(port, &status, NULL);
*/	//2-17-05 CJC
		
		// Now close the port
		CloseHandle(port);
	}
}

BOOL Table::Send(char *buf)
{
	DWORD nwrote;
	//DWORD status, nwrote;
	int len;
	BOOL success = TRUE;

	// Check to see if table is valid
	if( port == INVALID_HANDLE_VALUE )
		return(FALSE);

/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
	// Set RTS high and wait for CTS to go high
	EscapeCommFunction(port, SETRTS);
	SetCommMask(port, EV_CTS);
	GetCommModemStatus(port, &status);
	if( !(status & MS_CTS_ON) )
		WaitCommEvent(port, &status, NULL);

	// if CTS went high, send the command 
	if( status & MS_CTS_ON )
	{
*/	//2-17-05 CJC

		len = (int) strlen(buf);

		if( !WriteFile(port, buf, (DWORD) len, &nwrote, NULL) )
			success = FALSE;

/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
	}
	else
	{
		success = FALSE;
	}
*/	//2-17-05 CJC



/*	2-17-05 CJC COMMENT OUT THE HARDWARE HANDSHAKING PROTOCOL
	// Clear RTS
	EscapeCommFunction(port, CLRRTS);
*/	//2-17-05 CJC

	return(success);
}

BOOL Table::Read(char *buf, int size)
{
	char c;
	int i = 0;
	DWORD nread = 0;

	if( port == INVALID_HANDLE_VALUE )
		return(FALSE);

	// Read into buffer
	do
	{
		ReadFile(port, &c, (DWORD) 1, &nread, NULL);
		if( (nread > 0) && (i < (size - 1)) )
		{
			buf[i] = c;
			i++;
		}
	} while( (c != '\r') && (nread > 0) && (i < (size - 1)) );

	// Put a null at end
	buf[i] = '\0';
	
	// Return success
	if( i > 0 )
		return(TRUE);
	else
		return(FALSE);
}

BOOL Table::Clear()
{
	if( port == INVALID_HANDLE_VALUE )
		return(FALSE);

	if( PurgeComm(port, PURGE_RXCLEAR | PURGE_TXCLEAR) )
		return(TRUE);
	else
		return(FALSE);
}

BOOL Table::MoveRel(int x, int y)
{
   char string[255];
//   sprintf(string, "movrel x=%d y=%d\r", x, y);		//CALTECH
//   sprintf(string, "gr %d, %d\r", x, y);			//UNIVERSITY OF SAN DIEGO

	//if(locationcode==0)	//Caltech
	if(stagestyle==0)		// Ludl BioPoint
		sprintf(string, "movrel x=%d y=%d\r", x, y);		//Ludl BioPoint
	//else if(locationcode==1)	//University of San Diego
	else if(stagestyle==1)		// Prior ProScan
		sprintf(string, "gr %d, %d\r", -x, -y);			//Prior ProScan
	else
		AfxMessageBox("Tracker configuration undefined.  Use <Ctrl><Alt> L (lowercase 'L' to set)");



   if( this->Send(string) )
	  return(TRUE);
   else
	  return(FALSE);
}

BOOL Table::Home()
{
   char string[255];
//   sprintf(string, "move x=0 y=0\r");		//CALTECH
//   sprintf(string, "g 0, 0\r");			//UNIVERSITY OF SAN DIEGO

	//if(locationcode==0)	//Caltech
	if(stagestyle==0)		// Ludl BioPoint
		sprintf(string, "move x=0 y=0\r");		//Ludl BioPoint
	//else if(locationcode==1)	//University of San Diego
	else if(stagestyle==1)	// Prior ProScan
		sprintf(string, "g 0, 0\r");			//Prior ProScan	
	else
		AfxMessageBox("Tracker configuration undefined.  Use <Ctrl><Alt> L (lowercase 'L' to set)");

   if( this->Send(string) )
	  return(TRUE);
   else
	  return(FALSE);
}

BOOL Table::HomeReset()
{
   char string[255];
//   sprintf(string, "here x=0 y=0\r");		//CALTECH
//   sprintf(string, "ps 0, 0\r");			//UNIVERSITY OF SAN DIEGO

	//if(locationcode==0)	//Caltech
	if(stagestyle==0)		//Ludl BioPoint
		sprintf(string, "here x=0 y=0\r");		// Ludl BioPoint
	//else if(locationcode==1)	//University of San Diego
	else if(stagestyle==1)		//Prior ProScan
		sprintf(string, "ps 0, 0\r");			//Prior ProScan
	else
		AfxMessageBox("Tracker configuration undefined.  Use <Ctrl><Alt> L (lowercase 'L' to set)");

	if( this->Send(string) )
		return(TRUE);
	else
		return(FALSE);
}
