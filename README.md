# EasySSH

EasySSH は、Windows 上で動作する対話式の SSH 接続ツールです。
PowerShell スクリプト 1 本でセットアップから接続、履歴管理、Windows Terminal プロファイル追加まで自動化します。

## 特長

* **対話式メニュー**: 履歴から番号選択、または新規接続
* **履歴管理**: 個別削除・全削除対応
* **多彩なオプション**: ユーザー名、ポート、鍵ファイル、ポートフォワーディング
* **ウィンドウ保持**: SSH 切断後もウィンドウを維持
* **自己展開**: install スクリプトを実行するだけで完了
* **何度でも実行可**: 上書き更新対応

## インストール方法

### A. インストールスクリプトを使用する場合

1. リポジトリをクローンまたは `install_connect_ssh_ver1.0.ps1` をダウンロード
2. PowerShell を**管理者として実行**で起動
3. スクリプト保存フォルダへ移動:

   ```powershell
   cd <スクリプトを保存したフォルダ>
   ```
4. インストールスクリプトを実行:

   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\install_connect_ssh_ver1.0.ps1
   ```
5. 以下が自動で行われます:

   * `C:\terminalSSH\connect_ssh.ps1` の展開と更新
   * `ssh_history.txt` の初回作成
   * Windows Terminal に `EasySSH` プロファイルが追加
   * Windows Terminal の再起動

### B. 手動でセットアップする場合（スクリプトを使わない）

1. リポジトリをクローンまたは必要ファイルをダウンロード:

   * `connect_ssh.ps1`
   * `ssh_history.txt`（空ファイルを用意）
2. `C:\terminalSSH` フォルダを手動で作成し、上記ファイルを配置
3. PowerShell で実行ポリシーを設定（初回のみ）:

   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```
4. Windows Terminal の `settings.json` を開き、`profiles.list` に以下を追加:

   ```json
   {
     "name": "EasySSH",
     "commandline": "powershell.exe -ExecutionPolicy Bypass -File C:\\terminalSSH\\connect_ssh.ps1",
     "hidden": false
   }
   ```
5. Windows Terminal を再起動

## 使い方

1. Windows Terminal を開き、`EasySSH` プロファイルを選択
2. メニューの案内に従い、番号選択 (`0`, `1`, ...) または `n` で新規接続
3. `e` で履歴編集モード:

   * `d`: 指定番号削除
   * `c`: 全削除
   * `q`: 編集終了
4. ユーザー名、ポート番号、鍵ファイル、フォワーディング設定を入力
5. SSH 接続後、`exit` または `Ctrl+D` で切断し、Enter でウィンドウを閉じる

## アンインストール

* `C:\terminalSSH` フォルダを削除
* Windows Terminal の設定から `EasySSH` プロファイルを削除

## 注意事項

* 本ツールの利用は**自己責任**でお願いします。
* インストールスクリプトは予期せぬ不具合が発生する場合があります。
  実行前に必ず内容を確認し、**必要に応じバックアップを取得**してください。

## ライセンス

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
