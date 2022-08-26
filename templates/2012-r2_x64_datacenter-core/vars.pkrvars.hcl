template = "2012-r2_x64_datacenter-core"
version  = "0.1.0"

guest_os_type = {
  parallels  = "win-2012"
  virtualbox = "Windows2012_64"
}

iso_url      = "http://download.microsoft.com/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.16384.WINBLUE_RTM.130821-1623_X64FRE_SERVER_EVAL_EN-US-IRM_SSS_X64FREE_EN-US_DV5.ISO"
iso_checksum = "458ff91f8abc21b75cb544744bf92e6a"

shutdown_args = "-UseStartupWorkaround"
