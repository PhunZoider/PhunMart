@echo off
setlocal enabledelayedexpansion

rem ---------------------------------------------------------------------------
rem Runs the Lua test suites against a runtime cut down to PZ B42.20.4.
rem See README.md in this folder for what that means and why it matters.
rem ---------------------------------------------------------------------------

set LUA=
where luajit >nul 2>nul && set LUA=luajit
if "%LUA%"=="" if exist "%LOCALAPPDATA%\Programs\LuaJIT\bin\luajit.exe" set LUA=%LOCALAPPDATA%\Programs\LuaJIT\bin\luajit.exe

if "%LUA%"=="" (
    echo No LuaJIT found.
    echo Install it with:  winget install --id DEVCOM.LuaJIT --source winget
    exit /b 1
)

set FAILED=0

for %%T in (test_json test_playerdata test_months) do (
    echo.
    echo ==================== %%T ====================
    "%LUA%" "%~dp0%%T.lua"
    if errorlevel 1 set FAILED=1
)

echo.
if "%FAILED%"=="1" (
    echo SUITE FAILED
    exit /b 1
)
echo All suites passed.
endlocal
