#include "stdafx.h"
#include "VCRCtrl.h"

BOOL VCR::Initialize(int portid)
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
	wsprintf(szStr, "COM%d: baud=9600 parity=O data=7 stop=1", portid);

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
	
	// if CTS went high, initialize VCR
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

void VCR::Destroy()
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

BOOL VCR::Send(char *buf)
{
	DWORD status, nwrote;
	int len;
	BOOL success = TRUE;

	// Check to see if VCR is valid
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

BOOL VCR::Read(char *buf, int size)
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

BOOL VCR::Clear()
{
	if( port == INVALID_HANDLE_VALUE )
		return(FALSE);

	if( PurgeComm(port, PURGE_RXCLEAR | PURGE_TXCLEAR) )
		return(TRUE);
	else
		return(FALSE);
}

void sleep()
{
	CTime startTime, endTime;
	CTimeSpan elapsedTime;
		
	startTime = CTime::GetCurrentTime();
	do
	{
		endTime = CTime::GetCurrentTime();
		elapsedTime = endTime - startTime;
	} while (elapsedTime < 2);	
}

void VCR::Power() 
{
	char string[255];	

	// clear the vcr
	this->Clear();

	// now generate and send command
	wsprintf(string, "%c%s%c", '\x02', "POW", '\x03');
	if( this->Send(string) )		
		this->Read(string, 255);
	
	// wait for 150 milliseconds
	sleep();
}

void VCR::Reset() 
{
	char string[255];	

	// clear the vcr
	this->Clear();

	// now generate and send command
	wsprintf(string, "%c%s%c", '\x02', "CRT", '\x03');
	if( this->Send(string) )		
		this->Read(string, 255);

	// wait for 150 milliseconds
	sleep();	
}

void VCR::Rewind() 
{
	char string[255];	

	// clear the vcr
	this->Clear();

	// now generate and send command
	wsprintf(string, "%c%s%c", '\x02', "ORW", '\x03');
	if( this->Send(string) )		
		this->Read(string, 255);
	
	// wait for 150 milliseconds
	sleep();
}

void VCR::Stop() 
{
	char string[255];	

	// clear the vcr
	this->Clear();

	// now generate and send command
	wsprintf(string, "%c%s%c", '\x02', "OSP", '\x03');
	if( this->Send(string) )		
		this->Read(string, 255);

	// wait for 150 milliseconds
	sleep();
}

void VCR::Play() 
{
	char string[255];	

	// clear the vcr
	this->Clear();

	// now generate and send command
	wsprintf(string, "%c%s%c", '\x02', "OPL", '\x03');
	if( this->Send(string) )		
		this->Read(string, 255);

	// wait for 150 milliseconds
	sleep();
}

void VCR::Forward() 
{
	char string[255];	

	// clear the vcr
	this->Clear();

	// now generate and send command
	wsprintf(string, "%c%s%c", '\x02', "OFF", '\x03');
	if( this->Send(string) )		
		this->Read(string, 255);	

	// wait for 150 milliseconds
	sleep();
}

int VCR::GetPosition()
{
	char string[255];	
	int hrs, min, sec, frm;
	int result;

	// clear the vcr
	this->Clear();

	// now generate and send command
	wsprintf(string, "%c%s%c", '\x02', "QCD", '\x03');
	if( this->Send(string) )		
		this->Read(string, 255);	

	// now parse in the string
	sscanf(&string[6], "%1d%2d%2d%2d", &hrs, &min, &sec, &frm);

	// now compute result
	result = hrs*60*60*30 + min*60*30 + sec*30 + frm;

	// change sign if necessary
	if( string[5] == '-' )
		result = -1 * result;

	return(result);
}

void VCR::Goto(int sgn, int hrs, int min, int sec, int frm)
{
	char string[255];
	int target = sgn * (hrs*60*60*30 + min*60*30 + sec*30 + frm);
	int current;

	// Forward past target position
	current = this->GetPosition();

	if( target > current )
		this->Forward();

	while( target > current )
		current = this->GetPosition();

	this->Stop();

	// Rewind pre target position
	current = this->GetPosition();

	if( current > target )
		this->Rewind();

	while( current > target )
		current = this->GetPosition();

	this->Stop();	

	// Play to target position
	this->Clear();

	if( sgn > 0 )
		wsprintf(string, "%cSPT: %1.1d%2.2d%2.2d%2.2d%c", '\x02', hrs, min, sec, frm, '\x03');
	else
		wsprintf(string, "%cSPT:-%1.1d%2.2d%2.2d%2.2d%c", '\x02', hrs, min, sec, frm, '\x03');	
	
	if( this->Send(string) )		
		this->Read(string, 255);
	
	// Get Status
	do
	{
		this->Clear();
		wsprintf(string, "%cQOP%c", '\x02', '\x03');

		if( this->Send(string) )		
			this->Read(string, 255);
	} while( string[1] == 'S' && string[2] == 'P' && string[3] == 'T' );

	// Stop the VCR
	this->Stop();
}

