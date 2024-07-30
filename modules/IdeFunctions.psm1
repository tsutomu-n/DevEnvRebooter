# IdeFunctions.psm1
#
# This module contains functions to manage IDEs.

# Import common functions
. "$PSScriptRoot\CommonFunctions.psm1"

function Restart-IDE {
    <#
    .SYNOPSIS
    Restarts the specified IDE.

    .DESCRIPTION
    This function stops and restarts the IDE specified by the given path.
    If the IDE is WSL-based, it waits until WSL is fully up and running.

    .PARAMETER Paths
    The paths to the IDE executables.

    .PARAMETER WslBased
    Indicates if the IDE is WSL-based.

    .OUTPUTS
    None
    #>

    param (
        [string[]]$Paths,
        [switch]$WslBased
    )
    
    Stop-Applications -Paths $Paths -Type "IDE"
    
    if ($WslBased) {
        # Wait until WSL is fully up and running
        $wslReady = $false
        $startTime = Get-Date
        while (-not $wslReady) {
            if ((wsl echo "WSL is ready") -eq "WSL is ready") {
                $wslReady = $true
            } elseif (((Get-Date) - $startTime).TotalSeconds -gt 60) {
                Write-Warning "WSL is not ready. Skipping IDE restart."
                return
            }
            Start-Sleep -Seconds 1
        }
    }
    
    Start-Applications -Paths $Paths -Type "IDE"
}

# Export function
Export-ModuleMember -Function Restart-IDE
