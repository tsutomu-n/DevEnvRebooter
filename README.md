# DevEnvRebooter

![DevEnvRebooter Logo](images/logo.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/DevEnvRebooter)](https://www.powershellgallery.com/packages/DevEnvRebooter)
[![GitHub issues](https://img.shields.io/github/issues/yourusername/DevEnvRebooter)](https://github.com/yourusername/DevEnvRebooter/issues)

DevEnvRebooterは、開発環境（WSL、IDE、ブラウザ）を効率的に再起動するためのPowerShellベースのツールです。並列処理、GUIによる進行状況表示、エラーハンドリング、ログ記録機能を備えています。

## 特徴

- WSL、ブラウザ、IDEの並列再起動
- 直感的なGUIによる進行状況表示
- 詳細なログ記録とログローテーション
- カスタマイズ可能な設定
- スケジューリング機能による自動実行
- セキュアな設定ファイル管理

## システム要件

- Windows 10以降
- PowerShell 5.1以降
- .NET Framework 4.7.2以降

## インストール

PowerShellギャラリーからインストール（推奨）:

```powershell
Install-Module -Name DevEnvRebooter -Scope CurrentUser
```

または、このリポジトリをクローンして手動でインストール:

```powershell
git clone https://github.com/yourusername/DevEnvRebooter.git
cd DevEnvRebooter
# 必要に応じて、モジュールを手動でインポート
```

## 使用方法

1. PowerShellを管理者として実行します。
2. 以下のコマンドを実行します:

```powershell
Start-DevEnvRebooter
```

3. 画面の指示に従って、再起動するアプリケーションを選択します。

詳細な使用方法については、[ユーザーガイド](docs/UserGuide.md)を参照してください。

## 設定

`config.json`ファイルを編集して、DevEnvRebooterの動作をカスタマイズできます。設定オプションの詳細については、[設定ガイド](docs/ConfigurationGuide.md)を参照してください。

## 開発

DevEnvRebooterの開発に貢献したい方は、[開発者ガイド](docs/DeveloperGuide.md)を参照してください。

## テスト

テストを実行するには、以下のコマンドを使用します:

```powershell
Invoke-Pester .\Tests
```

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細については、[LICENSE](LICENSE)ファイルを参照してください。

## 貢献

バグ報告、機能リクエスト、プルリクエストを歓迎します。貢献する前に、[貢献ガイドライン](CONTRIBUTING.md)をお読みください。

## サポート

問題が発生した場合や質問がある場合は、[Issueページ](https://github.com/yourusername/DevEnvRebooter/issues)にてお問い合わせください。

## 謝辞

このプロジェクトは、以下のオープンソースプロジェクトを使用しています:

- [Pester](https://github.com/pester/Pester) - PowerShellテストフレームワーク

## 変更履歴

プロジェクトの変更履歴については、[CHANGELOG.md](CHANGELOG.md)を参照してください。