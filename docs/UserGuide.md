# DevEnvRebooter ユーザーガイド

## 目次
- [DevEnvRebooter ユーザーガイド](#devenvrebooter-ユーザーガイド)
  - [目次](#目次)
  - [はじめに](#はじめに)
  - [システム要件](#システム要件)
  - [インストール手順](#インストール手順)
  - [基本的な使用方法](#基本的な使用方法)
  - [設定のカスタマイズ](#設定のカスタマイズ)
  - [高度な機能](#高度な機能)
    - [スケジューリング](#スケジューリング)
    - [ログ分析](#ログ分析)
  - [トラブルシューティング](#トラブルシューティング)
  - [よくある質問（FAQ）](#よくある質問faq)
  - [サポートとフィードバック](#サポートとフィードバック)

## はじめに

DevEnvRebooterへようこそ！このツールは、開発環境（WSL、IDE、ブラウザ）を効率的に再起動するためのPowerShellベースのアプリケーションです。本ガイドでは、インストールから高度な使用方法まで、段階的に説明します。

## システム要件

- Windows 10以降
- PowerShell 5.1以降
- 管理者権限
- .NET Framework 4.7.2以降

## インストール手順

1. [GitHub リポジトリ](https://github.com/yourusername/DevEnvRebooter)からプロジェクトをダウンロードまたはクローンします。
2. PowerShellを管理者として実行し、以下のコマンドで必要なモジュールをインストールします：

   ```powershell
   Install-Module -Name Pester -Scope CurrentUser -Force
   ```

3. `config.json`ファイルを編集して、環境に合わせてカスタマイズします。（詳細は[設定のカスタマイズ](#設定のカスタマイズ)セクションを参照）

## 基本的な使用方法

1. PowerShellを管理者として実行します。
2. DevEnvRebooterのディレクトリに移動します：
   ```powershell
   cd path\to\DevEnvRebooter
   ```
3. スクリプトを実行します：
   ```powershell
   .\main.ps1
   ```
4. 画面の指示に従って、再起動するアプリケーションを選択します。
5. 進行状況ウィンドウで再起動プロセスを監視します。

## 設定のカスタマイズ

`config.json`ファイルを編集して、DevEnvRebooterの動作をカスタマイズできます：

- `RESTART_WAIT_TIME`: アプリケーション再起動間の待機時間（秒）
- `LOG_DIR`: ログファイルの保存ディレクトリ
- `LOG_FILE`: ログファイルの名前
- `RESTART_WSL`: WSLを再起動するかどうか（true/false）
- `BROWSERS`: 再起動対象のブラウザリスト
- `IDES`: 再起動対象のIDEリスト
- `ENABLE_SCHEDULING`: スケジューリング機能の有効化（true/false）
- `SCHEDULE_TRIGGER`: スケジュールの設定（例: "Daily 09:00"）

設定例：
```json
{
    "RESTART_WAIT_TIME": 2,
    "LOG_DIR": "C:\\Logs\\DevEnvRebooter",
    "LOG_FILE": "restart_log.txt",
    "RESTART_WSL": true,
    "BROWSERS": [
        "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
        "C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe"
    ],
    "IDES": [
        "C:\\Users\\Username\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe"
    ],
    "ENABLE_SCHEDULING": true,
    "SCHEDULE_TRIGGER": "Daily 09:00"
}
```

## 高度な機能

### スケジューリング
毎日特定の時間にDevEnvRebooterを自動実行するよう設定できます：

1. `config.json`で`ENABLE_SCHEDULING`を`true`に設定します。
2. `SCHEDULE_TRIGGER`に希望の実行時間を設定します。（例: "Daily 09:00"）

### ログ分析
`logs/restart_log.txt`ファイルで、詳細な動作ログを確認できます。エラーや警告を含む重要な情報が記録されています。

## トラブルシューティング

1. **エラー: 管理者権限が必要です**
   - PowerShellを右クリックし、「管理者として実行」を選択してください。

2. **エラー: 設定ファイルが無効です**
   - `config.json`ファイルの形式や内容を確認してください。JSONの構文が正しいことを確認します。

3. **特定のアプリケーションが再起動されない**
   - `config.json`のパスが正しいか確認してください。
   - アプリケーションが実行中であることを確認してください。

4. **WSLの再起動に失敗する**
   - WSLが正しくインストールされていることを確認してください。
   - `wsl --shutdown`コマンドを手動で実行してみてください。

## よくある質問（FAQ）

Q: DevEnvRebooterは複数のWSLディストリビューションを再起動できますか？
A: 現在のバージョンでは、すべてのWSLインスタンスを再起動します。特定のディストリビューションの再起動はサポートしていません。

Q: カスタムアプリケーションを再起動リストに追加できますか？
A: はい、`config.json`の`BROWSERS`または`IDES`リストに実行ファイルのパスを追加してください。

Q: ログファイルはどのくらいの期間保存されますか？
A: デフォルトでは最新の5つのログファイルが保持されます。この設定は`Logging.psm1`モジュールで変更できます。

## サポートとフィードバック

問題が解決しない場合や機能リクエストがある場合は、[GitHubのIssueページ](https://github.com/yourusername/DevEnvRebooter/issues)にてご連絡ください。

皆様のフィードバックは、DevEnvRebooterの改善に不可欠です。ご協力ありがとうございます！