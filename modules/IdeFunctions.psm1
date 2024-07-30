# IdeFunctions.psm1
#
# このモジュールは、IDEの再起動機能を提供します。

# 共通ファンクションのインポート
. "$PSScriptRoot\CommonFunctions.psm1"

function Restart-IDE {
    <#
    .SYNOPSIS
    指定されたIDEを再起動します。

    .DESCRIPTION
    このファンクションは、指定されたパスのIDEを終了し、再起動します。
    WSLベースのIDEの場合、WSLが完全に起動するまで待機します。

    .PARAMETER Paths
    IDEの実行ファイルのパスの配列

    .PARAMETER WslBased
    IDEがWSLベースかどうかを示すスイッチ

    .OUTPUTS
    なし
    #>

    param (
        [string[]]$Paths,
        [switch]$WslBased
    )
    
    Stop-Applications -Paths $Paths -Type "IDE"
    
    if ($WslBased) {
        # WSLベースのIDEの場合、WSLが完全に起動するまで待機
        $wslReady = $false
        $startTime = Get-Date
        while (-not $wslReady) {
            if ((wsl echo "WSL is ready") -eq "WSL is ready") {
                $wslReady = $true
            } elseif (((Get-Date) - $startTime).TotalSeconds -gt 60) {
                Write-Warning "WSLの準備ができていません。IDEの起動をスキップします。"
                return
            }
            Start-Sleep -Seconds 1
        }
    }
    
    Start-Applications -Paths $Paths -Type "IDE"
}

# モジュールの公開ファンクション
Export-ModuleMember -Function Restart-IDE
