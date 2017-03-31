#include "stdafx.h"
#include "TableCtrl.h"

BOOL Table::Initialize(int portid)
{
	char szStr[64];
	COMMTIMEOUTS cto;
	DCB dcb;
	DWORD status;

	wsprintf(szStr, "COM%d", portid);
	port = CreateFile(szStr, GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);

	if( port == INVALID_HANDLE_VALUE )
		return(FALSE);

	memset(&cto, 0, sizeof(COMMTIMEOUTS));
	cto.ReadIntervalTimeout = 1000;
	cto.ReadTotalTimeoutMultiplier = 0;
	cto.ReadTotalTimeoutConstant = 5000;
	SetCommTimeouts(port, &cto);

	memset(&dcb, 0, sizeof(DCB));
	wsprintf(szStr, "COM%d: baud=9600 parity=N data=8 stop=2", portid);

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

	// Set DTR high and wait for DSR to go high
	EscapeCommFunction(port, SETDTR);
	SetCommMask(port, EV_DSR);
	GetCommModemStatus(port, &status);
	if( !(status & MS_DSR_ON) )		
		WaitCommEvent(port, &status, NULL);

	// If DSR is low, close port and return an error
	if( !(status & MS_DSR_ON) )
	{
		CloseHandle(port);
		port = INVALID_HANDLE_VALUE;
		return(FALSE);
	}

	// Set RTS high and wait for CTS to go high
	EscapeCommFunction(port, SETRTS);
	SetCommMask(port, EV_CTS);
	GetCommModemStatus(port, &status);
	if( !(status & MS_CTS_ON) )
		WaitCommEvent(port, &status, NULL);
	
	// if CTS went high, initialize table
	if( status & MS_CTS_ON )
	{
		char buf[2];
		DWORD nwrote;

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

	return(TRUE);
}

void Table::Destroy()
{
	DWORD status;

	if( port != INVALID_HANDLE_VALUE )
	{
		// Set DTR low
		EscapeCommFunction(port, CLRDTR);
		SetCommMask(port, EV_DSR);
		// Check if DSR is low already
		GetCommModemStatus(port, &status);
		// If not, wait for it to go low
		if( status & MS_DSR_ON )
			WaitCommEvent(port, &status, NULL);
		// Now close the port
		CloseHandle(port);
	}
}

BOOL Table::Send(char *buf)
{
	DWORD status, nwrote;
	int len;
	BOOL success = TRUE;

	// Check to see if table is valid
	if( port == INVALID_HANDLE_VALUE )
		return(FALSE);

	// Set RTS high and wait for CTS to go high
	EscapeCommFunction(port, SETRTS);
	SetCommMask(port, EV_CTS);
	GetCommModemStatus(port, &status);
	if( !(status & MS_CTS_ON) )
		WaitCommEvent(port, &status, NULL);

	// if CTS went high, send the command 
	if( status & MS_CTS_ON )
	{
		len = (int) strlen(buf);

		if( !WriteFile(port, buf, (DWORD) len, &nwrote, NULL) )
			success = FALSE;
	}
	else
	{
		success = FALSE;
	}

	// Clear RTS
	EscapeCommFunction(port, CLRRTS);

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

   sprintf(string, "movrel x=%d y=%d\r", x, y);
   this->Clear();
   if( this->Send(string) )
	  return(TRUE);
   else
	  return(FALSE);
}