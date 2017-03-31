#include "windows.h"

class VCR 
{
public :	VCR(int portid) { Initialize(portid); };
			~VCR() { Destroy(); };
			BOOL Send(char *buf);
			BOOL Read(char *buf, int maxsize);
			BOOL Clear();
			BOOL Valid();
			void Power();
			void Reset();
			void Rewind();
			void Stop();
			void Play();
			void Forward();
			int GetPosition();
			void Goto(int sgn, int hrs, int min, int sec, int frm);

protected:	HANDLE port;
			BOOL Initialize(int portid);
			void Destroy();
};
