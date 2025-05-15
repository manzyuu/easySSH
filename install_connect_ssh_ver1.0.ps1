# install_connect_ssh.ps1
# → 1ファイル自己展開版 EasySSH インストーラ
#    （ポート表示付き番号選択＋対話式履歴編集版・Quitバグ修正版）

$installPath = "C:\terminalSSH"
$scriptPath  = "$installPath\connect_ssh.ps1"
$historyFile = "$installPath\ssh_history.txt"

Write-Host "== EasySSH インストーラ ==" -ForegroundColor Cyan

# 1) ディレクトリ作成
if (-not (Test-Path $installPath)) {
    New-Item -ItemType Directory -Path $installPath | Out-Null
    Write-Host "フォルダ作成: $installPath" -ForegroundColor Green
}

# 2) connect_ssh.ps1 を自己展開・上書き
$body = @'
# C:\terminalSSH\connect_ssh.ps1
# EasySSH 本体スクリプト（番号選択＋対話式履歴編集・鍵/ポート/フォワーディング対応・exit後も維持）

$historyFile = "C:\terminalSSH\ssh_history.txt"

# 履歴読み込み（常に配列化）
$history = @()
if (Test-Path $historyFile) {
    $history = @(Get-Content $historyFile)
}

Write-Host "== EasySSH ==" -ForegroundColor Cyan

# メイン選択ループ
do {
    Write-Host "`n履歴から接続 (番号選択) / 新規接続 (n) / 履歴編集 (e) を選んでください："
    for ($i = 0; $i -lt $history.Count; $i++) {
        $f = $history[$i] -split '\|'
        Write-Host "[$i] $($f[1])@$($f[0]):$($f[2])"
    }
    Write-Host "[n] 新しい接続先"
    Write-Host "[e] 履歴編集"

    $choice = Read-Host "選択"

    if ($choice -eq 'e') {
        # 対話式履歴編集
        $flag=0
        do {
            Write-Host "`n-- 履歴編集モード --"
            Write-Host "[d] 指定削除  [c] 全削除  [q] 編集終了"
            $edit = Read-Host "操作"
            switch ($edit) {
                'd' {
                    for ($j = 0; $j -lt $history.Count; $j++) {
                        $fj = $history[$j] -split '\|'
                        Write-Host "[$j] $($fj[0]):$($fj[2])"
                    }
                    $idx = Read-Host "削除する番号"
                    if ($idx -match '^\d+$' -and $idx -lt $history.Count) {
                        $history = $history | Where-Object { $_ -ne $history[$idx] }
                        $history | Set-Content $historyFile
                        Write-Host "項目[$idx]を削除しました。" -ForegroundColor Green
                    } else {
                        Write-Host "無効な番号です。" -ForegroundColor Red
                    }
                }
                'c' {
                    Clear-Content $historyFile
                    $history = @()
                    Write-Host "履歴を全削除しました。" -ForegroundColor Green
                }
                'q' {
                    $flag=1    # **内側の編集ループのみを抜ける**
                }
                default {
                    Write-Host "無効な操作です。" -ForegroundColor Red
                }
            }
        } while ($flag -ne 1)
        continue    # **メインループに戻る**
    }
    elseif ($choice -match '^\d+$' -and $choice -lt $history.Count) {
        # 登録済み履歴から選択
        $f          = $history[$choice] -split '\|'
        $hostInput  = $f[0]
        $user       = $f[1]
        $port       = $f[2]
        $keyPath    = $f[3]
        $forwarding = $f[4]
        break
    }
    elseif ($choice -eq 'n') {
        # 新規入力
        do{
            $hostInput = Read-Host "接続先ホスト名またはIPを入力"
            if ($hostInput -match '^[a-zA-Z0-9.-]+$') { break } else { Write-Host "無効なホスト名です。" -ForegroundColor Red }   
        }while (-not $hostInput) 
        $user       = Read-Host "ユーザー名を入力してください（デフォルト: ubuntu）";  if (-not $user) { $user = "ubuntu" }
        $port       = Read-Host "ポート番号を入力してください（デフォルト: 22）";   if (-not $port) { $port = "22" }
        $keyPath    = Read-Host "秘密鍵ファイルのパスを入力（空白ならパスワード認証）"
        $forwarding = Read-Host "ポートフォワーディング設定 (例: 8080:localhost:80)（空白可）"
        break
    }
    else {
        Write-Host "無効な選択です。" -ForegroundColor Red
    }
} while ($true)

# SSHコマンド組み立て
$args = @()
if ($keyPath)    { $args += "-i `"$keyPath`"" }
$args += "-p $port"
$args += "$user@$hostInput"
if ($forwarding) { $args += "-L $forwarding" }

$command = "ssh " + ($args -join " ")
Write-Host "`n→ 実行: $command" -ForegroundColor Green

# 履歴保存（host|user|port|key|forwarding 形式、重複登録なし）
$entryLine = "$hostInput|$user|$port|$keyPath|$forwarding"
if (-not $history -contains $entryLine) {
    Add-Content $historyFile $entryLine
}

# SSH実行、切断後も維持
& ssh @args
Write-Host "`nSSH接続が終了しました。Enterキーを押すとウィンドウを閉じます。" -ForegroundColor Cyan
Read-Host
'@

# ファイル書き出し
Set-Content -Path $scriptPath -Value $body -Force
Write-Host "connect_ssh.ps1 展開／上書き完了！" -ForegroundColor Green

# 3) 履歴ファイル作成（初回のみ）
if (-not (Test-Path $historyFile)) {
    New-Item -ItemType File -Path $historyFile | Out-Null
    Write-Host "ssh_history.txt 作成完了！" -ForegroundColor Green
}

# 4) 実行ポリシー設定
$policy = Get-ExecutionPolicy -Scope CurrentUser
if ($policy -notin @("RemoteSigned","Bypass")) {
    Write-Host "実行ポリシーを RemoteSigned に変更します。" -ForegroundColor Yellow
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
}

# 5) Windows Terminal プロファイル追加
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (-not (Test-Path $settingsPath)) {
    Write-Host "settings.json が見つかりません。手動で追加してください。" -ForegroundColor Red
    exit
}
Copy-Item $settingsPath "$settingsPath.bak" -Force
$json = Get-Content $settingsPath | ConvertFrom-Json
if (-not ($json.profiles.list | Where-Object Name -EQ "EasySSH")) {
    $json.profiles.list += @{
        name        = "EasySSH"
        commandline = "powershell.exe -ExecutionPolicy Bypass -File C:\\terminalSSH\\connect_ssh.ps1"
        hidden      = $false
    }
    $json | ConvertTo-Json -Depth 5 | Set-Content $settingsPath -Force
    Write-Host "EasySSH プロファイルを追加しました。" -ForegroundColor Green
} else {
    Write-Host "EasySSH プロファイルは既に存在します。" -ForegroundColor Yellow
}

# 6) Windows Terminal 再起動
Get-Process WindowsTerminal -ErrorAction SilentlyContinue | Stop-Process
Start-Sleep -Milliseconds 500
Start-Process wt.exe

Write-Host "`n✅ インストール／アップデート完了！Windows Terminal を再起動しました。" -ForegroundColor Cyan
