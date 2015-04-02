@echo off

REM
REM Vagrant Windows box factory
REM
REM @author Luke Carrier <luke@carrier.im>
REM @copyright 2015 Luke Carrier
REM @license GPL v3
REM

setlocal EnableDelayedExpansion
set source=\\vboxsvr\PowerShell
set target=%USERPROFILE%\Desktop\PowerShell

echo Copying files...
if exist !target! (
    rmdir /S /Q !target!
)
mkdir !target!
copy /Y !source! !target!

echo Calling bootstrap...
call !target!\bootstrap.bat
