@echo off
title Hearth operator setup
REM Terminal picker that wires project hooks. Needs Node 22 or newer.
where node >nul 2>nul
if errorlevel 1 goto missing
for /f "usebackq delims=" %%v in (`node -p "process.versions.node.split('.')[0]"`) do set NODEMAJOR=%%v
if %NODEMAJOR% LSS 22 goto missing
node "%~dp0scripts\welcome.mjs"
goto done
:missing
echo Operator setup needs Node 22 or newer, and it was not found.
echo Get it from https://nodejs.org and run this file again.
echo Nothing was installed.
:done
echo.
pause
