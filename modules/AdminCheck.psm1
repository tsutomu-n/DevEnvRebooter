# AdminCheck.psm1

<#
.SYNOPSIS
管理者権限のチェックと要求を行うモジュール

.DESCRIPTION
このモジュールは、現在のユーザーが管理者権限を持っているかをチェックし、
必要に応じて管理者権限でスクリプトを再実行する機能を提供します。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

function Test-AdminPrivileges {
    <#
    .SYNOPSIS
    現在のユーザーが管理者権限を持っているかチェックします。

    .DESCRIPTION
    このファンクションは、現在のユーザーが管理者権限を持っているかどうかを確認します。

    .OUTPUTS
    [bool] 管理者権限がある場合はTrue、ない場合はFalse
    #>
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Request-AdminPrivileges {
    <#
    .SYNOPSIS
    管理者権限でスクリプトを再実行します。

    .DESCRIPTION
    このファンクションは、現在のスクリプトを管理者権限で再実行します。
    #>
    if (-not ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-LogWarning "管理者権限が必要です。スクリプトを管理者として再実行します。"
        $newProcess = New-Object System.Diagnostics.ProcessStartInfo "powershell"
        $newProcess.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
        $newProcess.Verb = "runas"
        [System.Diagnostics.Process]::Start($newProcess) | Out-Null
        exit
    }
}

Export-ModuleMember -Function Test-AdminPrivileges, Request-AdminPrivileges