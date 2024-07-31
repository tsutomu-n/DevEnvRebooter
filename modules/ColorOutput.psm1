# ColorOutput.psm1
#
# This module provides colorful output functions.

function Write-ColoredOutput {
    param (
        [string]$Message,
        [string]$Color
    )

    switch ($Color) {
        "Green" { Write-Host $Message -ForegroundColor Green }
        "Yellow" { Write-Host $Message -ForegroundColor Yellow }
        "Red" { Write-Host $Message -ForegroundColor Red }
        "Blue" { Write-Host $Message -ForegroundColor Blue }
        default { Write-Host $Message }
    }
}

# Export functions
Export-ModuleMember -Function Write-ColoredOutput
