Import-Module Boxstarter.Chocolatey

New-Item -Type Directory -Path C:\is_first_logon

$credential = New-Object System.Management.Automation.PSCredential(
        "vagrant", (ConvertTo-SecureString -String "vagrant" -AsPlainText -Force))
Install-BoxstarterPackage -PackageName A:\boxstarter.package.ps1 -Credential $credential
