# main.ps1
#
# This script manages restarting WSL, browsers, and IDEs.
# It needs to be run with administrator privileges.

# Import necessary modules
Import-Module "$PSScriptRoot\modules\AdminCheck.psm1" -ErrorAction Stop
Import-Module "$PSScriptRoot\modules\WslFunctions.psm1" -ErrorAction Stop
Import-Module "$PSScriptRoot\modules\BrowserFunctions.psm1" -ErrorAction Stop
Import-Module "$PSScriptRoot\modules\IdeFunctions.psm1" -ErrorAction Stop
Import-Module "$PSScriptRoot\modules\Logging.psm1" -ErrorAction Stop
Import-Module "$PSScriptRoot\modules\Notification.psm1" -ErrorAction Stop
Import-Module "$PSScriptRoot\modules\CommonFunctions.psm1" -ErrorAction Stop  # Import without displaying the content

# Load global configuration file
$configPath = "$PSScriptRoot\config.json"
$global:config = Get-Content $configPath | ConvertFrom-Json

# Manually expand environment variables in config paths
$global:config.LOG_DIR = $global:config.LOG_DIR -replace '\${env:USERNAME}', $env:USERNAME
$global:config.BROWSERS = $global:config.BROWSERS | ForEach-Object { $_ -replace '\${env:USERNAME}', $env:USERNAME }
$global:config.IDES = $global:config.IDES | ForEach-Object { $_ -replace '\${env:USERNAME}', $env:USERNAME }

# Check for administrator privileges
if (-not (Test-AdminPrivileges)) {
    Show-ErrorNotification "This script must be run with administrator privileges. Please run PowerShell as an administrator and try again." "Admin Privileges Required"
    Exit 1
}

try {
    # Ensure the log directory exists
    $logDir = $global:config.LOG_DIR
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }

    # Rotate logs
    Invoke-LogRotation -logFile "$logDir\$($global:config.LOG_FILE)"

    # Stop browsers
    Stop-Applications -Paths $global:config.BROWSERS -Type "Browser"
    Write-LogInfo "All browsers stopped."

    # Restart WSL if required
    if ($global:config.RESTART_WSL) {
        Restart-WSL
        Write-LogInfo "WSL restarted successfully."
    }

    # Restart IDEs
    $wslBasedIDEs = $global:config.IDES | Where-Object { $_ -match "wsl" }
    $nativeIDEs = $global:config.IDES | Where-Object { $_ -notmatch "wsl" }

    if ($wslBasedIDEs) {
        Restart-IDE -Paths $wslBasedIDEs -WslBased
        Write-LogInfo "WSL-based IDEs restarted successfully."
    }

    if ($nativeIDEs) {
        Restart-IDE -Paths $nativeIDEs
        Write-LogInfo "Native IDEs restarted successfully."
    }

    # Start browsers
    Start-Applications -Paths $global:config.BROWSERS -Type "Browser"
    Write-LogInfo "All browsers started."

    # Show completion notification
    Show-Notification "Restart process completed successfully." "Restart Complete"
} catch {
    # Log errors and show error notification
    Write-LogError "An error occurred during the restart process." @{Exception=$_.Exception.Message}
    Show-ErrorNotification "An error occurred during the restart process. Check the logs for details." "Error"
}
