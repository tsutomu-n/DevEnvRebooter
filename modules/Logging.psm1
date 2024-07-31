# Logging.psm1
#
# This module provides logging functions.

function Invoke-LogRotation {
    param (
        [string]$logFile,
        [int]$maxSizeKB = 1024,
        [int]$maxBackups = 5
    )

    if (-not (Test-Path $logFile)) {
        # If log file doesn't exist, create it
        New-Item -Path $logFile -ItemType File | Out-Null
    }

    if ((Get-Item $logFile).Length / 1KB -gt $maxSizeKB) {
        for ($i = $maxBackups; $i -gt 0; $i--) {
            $oldFile = "$logFile.$i"
            $newFile = "$logFile.$($i+1)"
            if (Test-Path $oldFile) {
                Move-Item $oldFile $newFile -Force
            }
        }
        Move-Item $logFile "$logFile.1" -Force
        New-Item $logFile -ItemType File | Out-Null
    }
}

function Write-LogMessage {
    param (
        [string]$Level,
        [string]$Message,
        [hashtable]$AdditionalInfo = @{}
    )

    $logDir = $global:config.LOG_DIR
    $logFile = "$logDir\$($global:config.LOG_FILE)"

    if (-not (Test-Path $logDir)) {
        # Ensure the log directory exists
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }

    if (-not (Test-Path $logFile)) {
        # Ensure the log file exists
        New-Item -Path $logFile -ItemType File | Out-Null
    }

    $logEntry = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Level = $Level
        Message = $Message
    } + $AdditionalInfo

    $jsonLog = $logEntry | ConvertTo-Json -Compress
    Add-Content -Path $logFile -Value $jsonLog
}

function Write-LogInfo {
    param ([string]$message, [hashtable]$additionalInfo = @{})
    Write-LogMessage -Level "INFO" -Message $message -AdditionalInfo $additionalInfo
}

function Write-LogError {
    param ([string]$message, [hashtable]$additionalInfo = @{})
    Write-LogMessage -Level "ERROR" -Message $message -AdditionalInfo $additionalInfo
}

# Export functions
Export-ModuleMember -Function Invoke-LogRotation, Write-LogMessage, Write-LogInfo, Write-LogError
