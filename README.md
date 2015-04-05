# Vagrant Windows box factory

For the poor ones amongst us who have to work with mediocre operating systems.

* * *

## Introduction

This project was born out of a last ditch attempt to escape the shackles of
Windows and go back to working on a "nice" operating system whilst still testing
on Windows. It builds Vagrant boxes for you.

## Building a box

Boxes are identified by the names of their directories under ```templates```. To
build one, you'll want to execute a command along the lines of the following:

    $ ./make-vm --template 2008_r2_64

## A note on ISOs

By default, this project uses the free trial Windows Server trial ISOs provided
by Microsoft. If you wish to use an activated copy, you can do so by editing the
```iso_url``` and ```iso_checksum``` fields in the ```template.json``` files and
altering ```Autounattend.xml``` accordingly.

The default ISOs are as follows:

* Windows Server 2008 R2 x64:
  http://download.microsoft.com/download/7/5/E/75EC4E54-5B02-42D6-8879-D8D3A25FBEF7/7601.17514.101119-1850_x64fre_server_eval_en-us-GRMSXEVAL_EN_DVD.iso
* Windows Server 2012
  http://download.microsoft.com/download/6/D/A/6DAB58BA-F939-451D-9101-7DE07DC09C03/9200.16384.WIN8_RTM.120725-1247_X64FRE_SERVER_EVAL_EN-US-HRM_SSS_X64FREE_EN-US_DV5.ISO
* Windows Server 2012 R2
  http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO
