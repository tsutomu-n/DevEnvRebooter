# UnitTests.ps1

<#
.SYNOPSIS
DevEnvRebooterの単体テスト

.DESCRIPTION
このスクリプトは、DevEnvRebooterの各モジュールの機能を個別にテストします。
Pesterテストフレームワークを使用しています。

.NOTES
Version:        1.0
Author:         Your Name
Creation Date:  2024-08-02
#>

# モジュールのインポート
$modulesToTest = @(
    "AdminCheck",
    "WslFunctions",
    "BrowserFunctions",
    "IdeFunctions",
    "Logging",
    "GUI",
    "Notification",
    "CommonFunctions",
    "ProcessManagement",
    "Scheduling",
    "SecurityFunctions"
)

foreach ($module in $modulesToTest) {
    Import-Module "$PSScriptRoot\..\modules\$module.psm1" -Force
}

Describe "AdminCheck Module Tests" {
    It "Test-AdminPrivileges should return a boolean" {
        $result = Test-AdminPrivileges
        $result | Should -BeOfType [bool]
    }
}

Describe "WslFunctions Module Tests" {
    Mock Write-LogInfo { }
    Mock wsl { "WSL is ready" }

    It "Restart-WSL should return a success result" {
        $result = Restart-WSL
        $result.Success | Should -BeTrue
        $result.Message | Should -Be "WSLの再起動が成功しました。"
    }
}

Describe "BrowserFunctions Module Tests" {
    Mock Stop-Process { }
    Mock Start-Process { }
    Mock Write-LogInfo { }

    It "Restart-Browser should return a success result" {
        $result = Restart-Browser -Path "C:\fakepath\chrome.exe"
        $result.Success | Should -BeTrue
        $result.Message | Should -Match "ブラウザ \(chrome\) の再起動が成功しました。"
    }
}

Describe "IdeFunctions Module Tests" {
    Mock Stop-Process { }
    Mock Start-Process { }
    Mock Write-LogInfo { }

    It "Restart-IDE should return a success result" {
        $result = Restart-IDE -Paths @("C:\fakepath\vscode.exe")
        $result.Success | Should -BeTrue
        $result.Message | Should -Be "すべてのIDEの再起動が成功しました。"
    }
}

Describe "Logging Module Tests" {
    Mock Add-Content { }

    It "Write-LogInfo should not throw" {
        { Write-LogInfo "Test message" } | Should -Not -Throw
    }

    It "Write-LogError should not throw" {
        { Write-LogError "Test error" } | Should -Not -Throw
    }
}

Describe "CommonFunctions Module Tests" {
    It "Get-SafeFilename should remove invalid characters" {
        $result = Get-SafeFilename "File:Name?.txt"
        $result | Should -Be "File_Name_.txt"
    }

    It "Convert-SizeToReadableFormat should format bytes correctly" {
        $result = Convert-SizeToReadableFormat 1048576
        $result | Should -Be "1.00 MB"
    }
}

Describe "ProcessManagement Module Tests" {
    Mock Get-Process {
        @(
            @{ ProcessName = "chrome"; Path = "C:\Program Files\Google\Chrome\Application\chrome.exe" },
            @{ ProcessName = "code"; Path = "C:\Program Files\Microsoft VS Code\Code.exe" }
        )
    }

    It "Get-RunningApplications should return an array" {
        $result = Get-RunningApplications
        $result | Should -BeOfType [array]
        $result.Count | Should -BeGreaterThan 0
    }

    It "Compare-WithConfig should return matching apps" {
        $config = @{
            BROWSERS = @("C:\Program Files\Google\Chrome\Application\chrome.exe")
            IDES = @("C:\Program Files\Microsoft VS Code\Code.exe")
        }
        $runningApps = Get-RunningApplications
        $result = Compare-WithConfig -RunningApps $runningApps -Config $config
        $result.Count | Should -Be 2
    }
}

Describe "SecurityFunctions Module Tests" {
    It "Protect-ConfigFile should create an encrypted file" {
        $testConfig = '{"TestKey": "TestValue"}'
        $inputFile = "TestDrive:\test_config.json"
        $outputFile = "TestDrive:\test_config.secure"
        Set-Content -Path $inputFile -Value $testConfig
        Protect-ConfigFile -InputFile $inputFile -OutputFile $outputFile
        Test-Path $outputFile | Should -BeTrue
    }

    It "Read-SecureConfig should decrypt the config file" {
        $testConfig = '{"TestKey": "TestValue"}'
        $inputFile = "TestDrive:\test_config.json"
        $outputFile = "TestDrive:\test_config.secure"
        Set-Content -Path $inputFile -Value $testConfig
        Protect-ConfigFile -InputFile $inputFile -OutputFile $outputFile
        $decrypted = Read-SecureConfig -Path $outputFile
        $decrypted.TestKey | Should -Be "TestValue"
    }
}

# GUI、Notification、Schedulingモジュールのテストは、
# これらがシステムの状態に依存するため、統合テストで行います。