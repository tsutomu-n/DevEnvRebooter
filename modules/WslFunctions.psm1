# WslFunctions.psm1
#
# このモジュールは、WSL (Windows Subsystem for Linux) の再起動機能を提供します。

function Restart-WSL {
    <#
    .SYNOPSIS
    WSLを再起動します。

    .DESCRIPTION
    このファンクションは、WSLをシャットダウンし、再起動します。
    再起動後、WSLが完全に起動するまで待機します。

    .PARAMETER maxRetries
    再起動を試行する最大回数

    .PARAMETER retryWaitTime
    再試行間の待機時間（秒）

    .PARAMETER wslStartupWaitTime
    WSL起動の最大待機時間（秒）

    .OUTPUTS
    なし
    #>

    param (
        [int]$maxRetries = 3,
        [int]$retryWaitTime = 5,
        [int]$wslStartupWaitTime = 30
    )

    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            Write-Host "WSLを再起動しています..."
            wsl --shutdown
            Start-Sleep -Seconds $global:config.RESTART_WAIT_TIME
            wsl echo "WSL is starting..."
            
            # WSLが完全に起動するまで待機
            $startTime = Get-Date
            while ($true) {
                if ((wsl echo "WSL is ready") -eq "WSL is ready") {
                    break
                }
                if (((Get-Date) - $startTime).TotalSeconds -gt $wslStartupWaitTime) {
                    throw "WSLの起動がタイムアウトしました。"
                }
                Start-Sleep -Seconds 1
            }
            
            Write-Host "WSLを再起動しました。"
            return
        } catch {
            if ($i -eq $maxRetries) {
                throw "WSLの再起動に$maxRetries回失敗しました。"
            } else {
                Write-Warning "WSLの再起動に失敗しました。リトライ $i/$maxRetries"
                Start-Sleep -Seconds $retryWaitTime
            }
        }
    }
}

# モジュールの公開ファンクション
Export-ModuleMember -Function Restart-WSL
