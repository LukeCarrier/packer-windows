function Get-StageCompletionFlagFilename {
    Param(
        [Parameter(Mandatory=$true)]
        [string] $Stage
    )

    return "$($env:APPDATA)\SetupFlags\$($Stage)"
}

function Test-StageOutstanding {
    Param(
        [Parameter(Mandatory=$true)]
        [string] $Stage
    )

    return !(Test-Path (Get-StageCompletionFlagFilename $Stage))
}

function Write-StageComplete {
    Param(
        [Parameter(Mandatory=$true)]
        [string] $Stage
    )

    $stageFlag = Get-StageCompletionFlagFilename $Stage

    $stageFlagParent = Split-Path -Parent $stageFlag
    if (!(Test-Path $stageFlagParent)) {
        New-Item -Type Directory $stageFlagParent >$null

        $account = [System.Security.Principal.NTAccount] "vagrant"

        $acl = Get-Acl $stageFlagParent
        $acl.SetOwner($account)
        $acl.SetAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule(
                $account, "FullControl", "Allow")))
        $acl.SetAccessRuleProtection($true, $true)
        Set-Acl $stageFlagParent $acl
    }

    New-Item -Type File $stageFlag >$null
}

if (Test-StageOutstanding "CompletedProfileSetup") {
    Write-BoxstarterMessage "Rebooting system to complete profile setup"
    Write-StageComplete "CompletedProfileSetup"
    Invoke-Reboot
}

if (Test-StageOutstanding "PreventIdleDisplayTurnOff") {
    Write-BoxstarterMessage "Prevent idle display turn off"
    & powercfg -change -monitor-timeout-ac 0
    & powercfg -change -monitor-timeout-dc 0
    Write-StageComplete "PreventIdleDisplayTurnOff"
}

if (Test-StageOutstanding "SetPowerShellExecutionPolicy") {
    Write-BoxstarterMessage "Setting PowerShell execution policy"
    Update-ExecutionPolicy RemoteSigned
    Write-StageComplete "SetPowerShellExecutionPolicy"
}

if (Test-StageOutstanding "SetWindowsUpdatePolicy") {
    Write-BoxstarterMessage "Setting update policy"
    Enable-MicrosoftUpdate
    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" `
            -Name AUOptions -PropertyType DWord -Value 1 -Force
    Write-StageComplete "SetWindowsUpdatePolicy"
}

if (Test-StageOutstanding "InstallWindowsUpdates") {
    Write-BoxstarterMessage "Installing updates"
    Install-WindowsUpdate -AcceptEula -Criteria "IsHidden=0 and IsInstalled=0"
    if (Test-PendingReboot) {
        Invoke-Reboot
    }
    Write-StageComplete "InstallWindowsUpdates"
}

if (Test-StageOutstanding "ExecuteSysprep") {
    Write-BoxstarterMessage "Running sysprep"
    & C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /unattend:A:\\Autounattend.xml /quiet /restart
    Write-StageComplete "ExecuteSysprep"
}

# Enable WinRM at the very end of the provisioning process, preventing Packer
# from restarting the machine mid-way through
if (Test-StageOutstanding "EnableWinRM") {
    Write-BoxstarterMessage "Enabling WinRM"
    Enable-PSRemoting -Force

    Set-Item -Path WSMan:\localhost\MaxTimeoutms             -Value 1800000
    Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value True
    Set-Item -Path WSMan:\localhost\Service\Auth\Basic       -Value True

    Set-Item -Path WSMan:\localhost\Shell\MaxMemoryPerShellMB -Value 2048

    Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any

    Write-StageComplete "EnableWinRM"
}
