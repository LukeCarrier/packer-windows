Write-BoxstarterMessage "Prevent idle display turn off"
& powercfg -x -monitor-timeout-dc 0

Write-BoxstarterMessage "Setting PowerShell execution policy"
Update-ExecutionPolicy RemoteSigned

Write-BoxstarterMessage "Setting update policy"
Enable-MicrosoftUpdate
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" `
        -Name AUOptions -PropertyType DWord -Value 1 -Force


Write-BoxstarterMessage "Installing updates"
Install-WindowsUpdate -AcceptEula -Criteria "IsHidden=0 and IsInstalled=0"
if (Test-PendingReboot) {
    Invoke-Reboot
}

Write-BoxstarterMessage "Enabling WinRM"
Enable-PSRemoting -Force
& winrm set winrm/config "@{MaxTimeoutms=`"1800000`"}"
& winrm set winrm/config/service "@{AllowUnencrypted=`"true`"}"
& winrm set winrm/config/winrs "@{MaxMemoryPerShellMB=`"2048`"}"
& winrm set winrm/config/client/auth "@{Basic=`"true`"}"
& winrm set winrm/config/listener?Address=*+Transport=HTTP "@{Port=`"5985`"}"
& winrm set winrm/config/service/auth "@{Basic=`"true`"}"
