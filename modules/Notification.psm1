# Notification.psm1

<#
.SYNOPSIS
通知機能を提供するモジュール

.DESCRIPTION
このモジュールは、ユーザーへの通知機能を提供します。
トースト通知やダイアログボックスを使用して情報を表示します。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

Add-Type -AssemblyName System.Windows.Forms

function Show-Notification {
    <#
    .SYNOPSIS
    通知を表示します。

    .DESCRIPTION
    このファンクションは、指定されたメッセージとタイトルで通知を表示します。

    .PARAMETER Message
    表示するメッセージ

    .PARAMETER Title
    通知のタイトル
    #>
    param (
        [string]$Message,
        [string]$Title
    )

    $balloon = New-Object System.Windows.Forms.NotifyIcon
    $balloon.Icon = [System.Drawing.SystemIcons]::Information
    $balloon.BalloonTipTitle = $Title
    $balloon.BalloonTipText = $Message
    $balloon.Visible = $true
    $balloon.ShowBalloonTip(5000)
}

function Show-ErrorNotification {
    <#
    .SYNOPSIS
    エラー通知を表示します。

    .DESCRIPTION
    このファンクションは、指定されたエラーメッセージとタイトルでエラー通知を表示します。

    .PARAMETER Message
    表示するエラーメッセージ

    .PARAMETER Title
    エラー通知のタイトル
    #>
    param (
        [string]$Message,
        [string]$Title
    )

    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

Export-ModuleMember -Function Show-Notification, Show-ErrorNotification