@echo off
title Hearth
REM Double-click this to begin. It opens the Hearth window: a real window, no typing.
REM It cannot harm your computer, and nothing happens without your yes.
REM
REM First choice: open the graphical window (no console). If PowerShell is missing
REM entirely, fall through to the text installer in this same window.

start "" powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -STA -File "%~dp0gui\Hearth.ps1"
if %errorlevel%==0 goto :eof

echo.
echo Opening the text installer instead...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0welcome.ps1"
echo.
pause
