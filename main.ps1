# main.ps1
# 
# This script manages restarting WSL, browsers, and IDEs.
# It needs to be run with administrator privileges.

# Import required modules
Import-Module "$PSScriptRoot\modules\AdminCheck.psm1"
Import-Module "$PSScriptRoot\modules\WslFunctions.psm1"
Import-Module "$PSScriptRoot\modules\BrowserFunctions.psm1"
Import-Module "$PSScriptRoot\modules\IdeFunctions.psm1"
Import-Module "$PSScriptRoot\modules\Logging.psm1"
Import-Module "$PSScriptRoot\modules\Notification.psm1"

# Load global configuration file
$global:config = Get-Content "$PSScriptRoot\config.json" | ConvertFrom-Json

# Check for administrator privileges
if (-not (Test-AdminPrivileges)) {
    Show-ErrorNotification "This script must be run with administrator privileges." "Admin Privileges Required"
    Exit 1
}

try {
    # Stop browsers
    foreach ($browser in $global:config.BROWSERS) {
        Restart-Browser -Path $browser
        Log-Info "$browser stopped."
    }

    # Restart WSL if needed
    if ($global:config.RESTART_WSL) {
        Restart-WSL
        Log-Info "WSL restarted successfully."
    }

    # Restart IDEs
    foreach ($ide in $global:config.IDES) {
        Restart-IDE -Path $ide -WslBased
        Log-Info "$ide restarted successfully."
    }

    # Start browsers
    foreach ($browser in $global:config.BROWSERS) {
        Start-Process -FilePath $browser
        Log-Info "$browser started."
    }

    # Show completion notification
    Show-Notification "Restart completed successfully." "Restart Complete"
} catch {
    # Log error and show notification
    Log-Error "An error occurred during the restart process." $_.Exception.Message
    Show-ErrorNotification "An error occurred during the restart process. Check the log for details." "Error"
}
