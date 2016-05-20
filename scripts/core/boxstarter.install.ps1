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
            return
        }

        $attempt++
        Start-Sleep -Seconds 1
    } while ($attempt -lt $maxAttempts)

    Write-Error "No network adapter available after $(maxAttempts) attempts"
}

Wait-ForNetwork

(New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/mwrock/boxstarter/master/BuildScripts/bootstrapper.ps1") `
        | Invoke-Expression
if (!(Test-Path -Type Container -Path $env:Temp)) {
    New-Item -ItemType Directory -Path $env:Temp
}
Get-Boxstarter -Force
