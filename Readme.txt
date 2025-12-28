■ これは何?
PC の時間を NTP から取得した時間にします


■ 時間調整方法
# SetNtpTime.ps1 を管理権限で実行するか
# PowerShell を管理者権限で開いて、以下をコピペ

$ModuleName = "GetNtpTime"
$GitHubName = "MuraAtVwnet"
$URI = "https://raw.githubusercontent.com/$GitHubName/$ModuleName/refs/heads/main/SetNtpTime.ps1"
$OutFile = "~/SetNtpTime.ps1"
Invoke-WebRequest -Uri $URI -OutFile $OutFile
& $OutFile


■ オプション
-PreferIPv4
    IPv4 を優先する

-Server
    NTP Server を指定する
    省略時は以下 NTP を使用
        ntp.nict.jp
        time.google.com
        pool.ntp.org


■ Windows PowerShell を使っている方へ
Windows PowerShell では、スクリプト実行が禁止になっていて、スクリプトが実行出来ない場合は以下コマンドを PowerShell  のプロンプトにコピペしてください

if((Get-ExecutionPolicy) -ne 'RemoteSigned'){Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force}


■ 動作確認
Windows PowerShell 5.1
PowerShell 7.5.4 (Windows)

Linux/Mac でも動くとは思いますが、動作確認していません


■ GitHub
以下リポジトリで公開しています
https://github.com/MuraAtVwnet/GetNtpTime
git@github.com:MuraAtVwnet/GetNtpTime.git


■ リポジトリ内モジュール説明
SetNtpTime.ps1
	スクリプト本体
Readme.txt
	このファイル

