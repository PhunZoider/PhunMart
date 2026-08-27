@echo off
setlocal enabledelayedexpansion

rem ---------------------------------------------------------------------------
rem PhunMart2 deploy.
rem
rem v1 spelled every copy step out inline in .vscode/settings.json. With six
rem mods that would be sixty-odd entries, so the whole pipeline lives here and
rem settings.json just calls this on save.
rem
rem Deploys to:
rem   %USERPROFILE%\Zomboid\mods\<Mod>              - playable
rem   %USERPROFILE%\Zomboid\mods\<Mod>Test          - test-id variant
rem   %USERPROFILE%\Zomboid\Workshop\PhunMart2     - upload staging
rem   %USERPROFILE%\Zomboid\Workshop\PhunMart2Test - test upload staging
rem ---------------------------------------------------------------------------

set MODS=PhunMart2

set SRC=%~dp0
set MODDIR=%USERPROFILE%\Zomboid\mods
set WS=%USERPROFILE%\Zomboid\Workshop\PhunMart2
set WSTEST=%USERPROFILE%\Zomboid\Workshop\PhunMart2Test

echo [PhunMart2] Deploying to %MODDIR%

rem --- Live mods -------------------------------------------------------------
for %%M in (%MODS%) do (
    rmdir /S /Q "%MODDIR%\%%M" 2>nul
    xcopy "%SRC%Contents\mods\%%M" "%MODDIR%\%%M" /Y /I /E /F /Q >nul
    if errorlevel 1 echo [PhunMart2] FAILED copying %%M
)

rem --- Test-id variants ------------------------------------------------------
rem Copy the live mod, then overlay Tests\root\<Mod> which swaps in a mod.info
rem carrying the *test ids. Lets both versions sit side by side in one install.
for %%M in (%MODS%) do (
    rmdir /S /Q "%MODDIR%\%%MTest" 2>nul
    xcopy "%MODDIR%\%%M" "%MODDIR%\%%MTest" /Y /I /E /F /Q >nul
    if exist "%SRC%Tests\root\%%M" (
        xcopy "%SRC%Tests\root\%%M" "%MODDIR%\%%MTest" /Y /I /E /F /Q >nul
    )
)

rem --- Workshop staging, live ------------------------------------------------
rmdir /S /Q "%WS%" 2>nul
xcopy "%SRC%" "%WS%" /Y /I /E /F /Q /EXCLUDE:%SRC%xclude >nul
rmdir /S /Q "%WS%\Tests" 2>nul
rmdir /S /Q "%WS%\Contents" 2>nul
for %%M in (%MODS%) do (
    xcopy "%MODDIR%\%%M" "%WS%\Contents\mods\%%M" /Y /I /E /F /Q >nul
)

rem --- Workshop staging, test ------------------------------------------------
rem Same mod folder names as live, but each carries the test mod.info, and the
rem workshop.txt / preview.png come from Tests\.
rmdir /S /Q "%WSTEST%" 2>nul
xcopy "%SRC%" "%WSTEST%" /Y /I /E /F /Q /EXCLUDE:%SRC%xclude >nul
rmdir /S /Q "%WSTEST%\Tests" 2>nul
rmdir /S /Q "%WSTEST%\Contents" 2>nul
for %%M in (%MODS%) do (
    xcopy "%MODDIR%\%%MTest" "%WSTEST%\Contents\mods\%%M" /Y /I /E /F /Q >nul
)
copy /Y "%SRC%Tests\workshop.txt" "%WSTEST%\workshop.txt" >nul
if exist "%SRC%Tests\preview.png" copy /Y "%SRC%Tests\preview.png" "%WSTEST%\preview.png" >nul

echo [PhunMart2] Done.
endlocal
