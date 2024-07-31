# CommonFunctions.psm1
#
# This module provides common functions for managing applications.

function Stop-Applications {
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

# Export the functions in this module
Export-ModuleMember -Function Stop-Applications, Start-Applications
