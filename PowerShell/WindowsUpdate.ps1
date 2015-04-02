#
# Vagrant Windows box factory
#
# @author Luke Carrier <luke@carrier.im>
# @copyright 2015 Luke Carrier
# @license GPL v3
#

Import-Module PSWindowsUpdate

# Enable Microsoft Update in addition to Windows Update
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d

# Apply all updates and reboot if necessary
Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot
