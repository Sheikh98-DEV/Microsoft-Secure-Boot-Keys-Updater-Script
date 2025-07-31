@ECHO OFF
CD /D "%~dp0" > NUL 2>&1
SETLOCAL EnableDelayedExpansion
SET Version=1.0.0
SET ReleaseTime=Aug 01, 2025
Title Secure Boot Keys Updater - by S.H.E.I.K.H (V. %version%)
CD /D "%TEMP%" > NUL 2>&1
SET /P current=<%TEMP%\CurrentSBKU.txt > NUL 2>&1
CD /D "%~dp0" > NUL 2>&1
CLS
If "%current%"=="RebootAgain" (GoTo RebootAgain > NUL 2>&1) Else If "%current%"=="FinishSetup" (GoTo FinishSetup > NUL 2>&1) Else (GoTo Install > NUL 2>&1)

:Install
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check to see if this batch file is being run as Administrator. If it is not, then rerun the batch file ::
:: automatiCally as admin and terminate the initial instance of the batch file.                           ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

(Fsutil Dirty Query %SystemDrive%>nul 2>&1)||(PowerShell start """%~f0""" -verb RunAs & Exit /B) > NUL 2>&1

::::::::::::::::::::::::::::::::::::::::::::::::
:: End Routine to check if being run as Admin ::
::::::::::::::::::::::::::::::::::::::::::::::::

CLS
ECHO :::::::::::::::::::::::::::::::::::::::
ECHO ::     Secure Boot Keys Updater      ::
ECHO ::                                   ::
ECHO ::           Version %Version%          ::
ECHO ::                                   ::
ECHO ::   %ReleaseTime% by  S.H.E.I.K.H    ::
ECHO ::                                   ::
ECHO ::       GitHub: Sheikh98-DEV        ::
ECHO :::::::::::::::::::::::::::::::::::::::
ECHO.
ECHO  This script will update your secure boot keys.
ECHO.
ECHO  Before updating it shows you your BitLocker keys to write somewhere.
ECHO.
ECHO  First, connect to the internet and then,
ECHO.
ECHO  Press any key to start Bitlocker backup ...
Pause > NUL 2>&1


ECHO.
ECHO ::::::::::::::::::::::::::::::::::::::::::
ECHO ::::: Backing up Your BitLocker Keys :::::
ECHO ::::::::::::::::::::::::::::::::::::::::::
ECHO.

ECHO Write your BitLocker keys somewhere.
ECHO.
ECHO For example on a paper, not in a text file on this computer,
ECHO.
ECHO Then return here and press any key to start updating your secure boot keys.
ECHO.
manage-bde -protectors -get %systemdrive%
ECHO.
ECHO Done.
ECHO.
ECHO Press any key to start updating ...
Pause > NUL 2>&1


ECHO.
ECHO :::::::::::::::::::::::::::::::::::::
ECHO ::::: Updating Secure Boot Keys :::::
ECHO :::::::::::::::::::::::::::::::::::::
ECHO.

REG Add "HKLM\SYSTEM\CurrentControlSet\Control\Secureboot" /V "AvailableUpdates" /T "REG_DWORD" /D "0x40" /F > NUL 2>&1
SchTasks /Run /TN "\Microsoft\Windows\PI\Secure-Boot-Update" > NUL 2>&1
ECHO Updates will be installed the next time you restart your machine.
ECHO.
ECHO Your machine restarts twice to complete the installation.
ECHO.
ECHO Press any key to restart ...
Pause > NUL 2>&1
REG Add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /V "%~n0" /D "%~dpnx0" /F > NUL 2>&1
ECHO RebootAgain>%TEMP%\CurrentSBKU.txt
Shutdown /R /T 10 > NUL 2>&1
Exit

:RebootAgain
CLS
ECHO Finishing Setup. Your Machine will restart in 10 seconds.
ECHO FinishSetup>%TEMP%\CurrentSBKU.txt
Shutdown /R /T 10  > NUL 2>&1
Exit

:FinishSetup
(Fsutil Dirty Query %SystemDrive%>nul 2>&1)||(PowerShell start """%~f0""" -verb RunAs & Exit /B) > NUL 2>&1
REG Delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /V "%~n0" /F > NUL 2>&1
powershell -C "[System.Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI db).bytes) -match 'Windows UEFI CA 2023'" > NUL 2>&1
powershell -C "[System.Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI db).bytes) -match 'Windows UEFI CA 2023'" > %TEMP%\OutputSBKU.txt
CD /D "%TEMP%" > NUL 2>&1
SET /P output=<%TEMP%\OutputSBKU.txt > NUL 2>&1
DEL "%TEMP%\CurrentSBKU.txt" /S /F /Q > NUL 2>&1
DEL "%TEMP%\OutputSBKU.txt" /S /F /Q > NUL 2>&1
CLS
If "%output%"=="True" (
	ECHO :::::::::::::::::::::::::::::::::::::::
	ECHO ::     Secure Boot Keys Updater      ::
	ECHO ::                                   ::
	ECHO ::           Version %Version%          ::
	ECHO ::                                   ::
	ECHO ::   %ReleaseTime% by  S.H.E.I.K.H    ::
	ECHO ::                                   ::
	ECHO ::       GitHub: Sheikh98-DEV        ::
	ECHO :::::::::::::::::::::::::::::::::::::::
	ECHO.
	ECHO :::: Update installed successfully ::::
	ECHO.
	ECHO Press any key to exit ...
	Pause > NUL 2>&1
) Else (
	ECHO Update failed.
	ECHO Check your internet connection and run the script again.
	ECHO.
	ECHO Press any key to exit ...
	Pause > NUL 2>&1
)
Exit