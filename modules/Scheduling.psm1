# Scheduling.psm1

<#
.SYNOPSIS
    スケジューリング機能を提供するモジュール
.DESCRIPTION
    このモジュールは、タスクスケジューラを使用して DevEnvRebooter の定期実行をスケジュールする機能を提供します。
.NOTES
    Version: 2.0
    Author: Your Name
    Creation Date: 2024-08-02
#>

function Register-ScheduledTask {
    <#
    .SYNOPSIS
        DevEnvRebooter のスケジュールタスクを登録します。
    .DESCRIPTION
        このファンクションは、指定されたスケジュールで DevEnvRebooter を実行するタスクを登録します。
    .PARAMETER TaskName
        登録するタスクの名前。デフォルトは "DevEnvRebooter"。
    .PARAMETER ScriptPath
        実行するスクリプトのパス。
    .PARAMETER Trigger
        タスクの実行トリガー（例: "Daily 09:00"）。
    .OUTPUTS
        [PSCustomObject] タスク登録の結果を示すオブジェクト。Success プロパティと Message プロパティを含む。
    #>
    param (
        [string]$TaskName = "DevEnvRebooter",
        [string]$ScriptPath,
        [string]$Trigger
    )
    try {
        # タスクアクションの作成
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
            -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

        # トリガーのパラメータ設定
        $triggerParams = @{ Once = $true; At = (Get-Date).Date }
        switch -Regex ($Trigger) {
            "Daily" { $triggerParams['Daily'] = $true }
            "Weekly" { $triggerParams['Weekly'] = $true }
            "^(\d{1,2}):(\d{2})$" {
                $triggerParams['Daily'] = $true
                $triggerParams['At'] = [datetime]::ParseExact($Trigger, "HH:mm", $null)
            }
            default { throw "無効なトリガー形式: $Trigger" }
        }

        # タスクトリガーの作成
        $taskTrigger = New-ScheduledTaskTrigger @triggerParams

        # タスクの登録
        Register-ScheduledTask -Action $action -Trigger $taskTrigger -TaskName $TaskName -Description "Automatic DevEnvRebooter task"

        return [PSCustomObject]@{
            Success = $true
            Message = "スケジュールタスクが正常に登録されました。"
        }
    } catch {
        return [PSCustomObject]@{
            Success = $false
            Message = "スケジュールタスクの登録中にエラーが発生しました: $_"
        }
    }
}

function Remove-ScheduledTask {
    <#
    .SYNOPSIS
        DevEnvRebooter のスケジュールタスクを削除します。
    .DESCRIPTION
        このファンクションは、登録されている DevEnvRebooter のスケジュールタスクを削除します。
    .PARAMETER TaskName
        削除するタスクの名前。デフォルトは "DevEnvRebooter"。
    .OUTPUTS
        [PSCustomObject] タスク削除の結果を示すオブジェクト。Success プロパティと Message プロパティを含む。
    #>
    param (
        [string]$TaskName = "DevEnvRebooter"
    )
    try {
        # タスクの削除
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

        return [PSCustomObject]@{
            Success = $true
            Message = "スケジュールタスクが正常に削除されました。"
        }
    } catch {
        return [PSCustomObject]@{
            Success = $false
            Message = "スケジュールタスクの削除中にエラーが発生しました: $_"
        }
    }
}

# モジュールのエクスポート
Export-ModuleMember -Function Register-ScheduledTask, Remove-ScheduledTask
