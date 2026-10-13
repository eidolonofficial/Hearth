@echo off
title Hearth
REM Double-click this file. It runs welcome.ps1, which copies two skills and nothing else.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0welcome.ps1"
echo.
pause
