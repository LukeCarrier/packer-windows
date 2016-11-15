Enable-MicrosoftUpdate
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" `
        -Name AUOptions -PropertyType DWord -Value 1 -Force

Install-WindowsUpdate -AcceptEula -Criteria "IsHidden=0 and IsInstalled=0"
if (Test-PendingReboot) {
    Invoke-Reboot
}
