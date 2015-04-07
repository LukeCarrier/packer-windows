@ECHO off

REM
REM Vagrant Windows box factory
REM
REM @author Luke Carrier <luke@carrier.im>
REM @copyright 2015 Luke Carrier
REM @license GPL v3
REM

cmd /c reg add HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell /v ExecutionPolicy /t REG_SZ /d RemoteSigned /f
