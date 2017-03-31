# Microsoft Developer Studio Project File - Name="MDoubleBufferingLite" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=MDoubleBufferingLite - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "MDoubleBufferingLite.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "MDoubleBufferingLite.mak" CFG="MDoubleBufferingLite - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "MDoubleBufferingLite - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "MDoubleBufferingLite - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "MDoubleBufferingLite - Win32 Release"

# PROP BASE Use_MFC 2
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 2
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MD /W3 /GX /O2 /I "C:\Program Files\Matrox Imaging\ActiveMIL\Containers\VC++\include" /I "C:\Program Files\Matrox Imaging\ActiveMIL\controls" /I "C:\Program Files\Matrox Imaging\ActiveMIL\NativeMIL\Include" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /D "ACTIVEMIL_IN_PROJECT" /D "ACTIVEMIL_USE_COM_CLASS" /Yu"stdafx.h" /FD /c
# SUBTRACT CPP /X
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /fo"Release\Recognizer2_1.res" /d "NDEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo /o"Release/Recognizer2_1.bsc"
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /machine:I386
# ADD LINK32 /nologo /subsystem:windows /machine:I386 /out:"Release/Recognizer2_1.exe"

!ELSEIF  "$(CFG)" == "MDoubleBufferingLite - Win32 Debug"

# PROP BASE Use_MFC 2
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 2
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /I "C:\Program Files\Matrox Imaging\ActiveMIL\Containers\VC++\include" /I "C:\Program Files\Matrox Imaging\ActiveMIL\controls" /I "C:\Program Files\Matrox Imaging\ActiveMIL\NativeMIL\Include" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /D "ACTIVEMIL_IN_PROJECT" /D "ACTIVEMIL_USE_COM_CLASS" /FR /Yu"stdafx.h" /FD /GZ /c
# SUBTRACT CPP /X
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /fo"Debug/Recognizer2_1.res" /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo /o"Debug/Recognizer2_1.bsc"
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 /nologo /subsystem:windows /debug /machine:I386 /out:"Debug/Recognizer2_1.exe" /pdbtype:sept

!ENDIF 

# Begin Target

# Name "MDoubleBufferingLite - Win32 Release"
# Name "MDoubleBufferingLite - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\boundary.cpp
# End Source File
# Begin Source File

SOURCE=.\centerline.cpp
# End Source File
# Begin Source File

SOURCE=.\draw.cpp
# End Source File
# Begin Source File

SOURCE=.\findworm.cpp
# End Source File
# Begin Source File

SOURCE=.\foa.cpp
# End Source File
# Begin Source File

SOURCE=.\helper.cpp
# End Source File
# Begin Source File

SOURCE=.\MDoubleBufferingLite.cpp
# End Source File
# Begin Source File

SOURCE=.\MDoubleBufferingLite.rc
# End Source File
# Begin Source File

SOURCE=.\MDoubleBufferingLiteDlg.cpp
# End Source File
# Begin Source File

SOURCE=.\mex.cpp
# End Source File
# Begin Source File

SOURCE=.\save.cpp
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# Begin Source File

SOURCE=.\triangle.cpp
# End Source File
# Begin Source File

SOURCE=.\vcr.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\diameter.h
# End Source File
# Begin Source File

SOURCE=.\MDoubleBufferingLite.h
# End Source File
# Begin Source File

SOURCE=.\MDoubleBufferingLiteDlg.h
# End Source File
# Begin Source File

SOURCE=.\mex.h
# End Source File
# Begin Source File

SOURCE=.\Resource.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# Begin Source File

SOURCE=.\triangle.h
# End Source File
# Begin Source File

SOURCE=.\vcr.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\res\MDoubleBufferingLite.ico
# End Source File
# Begin Source File

SOURCE=.\res\MDoubleBufferingLite.rc2
# End Source File
# End Group
# Begin Source File

SOURCE=.\ReadMe.txt
# End Source File
# End Target
# End Project
# Section MDoubleBufferingLite : {B9475B93-8F25-11D0-914B-00A024D24992}
# 	2:21:DefaultSinkHeaderFile:Digitizer.h
# 	2:16:DefaultSinkClass:CDigitizer
# End Section
# Section MDoubleBufferingLite : {F2E7BDE4-B006-11D0-9162-00A024D24992}
# 	2:5:Class:CGraphicContext
# 	2:10:HeaderFile:GraphicContext.h
# 	2:8:ImplFile:GraphicContext.cpp
# End Section
# Section MDoubleBufferingLite : {6D9F7F74-9658-11D0-BDB5-00608CC9F9FB}
# 	2:21:DefaultSinkHeaderFile:System.h
# 	2:16:DefaultSinkClass:CSystem
# End Section
# Section MDoubleBufferingLite : {03985968-6B33-11D0-AB4A-00608CC9CA57}
# 	2:21:DefaultSinkHeaderFile:Image.h
# 	2:16:DefaultSinkClass:CImage
# End Section
# Section MDoubleBufferingLite : {E9502373-9624-11D0-BDB4-00608CC9F9FB}
# 	2:21:DefaultSinkHeaderFile:Display.h
# 	2:16:DefaultSinkClass:CDisplay
# End Section
# Section MDoubleBufferingLite : {E1208DE4-A783-11D0-9161-00A024D24992}
# 	2:5:Class:CApplication
# 	2:10:HeaderFile:Application.h
# 	2:8:ImplFile:Application.cpp
# End Section
# Section MDoubleBufferingLite : {45BC0BC4-A6C5-11D0-BDD1-00608CC9F9FB}
# 	2:5:Class:CDisplay
# 	2:10:HeaderFile:Display.h
# 	2:8:ImplFile:Display.cpp
# End Section
# Section MDoubleBufferingLite : {6D9F7F72-9658-11D0-BDB5-00608CC9F9FB}
# 	2:5:Class:CSystem
# 	2:10:HeaderFile:System.h
# 	2:8:ImplFile:System.cpp
# End Section
# Section MDoubleBufferingLite : {B9475B91-8F25-11D0-914B-00A024D24992}
# 	2:5:Class:CDigitizer
# 	2:10:HeaderFile:Digitizer.h
# 	2:8:ImplFile:Digitizer.cpp
# End Section
# Section MDoubleBufferingLite : {03985966-6B33-11D0-AB4A-00608CC9CA57}
# 	2:5:Class:CImage
# 	2:10:HeaderFile:Image.h
# 	2:8:ImplFile:Image.cpp
# End Section
# Section MDoubleBufferingLite : {F2E7BDE6-B006-11D0-9162-00A024D24992}
# 	2:21:DefaultSinkHeaderFile:GraphicContext.h
# 	2:16:DefaultSinkClass:CGraphicContext
# End Section
# Section MDoubleBufferingLite : {E1208DE6-A783-11D0-9161-00A024D24992}
# 	2:21:DefaultSinkHeaderFile:Application.h
# 	2:16:DefaultSinkClass:CApplication
# End Section
