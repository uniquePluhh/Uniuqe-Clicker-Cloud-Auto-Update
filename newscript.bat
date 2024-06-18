@echo off 

:-------------------------------------
REM BatchGotAdmin
REM Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

title Clicker
color f
set clicks=1000
set cp=1
set buyit?=no
set savefile=%temp%\clicker_save.txt
set updateFlag=%temp%\clicker_update.flag

REM Set the URL of the updated script
set "updateUrl=https://raw.githubusercontent.com/username/repository/branch/newscript.bat"
REM Set the path to the temp file where the new script will be downloaded
set "tempFile=%temp%\newscript.bat"

REM Function to update the script
:updateScript
    if exist %updateFlag% (
        del %updateFlag%
        goto continue
    )
    echo Checking for updates...
    REM Download the new script using bitsadmin
    bitsadmin /transfer "DownloadUpdate" /priority normal %updateUrl% %tempFile%
    REM Check if the download was successful
    if exist %tempFile% (
        echo Update downloaded successfully.
        REM Replace the current script with the new one
        copy /y %tempFile% "%~f0"
        echo Update applied. Restarting the script...
        echo. > %updateFlag%
        REM Restart the script
        start "" "%~f0" :restart
        exit /B
    ) else (
        echo Failed to download the update.
        pause >nul
    )
    goto :EOF

:continue
REM Load the game state if it exists
call :loadGame

goto Menu

:Menu
cls 
echo .                      ======================
echo .                          unique clicker
echo .                      ======================
echo .                      Cp,
echo .                      %cp%
echo .                      clicks,        
echo .                      %clicks%              
echo .
echo .                      press 1 click 
echo .                      press 2 shop
echo .                      press Q save and exit
echo . 
echo .                      ======================= 

set /p input=choose input: 
if /i "%input%"=="1" (
    set /a clicks+=cp
    goto Menu
) else if /i "%input%"=="2" (
    goto shops
) else if /i "%input%"=="Q" (
    call :saveGame
    echo Game saved. Exiting...
    pause >nul
    exit /B
) else (
    echo invalid input 
    pause >nul  
    goto Menu
)

:shops
set /a "specialoffer?=%random% %% 2"
if "%specialoffer?%"=="1" (
    set /a "specialoffercp=%random% %% 99 + 1"
    set buyit?=yes
    set /a "specialoffercost=%random% %% 9999 + 1"
) else (
    set buyit?=no
)
cls 
echo .                      ======================
echo .                      barrys shop of wonders
echo .                      ======================
echo .                      Clicks, %clicks%
echo . 
echo .                      1. 1 cp $35
echo .                      2. 2 cp $55
echo .                      3. 3 cp $85
echo . 
echo .                      0. exit shop
if "%buyit?%"=="yes" (
    echo .                      special offer +%specialoffercp% cp for $%specialoffercost%
    echo .                      9. to buy special offer
)
echo .                      ======================= 

:shopInput
set /p input=choose input: 
if "%input%"=="1" (
    if %clicks% GEQ 35 (
        set /a clicks-=35
        set /a cp+=1
        goto shops
    ) else (
        echo not enough clicks!
        pause >nul
        goto shops
    )
) else if "%input%"=="2" (
    if %clicks% GEQ 55 (
        set /a clicks-=55
        set /a cp+=2
        goto shops
    ) else (
        echo not enough clicks!
        pause >nul 
        goto shops
    )
) else if "%input%"=="3" (
    if %clicks% GEQ 85 (
        set /a clicks-=85
        set /a cp+=3
        goto shops
    ) else (
        echo not enough clicks!
        pause >nul
        goto shops
    )
) else if "%input%"=="0" (
    goto Menu 
) else if "%input%"=="9" (
    if "%buyit?%"=="yes" (
        if %clicks% GEQ %specialoffercost% (
            set /a clicks-=specialoffercost
            set /a cp+=specialoffercp
            set buyit?=no
            goto shops
        ) else (
            echo not enough clicks!
            pause >nul
            goto shops
        )
    ) else (
        echo invalid input!
        pause >nul
        goto shops
    )
) else (
    echo invalid input!
    pause >nul
    goto shopInput
)

pause >nul
exit /B

:saveGame
(
    echo clicks=%clicks%
    echo cp=%cp%
) > "%savefile%"
goto :EOF

:loadGame
if exist "%savefile%" (
    for /f "tokens=1,2 delims==" %%a in (%savefile%) do (
        if "%%a"=="clicks" set clicks=%%b
        if "%%a"=="cp" set cp=%%b
    )
)
goto :EOF
