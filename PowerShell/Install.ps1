#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# Source configuration
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
. $ScriptDir\Config.ps1

# Create a temporary directory to work in
$TempDir          = [string]::Concat("VWPS-", [System.Guid]::NewGuid().ToString())
$QualifiedTempDir = (Join-Path $env:Temp $TempDir)
New-Item -Type Directory -Name $TempDir -Path $env:Temp
Set-Location $QualifiedTempDir

# Ensure the user module directory exists
if (!(Test-Path $PSModuleDir)) {
    New-Item -Type Directory -Path $PSModuleDir
}

# Ensure all of our dependendencies are installed
$Shell = New-Object -Com Shell.Application
foreach ($Source in $PSModuleSources) {
    $ModuleTempFile = $Source.SubString($Source.LastIndexOf('/') + 1)
    $ModuleName     = [IO.Path]::GetFilenameWithoutExtension($ModuleTempFile)
    $ModuleDir      = (Join-Path $PSModuleDir $ModuleName)

    Invoke-WebRequest $Source -OutFile $ModuleTempFile

    $Archive = $Shell.Namespace((Join-Path $QualifiedTempDir $ModuleTempFile))
    $Target  = $Shell.Namespace($QualifiedTempDir)
    echo $Archive
    $Target.CopyHere($Archive.Items())
    
    if (Test-Path $ModuleDir) {
        Remove-Item -Recurse -Force $ModuleDir
    }

    Move-Item -Path (Join-Path $QualifiedTempDir $ModuleName) -Destination $PSModuleDir
}

# Remove the temporary directory
Set-Location (Split-Path -parent $QualifiedTempDir)
Remove-Item -Recurse -Force $QualifiedTempDir
