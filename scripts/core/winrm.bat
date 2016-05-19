@ECHO off

call winrm quickconfig -q
call winrm quickconfig -transport:http

call winrm set winrm/config @{MaxTimeoutms="1800000"}
call winrm set winrm/config/service @{AllowUnencrypted="true"}
call winrm set winrm/config/winrs @{MaxMemoryPerShellMB="2048"}
call winrm set winrm/config/client/auth @{Basic="true"}
call winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"}
call winrm set winrm/config/service/auth @{Basic="true"}

sc config WinRM start= auto
