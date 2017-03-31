To build libjpeg.lib with Visual Studio (e.g. 2008):
using instructions by "Silverio" from 
http://social.msdn.microsoft.com/Forums/en-US/vcgeneral/thread/f1c0a712-4c83-4cd3-a460-e8669ccc2059

----------
1) Decompress the [IJG] archive to some_folder

2) Rename jconfig.vc to jconfig.h and makefile.vc to makefile

3) Run Visual Studio Command Prompt and cd to some_folder

4) Run 
     'nmake clean all' 
command (to generate execuatble with debug information) or 
     'nmake nodebug=1 clean all' 
command (to generate optimized executables _without_ debug information). 
----------

Notes:
The Visual Studio Command Prompt can be accessed from the Start menu or
from the 'Tools' menu within Microsoft Visual Studio.

This uses 'makefile' as nmake's makefile.

The 'all' argument generates the full suite of JPEG executables (cjpeg.exe, 
djpeg.exe, jpegtran.exe, rdjpgcom.exe, wrjpgcom.exe) as well as the 
libjpeg.lib library.  

The 'clean' argument removes any existing libjpeg.lib, .obj, .exe, and 
testout* files prior to compiling.

Calling 'nmake clean libjpeg.lib' generates only the libjpeg.lib library.

If 'all' has been specified, the compiled code can be tested via:
'nmake test'.  
(These tests will not work if only libjpeg.lib was generated.)
