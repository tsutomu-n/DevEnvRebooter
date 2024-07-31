# main.ps1
# This script manages the restart of WSL, browsers, and IDEs.
# It must be run with administrator privileges.

# Import necessary modules
Import-Module "$PSScriptRoot\modules\AdminCheck.psm1"
Import-Module "$PSScriptRoot\modules\WslFunctions.psm1"
Import-Module "$PSScriptRoot\modules\BrowserFunctions.psm1"
Import-Module "$PSScriptRoot\modules\IdeFunctions.psm1"
Import-Module "$PSScriptRoot\modules\Logging.psm1"
Import-Module "$PSScriptRoot\modules\Notification.psm1"
Import-Module "$PSScriptRoot\modules\ColorOutput.psm1"

# Load global configuration file
$global:config = Get-Content "$PSScriptRoot\config.json" | ConvertFrom-Json

# Update log directory path with current username
$global:config.LOG_DIR = $global:config.LOG_DIR -replace "<username>", $env:USERNAME
$global:config.IDES = $global:config.IDES -replace "<username>", $env:USERNAME

# Check for admin privileges
if (-not (Test-AdminPrivileges)) {
    Show-ErrorNotification "This script must be run with administrator privileges." "Administrator Required"
    Exit 1
}

# Ensure log directory exists
$logDir = $global:config.LOG_DIR
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

try {
    # Stop browsers
    Stop-Applications -Paths $global:config.BROWSERS -Type "Browser"
    Log-Info "All browsers stopped."

    # Restart WSL
    if ($global:config.RESTART_WSL) {
        Restart-WSL
        Log-Info "WSL restarted successfully."
    }

    # Restart IDEs
    $wslBasedIDEs = $global:config.IDES | Where-Object { $_ -match "wsl" }
    $nativeIDEs = $global:config.IDES | Where-Object { $_ -notmatch "wsl" }

    if ($wslBasedIDEs) {
        Restart-IDE -Paths $wslBasedIDEs -WslBased
        Log-Info "WSL-based IDEs restarted successfully."
    }

    if ($nativeIDEs) {
        Restart-IDE -Paths $nativeIDEs
        Log-Info "Native IDEs restarted successfully."
    }

    # Start browsers
    Start-Applications -Paths $global:config.BROWSERS -Type "Browser"
    Log-Info "All browsers started."

    # Show completion notification
    Show-Notification "Restart process completed successfully." "Restart Complete"
} catch {
    Log-Error "An error occurred during the restart process." @{Exception = $_.Exception.Message}
    Show-ErrorNotification "An error occurred during the restart process. Please check the logs for details." "Error"
}
