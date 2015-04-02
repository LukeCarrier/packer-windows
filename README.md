# Vagrant Windows box factory

A suite of scripts I've cobbled together to make birthing Vagrant boxes of
Windows a little more automated.

* * *

## Creating a box

1. Create a VirtualBox VM with a dynamically expanding drive of up to 1TB,
   allocating two CPUs and 2GB of RAM.
2. Install Windows, disabling automatic updates.
3. Activate Windows.
4. Install Guest Additions.
5. Add a shared folder to the ```PowerShell``` directory.
6. Execute ```bootstrap.bat``` to configure PowerShell's execution policy. This
   will in turn execute ```Install.ps1`` to install a bunch of modules.

## What's included
