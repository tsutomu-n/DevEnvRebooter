# WslFunctions.psm1
#
# This module contains functions to manage WSL.

function Restart-WSL {
    <#
    .SYNOPSIS
    Restarts WSL.

    .DESCRIPTION
    This function shuts down and restarts WSL.
    After restarting, it waits until WSL is fully up and running.

    .PARAMETER maxRetries
    Maximum number of retry attempts.

    .PARAMETER retryWaitTime
    Wait time between retries in seconds.

    .PARAMETER wslStartupWaitTime
    Maximum wait time for WSL to start up in seconds.

    .OUTPUTS
    None
    #>

    param (
        [int]$maxRetries = 3,
        [int]$retryWaitTime = 5,
        [int]$wslStartupWaitTime = 30
    )

    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            Write-Host "Restarting WSL..."
            wsl --shutdown
            Start-Sleep -Seconds $global:config.RESTART_WAIT_TIME
            wsl echo "WSL is starting..."
            
            # Wait until WSL is fully up and running
            $startTime = Get-Date
            while ($true) {
                if ((wsl echo "WSL is ready") -eq "WSL is ready") {
                    break
                }
                if (((Get-Date) - $startTime).TotalSeconds -gt $wslStartupWaitTime) {
                    throw "WSL startup timed out."
                }
                Start-Sleep -Seconds 1
            }
            
            Write-Host "WSL restarted."
            return
        } catch {
            if ($i -eq $maxRetries) {
                throw "Failed to restart WSL after $maxRetries attempts."
            } else {
                Write-Warning "Failed to restart WSL. Retrying $i/$maxRetries"
                Start-Sleep -Seconds $retryWaitTime
            }
        }
    }
}

# Export function
Export-ModuleMember -Function Restart-WSL
