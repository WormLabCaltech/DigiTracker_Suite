                     Sentinel System Drivers Version 5.39                                                  README.TXT File
              Copyright (c) 1991-2000 Rainbow Technologies
                          All Rights Reserved

 Thank you for choosing Sentinel System Drivers from Rainbow Technologies!
 The Sentinel System Drivers provide a communication path between your
 protected application and the Sentinel key.  The driver you install depends
 on the operating system you are using.

 This readme file describes the installation procedures for all Sentinel
 System Drivers.  See the appropriate section for the procedure about the
 driver that you are installing.

 This README file provides information on product installation for all
 Sentinel System Drivers, new features, last-minute news, and where to go for
 more information or to report problems.

-----------------------
 TABLE OF CONTENTS
-----------------------

  1.0 Installing and Configuring the Product
      1.1 Compatibility
      1.2 Quick Installation
      1.3 Windows NT Driver 
          1.3.1 Windows NT Driver Installation
          1.3.2 Windows NT Driver Configuration
          1.3.3 Windows NT Driver Removal
          1.3.4 Windows NT DOS Device Driver
      1.4 Windows 3.X
          1.4.1 Windows 3.X Driver Installation
          1.4.1 Windows 3.X Driver Configuration
          1.4.1 Windows 3.X Driver Removal
      1.5 OS/2 Driver
          1.5.1 OS/2 Driver Installation
          1.5.2 OS/2 Driver Configuration
      1.6 Windows 9X
          1.6.1 Windows 9X Driver Installation
          1.6.2 Windows 9X Driver Configuration
          1.6.3 Windows 9X Driver Removal
      1.7 Autodetecting Setup Program          
  2.0 What's New in This Release?
      2.1 Problems Fixed
  3.0 Known Problems
  4.0 Where to Go Next?
  5.0 Reporting Problems

-------------------------------
 1.0 INSTALLING THE PRODUCT
-------------------------------

 This version of the Sentinel System Driver includes an updated installation
 program that is based on the Windows Installer.  It supports Windows 9x,
 ME, NT & 2000 systems and is the preferred method for installing on those
 operating systems.
 
 The old installation program is also provided in the \LEGACY subdirectory of
 the driver CD.  It can be used to install the driver on all supported 
 operating systems including those supported by the new installation program.
   
 This document describes the installation proceedure for the old installation
 program.  For information regarding the new Windows installer, please refer 
 to the documentation located in the root directory of this CD.

                  ************* IMPORTANT NOTE ***************

 It is important to note that the two installation methods cannot be mixed 
 together.  All files and directories under the \LEGACY subdirectory on the 
 driver CD are for the old method of installation.

                  ************* IMPORTANT NOTE ***************

--------------------------
 1.1 Compatibility
--------------------------
 
 This version of the Sentinel System Driver is fully backward compatible with
 all of the software that was supported by the previous release.
 
------------------------
 1.2 Quick Installation 
------------------------

 The easiest way to integrate the driver installation program with the 
 installation program for an application is to do the following:
 
 1. Copy the entire contents of the \LEGACY subdirectory on the CD
    to the installation media for the application.
 2. Execute SETUP.EXE from the installer for the application.
 
Notes:  
 1. If the SuperPro USB device will be supported then the command line
    for SETUP.EXE must include the "/USB" switch.  
 2. The "/P" switch may be necessary to specify the location of the driver
    files on the application's installation media.

-----------------------
 1.3 Windows NT Driver 
-----------------------
 
 This section covers the installation, configuration and removal of the Sentinel
 System Driver for the Windows NT operating system.
 
Notes:
 1.  Administrative privilege is required to install, configure or remove the 
     Sentinel System Driver for Windows NT.
     
 2.  Subsequent sections of this document will refer to the program used to 
     install, configure or remove the Sentinel System Driver for the Windows NT
     operating system generically as the "NTsetup" program.  It is used to 
     refer to the following platform specific programs:
     
     SETUPX86 is for Intel x86 systems
     SETUPPPC is for PowerPC systems
     SETUPAXP is for DEC Alpha systems
     
 3.  The setup program can be found on the Sentinel System Driver CD in the 
     \LEGACY\WIN_NT subdirectory.  After installation it can be found in the 
     %SYSTEMROOT%\SYSTEM32\RNBOSENT subdirectory.  "%SYSTEMROOT%" refers to the
     directory where Windows NT is installed and is usually WINNT.

--------------------------------------
 1.3.1 Windows NT Driver Installation 
--------------------------------------

 1.  Run the NTsetup program.  If started from a command prompt the following 
     command line options are supported:
    
     /q     Quiet mode. 
            Normal dialogs are not displayed but error messages will be 
            displayed.
        
     /e     Suppress all messages. (Overwrites the /q switch)
            Both normal dialogs and error messages not displayed.
            Look for non-zero return code from the installer so installation 
            error can be detected.
        
     /pxxx  Path, where xxx is the path of files to be installed.
            Specify the path of files to be installed.  Otherwise, files will 
            be copied from the default directory.
           
     /o     Overwrite the existing Sentinel Driver.  By default, if the 
            existing driver is newer than the one to be installed, the 
            installer will not copy over it.
           
     /USB   Install USB driver support (Windows 2000 on Intel platforms only)
    
     /v     Do not install the virtual device driver (VDD).  The VDD in only 
            necessary for older DOS and Win16 applications.

     Optionally, an integrated setup program SETUP.EXE, is provided in the root
     directory of the driver software.  It autodetects the operating system and 
     runs the correct driver setup program automatically.  Please refer to the 
     "Autodetecting Setup Program" section in this document for more details.

     If the /q command line option is used then the driver will be installed
     and the NTsetup program will exit.  The remaining steps in this procedure
     can do not apply.
     
 2.  A window with the title bar "Rainbow Technologies Sentinel" is displayed.

 3.  Click "Functions" and then "Install Sentinel Driver" from the menu bar.

 4.  A dialog box with the default path for the NT driver is displayed.
     Change the drive letter and path if necessary and click "OK".

 5.  The Sentinel Driver and associated files are copied to the hard disk.

 6.  When complete, a dialog box with the message "Driver Installed!" will be
     displayed.

 7.  Click "OK" to continue.

 8.  Select "Functions" and then "Quit" from the menu bar to exit the 
     installation program.

-------------------------------------------
 1.3.1     Windows NT Driver Configuration 
-------------------------------------------

 The Sentinel System Driver for Windows NT can be configured as follows:

 1.  Run the NTsetup program.

 2.  Click "Functions" and then "Configure Sentinel Driver" from the menu bar.
     A window with the title bar "Sentinel Driver" will be displayed.

 3.  Click the "Edit" button to edit an existing parallel port setting, the 
     "Add" button to add a new parallel port setting, or the "Help" button to
     get help.  
     
 4.  Click "OK" to close the port configuration.

 5.  If any configuration changes were made, a dialog box with the message 
     "You are about to change the settings of this port.  Click 'OK' to 
     continue, 'Cancel' to go back."  will appear.  Click OK to make the 
     changes.
     
 6.  Click "OK" to continue.

 7.  Click "Functions" and then "Quit" from the menu bar to exit the 
     installation program.

-------------------------------------
 1.3.2     Windows NT Driver Removal 
-------------------------------------

 1.  Run the NTsetup program using the /q /u command line options to quietly
     remove the driver.
      
     or
      
     Run the NTsetup program.
        
 2.  Click "Functions" and then "Remove Sentinel Driver" from the menu bar.
  
 3.  A dialog box with the message "Are you sure you want to remove the 
     driver?" will be displayed.  Click OK to remove the driver.
      
 4.  A dialog box with the message "Sentinel Driver removed" will be displayed.  
     Click OK.
      
 5.  Click "Functions" and then "Quit" from the menu bar to exit the 
     installation program.

Note:  
 Some files may not be removed until the computer has been restarted.
 
----------------------------------------
 1.3.3     Windows NT DOS Device Driver
----------------------------------------

 It is possible, though unlikely, that on some systems, applications using
 the Watcom C/C++ with Rational DOS/4G and Microsoft Visual C/C++ with Phar
 Lap TNT DOS Extender may be unable to communicate with the Windows NT
 Device Driver.  To remedy this cituation, a DOS Device Driver is  provided 
 that allows the protected application to communicate with the Windows NT
 Device Driver on systems where it otherwise could not.

 The DOS Device Driver can be installed as follows:

 1.  Copy the file SENTDOS.SYS to the target system's hard disk.
 
 2.  Add the following statement to the custom Config file used by the  
     application's PIF file, or if the application does not use a custom 
     Config file, to the system's CONFIG.NT file.

     device=%path%\sentdos.sys

     where %path% is the actual path where SENTDOS.SYS resides

------------------------------
 1.4       Windows 3.X Driver
------------------------------
 
 This section covers the installation, configuration and removal of the 
 Sentinel System Driver for the Windows 3.X operating system.
 
Note:
 The path to the driver on the distribution CD is as follows:
 
 {CD-ROM DRIVE}:\LEGACY\WIN_31\INSTALL.EXE 
 
 where {CD-ROM DRIVE} is the drive letter that corresponds to CD-ROM drive
 
-------------------------------------------
 1.4.1     Windows 3.X Driver Installation 
-------------------------------------------

 1.  Click the "File" and then "Run..." menu under the Program Manager.

 2.  Type the path to the installation program, INSTALL.EXE, and then click OK.
     
     The following command line options are supported:
     
     /q     Quiet mode. 
            Normal dialogs (warning, information) are not displayed.
            Error messages are displayed.
            
     /pxxx  Path, where xxx is the path of files to be installed.
            Specify the path of files to be installed.  Otherwise, files will 
            be copied from the default directory.
            
     /o     Overwrite the existing Sentinel Driver.  By default, if the 
            existing driver is newer than the one to be installed, the 
            installer will not copy over it.

     Optionally, an integrated setup program SETUP.EXE, is provided in the root
     directory of the driver software.  It autodetects the operating system and 
     runs the correct driver setup program automatically.  Please refer to the 
     "Autodetecting Setup Program" section in this document for more details.

  4.  Follow the installation instructions.

  5.  The driver's default settings can be modified if necessary by modifying 
      the SYSTEM.INI file.  See the Windows 3.X Driver Configuration section in
      this document for details.

  6.  When the installation is complete, restart Windows.

Windows 3.X Driver Installer Return Values
------------------------------------------

  When installation is complete the installer will broadcast a message
  to all top level tasks.  The message RNBO_INSTALL_DONE will be sent.
  The first number will be 5555h and the second number will be one of the
  following:

  0  -- RNBO_SUCCESS                Install/uninstall successful
  1  -- RNBO_CLASS_REGISTER_ERROR   RegisterClass call failed
  2  -- RNBO_CREATE_WINDOW_ERROR    CreateWindow call failed
  3  -- RNBO_INIT_FAILED            Cannot initialize the installer
  4  -- RNBO_BAD_OS                 Running under wrong operating system
  5  -- RNBO_NO_DRIVER              Cannot find the driver source file
  7  -- RNBO_NEWER_DRIVER_EXISTS    The existing driver is newer
  8  -- RNBO_SYSINI_READONLY        The SYSTEM.INI is write protected
  9  -- RNBO_SYS_INI_NOT_FOUND      Cannot find the SYSTEM.INI file
  10 -- RNBO_SYS_INI_UPDATE_FAILED  The SYSTEM.INI file cannot be updated
  11 -- RNBO_USER_TERMINATED        Installation terminated by the user
  15 -- RNBO_UNINSTALL_FAILED       Cannot uninstall the driver

Manual Installation of Sentinel System Driver for Windows 3.X
-------------------------------------------------------------

 Although not recommended, the Sentinel System Driver for Windows 3.X can be
 manually installed as follows:

 1.  Copy SENTINEL.386 to the windows directory.

 2.  Add the following line under the [386Enh] section in the SYSTEM.INI
     file located in the windows directory.  The following example assumes that
     the windows directory is C:\WINDOWS.

     DEVICE=C:\WINDOWS\SENTINEL.386

--------------------------------------------
 1.4.1     Windows 3.X Driver Configuration
--------------------------------------------

 The Sentinel System Driver for Windows 3.X is configured using the fields 
 in the SYSTEM.INI file.  Data can be defined for all ports up to a maximum
 of 4 ports.  The section [SentinelSetup] contains global configuration 
 data, i.e. autotiming  delay, interrupts to mask, etc. The section names 
 [SentinelSetupPortA] through [SentinelSetupPortZ] contain per-port 
 configuration data. The port address field must be defined for the 
 configuration data under these sections to be used.

;Windows 3.X System Driver Sample SYSTEM.INI File settings
;
;
; Sentinel Device Driver Configuration Options for Windows 3.X drivers.
;
; ---------------------------
; GENERAL CONFIGURATION DATA:
; ---------------------------
;
; General driver configuration and parameters are defined as follows:
;
; Section Name: [SentinelSetup]
;
; Parameters  :
;
;         MachineType - Defines the machine type the driver is to be
;                       configured for. The valid values are:
;                       
;              * 0 - Autodetect machine type.
;                1 - Defines IBM and IBM compatible machines.
;                2 - Defines NEC PC-9800 series machines.
;                3 - Defines Fujitsu FMR series machines.
;
;              * Default.
;
;                Example:
;
;                [SentinelSetup]
;                MachineType = 1        ; Configure driver for IBM machines.
;
;         Delay - Defines the number of machine loops to use to
;                 create a 2 microsecond delay. The valid values
;                 are:
;
;              * 0 - Use autotiming.
;                1 through 65535 - Number of loops to use to create a
;                                  2us delay.
;
;              * Default.
;
;                Example:
;               
;                [SentinelSetup]
;                Delay = 100                ; Use 100 loops to create a 2us
;                                           ; delay.
;
;         MaskInterrupts - Defines the set of interrupts to mask when
;                          accessing the port (used for port contention).
;                          This is defined as a hexadecimal bit mask with
;                          the following values:
;
;                0 - Disable interrupt masking.
;              * 1 - Mask LPT1 printer interrupt.
;                2 - Mask LPT2 printer interrupt.
;              * 4 - Mask TIMER interrupt.
;
;              * Default interrupts masked.
;
;                To disable a set of interrupts, add the individual
;                bit masks together to form the result mask.
;
;                Example:
;
;                [SentinelSetup]
;                MaskInterrupts = 5        ; Mask LPT1 and TIMER interrupts.
;
; ------------------------
; PORT CONFIGURATION DATA:
; ------------------------
;
; Per-Port configuration and parameters are defined as follows:
;
; Section Name: [SentinelSetupPort?]
;
; where ? is the port to configure defined as A through Z. Any port
; configuration defined overrides the default port configuration for
; the driver. Only the first 4 port configuration records (starting
; alphabetically with A) are used. The PortAddress parameter must be
; defined for the port configuration record to be used.
;
; Parameters  :
;
;       PortAddress - Defines the base address for a port. The
;                     parameter must be defined for the remaining
;                     parameters to be used. The value must be
;                     defined in hexadecimal. The valid values are:
;
;                0 - Disables setup record.
;                1 through FFFE - Used as actual port address.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC            ; Define the first port to use
;                                             ; as 0x03BC.
;
;       PortContentionMethod - Defines the contention method used to
;                              gain access to a port. This is defined as
;                              a hexadecimal bit mask with the following
;                              values:
;
;                0 - Disable all port contention methods.
;                1 - Use system port contention handler if
;                             available.
;                             (Not available for Windows 3.X).
;                4 - Disable system interrupts.
;                8 - Mask interrupts as defined by the
;                    MaskInterrupts parameter under the
;                    [SentinelSetup] section (see above).
;               10 - Use windows critical section handler.
;                    (Not available for OS/2).
;               20 - Poll the port for access.
;               40 - Enable collision detection.
;       * 80000000 - Use driver defined values.
;
;              * Default.
;
;                To enable a set of contention methods, add the individual
;                bit masks together to form the resulting contention method.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC              ; Define the first port to use
;                                               ; as 0x03BC.
;                PortContentionMethod = 78      ; Enable the following:
;                                               ; mask interrupts,
;                                               ; Windows critical section,
;                                               ; port polling, and
;                                               ; collision detection.
;
;       PortType - Defines the type of parallel port. The valid values are:
;
;              * 0 - Autodetect port type.
;                1 - NEC PC-9800 series parallel port.
;                      (Only valid when MachineType = 2 (NEC PC9800)).
;                2 - Fujitsu FMR series parallel port.
;                      (Only valid when MachineType = 3 (Fujitsu)).
;                3 - IBM AT or PS/2 compatible parallel port
;                      (Only valid when MachineType = 1 (IBM)).
;                4 - IBM PS/2 compatible parallel port w/DMA
;                      (Only valid when MachineType = 1 (IBM)).
;                6 - IBM AT Low Power
;                      (Only valid when MachineType = 1 (IBM)).
;;
;              * Default.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC            ; Define the first port to use
;                                             ; as 0x03BC.
;                PortType = 3                 ; IBM AT type port.
;
;
;        PortContentionRetryInterval - Defines the number of milliseconds
;                                      to delay in-between retries on
;                                      contenting for a busy port. This
;                                      parameter is used in conjunction
;                                      with the PortContentionRetryCount
;                                      parameter (see below). The valid
;                                      values are:
;
;                0 through 65534 - number of milliseconds to
;                                  delay in-between retries of
;                                  contenting for a busy
;                                  port.
;
;                -1 - indefinite retry interval.
;
;              * Default is 300.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC               ; Define the first port to
;                                                ; use as 0x03BC.
;                PortContentionRetryInterval = 5 ; Delay 5 milliseconds
;                                                ; between retries on
;                                                ; a busy port.
;
;         PortContentionRetryCount - Defines the number of retries
;                                    to perform on a busy port.
;                                    Used in conjunction with the
;                                    PortContentionRetryInterval
;                                    parameter (see above). The valid
;                                    values are:
;
;                0 through 65534 - Number of retries to perform on a busy
;                                  port.
;
;                -1 - Indefinite retry count.
;
;              * Default is 100.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC              ; Define the first port to use
;                                               ; as 0x03BC.
;                PortContentionRetryInterval = 5; Delay 5 milliseconds
;                                               ; between retries on
;                                               ; a busy port.
;                                               ; port is owned
;                PortContentionRetryCount = -1  ; Indefinite retries.
;
;         DeviceRetryCount - Defines the number of retries
;                            to perform on a I/O request (query) if
;                            communications is interrupted (the
;                            collision detection contention method
;                            (see above) must be enabled for this parameter
;                            to be used). The valid values are:
;
;                0 through 65534 - Number of retries to perform.
;                             -1 - Indefinite retry count.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC              ; Define the first port to use
;                                               ; as 0x03BC.
;                DeviceRetryCount = -1          ; Indefinite retries.
;
;
;        ValidatePort - is a Boolean the defines whether the driver should
;                       validate the port's existence before using it. The
;                       valid values are:
;
;                0 - disable port validation.
;              * 1 - enable port validation.
;
;              * Default.
;***********************************************************************
[SentinelSetup]                                ; General config options
MachineType                 = 1                ; IBM machine
Delay                       = 0                ; Use autotiming
MaskInterrupts              = 0                ; Don't mask any interrupts

[SentinelSetupPortA]                           ; First port setup record
PortAddress                 = 3bc              ; port address to use
PortContentionMethod        = 80000000         ; use driver defined methods
PortType                    = 3                ; IBM AT type port
PortContentionRetryCount    = 0                ; disable contention rc
PortContentionRetryInterval = 0                ; disable contention ri
DeviceRetryCount            = -1               ; indefinite device rc
ValidatePort                = 0                ; don't validate the port

[SentinelSetupPortB]                           ; Second port setup record
;PortAddress                = 278              ; port address to use
PortAddress                 = 0                ; ignore this setup record
PortContentionMethod        = 80000000         ; use driver defined
                                               ; contention methods when
                                               ; accessing this port
PortType                    = 4                ; IBM PS/2 DMA type port
PortContentionRetryCount    = 0                ; disable contention rc
PortContentionRetryInterval = 0                ; disable contention ri
DeviceRetryCount            = -1               ; indefinite device rc
ValidatePort                = 0                ; don't validate the port

[SentinelSetupPortC]                           ; Second port setup record
PortAddress                 = 378              ; port address to use
PortContentionMethod        = 4                ; Disable system interrupts
                                               ; when accessing this port
PortType                    = 4                ; IBM PS/2 DMA type port

--------------------------------------
 1.4.2     Windows 3.X Driver Removal
--------------------------------------

 1.  Select File|Run under the Program Manager.

 2.  Type the path to the installation program INSTALL.EXE and the /u command
     line option and then click OK.  For example:
     
     D:\LEGACY\WIN_31\INSTALL /u
     
     where D: is the drive letter of the CD-ROM that contains the driver 
     distribution CD.
     
 3.  Follow the instructions to remove the driver.

-----------------------
 1.5       OS/2 Driver 
-----------------------

 This section covers the installation, configuration and removal of the 
 Sentinel System Driver for the OS/2 operating system.
 
Note:
 The path to the driver on the distribution CD is as follows:
 
 {CD-ROM DRIVE}:\LEGACY\OS2\INSTALL.CMD
 
 where {CD-ROM DRIVE} is the drive letter that corresponds to CD-ROM drive

------------------------------------
 1.5.1     OS/2 Driver Installation 
------------------------------------

 1.  Start a OS/2 windows by double clicking on the OS/2 Windows icon in the
     Command prompt folder.

 2.  Type the path to the installation program, INSTALL.CMD, and then click OK.
     
     Optionally, an integrated setup program SETUP.EXE, is provided in the root
     directory of the driver software.  It autodetects the operating system and 
     runs the correct driver setup program automatically.  Please refer to the 
     "Autodetecting Setup Program" section in this document for more details.

 3.  A dialog box with title "OS/2 Device Driver Installation" is displayed.

 4.  Click on "Install".

 5.  Select the "Rainbow OS/2 Device Driver".

 6.  Click on "OK" button.

 7.  After the driver has been installed, click on "Exit" to exit.

 8.  Click on "Yes" button when the dialog box with message "Exit The Program" 
     appears.

 9.  Restart OS/2.

 10. If any of the driver's default settings need to be changed, modify the
     DEVICE statement in the CONFIG.SYS file and create an .ini file
     containing the required parameters.  See the following section for
     details.

Manual Installation of Sentinel System Driver for OS/2
------------------------------------------------------

 Although not recommended, the Sentinel System Driver for Windows 3.X can be
 manually installed as follows:

 1.  Copy OS2\SENTINEL.SYS to the OS2 subdirectory.

 2.  Add the following line to the CONFIG.SYS file:
 
     DEVICE=C:\OS2\SENTINEL.SYS

     This assumes that the OS2 directory is C:\OS2.

-------------------------------------
1.5.1      OS/2 Driver Configuration
-------------------------------------

 The Sentinel System Driver for OS/2 is configured using the fields in the 
 configuration file.  The name of the configuration file is passed to the 
 driver via a command line argument.  The configuration file uses syntax 
 similar to that used by Windows for INI files. The configuration file uses 
 the same section names as defined for the Sentinel System Driver for Windows 
 3.X.  Data can be defined for all ports up to a maximum of 4 ports.  
 Configuration information can be written to a log file.

;OS/2 1.x/2.x/3.X System Driver Sample .ini File
;
;
; Sentinel Device Driver Configuration Options for OS/2 1.x/2.x driver.
;
; The OS/2 Sentinel Device Driver is installed through the OS/2
; CONFIG.SYS file by adding a DEVICE statement as follows:
;
; DEVICE=[PATH]\SENTINEL.SYS
;
; where [PATH] is the drive and directory where the SENTINEL.SYS driver
; resides.
;
; -----------------------
; COMMAND LINE ARGUMENTS:
; -----------------------
;
; DEVICE=[PATH]\SENTINEL.SYS [[/Q] [/C=<config file>] [/L=<log file>]]
;
;        where:
;       
;                /Q  - Suppresses the sign-on banner.
;                /C= - Defines the configuration file to use. The format of
;                        a configuration file is defined below.
;                /L= - Defines the path and file name of where to log the
;                        driver's current configuration results to.
;
;
;        Example:
;
;        DEVICE=C:\SENTINEL.SYS /Q /C=C:\SENTINEL.INI /L=C:\SENTINEL.LOG
;
;        The above command line arguments perform the following functions:
;                Suppress the sign-on banner
;                Use the configuration parameters in C:\SENTINEL.INI
;                Log the current driver configuration to C:\SENTINEL.LOG
;
; --------------------------
; CONFIGURATION FILE FORMAT:
; --------------------------
;
; ---------------------------
; GENERAL CONFIGURATION DATA:
; ---------------------------
;
; General driver configuration and parameters are defined as follows:
;
; Section Name: [SentinelSetup]
;
; Parameters  :
;
;         LogFileName - Defines the path and file name used to log the
;                       configuration results of the driver during
;                       installation. This parameter overrides the
;                       corresponding command line argument, /L=.
;
;                Example:
;
;                [SentinelSetup]
;                LogFileName = C:\SENTINEL.LOG ; log output results to
;                                                        ; this file.
;
;         SignOnMessage - A Boolean value defining whether the sign on
;                         banner should be displayed. This parameter
;                         overrides the corresponding command line
;                         argument, /Q. The valid values are:
;
;                0 - disable banner display.
;                1 - enable banner display.
;
;                Example:
;
;                [SentinelSetup]
;                SignOnMessage = 1                    ; enable sign-on banner
;
;         MachineType - Defines the machine type the driver is to be
;                       configured for. The valid values are:
;                       
;              * 0 - Autodetect machine type.
;                1 - Defines IBM and IBM compatible machines.
;                2 - Defines NEC PC-9800 series machines.
;                3 - Defines Fujitsu FMR series machines.
;
;              * Default.
;
;                Example:
;
;                [SentinelSetup]
;                MachineType = 1        ; Configure driver for IBM machines.
;
;         Delay - Defines the number of machine loops to use to
;                 create a 2 microsecond delay. The valid values
;                 are:
;
;              * 0 - Use autotiming.
;                1-65535 - Number of loops to use to create a 2us delay.
;
;              * Default.
;
;                Example:
;              
;                [SentinelSetup]
;                Delay = 100                ; Use 100 loops to create a 2us
;                                           ; delay.
;
;        MaskInterrupts - Defines the set of interrupts to mask when
;                         accessing the port (used for port contention).
;                         This is defined as a hexadecimal bit mask with the
;                         following values:
;
;                0 - Disable interrupt masking.
;              * 1 - Mask LPT1 printer interrupt.
;                2 - Mask LPT2 printer interrupt.
;              * 4 - Mask TIMER interrupt.
;
;              * Default interrupts masked.
;
;                To disable a set of interrupts, add the individual bit masks
;                together to form the result mask.
;
;                Example:
;
;                [SentinelSetup]
;                MaskInterrupts = 5        ; Mask LPT1 and TIMER interrupts.
;
; ------------------------
; PORT CONFIGURATION DATA:
; ------------------------
;
; Per-Port configuration and parameters are defined as follows:
;
; Section Name: [SentinelSetupPort?]
;
; Where ? is the port to configure defined as A through Z. Any port
; configuration defined overrides the default port configuration for
; the driver. Only the first 4 port configuration records (starting
; alphabetically with A) are used. The PortAddress parameter must be
; defined for the port configuration record to be used.
;
; Parameters  :
;
;        PortAddress - Defines the base address for a port. The
;                      parameter must be defined for the remaining
;                      parameters to be used. The value must be
;                      defined in hexadecimal. The valid values are:
;
;                             0 - Disables setup record.
;                1 through FFFE - Used as actual port address.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC              ; Define the first port to use
;                                               ; as 0x03BC.
;
;        PortContentionMethod - Defines the contention method used to
;                               gain access to a port. This is defined as
;                               a hexadecimal bit mask with the following 
;                               values:
;
;                 0 - Disable all port contention methods.
;                 1 - Use system port contention handler if available.
;                     (Not available for Windows 3.X).
;                 4 - Disable system interrupts.
;                 8 - Mask interrupts as defined by the MaskInterrupts
;                     parameter under the [SentinelSetup] section
;                     (see above).
;                10 - Use windows critical section handler.
;                     (Not available for OS/2).
;                20 - Poll the port for access.
;                40 - Enable collision detection.
;        * 80000000 - Use driver defined values.
;
;              * Default.
;
;                To enable a set of contention methods, add the
;                individual bit masks together to form the
;                resulting contention method.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC              ; Define the first port to use
;                                               ; as 0x03BC.
;                PortContentionMethod = 79      ; Enable the following:
;                                               ; mask interrupts,
;                                               ; Windows critical section,
;                                               ; port polling,
;                                               ; collision detection, and
;                                               ; system port contention
;                                               ; handler.
;
;        SystemPortNumber - Defines the logical port number to use
;                           for the defined port address when
;                           system contention driver is installed.
;                           The valid values are:
;
;
;                0-65534 - The logical port number to use.
;                   * -1 - Autodetect the logical port number.
;
;              * Default.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC              ; Define the first port to use
;                                               ; as 0x03BC.
;                PortContentionMethod = 79      ; Enable the following:
;                                               ; mask interrupts,
;                                               ; Windows critical section,
;                                               ; port polling,
;                                               ; collision detection, and
;                                               ; system port contention
;                                               ; handler.
;                SystemPortNumber = 0           ; First installed port.
;
;       PortDriver - Defines the system driver that handles system
;                    port contention for the parallel ports. This
;                    option is only available on version 2.11 and
;                    above of OS/2. The valid value is a string
;                    which length does not exceed 8 characters.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC               ; Define the first port to use
;                                                ; as 0x03BC.
;                PortContentionMethod = 1        ; Use system port contention
;                                                ; handler.
;                PortDriver = LPT1               ; Use the LPT1 driver for
;                                                ; system port contention.
;
;
;        PortType - Defines the type of parallel port. The valid values are:
;
;              * 0 - Autodetect port type.
;                1 - NEC PC-9800 series parallel port.
;                    (Only valid when MachineType = 2 (NEC PC9800)).
;                2 - Fujitsu FMR series parallel port.
;                    (Only valid when MachineType = 3 (Fujitsu)).
;                3 - IBM AT or PS/2 compatible parallel port
;                    (Only valid when MachineType = 1 (IBM)).
;                4 - IBM PS/2 compatible parallel port w/DMA
;                    (Only valid when MachineType = 1 (IBM)).
;                6 - IBM AT Low Power
;                    (Only valid when MachineType = 1 (IBM)).
;
;              * Default.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC               ; Define the first port to use
;                                                ; as 0x03BC.
;                PortType = 3                    ; IBM AT type port.
;
;        PortContentionRetryInterval - Defines the number of milliseconds
;                                      to delay in-between retries on
;                                      contenting for a busy port. This
;                                      parameter is used in conjunction
;                                      with the PortContentionRetryCount
;                                      parameter (see below). The valid
;                                      values are:
;
;                0 through 65534 - number of milliseconds to delay in-between
;                                  retries of contending for a busy port.
;
;                             -1 - indefinite retry interval.
;
;              * Default is 300.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC               ; Define the first port to use
;                                                ; as 0x03BC.
;                PortContentionRetryInterval = 5 ; Delay 5 milliseconds
;                                                ; between retries on
;                                                ; a busy port.
;
;        PortContentionRetryCount - Defines the number of retries to perform
;                                   on a busy port.  Used in conjunction with
;                                   the PortContentionRetryInterval parameter
;                                   (see above). The valid values are:
;
;                0-65534 - number of retries to perform on a busy port.
;
;                     -1 - indefinite retry count.
;
;              * Default is 100.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC               ; Define the first port to use
;                                                ; as 0x03BC.
;                PortContentionRetryInterval = 5 ; Delay 5 milliseconds
;                                                ; between retries on
;                                                ; a busy port.
;                                                ; port is owned
;                PortContentionRetryCount = -1   ; indefinite retries.
;
;        DeviceRetryCount - Defines the number of retries to perform on a I/O
;                           request (query) if communications is interrupted
;                           (the collision detection contention method
;                           (see above) must be enabled for this parameter
;                           to be used). The valid values are:
;
;                0 through 65534 - number of retries to perform.
;                             -1 - indefinite retry count.
;
;              * Default is 300.
;
;                Example:
;
;                [SentinelSetupPortA]
;                PortAddress = 3BC              ; Define the first port to use
;                                               ; as 0x03BC.
;                PortContentionMethod = 78      ; Enable the following:
;                                               ; mask interrupts,
;                                               ; Windows critical section,
;                                               ; port polling, and
;                                               ; collision detection.
;                DeviceRetryCount     = -1      ; indefinite retries.
;
;
;        ValidatePort - is a Boolean the defines whether the driver should
;                       validate the port's existence before using it. The
;                       valid values are:
;
;                0 - disable port validation.
;              * 1 - enable port validation.
;
;              * Default.
;***********************************************************************
[SentinelSetup]                                    ; General config options
SignOnMessage                    = 1               ; Enable sign-on banner
LogFileName                      = C:\SENTINEL.LOG ; log current configuration
MachineType                      = 1               ; IBM machine
Delay                            = 0               ; Use autotiming
MaskInterrupts                   = 0               ; Don't mask any interrupts

[SentinelSetupPortA]                               ; First port setup record
PortAddress                      = 3bc             ; port address to use
PortContentionMethod             = 80000000        ; use driver defined methods
PortType                         = 3               ; IBM AT type port
PortContentionRetryCount         = 0               ; disable contention rc
PortContentionRetryInterval      = 0               ; disable contention ri
DeviceRetryCount                 = -1              ; indefinite device rc
SystemPortNumber                 = 0               ; system logical port number
PortDriver                       = LPT1            ; system port contention dvr
ValidatePort                     = 0               ; don't validate the port

[SentinelSetupPortB]                               ; Second port setup record
;PortAddress                     = 278             ; port address to use
PortAddress                      = 0               ; ignore this setup record
PortContentionMethod             = 80000000        ; use driver defined
                                                   ; contention methods when
                                                   ; accessing this port
PortType                         = 4               ; IBM PS/2 DMA type port
PortContentionRetryCount         = 0               ; disable contention rc
PortContentionRetryInterval      = 0               ; disable contention ri
DeviceRetryCount                 = -1              ; indefinite device rc
ValidatePort                     = 0               ; don't validate the port

[SentinelSetupPortC]                               ; Second port setup record
PortAddress                      = 378             ; port address to use
PortContentionMethod             = 4               ; Disable system interrupts
                                                   ; when accessing this port
PortType                         = 4               ; IBM PS/2 DMA type port

-----------------------------
 1.6       Windows 9X Driver
-----------------------------

 This section covers the installation, configuration and removal of the 
 Sentinel System Driver for the Windows 9X operating system.
 
Note:
 The path to the driver on the distribution CD is as follows:
 
 {CD-ROM DRIVE}:\LEGACY\WIN_9x\INSTALL.CMD
 
 where {CD-ROM DRIVE} is the drive letter that corresponds to CD-ROM drive

------------------------------------------
 1.6.1     Windows 9X Driver Installation
------------------------------------------

 1.  Run the SENTW9X.EXE setup program.  If started from a command prompt the 
     following command line options are supported:

     /q     Quiet mode. 
            Normal dialogs are not displayed but error messages
            will be displayed.
            
     /e     Suppress all messages. (Overwrites the /q switch)
            Both normal dialogs and error messages not displayed.
            Look for non-zero return code from the installer so
            installation error can be detected.
     
     /pxxx  Path, where xxx is the path of files to be installed.
            Specify the path of files to be installed.
            Otherwise, files will be copied from the default directory.
            
     /o     Overwrite the existing Sentinel Driver.  By default, if
            the existing driver is newer than the one to be installed,
            the installer will not copy over it.
            
     /USB   Install USB driver support.

     Optionally, an integrated setup program SETUP.EXE, is provided in the root
     directory of the driver software.  It autodetects the operating system and
     runs the correct driver setup program automatically.  Please refer to the 
     "Autodetecting Setup Program" section in this document for more details.

     If the /q command line option is used then the driver will be installed
     and the SENTW9X.EXE program will exit.  The remaining steps in this 
     procedure do not apply.
     
 2.  A window with the title bar "Rainbow Technologies Sentinel" is displayed.

 3.  Click "Functions" and then "Install Sentinel Driver" from the menu bar.

 4.  A dialog box with the default path for the driver is displayed.
     Change the drive letter and path if necessary and click "OK".

 5.  The Sentinel Driver and associated files are copied to the hard disk.

 6.  When complete, a dialog box with the message "Driver Installed!" and 
     "Restart your system." will be displayed.

 7.  Click "OK" to continue.

 8.  Select "Functions" and then "Quit" from the menu bar to exit the 
     installation program.  Restart Windows 9X.

 9.  The following files have been created on your hard disk:
 
     WINDOWS\SYSTEM\SENTINEL.VXD
     WINDOWS\SYSTEM\RNBOSENT\SENTW9X.EXE
     WINDOWS\SYSTEM\RNBOSENT\SENTW9X.DLL
     WINDOWS\SYSTEM\RNBOSENT\SENTW9X.HLP
     WINDOWS\SYSTEM\RNBOSENT\SENTSTRT.EXE
     WINDOWS\SYSTEM\RNBOSENT\SENTINEL.SAV


Manual Installation of Sentinel System Driver for Windows 9X
------------------------------------------------------------

 Although not recommended, the Sentinel System Driver for Windows 3.X can be
 manually installed as follows:

 1.  If the application to be protected by a Sentinel device is a Win32 
     application, go to step 6.

 2.  Run Registry Editor (REGEDIT.EXE in Windows 9X root directory).

 3.  Select 
     HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices.
     (Clicking on the expansion box next to the item name expands the branch )

 4.  With RunServices highlighted, click on "Edit" menu and select "New", 
     then select "String Value" from its submenu.  Registry Editor adds an 
     entry "New Value #1" to the end of the list.  Rename it to "RNBOStart".  
     (To rename a key, click it with right mouse button, select Rename, and 
     type the new name) Double-click on it to bring up "Edit String" dialog 
     box.  Type "%system_root%\system\rnbosent\sentstrt.exe" and click OK, 
     where %system_root% is the name of the Windows 9X root directory.

 5.  Alternatively, the file sentstrt.exe can be copied to the
     %system_root%\startm~1\programs\startup subdirectory.

 6.  Copy the file "SENTINEL.VXD" from the "WIN_9X\" directory on the
     Sentinel Driver diskette to the %system_root%\system directory.
     Create the subdirectory %system_root%\system\rnbosent.
     Copy all other files from the "WIN_9X\" directory to the
     %system_root%\system\rnbosent subdirectory.  Also copy "SENTINEL.VXD"
     to %system_root%\system\rnbosent as "SENTINEL.SAV", this is your
     back-up file to the system driver.

 7.  The installation is now complete.
     To use the driver with Win32 applications, simply start the application.
     For all other applications (DOS and/or Win16), restart Windows 9X. 
     
     Note:
     The driver can dynamically be loaded by running SENTSTRT.EXE, as this
     will remove the restriction to re-boot the machine after installation.

-------------------------------------------
 1.6.1     Windows 9X Driver Configuration
-------------------------------------------

 1.  Start Windows 9X.  Select "Run" from the Taskbar and run the file
     SENTW9X.EXE in the WINDOWS\SYSTEM\RNBOSENT subdirectory.

 2.  Select "Configure Sentinel Driver" from the "Functions" menu.

 3.  Click the "Edit" button to edit an existing parallel port setting, the 
     "Add" button to add a new parallel port setting, or the "Help" button 
     to get help.  
     
 4.  Click "OK" to close the port configuration.

 5.  Restart Windows 9X for the changes to take effect.

-------------------------------------
 1,6.2     Windows 9X Driver Removal
-------------------------------------

 1.  Start Windows 9X.  Select "Run" from the Taskbar and run the file
     SENTW9X.EXE in the WINDOWS\SYSTEM\RNBOSENT subdirectory (or from the
     original distribution media).  Alternatively, SETUP.EXE /U can be ran
     to remove the driver as well. The driver can be removed via the 
     command-line options or the pull-down menu.

     a. Command-line options:
     
        SENTW9X.EXE /q /u   - Quietly removes the existing driver. 
        
        or
        
        SETUP.EXE /q /u     - Quietly removes the existing driver.

     b. Pull-down menu:
     
        Select "Remove Sentinel Driver" from the "Function" menu.

 2.  When complete, a dialog box with the message "Sentinel Driver Removed"
     is displayed.

 3.  Click "OK" to continue.

---------------------------------------
 1.7.0     Autodetecting Setup Program
---------------------------------------

 SETUP.EXE is a 16-bit Windows program designed to detect the active OS, and 
 launch the appropriate Sentinel System Installation program.  SETUP can 
 launch the OS/2, Win3X, Win9X, Win NT(Intel), Win NT(PowerPC), and 
 Win NT(Alpha) installers.

 In order for the launching program to work correctly the directory structure 
 must be maintained.  That is, SETUP.EXE must be in the parent directory for 
 all the other installers to be supported.

 Execute the program by selecting "Run" from the Taskbar and run the file
 SETUP.EXE in the \LEGACY directory of the Sentinel System Driver CD.

 The command line option differs slightly from running the specific OS
 installer directly.  Please review the following options and the Special
 Notes that follows:

 /P<Source Path> -- Specify the root location of the driver.  If not specified,
                    the location defaults to the root.

                    SPECIAL NOTE: If parent directory of the system driver is
                    not specified correctly, setup.exe will be able to spawn 
                    the appropriate installer.

 /Qn             -- Quiet Mode, 4 different levels:
        /Q1          -   No error messages, launch installer quietly.
        /Q2(default) -   Report error messages, launch installer quietly.
        /Q3          -   No error messages, launch installer without quiet 
                         mode.
        /Q4          -   Report error messages, launch installer without quiet 
                         mode.

                    SPECIAL NOTE: Unlike the installers, SETUP.EXE runs quietly
                    by default.  To show options, use /Q3 or /Q4.

 /O              -- Overwrites existing driver regardless of version.

 /U              -- Uninstall the detected driver

 /Xn             -- Do not autodetect, instead use:
        /X1          -   Windows 3.X
        /X2          -   Windows 9X
        /X3          -   OS/2
        /X4          -   Windows NT - i86
        /X5          -   Windows NT - Alpha
        /X6          -   Windows NT - PowerPC

 /USB            -- Install USB driver support.

 /?              -- Display online usage.

 FINAL SPECIAL NOTE: 
 
 Due to its requirements for autodetection, SETUP.EXE does not support the 
 /E command.  

---------------------------------
 2.0 What's New in This Release?
---------------------------------

- New installer for Windows 9x and above; includes merge modules.

- Modify the SNTNLUSB.SYS WDM driver so that it can be loaded and accessed 
  independently of the SENTINEL.SYS parallel driver.  Note that this requires
  updated SentinelSuperPro interfaces to take advantage of this feature.

- Add the /v switch to the installer that prevents it from installing the VDD
  RNBOVDD.DLL.  It will also remove the VDD if it was installed by a previous
  installation.

--------------------
 2.1 Problems Fixed
--------------------

- Fixed a bug that caused the RNBOsproGetUnitInfo command to report incorrect
  device type and product code information if a USB key was in use.
  
- Removed informational messages logged to the NT Event log everytime the 
  driver is started.
  
- Changed the USB start type from SERVICE_AUTO_START to SERVICE_DEMAND_START 
  to prevent an error event from being logged under Windows 2000 when the 
  system is started without a SuperPro USB key inserted.  The driver can't 
  start unless a key is present.
  
- Allow the parallel driver to load under Windows 2000 even if the PARPORT.SYS
  driver isn't running.  This will allow the SENTINEL.SYS (parallel driver) to 
  load and provide a communication path to the SNTNLUSB.SYS (usb driver) for 
  old clients, i.e. ones that haven't been updated to communicate directly 
  with the updated USB driver.  Required for Legacy Free systems which don't
  have a parallel port.
 
--------------------
 3.0 KNOWN PROBLEMS
--------------------

- The legacy installation programs can not be used to install the USB driver,
  SNTNLUSB.SYS, by itself.  It must be installed using the new Windows 
  installer or in conjunction with the parallel driver using the /USB command
  line option.

-------------------------
 4.0 WHERE TO GO NEXT?
-------------------------

 Please read the Developers Guide for the specific product that will be used 
 with the Sentinel System Driver.

-------------------------
 5.0 REPORTING PROBLEMS
-------------------------

 If you find any problems, please contact Rainbow Technical Support 
 using any of the following methods:

 CORPORATE HEADQUARTERS NORTH AMERICA AND SOUTH AMERICA
 ------------------------------------------------------
 Rainbow Technologies, Inc.
 Internet      http://www.rainbow.com
 E-mail        techsupport@irvine.rainbow.com
 Telephone     (800) 959-9954 (6:00 a.m.-6:00 p.m. PST)
 Fax           (949) 450-7450

 AUSTRALIA
 ---------
 Rainbow Technologies (Australia) Pty Ltd.
 E-mail        techsupport@au.rainbow.com
 Telephone     (61) 3 9820 8900
 Fax           (61) 3 9820 8711

 CHINA
 -----
 Rainbow Information Technologies (China) Co.
 E-mail        techsupport@cn.rainbow.com
 Telephone     (86) 108 209 0680
 Fax           (86) 108 209 0681

 FRANCE AND DISTRIBUTORS IN EUROPE, MIDDLE EAST AND AFRICA
 ---------------------------------------------------------
 Rainbow Technologies
 E-mail        techsupport@fr.rainbow.com
 Telephone     (33) 1 41.43.29.02
 Fax           (33) 1 46.24.76.91
 
 GERMANY
 -------
 Rainbow Technologies, GmbH
 E-mail        techsupport@de.rainbow.com
 Telephone     (49) 89.32.17.98.0
 Fax           (49) 89.32.17.98.50

 TAIWAN
 ------
 Rainbow Technologies (Taiwan) Co.
 E-mail        techsupport@tw.rainbow.com
 Telephone     (886) 2 27155522
 Fax           (886) 2 27138220
 
 UNITED KINGDOM AND IRELAND
 --------------------------
 Rainbow Technologies, Ltd.
 E-mail        techsupport@uk.rainbow.com
 Telephone     (44) 1932.579200
 Fax           (44) 1932.570743
 
 OTHER COUNTRIES
 ---------------
 Customers not in countries listed above, please contact your local
 distributor.
