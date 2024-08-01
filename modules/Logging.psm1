# Logging.psm1

<#
.SYNOPSIS
ログ記録機能を提供するモジュール

.DESCRIPTION
このモジュールは、アプリケーションのログ記録とログファイルのローテーション機能を提供します。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

function Write-Log {
    <#
    .SYNOPSIS
    指定されたメッセージをログファイルに記録します。

    .DESCRIPTION
    このファンクションは、指定されたレベルとメッセージをログファイルに記録します。

    .PARAMETER Level
    ログレベル（INFO, WARNING, ERROR）

    .PARAMETER Message
    ログに記録するメッセージ
    #>
    param (
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level,
        [string]$Message
    )

    $logEntry = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -Path "$($global:config.LOG_DIR)\$($global:config.LOG_FILE)" -Value $logEntry
}

function Write-LogInfo {
    param ([string]$Message)
    Write-Log -Level "INFO" -Message $Message
}

function Write-LogWarning {
    param ([string]$Message)
    Write-Log -Level "WARNING" -Message $Message
}

function Write-LogError {
    param ([string]$Message)
    Write-Log -Level "ERROR" -Message $Message
}

function Invoke-LogRotation {
    <#
    .SYNOPSIS
    ログファイルのローテーションを実行します。

    .DESCRIPTION
    このファンクションは、ログファイルのサイズをチェックし、
    指定されたサイズを超えた場合にローテーションを実行します。
    #>
    param (
        [int]$MaxSizeKB = 1024,
        [int]$MaxBackups = 5
    )

    $logFile = "$($global:config.LOG_DIR)\$($global:config.LOG_FILE)"
    if ((Get-Item $logFile).Length / 1KB -gt $MaxSizeKB) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $newLogFile = "{0}_{1}" -f $logFile, $timestamp
        Move-Item -Path $logFile -Destination $newLogFile -Force

        Get-ChildItem -Path $global:config.LOG_DIR -Filter "$($global:config.LOG_FILE)*" |
            Sort-Object LastWriteTime -Descending |
            Select-Object -Skip $MaxBackups |
            Remove-Item -Force
    }
}

Export-ModuleMember -Function Write-LogInfo, Write-LogWarning, Write-LogError, Invoke-LogRotation