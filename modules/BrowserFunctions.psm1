# BrowserFunctions.psm1
#
# このモジュールは、ブラウザの再起動機能を提供します。

# 共通ファンクションのインポート
. "$PSScriptRoot\CommonFunctions.psm1"

function Restart-Browser {
    <#
    .SYNOPSIS
    指定されたブラウザを再起動します。

    .DESCRIPTION
    このファンクションは、指定されたパスのブラウザを終了し、再起動します。

    .PARAMETER Path
    ブラウザの実行ファイルのパス

    .OUTPUTS
    なし
    #>

    param ([string]$Path)
    
    Stop-Applications -Paths @($Path) -Type "ブラウザ"
    Start-Applications -Paths @($Path) -Type "ブラウザ"
}

# モジュールの公開ファンクション
Export-ModuleMember -Function Restart-Browser
