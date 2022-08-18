#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

function Get-LargestContiguousBlock {
  Param(
    [Parameter(Mandatory=$true)]
    [char] $Character,

    [Parameter(Mandatory=$true)]
    [string] $Text
  )

  $matches = @{}
  $previousMatched = $false
  $previousStart = 0

  $Text.ToCharArray() | ForEach-Object {
    if ($_ -eq $Character) {
      if ($previousMatched) {
        $matches[$previousStart] += 1
      } else {
        $matches[$previousStart] = 1
        $previousMatched = $true
      }
    } else {
      $previousMatched = $false
    }
  }

  $enumerator = ($matches | Sort-Object -Descending Value).GetEnumerator()
  return ([string] $Character) * ($enumerator | Select-Object -First 1).Value
}

function Get-TempDirTemplateReplacement {
  Param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({ $_ -gt 0 })]
    [int] $Length
  )

  return -join ((65..90) + (97..122) | Get-Random -Count $Length `
      | ForEach-Object { [char] $_ })
}

function New-TempDirectory {
  Param(
    [Parameter(Mandatory=$false)]
    [ValidateScript({ $_ -contains "XXX" })]
    [string] $Template = "tmp.XXXXXXXXXX",

    [Parameter(Mandatory=$false)]
    [ValidateScript({ Test-Path -Type Container $_ })]
    [string] $TempDir = $env:Temp
  )

  $placeholder = Get-LargestContiguousBlock -Character 'X' -Text $Template

  do {
    $replacement = Get-TempDirTemplateReplacement -Length $placeholder.Length
    $child = $Template.Replace($placeholder, $replacement)
    $path = (Join-Path $TempDir $child)
  } while (Test-Path $path)

  return (New-Item -ItemType Directory $path).FullName
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

$rootDir = Split-Path -Parent ($MyInvocation.MyCommand.Definition)
$env:PACKER_CACHE_DIR = Join-Path $rootDir "cache"
$env:PACKER_BUILD_DIR = New-TempDirectory -TempDir (Join-Path $rootDir "builds")

foreach ($arg in $args) {
  if (Test-Path -Type Leaf $arg) {
    $args[$args.IndexOf($arg)] = (Get-Item $arg).FullName
  }
}

Push-Location $env:PACKER_BUILD_DIR
try {
  & packer @args
} finally {
  Pop-Location
}
