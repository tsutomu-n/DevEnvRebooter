# CommonFunctions.psm1
#
# このモジュールは、アプリケーションの停止と起動のための共通機能を提供します。

function Stop-Applications {
    <#
    .SYNOPSIS
    指定されたアプリケーションを停止します。

    .DESCRIPTION
    このファンクションは、指定されたパスのアプリケーションを停止します。
    停止に失敗した場合、指定された回数まで再試行します。

    .PARAMETER Paths
    アプリケーションの実行ファイルのパスの配列

    .PARAMETER Type
    アプリケーションの種類（ログ用）

    .PARAMETER maxRetries
    停止を試行する最大回数

    .PARAMETER retryWaitTime
    再試行間の待機時間（秒）

    .OUTPUTS
    なし
    #>

    param (
        [string[]]$Paths,
        [string]$Type,
        [int]$maxRetries = 3,
        [int]$retryWaitTime = 5
    )
    
    foreach ($path in $Paths) {
        for ($i = 1; $i -le $maxRetries; $i++) {
            try {
                $processName = (Split-Path $path -Leaf) -replace '\.exe$',''
                Stop-Process -Name $processName -Force -ErrorAction Stop
                Write-Host "$Type ($processName) を終了しました。"
                break
            } catch {
                if ($i -eq $maxRetries) {
                    Write-Warning "$Type ($processName) の終了に$maxRetries回失敗しました。"
                } else {
                    Write-Warning "$Type ($processName) の終了に失敗しました。リトライ $i/$maxRetries"
                    Start-Sleep -Seconds $retryWaitTime
                }
            }
        }
    }
}

function Start-Applications {
    <#
    .SYNOPSIS
    指定されたアプリケーションを起動します。

    .DESCRIPTION
    このファンクションは、指定されたパスのアプリケーションを起動します。

    .PARAMETER Paths
    アプリケーションの実行ファイルのパスの配列

    .PARAMETER Type
    アプリケーションの種類（ログ用）

    .OUTPUTS
    なし
    #>

    param (
        [string[]]$Paths,
        [string]$Type
    )
    
    foreach ($path in $Paths) {
        try {
            Start-Process -FilePath $path
            Write-Host "$Type ($(Split-Path $path -Leaf)) を起動しました。"
        } catch {
            Write-Warning "$Type ($(Split-Path $path -Leaf)) の起動に失敗しました。"
        }
    }
}

# モジュールの公開ファンクション
Export-ModuleMember -Function Stop-Applications, Start-Applications
