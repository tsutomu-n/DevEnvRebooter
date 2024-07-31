# ColorOutput.psm1
#
# This module provides functions for colorful output in the console.

function Write-Info {
    param (
        [string]$message
    )
    Write-Host $message -ForegroundColor Green
}

function Write-Warning {
    param (
        [string]$message
    )
    Write-Host $message -ForegroundColor Yellow
}

function Write-Error {
    param (
        [string]$message
    )
    Write-Host $message -ForegroundColor Red
}

function Show-ProgressBar {
    param (
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

# Export functions
Export-ModuleMember -Function Write-Info, Write-Warning, Write-Error, Show-ProgressBar
