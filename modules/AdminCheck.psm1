# AdminCheck.psm1
#
# このモジュールは、現在のユーザーが管理者権限を持っているかどうかをチェックします。

function Test-AdminPrivileges {
    <#
    .SYNOPSIS
    現在のユーザーが管理者権限を持っているかどうかをチェックします。

    .DESCRIPTION
    このファンクションは、現在のユーザーが管理者権限を持っているかどうかを確認し、
    結果を返します。管理者権限がない場合は警告メッセージを表示します。

    .OUTPUTS
    [bool] 管理者権限がある場合はTrue、ない場合はFalse
    #>

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Warning "このスクリプトは管理者権限で実行する必要があります。"
        Write-Host "PowerShellを管理者として実行し、スクリプトを再度実行してください。"
    }
    
    return $isAdmin
}

# モジュールの公開ファンクション
Export-ModuleMember -Function Test-AdminPrivileges
