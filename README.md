# Vagrant Windows box factory

Windows Server, as it should be out of the box.

---

## Introduction

This project contains a set of [Packer](https://www.packer.io/) templates and variable files which produce Windows base boxes for [Vagrant](https://www.vagrantup.com/).

## How it works

Packer downloads the required ISO files to the cache, creates a floppy image containing some key bootstrap files, creates the VM using the `virtualbox-iso` builder, then launches the VirtualBox VM with the installation media and generated floppy attached.

During its boot process, Windows setup reads the contents of the floppy disk locates the answer file (`Autounattend.xml`) and uses its contents to perform an unattended installation. This answer file configures automatic logon as the `vagrant` user.

During the OOBE (Out Of Box Experience) process, the machine executes a series of bootstrap scripts which install [Boxstarter](http://boxstarter.org/). Boxstarter is then used to install a package across a series of reboots, which:

- Reboots the machine to finalise the installation and exit the OOBE.
- Prevents the screen from being turned off when the machine is idle.
- Lowers the PowerShell policy to `RemoteSigned`.
- Prevents automated installation of Windows updates.
- Syspreps the machine.
- Enables WinRM for remote maintenance.

Once WinRM is available, Packer shuts the machine down and packages the machine image ready for distribution.

## Setting up your environment

Installation of a Packer build environment is simple:

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
2. Install [Packer](https://packer.io/downloads.html).
3. Ensure both of the above tools are on your `PATH`.

## Building a box

Two files instruct Packer on how to build our images:

- The template describes the target box and the source files and commands that build it.
- Variables files contain all of the parameter values.

These images are comprised of a single template (`templates/windows.pkr.hcl`) and a variables file which contains all of the values for the parameters that change across editions.

### On Linux

```console
./packer.sh build -var-file templates/2008-r2_x64_standard/vars.pkrvars.hcl templates/windows.pkr.hcl
```

### On Windows

```console
.\packer.ps1 build -var-file .\templates\2008-r2_x64_standard\vars.pkrvars.hcl .\templates\windows.pkr.hcl
```

## Activating Windows

By default, these images are built from Evaluation editions of Windows. To change the edition of a VM on the fly, run the following from an elevated Command Prompt:

```console
DISM /Online /Set-Edition:ServerStandard /AcceptEula /ProductKey:GET-YOUR-OWN
```

## Modifying answer files

Answer files are easiest to edit in the Windows System Image Manager. See [TechNet](https://technet.microsoft.com/en-GB/library/hh825494.aspx) for detailed installation instructions.

Be sure to check that WSIM hasn't made a mess of the XML file -- just open your preferred editor and check the line endings and indentation and remove any installation source information before checking in changes. It particularly enjoys obscuring cleartext passwords, which is unhelpful in an open source environment.

## A note on ISOs

By default, this project uses the free trial Windows Server trial ISOs provided by Microsoft. If you wish to use an activated copy, you can do so by editing the `iso_url` and `iso_checksum` fields in the `template.json` files and altering `Autounattend.xml` accordingly.

The default ISOs are as follows:

| Windows version | ISO URL | Cache filename |
| --- | --- | --- |
| 2008 R2 x64 | http://download.microsoft.com/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso | `75e529d96d6b175622512cf0a1bc55a5d1677e6a9d3b913fe95c65b6aa41770d.iso` |
| 2012 R2 x64 | http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO | `0fa2380dae2e2178d3dcbd7475d35a9133fd0d61cad4fa1f87a2a83f358a3c8b.iso` |
| 2016 x64 | http://care.dlservice.microsoft.com/dl/download/1/6/F/16FA20E6-4662-482A-920B-1A45CF5AAE3C/14393.0.160715-1616.RS1_RELEASE_SERVER_EVAL_X64FRE_EN-US.ISO | `524abd34eb2abcc5e5a12da5b1c97fa3a6a626a831c29b4e74801f4131fb08ed.iso` |
| 2019 x63 | https://software-download.microsoft.com/download/sg/17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso | `` |
