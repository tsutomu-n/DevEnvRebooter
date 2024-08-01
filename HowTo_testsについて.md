# Tests
テストファイルは、DevEnvRebooterの各モジュールと全体的な機能をテストします。単体テストは個々の関数をテストし、統合テストはモジュール間の相互作用と全体的なワークフローをテストします。

テストを実行する際は、以下のコマンドを使用します：

```powershell
Invoke-Pester .\Tests\UnitTests.ps1
Invoke-Pester .\Tests\IntegrationTests.ps1
```

これらのテストは、アプリケーションの信頼性を確保し、将来の変更による予期せぬ問題を早期に発見するのに役立ちます。また、新機能の追加や既存機能の修正を行う際には、適切なテストケースを追加することをお勧めします。


# 実行時の出力例
はい、テストを実行した際の出力内容をシミュレートしてお示しします。Pesterフレームワークの出力を再現します。

まず、UnitTests.ps1の実行結果：

```plaintext
Describing AdminCheck Module Tests
 [+] Test-AdminPrivileges should return a boolean 62ms

Describing WslFunctions Module Tests
 [+] Restart-WSL should return a success result 114ms

Describing BrowserFunctions Module Tests
 [+] Restart-Browser should return a success result 84ms

Describing IdeFunctions Module Tests
 [+] Restart-IDE should return a success result 77ms

Describing Logging Module Tests
 [+] Write-LogInfo should not throw 23ms
 [+] Write-LogError should not throw 16ms

Describing CommonFunctions Module Tests
 [+] Get-SafeFilename should remove invalid characters 31ms
 [+] Convert-SizeToReadableFormat should format bytes correctly 19ms

Describing ProcessManagement Module Tests
 [+] Get-RunningApplications should return an array 42ms
 [+] Compare-WithConfig should return matching apps 56ms

Describing SecurityFunctions Module Tests
 [+] Protect-ConfigFile should create an encrypted file 128ms
 [+] Read-SecureConfig should decrypt the config file 103ms

Tests Passed: 12
Tests Failed: 0
Tests Skipped: 0

```

次に、IntegrationTests.ps1の実行結果：

```plaintext
Describing DevEnvRebooter Integration Tests
 [+] Should run the main process without throwing 1.23s
 [+] Should restart WSL 76ms
 [+] Should restart Chrome 134ms
 [+] Should restart VSCode 129ms
 [+] Should create log entries 45ms
 [+] Should schedule the task 67ms
 [+] Should show notifications 38ms

Describing Error Handling Integration Tests
 [+] Should handle WSL restart failure 876ms
 [+] Should handle app restart failure 912ms

Describing GUI Integration Tests
 [+] Should create and update progress window 234ms

Describing Notification Integration Tests
 [+] Should show notifications without throwing 156ms

Describing Scheduling Integration Tests
 [+] Should register and remove scheduled task 543ms

Tests Passed: 12
Tests Failed: 0
Tests Skipped: 0

```

これらの出力は、すべてのテストが成功した理想的なシナリオを示しています。実際のテスト実行時には、環境やコードの状態によって結果が異なる可能性があります。

テストが失敗した場合、出力は以下のようになります：

```plaintext
Describing ProcessManagement Module Tests
 [-] Compare-WithConfig should return matching apps 78ms
   Expected: 2
   But was:  1
   at $result.Count | Should -Be 2, C:\DevEnvRebooter\Tests\UnitTests.ps1:94
   at <ScriptBlock>, C:\DevEnvRebooter\Tests\UnitTests.ps1:94

Tests Passed: 11
Tests Failed: 1
Tests Skipped: 0

```

この例では、`Compare-WithConfig`関数のテストが失敗し、期待された結果と実際の結果の差異が表示されています。

これらの出力を分析することで、テストの成功・失敗を確認し、問題がある場合はその原因を特定することができます。テスト駆動開発（TDD）のアプローチを採用する場合、これらのテスト結果を基にコードを改善していくことができます。