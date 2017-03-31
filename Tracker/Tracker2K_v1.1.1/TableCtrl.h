#include "windows.h"

class Table 
{
public :	Table(int portid) { Initialize(portid); };
			~Table() { Destroy(); };
			/* low level commands */
			BOOL Send(char *buf);
			BOOL Read(char *buf, int maxsize);
			BOOL Clear();
			/* high level commands */
			BOOL MoveRel(int x, int y);
			
protected:	HANDLE port;
			BOOL Initialize(int portid);
			void Destroy();
};

