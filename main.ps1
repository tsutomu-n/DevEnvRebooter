# main.ps1
# 
# このスクリプトは、WSL、ブラウザ、IDEの再起動を管理します。
# 管理者権限で実行する必要があります。

# 必要なモジュールをインポート
Import-Module "$PSScriptRoot\modules\AdminCheck.psm1"
Import-Module "$PSScriptRoot\modules\WslFunctions.psm1"
Import-Module "$PSScriptRoot\modules\BrowserFunctions.psm1"
Import-Module "$PSScriptRoot\modules\IdeFunctions.psm1"
Import-Module "$PSScriptRoot\modules\Logging.psm1"
Import-Module "$PSScriptRoot\modules\Notification.psm1"

# グローバル設定ファイルの読み込み
$global:config = Get-Content "$PSScriptRoot\config.json" | ConvertFrom-Json

# 管理者権限のチェック
if (-not (Test-AdminPrivileges)) {
    Show-ErrorNotification "このスクリプトは管理者権限で実行する必要があります。" "管理者権限が必要です"
    Exit 1
}

try {
    # ブラウザの終了
    Stop-Applications -Paths $global:config.BROWSERS -Type "ブラウザ"
    Log-Info "すべてのブラウザを終了しました。"

    # WSLの再起動
    if ($global:config.RESTART_WSL) {
        Restart-WSL
        Log-Info "WSLの再起動に成功しました。"
    }

    # IDEの再起動
    # WSLベースのIDEとネイティブIDEを区別
    $wslBasedIDEs = $global:config.IDES | Where-Object { $_ -match "wsl" }
    $nativeIDEs = $global:config.IDES | Where-Object { $_ -notmatch "wsl" }

    # WSLベースのIDEの再起動
    if ($wslBasedIDEs) {
        Restart-IDE -Paths $wslBasedIDEs -WslBased
        Log-Info "WSLベースのIDEの再起動に成功しました。"
    }

    # ネイティブIDEの再起動
    if ($nativeIDEs) {
        Restart-IDE -Paths $nativeIDEs
        Log-Info "ネイティブIDEの再起動に成功しました。"
    }

    # ブラウザの起動
    Start-Applications -Paths $global:config.BROWSERS -Type "ブラウザ"
    Log-Info "すべてのブラウザを起動しました。"

    # 完了通知
    Show-Notification "再起動が完了しました。" "再起動完了"
} catch {
    # エラーログの記録と通知
    Log-Error "再起動プロセス中にエラーが発生しました。" $_.Exception.Message
    Show-ErrorNotification "再起動プロセス中にエラーが発生しました。ログを確認してください。" "エラー"
}
