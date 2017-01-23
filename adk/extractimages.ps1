#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]] $ImagePath = @(),

    [Parameter(Mandatory=$false)]
    [string[]] $TargetDirectory = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-WSIMCacheDirectory {
    return Join-Path (Split-Path -Parent $PSScriptRoot) "cache"
}

function Get-WSIMCatalogDirectory {
    return Join-Path $PSScriptRoot "catalogs"
}

function Join-WSIMPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]] $PathComponents
    )

    return $PathComponents -join [System.IO.Path]::DirectorySeparatorChar
}

function Extract-WSIMInstallWindowsImage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path -Type Leaf -Path $_ })]
        [string] $ImagePath,

        [Parameter(Mandatory=$true)]
        [ValidateScript({ Test-Path -Type Container -Path $_ })]
        [string] $TargetDirectory
    )

    $volume = (Mount-DiskImage -ImagePath $ImagePath -StorageType ISO -Access ReadOnly -PassThru | Get-Volume)
    Write-Verbose "Mounted $($ImagePath) to $($volume.DriveLetter):"
    $installImagePath = Join-WSIMPath "$($volume.DriveLetter):", "sources", "install.wim"
    Write-Verbose "Copying $($installImagePath) to $($TargetDirectory)"
    Copy-Item -Force -Path $installImagePath -Destination $TargetDirectory
    Write-Verbose "Dismounting $($ImagePath) from $($volume.DriveLetter):"
    Dismount-DiskImage -ImagePath $ImagePath
}

# Set default parameter values when we have our common functions available,
# because using complex expressions in param() blocks is ugly, and param() is
# required to be the first statement in the script.
if (!$ImagePath) {
    $ImagePath = @(
        (Join-Path (Get-WSIMCacheDirectory) "75e529d96d6b175622512cf0a1bc55a5d1677e6a9d3b913fe95c65b6aa41770d.iso"),
        (Join-Path (Get-WSIMCacheDirectory) "0fa2380dae2e2178d3dcbd7475d35a9133fd0d61cad4fa1f87a2a83f358a3c8b.iso"),
        (Join-Path (Get-WSIMCacheDirectory) "524abd34eb2abcc5e5a12da5b1c97fa3a6a626a831c29b4e74801f4131fb08ed.iso")
    )
}
if (!$TargetDirectory) {
    $TargetDirectory = @(
        (Join-Path (Get-WSIMCatalogDirectory) "2008-r2_x64"),
        (Join-Path (Get-WSIMCatalogDirectory) "2012-r2_x64"),
        (Join-Path (Get-WSIMCatalogDirectory) "2016_x64")
    )
}

for ($i = 0; $i -lt $ImagePath.Length; $i++) {
    $currentImagePath       = $ImagePath[$i]
    $currentTargetDirectory = $TargetDirectory[$i]

    Write-Verbose "Extracting image in $($currentImagePath) to $($currentTargetDirectory)"
    New-Item -Force -Type Directory -Path $currentTargetDirectory | Out-Null
    Extract-WSIMInstallWindowsImage `
            -ImagePath $currentImagePath `
            -TargetDirectory $currentTargetDirectory
}
