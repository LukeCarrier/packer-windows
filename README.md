# Vagrant Windows box factory

Windows Server, as it should be out of the box.

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

Installation of a Packer build environment is simple:

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
$ ./packer.sh build -var-file templates/2008_r2_64/vars.json templates/windows.json
```

### On Windows

```
> .\packer.ps1 build -var-file .\templates\2008_r2_64\vars.json .\templates\windows.json
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

| Windows version | ISO URL | Cache filename  |
| --- | --- | --- |
| 2008 R2 x64 | http://download.microsoft.com/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso | `75e529d96d6b175622512cf0a1bc55a5d1677e6a9d3b913fe95c65b6aa41770d.iso` |
| 2012 R2 x64 | http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO | `0fa2380dae2e2178d3dcbd7475d35a9133fd0d61cad4fa1f87a2a83f358a3c8b.iso` |
| 2016 x64 | http://care.dlservice.microsoft.com/dl/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO | `524abd34eb2abcc5e5a12da5b1c97fa3a6a626a831c29b4e74801f4131fb08ed.iso` |
