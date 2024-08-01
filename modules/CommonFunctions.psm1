# CommonFunctions.psm1

<#
.SYNOPSIS
共通のユーティリティ関数を提供するモジュール

.DESCRIPTION
このモジュールは、他のモジュールで使用される共通のユーティリティ関数を提供します。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

function Get-SafeFilename {
    <#
    .SYNOPSIS
    安全なファイル名を生成します。

    .DESCRIPTION
    このファンクションは、指定された文字列から安全なファイル名を生成します。
    無効な文字を削除または置換します。

    .PARAMETER Name
    元の文字列

    .OUTPUTS
    [string] 安全なファイル名
    #>
    param (
        [string]$Name
    )

    $invalidChars = [IO.Path]::GetInvalidFileNameChars()
    $safeName = $Name -replace "[$invalidChars]", "_"
    return $safeName
}

function Convert-SizeToReadableFormat {
    <#
    .SYNOPSIS
    バイト数を人間が読みやすい形式に変換します。

    .DESCRIPTION
    このファンクションは、バイト数を KB, MB, GB などの単位に変換します。

    .PARAMETER Bytes
    変換するバイト数

    .OUTPUTS
    [string] 人間が読みやすい形式のサイズ
    #>
    param (
        [long]$Bytes
    )

    $sizes = "Bytes,KB,MB,GB,TB,PB,EB,ZB,YB".Split(',')
    $order = 0
    while ($Bytes -ge 1024 -and $order -lt $sizes.Count - 1) {
        $order++
        $Bytes /= 1024
    }
    "{0:N2} {1}" -f $Bytes, $sizes[$order]
}

Export-ModuleMember -Function Get-SafeFilename, Convert-SizeToReadableFormat