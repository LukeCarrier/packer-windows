@ECHO off

CALL winrm quickconfig -q
CALL winrm quickconfig -transport:http

CALL winrm set winrm/config @{MaxTimeoutms="1800000"}
CALL winrm set winrm/config/service @{AllowUnencrypted="true"}
CALL winrm set winrm/config/winrs @{MaxMemoryPerShellMB="2048"}
CALL winrm set winrm/config/client/auth @{Basic="true"}
CALL winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}
CALL winrm set winrm/config/service/auth @{Basic="true"}

sc config WinRM start= auto
