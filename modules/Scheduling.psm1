# Scheduling.psm1

<#
.SYNOPSIS
スケジューリング機能を提供するモジュール

.DESCRIPTION
このモジュールは、タスクスケジューラを使用して
DevEnvRebooterの定期実行をスケジュールする機能を提供します。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

function Register-ScheduledTask {
    <#
    .SYNOPSIS
    DevEnvRebooterのスケジュールタスクを登録します。

    .DESCRIPTION
    このファンクションは、指定されたスケジュールでDevEnvRebooterを実行するタスクを登録します。

    .PARAMETER TaskName
    登録するタスクの名前

    .PARAMETER ScriptPath
    実行するスクリプトのパス

    .PARAMETER Trigger
    タスクの実行トリガー（例: "Daily 09:00"）

    .OUTPUTS
    [PSCustomObject] タスク登録の結果を示すオブジェクト
    #>
    param (
        [string]$TaskName = "DevEnvRebooter",
        [string]$ScriptPath,
        [string]$Trigger
    )

    try {
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
            -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`""

        $triggerParams = @{
            Once = $true
            At = (Get-Date).Date
        }

        switch -Regex ($Trigger) {
            "Daily" { $triggerParams['Daily'] = $true }
            "Weekly" { $triggerParams['Weekly'] = $true }
            "^(\d{1,2}):(\d{2})$" {
                $triggerParams['Daily'] = $true
                $triggerParams['At'] = $Matches[0]
            }
        }

        $taskTrigger = New-ScheduledTaskTrigger @triggerParams

        Register-ScheduledTask -Action $action -Trigger $taskTrigger -TaskName $TaskName -Description "Automatic DevEnvRebooter task"

        return @{
            Success = $true
            Message = "スケジュールタスクが正常に登録されました。"
        }
    }
    catch {
        return @{
            Success = $false
            Message = "スケジュールタスクの登録中にエラーが発生しました: $_"
        }
    }
}

function Remove-ScheduledTask {
    <#
    .SYNOPSIS
    DevEnvRebooterのスケジュールタスクを削除します。

    .DESCRIPTION
    このファンクションは、登録されているDevEnvRebooterのスケジュールタスクを削除します。

    .PARAMETER TaskName
    削除するタスクの名前

    .OUTPUTS
    [PSCustomObject] タスク削除の結果を示すオブジェクト
    #>
    param (
        [string]$TaskName = "DevEnvRebooter"
    )

    try {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        return @{
            Success = $true
            Message = "スケジュールタスクが正常に削除されました。"
        }
    }
    catch {
        return @{
            Success = $false
            Message = "スケジュールタスクの削除中にエラーが発生しました: $_"
        }
    }
}

Export-ModuleMember -Function Register-ScheduledTask, Remove-ScheduledTask