# Logging.psm1
#
# このモジュールは、ログ記録機能を提供します。

function Log-Message {
    <#
    .SYNOPSIS
    メッセージをログファイルに記録します。

    .DESCRIPTION
    このファンクションは、指定されたレベル、メッセージ、追加情報をJSON形式でログファイルに記録します。

    .PARAMETER Level
    ログレベル（INFO, ERROR, など）

    .PARAMETER Message
    ログメッセージ

    .PARAMETER AdditionalInfo
    追加情報（オプション）

    .OUTPUTS
    なし
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
    INFO レベルのメッセージをログに記録します。

    .DESCRIPTION
    このファンクションは、INFO レベルのメッセージと追加情報をログに記録します。

    .PARAMETER message
    ログメッセージ

    .PARAMETER additionalInfo
    追加情報（オプション）

    .OUTPUTS
    なし
    #>

    param ([string]$message, [hashtable]$additionalInfo = @{})
    Log-Message -Level "INFO" -Message $message -AdditionalInfo $additionalInfo
}

function Log-Error {
    <#
    .SYNOPSIS
    ERROR レベルのメッセージをログに記録します。

    .DESCRIPTION
    このファンクションは、ERROR レベルのメッセージと追加情報をログに記録します。

    .PARAMETER message
    ログメッセージ

    .PARAMETER additionalInfo
    追加情報（オプション）

    .OUTPUTS
    なし
    #>

    param ([string]$message, [hashtable]$additionalInfo = @{})
    Log-Message -Level "ERROR" -Message $message -AdditionalInfo $additionalInfo
}

# モジュールの公開ファンクション
Export-ModuleMember -Function Log-Info, Log-Error
