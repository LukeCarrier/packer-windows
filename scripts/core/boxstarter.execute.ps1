Import-Module Boxstarter.Chocolatey

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
