Param(
    [Parameter()]
    [switch] $UseStartupWorkaround = $false
)

if ($UseStartupWorkaround) {
    Write-Warning "Cleaning up PowerShell profile workaround for startup items"

    Remove-ItemProperty `
            -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
            -Name Shell
    Remove-Item -Force $PROFILE
}

Remove-Item -Force -Recurse "$($env:APPDATA)\SetupFlags"

Stop-Computer -Force
