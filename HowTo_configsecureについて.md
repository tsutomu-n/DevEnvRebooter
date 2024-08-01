# config.secure

config.secureは暗号化されたファイルなので、直接の内容は表示できません。代わりに、元のJSONファイル（config.json）の内容と、それを暗号化する手順を示します。

まず、config.jsonの内容：

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
    "SCHEDULE_TRIGGER": "Daily 09:00",
    "ADMIN_EMAIL": "admin@example.com",
    "SMTP_SERVER": "smtp.example.com",
    "SMTP_PORT": 587,
    "SMTP_USERNAME": "notifications@example.com",
    "SMTP_PASSWORD": "YourEncryptedPasswordHere"
}
```

config.jsonを暗号化してconfig.secureを生成する手順：

1. PowerShellを管理者権限で開きます。
2. DevEnvRebooterのディレクトリに移動します。
3. 以下のコマンドを実行します：

```powershell
Import-Module .\modules\SecurityFunctions.psm1
Protect-ConfigFile -InputFile "config.json" -OutputFile "config.secure"
```

これにより、config.jsonの内容が暗号化され、config.secureファイルが生成されます。生成後は、元のconfig.jsonファイルを安全に削除してください。

この方法により、設定ファイルの内容が保護され、セキュリティが向上します。main.ps1スクリプトは、この暗号化されたconfig.secureファイルを読み込み、実行時に復号化して使用します。
</answer>