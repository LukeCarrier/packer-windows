#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

# PowerShell module sources
#
# Instead of bundling a bunch of third party code, we'll source it all from
# Microsoft's Script Center on TechNet.
[string[]] $PSModuleSources = @(
    # PSWindowsUpdate
    "https://gallery.technet.microsoft.com/scriptcenter/2d191bcd-3308-4edd-9de2-88dff796b0bc/file/41459/43/PSWindowsUpdate.zip"
)

# PowerShell module directory
#
# This is where we'll install modules to. It must still be on your PSModulePath;
# we won't attempt to add it for you.
[string] $PSModuleDir = "$env:UserProfile\Documents\WindowsPowerShell\Modules"
