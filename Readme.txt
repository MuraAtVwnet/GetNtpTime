■ これは何?
PC の時間を NTP から取得した時間にします


■ 時間調整方法
# PowerShell を管理者で開いて、以下をコピペ

$ModuleName = "GetNtpTime"
$GitHubName = "MuraAtVwnet"
$URI = "https://raw.githubusercontent.com/$GitHubName/$ModuleName/refs/heads/main/SetNtpTime.ps1"
$OutFile = "~/SetNtpTime.ps1"
Invoke-WebRequest -Uri $URI -OutFile $OutFile
& $OutFile


■ Windows PowerShell を使っている方へ
Windows PowerShell では、スクリプト実行が禁止になっていて、インストールとかうまく動かない場合は以下コマンドを PowerShell  のプロンプトにコピペしてください

if((Get-ExecutionPolicy) -ne 'RemoteSigned'){Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force}


■ GitHub
以下リポジトリで公開しています
https://github.com/MuraAtVwnet/GetNtpTime
git@github.com:MuraAtVwnet/GetNtpTime.git


■ リポジトリ内モジュール説明

SetNtpTime.ps1
	スクリプト本体
Readme.txt
	このファイル

