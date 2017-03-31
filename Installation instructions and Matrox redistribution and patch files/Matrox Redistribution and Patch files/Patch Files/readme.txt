--------------------------------------------------------------------
	Matrox Imaging Library MeteorII/1394 driver
	              Spetember 14th, 2005
--------------------------------------------------------------------

This Hotfix 25 is needed to run 1394b camera on the Meteor2/1394 or 
on any third party card running Matrox 1394 driver.


- Windows XP or Windows XP+SP1 : Install Matrox 1394 hotfix25

- Windows XP+SP2 : 

	o  Install Microsoft Windows XP+SP2 update KB885222 : can be found on Microsoft website at 

           http://support.microsoft.com/default.aspx?scid=kb;en-us;885222 

	o  Install Matrox 1394 HotFix 25

 

- Windows 2k:
	Put:
	o  image_mtx.inf to "c:\WINNT\INF"  &  
                         to "C:\Program Files\Matrox Imaging\drivers\win2000"

	o  mf1394core.sys to "C:\Program Files\Matrox Imaging\drivers\Meteor_II_1394\drivernt"

	o  mil.dll to "c:\WINNT\system32" & 
                   to "c:\program Files\Matrox Imaging\mil\library\winnt\msc\dll"

	o  Mil.h to "c:\program Files\Matrox Imaging\intellicam\mil\include"

	o  mil1394.dll to "c:\winnt\system32" & 
                       to "c:\program files\matrox imaging\mil\library\winnt\msc\dll"
	

	o  MTX1394.sys to "c:\winnt\system32\drivers" &
                       to "c:\\program files\matrox imaging\drivers\meteor_II_1394\drivernt" &
		       to "c:\\program files\matrox imaging\drivers\meteor_II_1394\wdm"
