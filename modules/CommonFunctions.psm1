# CommonFunctions.psm1
#
# This module provides common functions for stopping and starting applications.

function Stop-Applications {
    <#
    .SYNOPSIS
    Stops the specified applications.

    .DESCRIPTION
    This function stops the applications specified by the given paths.
    If stopping fails, it retries up to the specified number of times.

    .PARAMETER Paths
    The paths to the application executables.

    .PARAMETER Type
    The type of application (for logging).

    .PARAMETER maxRetries
    The maximum number of retry attempts.

    .PARAMETER retryWaitTime
    The wait time between retries in seconds.

    .OUTPUTS
    None
    #>

    param (
        [string[]]$Paths,
        [string]$Type,
        [int]$maxRetries = 3,
        [int]$retryWaitTime = 5
    )
    
    foreach ($path in $Paths) {
        for ($i = 1; $i -le $maxRetries; $i++) {
            try {
                $processName = (Split-Path $path -Leaf) -replace '\.exe$',''
                Stop-Process -Name $processName -Force -ErrorAction Stop
                Write-Host "$Type ($processName) stopped."
                break
            } catch {
                if ($i -eq $maxRetries) {
                    Write-Warning "Failed to stop $Type ($processName) after $maxRetries attempts."
                } else {
                    Write-Warning "Failed to stop $Type ($processName). Retrying $i/$maxRetries"
                    Start-Sleep -Seconds $retryWaitTime
                }
            }
        }
    }
}

function Start-Applications {
    <#
    .SYNOPSIS
    Starts the specified applications.

    .DESCRIPTION
    This function starts the applications specified by the given paths.

    .PARAMETER Paths
    The paths to the application executables.

    .PARAMETER Type
    The type of application (for logging).

    .OUTPUTS
    None
    #>

    param (
        [string[]]$Paths,
        [string]$Type
    )
    
    foreach ($path in $Paths) {
        try {
            Start-Process -FilePath $path
            Write-Host "$Type ($(Split-Path $path -Leaf)) started."
        } catch {
            Write-Warning "Failed to start $Type ($(Split-Path $path -Leaf))."
        }
    }
}

# Export functions
Export-ModuleMember -Function Stop-Applications, Start-Applications
