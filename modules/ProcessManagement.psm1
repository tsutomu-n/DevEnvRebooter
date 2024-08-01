# ProcessManagement.psm1

<#
.SYNOPSIS
プロセス管理機能を提供するモジュール

.DESCRIPTION
このモジュールは、実行中のアプリケーションの検出、設定との照合、
詳細なプロセス情報の取得などの機能を提供します。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

function Get-RunningApplications {
    <#
    .SYNOPSIS
    実行中のアプリケーションの一覧を取得します。

    .DESCRIPTION
    このファンクションは、現在実行中のアプリケーションの一覧を取得します。

    .OUTPUTS
    [array] 実行中のアプリケーションの配列
    #>
    $runningApps = Get-Process | Where-Object { $_.MainWindowTitle -ne "" } | Select-Object ProcessName, Path
    return $runningApps
}

function Compare-WithConfig {
    <#
    .SYNOPSIS
    実行中のアプリケーションと設定を照合します。

    .DESCRIPTION
    このファンクションは、実行中のアプリケーションと設定ファイルの内容を照合し、
    再起動対象のアプリケーションを特定します。

    .PARAMETER RunningApps
    実行中のアプリケーションの配列

    .PARAMETER Config
    設定オブジェクト

    .OUTPUTS
    [array] 再起動対象のアプリケーションの配列
    #>
    param (
        [array]$RunningApps,
        [PSCustomObject]$Config
    )

    $appsToRestart = @()

    foreach ($browser in $Config.BROWSERS) {
        $browserName = [System.IO.Path]::GetFileNameWithoutExtension($browser)
        if ($RunningApps.ProcessName -contains $browserName) {
            $appsToRestart += @{
                Type = "Browser"
                Path = $browser
            }
        }
    }

    foreach ($ide in $Config.IDES) {
        $ideName = [System.IO.Path]::GetFileNameWithoutExtension($ide)
        if ($RunningApps.ProcessName -contains $ideName) {
            $appsToRestart += @{
                Type = "IDE"
                Path = $ide
            }
        }
    }

    return $appsToRestart
}

function Get-DetailedProcessInfo {
    <#
    .SYNOPSIS
    指定されたプロセスの詳細情報を取得します。

    .DESCRIPTION
    このファンクションは、指定されたプロセス名の詳細情報を取得します。

    .PARAMETER ProcessName
    情報を取得するプロセス名

    .OUTPUTS
    [PSCustomObject] プロセスの詳細情報を含むオブジェクト
    #>
    param (
        [string]$ProcessName
    )

    $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    if ($process) {
        return @{
            Name = $process.ProcessName
            ID = $process.Id
            CPU = $process.CPU
            Memory = [math]::Round($process.WorkingSet64 / 1MB, 2)
            StartTime = $process.StartTime
            Path = $process.Path
        }
    }
    return $null
}

Export-ModuleMember -Function Get-RunningApplications, Compare-WithConfig, Get-DetailedProcessInfo