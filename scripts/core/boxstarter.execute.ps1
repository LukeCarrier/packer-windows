Param(
  [Parameter()]
  [switch] $UseStartupWorkaround = $false
)

. (Join-Path $env:ProgramData "BoxStarter\BoxstarterShell.ps1")
Import-Module Boxstarter.Chocolatey

function Install-StartupWorkaround {
  Set-ItemProperty `
      -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" `
      -Name Shell -Value "PowerShell.exe -NoExit"

  $profileDir = (Split-Path -Parent $PROFILE)
  if (!(Test-Path $profileDir)) {
    New-Item -Type Directory $profileDir
  }

  Copy-Item -Force A:\startup-profile.ps1 $PROFILE
}

if ($UseStartupWorkaround) {
  Write-Warning "Using PowerShell profile workaround for startup items"
  Install-StartupWorkaround
}

$credential = New-Object System.Management.Automation.PSCredential(
    "vagrant", (ConvertTo-SecureString -String "vagrant" -AsPlainText -Force))
$result = Install-BoxstarterPackage `
    -PackageName A:\boxstarter.package.ps1 -Credential $credential

if ($result.Errors.Count) {
  Write-Host "Install-BoxstarterPackage encountered errors; waiting for input to proceed"
  Write-Host $result.Errors
}

if (!$result.Completed) {
  Write-Error "Install-BoxstarterPackage did not complete"
}

if ($result.Errors.Count -or !$result.Completed) {
  & powershell
}
