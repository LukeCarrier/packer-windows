Enable-PSRemoting -Force
& winrm set winrm/config "@{MaxTimeoutms=`"1800000`"}"
& winrm set winrm/config/service "@{AllowUnencrypted=`"true`"}"
& winrm set winrm/config/winrs "@{MaxMemoryPerShellMB=`"2048`"}"
& winrm set winrm/config/client/auth "@{Basic=`"true`"}"
& winrm set winrm/config/listener?Address=*+Transport=HTTP "@{Port=`"5985`"}"
& winrm set winrm/config/service/auth "@{Basic=`"true`"}"
