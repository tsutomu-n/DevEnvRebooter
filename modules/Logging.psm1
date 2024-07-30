# Logging.psm1
#
# This module handles logging and log rotation.

function Rotate-LogFile {
    <#
    .SYNOPSIS
    Rotates the log file when it exceeds a specified size.

    .DESCRIPTION
    This function rotates the log file when it exceeds the specified size
    by creating backup files and deleting the oldest backup if needed.

    .PARAMETER logFile
    The path to the log file.

    .PARAMETER maxSizeKB
    The maximum size of the log file in KB before rotation.

    .PARAMETER maxBackups
    The maximum number of backup files to keep.

    .OUTPUTS
    None
    #>

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
    <#
    .SYNOPSIS
    Logs a message to the log file.

    .DESCRIPTION
    This function logs a message with the specified level and additional info
    in JSON format to the log file.

    .PARAMETER Level
    The log level (INFO, ERROR, etc.)

    .PARAMETER Message
    The log message.

    .PARAMETER AdditionalInfo
    Additional information (optional)

    .OUTPUTS
    None
    #>

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
    Add-Content -Path $global:config.LOG_FILE -Value $jsonLog
}

function Log-Info {
    <#
    .SYNOPSIS
    Logs an INFO level message.

    .DESCRIPTION
    This function logs an INFO level message with optional additional info.

    .PARAMETER message
    The log message.

    .PARAMETER additionalInfo
    Additional information (optional)

    .OUTPUTS
    None
    #>

    param ([string]$message, [hashtable]$additionalInfo = @{})
    Log-Message -Level "INFO" -Message $message -AdditionalInfo $additionalInfo
}

function Log-Error {
    <#
    .SYNOPSIS
    Logs an ERROR level message.

    .DESCRIPTION
    This function logs an ERROR level message with optional additional info.

    .PARAMETER message
    The log message.

    .PARAMETER additionalInfo
    Additional information (optional)

    .OUTPUTS
    None
    #>

    param ([string]$message, [hashtable]$additionalInfo = @{})
    Log-Message -Level "ERROR" -Message $message -AdditionalInfo $additionalInfo
}

# Export functions
Export-ModuleMember -Function Log-Info, Log-Error
