@ECHO off

REM
REM Vagrant Windows box factory
REM
REM @author Luke Carrier <luke@carrier.im>
REM @copyright 2015 Luke Carrier
REM @license GPL v3
REM

call winrm quickconfig -q
call winrm quickconfig -transport:http

call winrm set winrm/config @{MaxTimeoutms="1800000"}
call winrm set winrm/config/service @{AllowUnencrypted="true"}
call winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
call winrm set winrm/config/client/auth @{Basic="true"}
call winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}
call winrm set winrm/config/service/auth @{Basic="true"}

sc config WinRM start= auto

timeout 5
sc query winrm
