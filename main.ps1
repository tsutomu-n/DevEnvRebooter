<#
.SYNOPSIS
DevEnvRebooter - 開発環境の効率的な再起動ツール

.DESCRIPTION
このスクリプトは、WSL、ブラウザ、IDEなどの開発環境を効率的に再起動するためのツールです。
並列処理、GUIによる進行状況表示、エラーハンドリング、ログ記録機能を提供します。
セキュリティ強化、詳細なエラーハンドリング、管理者への通知機能が含まれています。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-01
Last Modified:  2024-08-02
#>

# モジュールのインポート
$modulesToImport = @(
    "AdminCheck",
    "WslFunctions",
    "BrowserFunctions",
    "IdeFunctions",
    "Logging",
    "GUI",
    "Notification",
    "CommonFunctions",
    "ProcessManagement",
    "Scheduling",
    "SecurityFunctions"
)

foreach ($module in $modulesToImport) {
    $modulePath = "$PSScriptRoot\modules\$module.psm1"
    if (Test-Path $modulePath) {
        Import-Module $modulePath -ErrorAction Stop
    } else {
        throw "必要なモジュール $module が見つかりません。スクリプトを終了します。"
    }
}

function Start-DevEnvRebooter {

# グローバル変数
$global:config = $null

# メイン処理
try {
    # 管理者権限のチェック
    if (-not (Test-AdminPrivileges)) {
        Request-AdminPrivileges
        exit
    }

    # 暗号化された設定ファイルの読み込みと検証
    $configPath = "$PSScriptRoot\config.secure"
    if (Test-Path $configPath) {
        $global:config = Read-SecureConfig -Path $configPath
    } else {
        throw "暗号化された設定ファイルが見つかりません。config.jsonを暗号化してconfig.secureを生成してください。"
    }

    # 設定の検証
    Test-ConfigValidity -Config $global:config

    # 実行中のアプリケーション取得
    $runningApps = Get-RunningApplications

    # 設定との照合
    $appsToRestart = Compare-WithConfig -RunningApps $runningApps -Config $global:config

    # ユーザーによるアプリケーション選択
    $selectedApps = Show-AppSelectionWindow -AppsToRestart $appsToRestart

    if ($null -eq $selectedApps) {
        Write-LogInfo "ユーザーが操作をキャンセルしました。"
        exit 0
    }

    # プログレスウィンドウの表示
    $totalSteps = ($global:config.RESTART_WSL ? 1 : 0) + $selectedApps.Count
    $progressWindow = Show-ProgressWindow -TotalSteps $totalSteps
    $currentStep = 0

    # WSLの再起動（必要な場合）
    if ($global:config.RESTART_WSL) {
        Update-ProgressWindow -ProgressWindow $progressWindow -Step $currentStep -Status "WSLを再起動中..."
        $wslResult = Restart-WSL
        if ($wslResult.Success) {
            Write-LogInfo "WSLの再起動が成功しました。"
        } else {
            Write-LogWarning "WSLの再起動中に問題が発生しました: $($wslResult.Message)"
        }
        $currentStep++
    }

    # 選択されたアプリケーションの再起動
    foreach ($app in $selectedApps) {
        Update-ProgressWindow -ProgressWindow $progressWindow -Step $currentStep -Status "$($app.Type)を再起動中: $($app.Path)"
        
        # 詳細プロセス情報の表示
        $processInfo = Get-DetailedProcessInfo -ProcessName ([System.IO.Path]::GetFileNameWithoutExtension($app.Path))
        if ($processInfo) {
            Show-ProcessDetailsWindow -ProcessInfo $processInfo
        }

        # アプリケーションタイプに応じた再起動処理
        $restartResult = switch ($app.Type) {
            "Browser" { Restart-Browser -Path $app.Path }
            "IDE" { Restart-IDE -Paths @($app.Path) }
            default { 
                Write-LogError "不明なアプリケーションタイプ: $($app.Type)"
                @{ Success = $false; Message = "不明なアプリケーションタイプ" }
            }
        }

        if ($restartResult.Success) {
            Write-LogInfo "$($app.Type) ($($app.Path)) の再起動が成功しました。"
        } else {
            Write-LogError "$($app.Type) ($($app.Path)) の再起動中にエラーが発生しました: $($restartResult.Message)"
            Show-ErrorNotification "アプリケーションの再起動中にエラーが発生しました。詳細はログを確認してください。" "エラー"
        }

        $currentStep++
    }

    # プログレスウィンドウのクローズ
    Close-ProgressWindow -ProgressWindow $progressWindow

    # 完了通知
    Show-Notification "再起動プロセスが完了しました。" "再起動完了"

    # スケジューリング機能（有効な場合）
    if ($global:config.ENABLE_SCHEDULING) {
        $schedulingResult = Register-ScheduledTask -TaskName "DevEnvRebooter" -ScriptPath $PSCommandPath -Trigger $global:config.SCHEDULE_TRIGGER
        if ($schedulingResult.Success) {
            Write-LogInfo "スケジュールタスクが正常に登録されました。"
        } else {
            Write-LogWarning "スケジュールタスクの登録中に問題が発生しました: $($schedulingResult.Message)"
        }
    }
}
catch {
    # エラーハンドリング
    $errorMessage = "再起動プロセス中にエラーが発生しました: $($_.Exception.Message)"
    $errorDetails = "エラーの詳細: $($_.Exception.StackTrace)"
    Write-LogError $errorMessage
    Write-LogError $errorDetails
    Show-ErrorNotification $errorMessage "エラー"
    
    # 重要なエラーの場合、管理者に通知
    if ($_.Exception.GetType().Name -eq "SecurityException" -or $_.Exception.GetType().Name -eq "UnauthorizedAccessException") {
        Send-ErrorNotificationToAdmin -ErrorMessage $errorMessage -ErrorDetails $errorDetails
    }

    exit 1
}
}

# スクリプトが直接実行された場合のみ、Start-DevEnvRebooterを呼び出す
if ($MyInvocation.InvocationName -ne '.') {
    Start-DevEnvRebooter
}