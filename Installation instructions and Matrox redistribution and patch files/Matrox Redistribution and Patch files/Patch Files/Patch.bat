:: MatroxPatch.bat
::
:: Copies patch files for MIL 7.5's Hotfix 25 into proper spots in Program Files folder and System folder.  
:: Using XCOPY to allow overwriting read-only files if present.
@echo off

:: Try "help xcopy" or "help copy" for info

:: Program Files
xcopy MTX1394.sys "c:\program files\Matrox imaging\drivers\meteor_II_1394\drivernt\" /R /Y
xcopy mf1394core.sys "c:\program files\Matrox imaging\drivers\meteor_II_1394\drivernt\" /R /Y

xcopy MTX1394.sys "c:\program files\Matrox imaging\drivers\meteor_II_1394\wdm\" /R /Y

xcopy image_mtx.inf "c:\program files\Matrox Imaging\drivers\win2000\" /R /Y


:: Intellicam and mil folders should probably only be present if the ActiveMIL-Lite (or better) is installed.  Copy files anyway for simplicity.
xcopy Mil.h "c:\program files\Matrox Imaging\intellicam\mil\include\" /R /Y

xcopy mil.dll "c:\program files\Matrox Imaging\mil\library\winnt\msc\dll\" /R /Y
xcopy mil1394.dll "c:\program files\Matrox Imaging\mil\library\winnt\msc\dll\" /R /Y


:: System Root (Windows or WINNT) files
xcopy image_mtx.inf "%SystemRoot%\INF\" /R /Y

xcopy mil.dll "%SystemRoot%\system32\" /R /Y
xcopy mil1394.dll "%SystemRoot%\system32\" /R /Y

xcopy MTX1394.sys "%SystemRoot%\system32\drivers\" /R /Y

xcopy mil.ini "%SystemRoot%\" /R /Y


@echo on