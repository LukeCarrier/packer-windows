Import-Module Boxstarter.Chocolatey

$credential = New-Object System.Management.Automation.PSCredential(
        "vagrant", (ConvertTo-SecureString -String "vagrant" -AsPlainText -Force))
Install-BoxstarterPackage -PackageName A:\boxstarter.package.ps1 -Credential $credential
