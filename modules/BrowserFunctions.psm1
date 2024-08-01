# BrowserFunctions.psm1

<#
.SYNOPSIS
ブラウザの再起動機能を提供するモジュール

.DESCRIPTION
このモジュールは、指定されたブラウザの再起動処理を提供します。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

function Restart-Browser {
    <#
    .SYNOPSIS
    指定されたブラウザを再起動します。

    .DESCRIPTION
    このファンクションは、指定されたパスのブラウザプロセスを停止し、再起動します。

    .PARAMETER Path
    再起動するブラウザの実行ファイルパス

    .OUTPUTS
    [PSCustomObject] 再起動の結果を示すオブジェクト
    #>
    param (
        [string]$Path
    )

    try {
        $browserName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
        Write-LogInfo "ブラウザ ($browserName) の再起動を開始します。"

        # ブラウザプロセスの停止
        Stop-Process -Name $browserName -Force -ErrorAction Stop
        Start-Sleep -Seconds $global:config.RESTART_WAIT_TIME

        # ブラウザの再起動
        Start-Process -FilePath $Path

        Write-LogInfo "ブラウザ ($browserName) の再起動が完了しました。"
        return @{
            Success = $true
            Message = "ブラウザ ($browserName) の再起動が成功しました。"
        }
    } catch {
        Write-LogError "ブラウザ ($browserName) の再起動中にエラーが発生しました: $_"
        return @{
            Success = $false
            Message = "ブラウザ ($browserName) の再起動中にエラーが発生しました: $_"
        }
    }
}

Export-ModuleMember -Function Restart-Browser