# ColorOutput.psm1
#
# This module provides functions for colorful console output.

function Write-Info {
    param ([string]$message)
    Write-Host $message -ForegroundColor Green
}

function Write-Warning {
    param ([string]$message)
    Write-Host $message -ForegroundColor Yellow
}

function Write-Error {
    param ([string]$message)
    Write-Host $message -ForegroundColor Red
}

# Export functions
Export-ModuleMember -Function Write-Info, Write-Warning, Write-Error
