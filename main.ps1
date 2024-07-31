# main.ps1
# This script manages restarting WSL, browsers, and IDEs.
# It needs to be run with administrator privileges.

# Function to restart script as admin if not already running as admin
function Restart-ScriptAsAdmin {
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = "powershell"
    $startInfo.Arguments = $arguments
    $startInfo.Verb = "runas"
    [System.Diagnostics.Process]::Start($startInfo) | Out-Null
    exit
}

# Import required modules
Import-Module "$PSScriptRoot\modules\CommonFunctions.psm1"
Import-Module "$PSScriptRoot\modules\AdminCheck.psm1"
Import-Module "$PSScriptRoot\modules\WslFunctions.psm1"
Import-Module "$PSScriptRoot\modules\BrowserFunctions.psm1"
Import-Module "$PSScriptRoot\modules\IdeFunctions.psm1"
Import-Module "$PSScriptRoot\modules\Logging.psm1"
Import-Module "$PSScriptRoot\modules\Notification.psm1"

# Load global configuration file
$global:config = Get-Content "$PSScriptRoot\config.json" | ConvertFrom-Json

# Ensure log directory exists
$logDir = [System.IO.Path]::GetDirectoryName($global:config.LOG_FILE)
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Check for administrator privileges
if (-not (Test-AdminPrivileges)) {
    Show-ErrorNotification "This script must be run with administrator privileges." "Admin Privileges Required"
    Restart-ScriptAsAdmin
    Exit 1
}

try {
    # Stop browsers
    foreach ($browser in $global:config.BROWSERS) {
        Restart-Browser -Path $browser
        Write-LogInfo "$browser stopped."
    }

    # Restart WSL if needed
    if ($global:config.RESTART_WSL) {
        Restart-WSL
        Write-LogInfo "WSL restarted successfully."
    }

    # Restart IDEs
    foreach ($ide in $global:config.IDES) {
        Restart-IDE -Paths @($ide) -WslBased:$false
        Write-LogInfo "$ide restarted successfully."
    }

    # Start browsers
    foreach ($browser in $global:config.BROWSERS) {
        Start-Process -FilePath $browser
        Write-LogInfo "$browser started."
    }

    # Show completion notification
    Show-Notification "Restart completed successfully." "Restart Complete"
} catch {
    # Log error and show notification
    $additionalInfo = @{ ExceptionMessage = $_.Exception.Message }
    Write-LogError -message "An error occurred during the restart process." -additionalInfo $additionalInfo
    Show-ErrorNotification "An error occurred during the restart process. Check the log for details." "Error"
}
