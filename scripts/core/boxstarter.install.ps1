Param(
  [Parameter()]
  [switch] $Use7Zip = $false
)

function Wait-ForNetwork {
  Param(
    [int] $maxAttempts = 32
  )

  $attempt = 0
  do {
    Write-Debug "Attempt $($attempt + 1) of $($maxAttempts)"
    $adapters = Get-WmiObject -class Win32_NetworkAdapterConfiguration -filter DHCPEnabled=True `
        | Where-Object { $_.DefaultIPGateway -ne $null } `
        | Measure-Object

    if ($adapters.Count -gt 0) {
      Write-Verbose "Found adapter on attempt $($attempt + 1)"
      return
    }

    $attempt++
    Start-Sleep -Seconds 1
  } while ($attempt -lt $maxAttempts)

  throw "No network adapter available after $(maxAttempts) attempts"
}

try {
  Wait-ForNetwork
} catch {
  Write-Host "Wait-ForNetwork failed; waiting for input to proceed"
  $_.Exception | Format-List -Force
  & powershell
}

if (!(Test-Path -Type Container -Path $env:Temp)) {
  New-Item -ItemType Directory -Path $env:Temp
}

if ($Use7Zip) {
  $env:chocolateyUseWindowsCompression = 'false'
}

try {
  (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/mwrock/boxstarter/master/BuildScripts/bootstrapper.ps1") `
      | Invoke-Expression
  Get-Boxstarter -Force
} catch {
  Write-Host "Get-Boxstarter failed; waiting for input to proceed"
  $_.Exception | Format-List -Force
  & powershell
}
