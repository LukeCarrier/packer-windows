try {
  $startup = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs\Startup\boxstarter-post-restart.bat"
  if (!$env:PACKER_STARTUP_WORKAROUND -and (Test-Path $startup)) {
    & cmd /c $startup
  }
} finally {
  $env:PACKER_STARTUP_WORKAROUND = 1
}
