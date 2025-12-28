#################################################################
#
# NTP から現在時刻を取得して PC の時刻を修正する
#
#################################################################

###################
# NTP Time 取得
###################
function GetNtpTime {
	param(
		[string[]]$Server = @("ntp.nict.jp", "time.google.com", "pool.ntp.org"),
		[int]$Port = 123,
		[int]$TimeoutMs = 3000,
		[int]$Retry = 2,
		[switch]$PreferIPv4 # IPv4 を優先する
	)

	function Convert-NtpTimestampToUtc([byte[]]$resp) {
		# Transmit Timestamp (bytes 40-47)
		$intPart  = [BitConverter]::ToUInt32($resp[43..40], 0)
		$fracPart = [BitConverter]::ToUInt32($resp[47..44], 0)

		$ms = ($intPart * 1000.0) + ($fracPart * 1000.0 / 0x100000000)

		$epoch = [DateTime]::SpecifyKind([DateTime]"1900-01-01T00:00:00", [DateTimeKind]::Utc)
		$epoch.AddMilliseconds($ms)
	}

	# NTP request packet (48 bytes)
	$req = New-Object byte[] 48
	$req[0] = 0x1B

	$errors = New-Object System.Collections.Generic.List[string]

	foreach ($s in $Server) {
		# Resolve all IPs
		try {
			$ips = [System.Net.Dns]::GetHostAddresses($s)
			if (-not $ips -or $ips.Count -eq 0) {
				throw "DNS解決結果が空です。"
			}

			if ($PreferIPv4) {
				$ips = @(
					$ips | Where-Object { $_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork }
					$ips | Where-Object { $_.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6 }
				)
			}
		}
		catch {
			$errors.Add("[$s] DNS解決失敗: $($_.Exception.Message)")
			continue
		}

		foreach ($ip in $ips) {
			for ($try = 0; $try -le $Retry; $try++) {
				$udp = $null
				try {
					# UdpClient
					$udp = New-Object System.Net.Sockets.UdpClient($ip.AddressFamily)
					$udp.Client.ReceiveTimeout = $TimeoutMs

					# Windows PowerShell 5.1 でエラーになる対策
					$ep = New-Object System.Net.IPEndPoint($ip, $Port)
					$udp.Connect($ep)

					[void]$udp.Send($req, $req.Length)

					$remote = $null
					$resp = $udp.Receive([ref]$remote)

					if (-not $resp -or $resp.Length -lt 48) {
						throw "NTP応答が不正（Length=$($resp.Length)）"
					}

					$utc = Convert-NtpTimestampToUtc $resp
					$local = $utc.ToLocalTime()

					return [PSCustomObject]@{
						Server	  = $s
						Address   = $ip.IPAddressToString
						UtcTime   = $utc
						LocalTime = $local
						TimeoutMs = $TimeoutMs
						Retry	  = $Retry
					}
				}
				catch {
					$errors.Add("[$s / $($ip.IPAddressToString) / try=$try] $($_.Exception.Message)")
				}
				finally {
					if ($udp) { $udp.Close(); $udp.Dispose() }
				}
			}
		}
	}

	$detail = ($errors | Select-Object -Last 12) -join "`n"
	throw "NTP時刻取得に失敗しました。UDP/123遮断 or IPv6/IPv4経路不調の可能性。`n直近のエラー:`n$detail"
}

#################################################################
# main
#################################################################

# PC の時刻を合わせる
Set-Date -Date (GetNtpTime).LocalTime
