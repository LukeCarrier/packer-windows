@ECHO off

REM
REM Vagrant Windows box factory
REM
REM @author Luke Carrier <luke@carrier.im>
REM @copyright 2015 Luke Carrier
REM @license GPL v3
REM

winrm quickconfig -q
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
winrm set winrm/config @{MaxTimeoutms="1800000"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}
sc config WinRM start= auto
