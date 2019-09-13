@echo off
setlocal enableextensions

if not "%APOLLO_REDIRECTED%"=="1" if exist "%LOCALAPPDATA%\apollo\client\bin\apollo.cmd" (
  set APOLLO_REDIRECTED=1
  "%LOCALAPPDATA%\apollo\client\bin\apollo.cmd" %*
  goto:EOF
)

if not defined APOLLO_BINPATH set APOLLO_BINPATH="%~dp0apollo.cmd"
if exist "%~dp0..\bin\node.exe" (
  "%~dp0..\bin\node.exe" "%~dp0..\bin\run" %*
) else if exist "%LOCALAPPDATA%\oclif\node\node-10.16.3.exe" (
  "%LOCALAPPDATA%\oclif\node\node-10.16.3.exe" "%~dp0..\bin\run" %*
) else (
  node "%~dp0..\bin\run" %*
)
