@echo off

REM
REM Vagrant Windows box factory
REM
REM @author Luke Carrier <luke@carrier.im>
REM @copyright 2015 Luke Carrier
REM @license GPL v3
REM

REM Set PowerShell's ExecutionPolicy so we don't have to screw around calling
REM Command Prompt later
echo Setting PowerShell ExecutionPolicy...
cmd /c powershell -Command "& { Set-ExecutionPolicy RemoteSigned -Scope LocalMachine }"

REM Everything else is in PowerShell because Command Prompt is simply too awful
echo Running installation...
cmd /c powershell %~dp0\Install.ps1
