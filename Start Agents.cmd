@echo off
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js 18 or newer is required. Nothing was installed. See README.md.
  pause
  exit /b 1
)
node "%~dp0scripts\welcome.mjs"
pause
