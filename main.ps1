# main.ps1
# This script manages restarting WSL, browsers, and IDEs.
# It needs to be run with administrator privileges.

# Import required modules
Import-Module "$PSScriptRoot\modules\AdminCheck.psm1"
Import-Module "$PSScriptRoot\modules\CommonFunctions.psm1"
Import-Module "$PSScriptRoot\modules\WslFunctions.psm1"
Import-Module "$PSScriptRoot\modules\BrowserFunctions.psm1"
Import-Module "$PSScriptRoot\modules\IdeFunctions.psm1"
Import-Module "$PSScriptRoot\modules\Logging.psm1"
Import-Module "$PSScriptRoot\modules\Notification.psm1"
Import-Module "$PSScriptRoot\modules\ColorOutput.psm1"

# Load global configuration file
$global:config = Get-Content "$PSScriptRoot\config.json" | ConvertFrom-Json

# Check for administrator privileges
if (-not (Test-AdminPrivileges)) {
    Restart-ScriptAsAdmin
    Exit 1
}

try {
    $steps = 4
    $currentStep = 0

    # Stop browsers
    foreach ($browser in $global:config.BROWSERS) {
        $currentStep++
        Write-Info "Stopping $browser..."
        Show-ProgressBar -Activity "Restart Process" -Status "Stopping $browser" -PercentComplete (($currentStep / $steps) * 100)
        Restart-Browser -Path $browser
        Write-Info "$browser stopped."
    }

    # Restart WSL if needed
    if ($global:config.RESTART_WSL) {
        $currentStep++
        Write-Info "Restarting WSL..."
        Show-ProgressBar -Activity "Restart Process" -Status "Restarting WSL" -PercentComplete (($currentStep / $steps) * 100)
        Restart-WSL
        Write-Info "WSL restarted successfully."
    }

    # Restart IDEs
    foreach ($ide in $global:config.IDES) {
        $currentStep++
        Write-Info "Restarting $ide..."
        Show-ProgressBar -Activity "Restart Process" -Status "Restarting $ide" -PercentComplete (($currentStep / $steps) * 100)
        Restart-IDE -Paths @($ide) -WslBased:$false
        Write-Info "$ide restarted successfully."
    }

    # Start browsers
    foreach ($browser in $global:config.BROWSERS) {
        $currentStep++
        Write-Info "Starting $browser..."
        Show-ProgressBar -Activity "Restart Process" -Status "Starting $browser" -PercentComplete (($currentStep / $steps) * 100)
        Start-Process -FilePath $browser
        Write-Info "$browser started."
    }

    # Show completion notification
    Show-Notification "Restart completed successfully." "Restart Complete"
    Write-Info "Restart process completed successfully."
} catch {
    # Log error and show notification
    $additionalInfo = @{ ExceptionMessage = $_.Exception.Message }
    Write-LogError -message "An error occurred during the restart process." -additionalInfo $additionalInfo
    Show-ErrorNotification "An error occurred during the restart process. Check the log for details." "Error"
    Write-Error "An error occurred: $_.Exception.Message"
}
