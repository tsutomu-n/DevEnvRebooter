# Logging.psm1
#
# This module provides logging functions.

function Rotate-LogFile {
    param (
        [string]$logFile,
        [int]$maxSizeKB = 1024,
        [int]$maxBackups = 5
    )

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

function Log-Message {
    param (
        [string]$Level,
        [string]$Message,
        [hashtable]$AdditionalInfo = @{}
    )

    $logEntry = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Level = $Level
        Message = $Message
    } + $AdditionalInfo

    $jsonLog = $logEntry | ConvertTo-Json -Compress
    Add-Content -Path "$global:config.LOG_DIR\$global:config.LOG_FILE" -Value $jsonLog
}

function Log-Info {
    param ([string]$message, [hashtable]$additionalInfo = @{})
    Log-Message -Level "INFO" -Message $message -AdditionalInfo $additionalInfo
}

function Log-Error {
    param ([string]$message, [hashtable]$additionalInfo = @{})
    Log-Message -Level "ERROR" -Message $message -AdditionalInfo $additionalInfo
}

# Export functions
Export-ModuleMember -Function Log-Message, Log-Info, Log-Error
