# IntegrationTests.ps1

<#
.SYNOPSIS
DevEnvRebooterの統合テスト

.DESCRIPTION
このスクリプトは、DevEnvRebooterの全体的な機能と
モジュール間の相互作用をテストします。
Pesterテストフレームワークを使用しています。

.NOTES
Version:        1.0
Author:         Your Name
Creation Date:  2024-08-02
#>

# メインスクリプトとすべてのモジュールをインポート
. "$PSScriptRoot\..\main.ps1"

Describe "DevEnvRebooter Integration Tests" {
    BeforeAll {
        # テスト用の設定ファイルを作成
        $global:config = @{
            RESTART_WAIT_TIME = 1
            LOG_DIR = "TestDrive:\Logs"
            LOG_FILE = "test_log.txt"
            RESTART_WSL = $true
            BROWSERS = @("C:\Program Files\Google\Chrome\Application\chrome.exe")
            IDES = @("C:\Program Files\Microsoft VS Code\Code.exe")
            ENABLE_SCHEDULING = $true
            SCHEDULE_TRIGGER = "Daily 09:00"
            ADMIN_EMAIL = "admin@example.com"
            SMTP_SERVER = "smtp.example.com"
            SMTP_PORT = 587
            SMTP_USERNAME = "test@example.com"
            SMTP_PASSWORD = "TestPassword"
        }

        # モックアプリケーションの作成
        function New-MockApp {
            param (
                [string]$Name,
                [string]$Path
            )
            $mockContent = @"
            param(`$Action)
            if (`$Action -eq 'Start') {
                "Starting $Name" | Out-File -Append "TestDrive:\${Name}_log.txt"
            } elseif (`$Action -eq 'Stop') {
                "Stopping $Name" | Out-File -Append "TestDrive:\${Name}_log.txt"
            }
"@
            Set-Content -Path $Path -Value $mockContent
        }

        New-MockApp -Name "Chrome" -Path "TestDrive:\Chrome.ps1"
        New-MockApp -Name "VSCode" -Path "TestDrive:\VSCode.ps1"

        # 実際の関数をモック関数で置き換え
        Mock Get-RunningApplications {
            @(
                @{ ProcessName = "chrome"; Path = "TestDrive:\Chrome.ps1" },
                @{ ProcessName = "code"; Path = "TestDrive:\VSCode.ps1" }
            )
        }

        Mock Show-AppSelectionWindow {
            @(
                @{ Type = "Browser"; Path = "TestDrive:\Chrome.ps1" },
                @{ Type = "IDE"; Path = "TestDrive:\VSCode.ps1" }
            )
        }

        Mock Show-ProgressWindow { return @{ Form = $null; ProgressBar = $null; Label = $null } }
        Mock Update-ProgressWindow { }
        Mock Close-ProgressWindow { }
        Mock Show-Notification { }
        Mock Show-ErrorNotification { }
        Mock Write-LogInfo { }
        Mock Write-LogError { }
        Mock Write-LogWarning { }
        Mock Restart-WSL { return @{ Success = $true; Message = "WSL restarted successfully." } }
        Mock Register-ScheduledTask { return @{ Success = $true; Message = "Task scheduled successfully." } }
    }

    It "Should run the main process without throwing" {
        { & "$PSScriptRoot\..\main.ps1" } | Should -Not -Throw
    }

    It "Should restart WSL" {
        Assert-MockCalled Restart-WSL -Times 1
    }

    It "Should restart Chrome" {
        $chromeLog = Get-Content "TestDrive:\Chrome_log.txt"
        $chromeLog | Should -Contain "Stopping Chrome"
        $chromeLog | Should -Contain "Starting Chrome"
    }

    It "Should restart VSCode" {
        $vscodeLog = Get-Content "TestDrive:\VSCode_log.txt"
        $vscodeLog | Should -Contain "Stopping VSCode"
        $vscodeLog | Should -Contain "Starting VSCode"
    }

    It "Should create log entries" {
        Assert-MockCalled Write-LogInfo -Times AtLeast 1
    }

    It "Should schedule the task" {
        Assert-MockCalled Register-ScheduledTask -Times 1
    }

    It "Should show notifications" {
        Assert-MockCalled Show-Notification -Times 1
    }
}

Describe "Error Handling Integration Tests" {
    It "Should handle WSL restart failure" {
        Mock Restart-WSL { return @{ Success = $false; Message = "WSL restart failed." } }
        { & "$PSScriptRoot\..\main.ps1" } | Should -Not -Throw
        Assert-MockCalled Write-LogWarning -Times AtLeast 1
    }

    It "Should handle app restart failure" {
        Mock Restart-Browser { return @{ Success = $false; Message = "Browser restart failed." } }
        { & "$PSScriptRoot\..\main.ps1" } | Should -Not -Throw
        Assert-MockCalled Write-LogError -Times AtLeast 1
        Assert-MockCalled Show-ErrorNotification -Times AtLeast 1
    }
}

# GUIのテスト
# 注: GUIのテストは複雑であり、ここでは基本的な機能テストのみを行います
Describe "GUI Integration Tests" {
    It "Should create and update progress window" {
        $progressWindow = Show-ProgressWindow -TotalSteps 5
        $progressWindow | Should -Not -BeNullOrEmpty
        { Update-ProgressWindow -ProgressWindow $progressWindow -Step 1 -Status "Testing" } | Should -Not -Throw
        { Close-ProgressWindow -ProgressWindow $progressWindow } | Should -Not -Throw
    }
}

# 通知機能のテスト
Describe "Notification Integration Tests" {
    It "Should show notifications without throwing" {
        { Show-Notification -Message "Test notification" -Title "Test" } | Should -Not -Throw
        { Show-ErrorNotification -Message "Test error" -Title "Error" } | Should -Not -Throw
    }
}

# スケジューリング機能のテスト
Describe "Scheduling Integration Tests" {
    It "Should register and remove scheduled task" {
        $result = Register-ScheduledTask -TaskName "TestTask" -ScriptPath "TestDrive:\test.ps1" -Trigger "Daily"
        $result.Success | Should -BeTrue
        $removeResult = Remove-ScheduledTask -TaskName "TestTask"
        $removeResult.Success | Should -BeTrue
    }
}