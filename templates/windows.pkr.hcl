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
  type = string
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

source "virtualbox-iso" "windows_server" {
  vm_name = var.template

  format        = "ova"
  guest_os_type = var.guest_os_type
  boot_wait     = "2m"
  headless      = true

  guest_additions_mode = "attach"
  vboxmanage = [
    [
      "modifyvm", "{{ .Name }}",
      "--memory", "4096",
      "--cpus",   "2",
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

  iso_url      = "${var.iso_url}"
  iso_checksum = "md5:${var.iso_checksum}"

  host_port_max = 5985
  host_port_min = 5985

  communicator   = "winrm"
  winrm_timeout  = "10h"
  winrm_username = "vagrant"
  winrm_password = "vagrant"

  floppy_files = [
    "../../templates/${var.template}/Autounattend.xml",
    "../../templates/${var.template}/Autounattend.generalize.xml",
    "../../scripts/core/pspolicy.cmd",
    "../../scripts/core/boxstarter.install.ps1",
    "../../scripts/core/boxstarter.execute.ps1",
    "../../scripts/core/boxstarter.package.ps1",
    "../../scripts/core/startup-profile.ps1",
    "../../scripts/core/shutdown.ps1",
  ]

  shutdown_command = "cmd.exe /c C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe -File A:\\shutdown.ps1 ${var.shutdown_args}"
  shutdown_timeout = "1h"
}

build {
  sources = [
    "source.virtualbox-iso.windows_server"
  ]

  post-processor "vagrant" {
    output               = "windows_${var.template}_${var.version}.box"
    vagrantfile_template = "../../templates/${var.template}/vagrantfile.template"
  }
}
