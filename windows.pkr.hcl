packer {
  required_plugins {
    parallels = {
      source  = "github.com/hashicorp/parallels"
      version = ">= 1.0.1"
    }
  }
}

variable "build_dir" {
  type    = string
  default = env("PACKER_BUILD_DIR")
}

variable "template" {
  type = string
}

variable "version" {
  type = string
}

variable "guest_os_type" {
  type = object({
    parallels  = string
    virtualbox = string
  })
}

variable "iso_url" {
  type = string
}

variable "iso_checksum" {
  type = string
}

variable "shutdown_args" {
  type    = string
  default = ""
}

locals {
  cpus      = 2
  memory_mb = 4096

  communicator = {
    communicator   = "winrm"
    winrm_timeout  = "10h"
    winrm_username = "vagrant"
    winrm_password = "vagrant"
  }

  cd_files = [
    "../../templates/${var.template}/Autounattend.xml",
    "../../templates/${var.template}/Autounattend.generalize.xml",
    "../../scripts/core/pspolicy.cmd",
    "../../scripts/core/boxstarter.install.ps1",
    "../../scripts/core/boxstarter.execute.ps1",
    "../../scripts/core/boxstarter.package.ps1",
    "../../scripts/core/startup-profile.ps1",
    "../../scripts/core/shutdown.ps1",
  ]

  shutdown = {
    command = "cmd.exe /c C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -File E:\\shutdown.ps1 ${var.shutdown_args}"
    timeout = "1h"
  }
}

source "parallels-iso" "windows_server" {
  vm_name = var.template

  guest_os_type = var.guest_os_type.parallels

  parallels_tools_mode = "disable"
  prlctl = [
    [
      "set",       "{{ .Name }}",
      "--memsize", local.memory_mb,
      "--cpus",    local.cpus,
    ],
  ]
  prlctl_post = []

  iso_url      = var.iso_url
  iso_checksum = "md5:${var.iso_checksum}"

  boot_wait = "0s"

  communicator   = local.communicator.communicator
  winrm_timeout  = local.communicator.winrm_timeout
  winrm_username = local.communicator.winrm_username
  winrm_password = local.communicator.winrm_password

  cd_files = local.cd_files

  shutdown_command = local.shutdown.command
  shutdown_timeout = local.shutdown.timeout
}

source "virtualbox-iso" "windows_server" {
  vm_name = var.template

  format        = "ova"
  guest_os_type = var.guest_os_type.virtualbox
  headless      = true

  firmware             = "efi"
  guest_additions_mode = "disable"
  vboxmanage = [
    [
      "modifyvm", "{{ .Name }}",
      "--memory", local.memory_mb,
      "--cpus",   local.cpus,
    ],
    [
      "modifyvm",            "{{ .Name }}",
      "--recordingscreens",  "0",
      "--recordingvideores", "1024x768",
      "--recordingvideorate", "512",
      "--recordingvideofps", "25",
      "--recordingfile",     "${var.build_dir}/capture.webm",
      "--recordingopts",     "vc_enabled=true,ac_enabled=true,ac_profile=med",
      "--recording",         "on",
    ],
  ]
  vboxmanage_post = [
    [
      "modifyvm",    "{{ .Name }}",
      "--recording", "off",
    ],
  ]

  hard_drive_interface = "sata"
  iso_interface        = "sata"
  iso_url              = var.iso_url
  iso_checksum         = "md5:${var.iso_checksum}"

  boot_command = [
    "<esc>",
    "FS0:\\EFI\\BOOT\\BOOTX64.EFI<enter>",
    "<wait1s>",
    "<enter>",
  ]
  boot_wait = "10s"
  host_port_max = 5985
  host_port_min = 5985

  communicator   = local.communicator.communicator
  winrm_timeout  = local.communicator.winrm_timeout
  winrm_username = local.communicator.winrm_username
  winrm_password = local.communicator.winrm_password

  cd_files = local.cd_files

  shutdown_command = local.shutdown.command
  shutdown_timeout = local.shutdown.timeout
}

build {
  sources = [
    "source.parallels-iso.windows_server",
    "source.virtualbox-iso.windows_server",
  ]

  post-processor "vagrant" {
    output               = "windows_${var.template}_${var.version}.box"
    vagrantfile_template = "../../templates/${var.template}/vagrantfile.template"
  }
}
