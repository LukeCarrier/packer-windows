#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# Parse CLI arguments
Param(
    [String] $Template
)

$ROOT_DIR = Split-Path -Parent ($MyInvocation.MyCommand.Definition)

# Exit statuses, modelled after Microsoft's System Error Codes
$ERROR_ACCESS_DENIED = 5
$ERROR_BAD_COMMAND   = 22
$ERROR_BUSY          = 167

# Ensure arguments are sane
function Ensure-ArgumentsSane() {
    if (!(Test-Path -PathType Leaf $TEMPLATE_FILE)) {
        Write-Host "[!] Template "${TEMPLATE}" does not exist in the templates directory"
        Write-Host "[!] Did you type it correctly?"
        Exit $ERROR_BAD_COMMAND
    }
}

# Ensure environment is sane
function Ensure-EnvironmentSane() {
    if (!(Test-Path -PathType Container $PACKER_PATH)) {
        Write-Host "[!] PACKER_PATH does not exist"
        Write-Host "[!] Download the Packer utilities and update make-vm.conf"
        Exit $ERROR_BUSY
    }
}

# Source configuration and dependencies
. "${ROOT_DIR}\make-vm.conf.ps1"

# Set up some other state before sanity checks
$TEMPLATE_FILE = "${ROOT_DIR}\templates\${TEMPLATE}\template.json"

# Ensure configuration and CLI arguments are relatively sane
Ensure-ArgumentsSane
Ensure-EnvironmentSane

# Put the Packer and VirtualBox utilities on our path to save typing
$env:Path = "${PACKER_PATH};${VIRTUALBOX_PATH};${env:Path}"

# Set Packer's cache directory outside of the build directory for faster builds
$env:PACKER_CACHE_DIR = "${ROOT_DIR}\cache"

# Build it
$BUILD_DIR = "${ROOT_DIR}\builds\${TEMPLATE}"
if (Test-Path -PathType Container $BUILD_DIR) {
    Write-Host "[!] Build directory for "${TEMPLATE}" already exists; aborting"
    Write-Host "[!] Delete or move aside the build directory to continue"
    Exit $ERROR_BUSY
}
New-Item -Type Directory $BUILD_DIR | Out-Null
Push-Location $BUILD_DIR
&packer build $TEMPLATE_FILE
Pop-Location
