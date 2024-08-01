# GUI.psm1

<#
.SYNOPSIS
GUIコンポーネントを提供するモジュール

.DESCRIPTION
このモジュールは、DevEnvRebooterのグラフィカルユーザーインターフェース要素を提供します。
進行状況ウィンドウ、アプリケーション選択ウィンドウなどが含まれます。

.NOTES
Version:        2.0
Author:         Your Name
Creation Date:  2024-08-02
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-ProgressWindow {
    <#
    .SYNOPSIS
    進行状況を表示するウィンドウを作成します。

    .DESCRIPTION
    このファンクションは、再起動プロセスの進行状況を表示するウィンドウを作成します。

    .PARAMETER TotalSteps
    進行状況バーの総ステップ数

    .OUTPUTS
    [PSCustomObject] 進行状況ウィンドウのコンポーネントを含むオブジェクト
    #>
    param (
        [int]$TotalSteps
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "DevEnvRebooter - 進行状況"
    $form.Size = New-Object System.Drawing.Size(400,150)
    $form.StartPosition = "CenterScreen"

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Size = New-Object System.Drawing.Size(360,20)
    $progressBar.Location = New-Object System.Drawing.Point(10,50)
    $progressBar.Maximum = $TotalSteps
    $form.Controls.Add($progressBar)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(360,20)
    $label.Text = "初期化中..."
    $form.Controls.Add($label)

    $form.Show()

    return @{
        Form = $form
        ProgressBar = $progressBar
        Label = $label
    }
}

function Update-ProgressWindow {
    <#
    .SYNOPSIS
    進行状況ウィンドウを更新します。

    .DESCRIPTION
    このファンクションは、進行状況ウィンドウの状態を更新します。

    .PARAMETER ProgressWindow
    進行状況ウィンドウオブジェクト

    .PARAMETER Step
    現在のステップ

    .PARAMETER Status
    現在の状態メッセージ
    #>
    param (
        [PSCustomObject]$ProgressWindow,
        [int]$Step,
        [string]$Status
    )

    $ProgressWindow.Form.Invoke([Action]{
        $ProgressWindow.ProgressBar.Value = $Step
        $ProgressWindow.Label.Text = $Status
    })
}

function Close-ProgressWindow {
    <#
    .SYNOPSIS
    進行状況ウィンドウを閉じます。

    .DESCRIPTION
    このファンクションは、進行状況ウィンドウを閉じます。

    .PARAMETER ProgressWindow
    進行状況ウィンドウオブジェクト
    #>
    param (
        [PSCustomObject]$ProgressWindow
    )

    $ProgressWindow.Form.Invoke([Action]{
        $ProgressWindow.Form.Close()
    })
}

function Show-AppSelectionWindow {
    <#
    .SYNOPSIS
    再起動するアプリケーションを選択するウィンドウを表示します。

    .DESCRIPTION
    このファンクションは、ユーザーが再起動するアプリケーションを選択するためのウィンドウを表示します。

    .PARAMETER AppsToRestart
    再起動可能なアプリケーションのリスト

    .OUTPUTS
    [array] 選択されたアプリケーションのリスト
    #>
    param (
        [array]$AppsToRestart
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "再起動するアプリケーションを選択"
    $form.Size = New-Object System.Drawing.Size(400,300)
    $form.StartPosition = "CenterScreen"

    $checkedListBox = New-Object System.Windows.Forms.CheckedListBox
    $checkedListBox.Size = New-Object System.Drawing.Size(360,200)
    $checkedListBox.Location = New-Object System.Drawing.Point(10,10)
    
    foreach ($app in $AppsToRestart) {
        $checkedListBox.Items.Add("$($app.Type): $($app.Path)", $true)
    }

    $form.Controls.Add($checkedListBox)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(160,220)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = "OK"
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selectedApps = @()
        for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
            if ($checkedListBox.GetItemChecked($i)) {
                $selectedApps += $AppsToRestart[$i]
            }
        }
        return $selectedApps
    }
    return $null
}

Export-ModuleMember -Function Show-ProgressWindow, Update-ProgressWindow, Close-ProgressWindow, Show-AppSelectionWindow