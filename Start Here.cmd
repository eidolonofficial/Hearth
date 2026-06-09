@echo off
title Hearth
REM Double-click this to begin. It opens the friendly setup window.
REM It cannot harm your computer, and nothing happens without your yes.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0welcome.ps1"
echo.
pause
