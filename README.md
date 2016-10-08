# Vagrant Windows box factory

Making Windows Great Again™

* * *

## Introduction

This project was born out of a last ditch attempt to escape the shackles of
Windows and go back to working on a "nice" operating system whilst still testing
on Windows. It builds Vagrant boxes for you.

## How it works

[Packer](https://www.packer.io/) downloads the required ISO files to the cache,
creates a floppy image containing some key bootstrap files, creates the VM using
the `virtualbox-iso` builder, then launches the VM with the floppy attached.

At this point, Windows boots, locates the answer file (`Autounattend.xml`)
specified in the Packer configuration and performs an unattended installation.

Upon rebooting, the machine executes a bootstrap script which sources files from
the floppy disk in order to run the first logon commands as indicated in the UI.

## Setting up your environment

Installation of a Packer build environment is simple, but a little messy:

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
2. Install [Packer](https://packer.io/downloads.html).
3. Ensure both of the above tools are on your `PATH`.

## Building a box

Boxes are identified by the names of their directories under `templates`. To
build one, you'll want to run a command along the lines of the following. Using
our helper script ensures the necessary environment variables are set, and
ensures that the relative paths in the templates can be resolved.

### On Linux

```
$ ./packer build templates/2008_r2_64/template.json
```

### On Windows

```
> .\packer.ps1 build .\templates\2008_r2_64\template.json
```

## Activating Windows

By default, these images are built from Evaluation editions of Windows. To
change the edition of a VM on the fly, run the following from an elevated
Command Prompt:

```
> DISM /online /Set-Edition:ServerStandard /AcceptEula /ProductKey:GET-YOUR-OWN
```

## Modifying answer files

Answer files are easiest to edit in the Windows System Image Manager. See
[TechNet](https://technet.microsoft.com/en-GB/library/hh825494.aspx) for
detailed installation instructions.

Be sure to check that WSIM hasn't made a mess of the XML file -- just open your
preferred editor and check the line endings and indentation and remove any
installation source information before checking in changes. It particularly
enjoys obscuring cleartext passwords, which is unhelpful in an open source
environment.

## A note on ISOs

By default, this project uses the free trial Windows Server trial ISOs provided
by Microsoft. If you wish to use an activated copy, you can do so by editing the
`iso_url` and `iso_checksum` fields in the `template.json` files and
altering `Autounattend.xml` accordingly.

The default ISOs are as follows:

* Windows Server 2008 R2 x64:
  http://download.microsoft.com/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso
* Windows Server 2012
  http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO
* Windows Server 2012 R2
  http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO
