# WslFunctions.psm1

<#
.SYNOPSIS
WSL (Windows Subsystem for Linux) の再起動機能を提供するモジュール

.DESCRIPTION
このモジュールは、WSLの再起動処理と状態確認機能を提供します。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

function Restart-WSL {
    <#
    .SYNOPSIS
    WSLを再起動します。

    .DESCRIPTION
    このファンクションは、WSLをシャットダウンし、再起動します。
    再起動後、WSLが完全に起動するまで待機します。

    .OUTPUTS
    [PSCustomObject] 再起動の結果を示すオブジェクト
    #>
    try {
        Write-LogInfo "WSLの再起動を開始します。"
        wsl --shutdown
        Start-Sleep -Seconds $global:config.RESTART_WAIT_TIME
        
        $startTime = Get-Date
        $timeout = New-TimeSpan -Minutes 5
        $wslReady = $false

        while (-not $wslReady) {
            if ((Get-Date) - $startTime -gt $timeout) {
                throw "WSLの起動がタイムアウトしました。"
            }
            
            try {
                $output = wsl echo "WSL is ready"
                if ($output -eq "WSL is ready") {
                    $wslReady = $true
                }
            } catch {
                Start-Sleep -Seconds 5
            }
        }

        Write-LogInfo "WSLの再起動が完了しました。"
        return @{
            Success = $true
            Message = "WSLの再起動が成功しました。"
        }
    } catch {
        Write-LogError "WSLの再起動中にエラーが発生しました: $_"
        return @{
            Success = $false
            Message = "WSLの再起動中にエラーが発生しました: $_"
        }
    }
}

Export-ModuleMember -Function Restart-WSL