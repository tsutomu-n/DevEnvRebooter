# Notification.psm1
#
# このモジュールは、通知機能を提供します。

function Show-Notification {
    <#
    .SYNOPSIS
    指定された方法で通知を表示します。

    .DESCRIPTION
    このファンクションは、指定された方法（コンソール、ポップアップ、トースト）で通知を表示します。

    .PARAMETER message
    通知メッセージ

    .PARAMETER title
    通知タイトル（デフォルト: "通知"）

    .PARAMETER method
    通知方法（"console", "popup", "toast"のいずれか）

    .OUTPUTS
    なし
    #>

    param (
        [string]$message,
        [string]$title = "通知",
        [string]$method = "console" # "console", "popup", "toast"のいずれか
    )
    
    switch ($method) {
        "console" {
            Write-Host $message -ForegroundColor Green
        }
        "popup" {
            Add-Type -AssemblyName PresentationFramework
            [System.Windows.MessageBox]::Show($message, $title)
        }
        "toast" {
            New-BurntToastNotification -Text $title, $message
        }
    }
}

function Show-ErrorNotification {
    <#
    .SYNOPSIS
    エラー通知を表示します。

    .DESCRIPTION
    このファンクションは、エラーメッセージをポップアップで表示します。

    .PARAMETER message
    エラーメッセージ

    .PARAMETER title
    エラータイトル

    .OUTPUTS
    なし
    #>

    param (
        [string]$message,
        [string]$title
    )
    
    Add-Type -AssemblyName PresentationFramework
    [System.Windows.MessageBox]::Show($message, $title, [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
}

# モジュールの公開ファンクション
Export-ModuleMember -Function Show-Notification, Show-ErrorNotification
