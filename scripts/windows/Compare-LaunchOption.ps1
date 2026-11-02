param(
  [string]$Plan = 'A=;B=-threads 9;C=-threads 9 -mainthreadpriority 2;D=',
  [string]$Tag = 'LAUNCH',
  [string]$OutDir = (Join-Path $PSScriptRoot 'sonuc'),
  [string]$SteamExe = 'C:\Program Files (x86)\Steam\steam.exe'
)
# CS2 baslatma secenegi bloklu karsilastirmasi (docs/windows.md, "CS2 baslatma secenekleri").
# -Plan 'ad=ek secenekler;...' ornek: 'A=;B=-threads 9;C=;' (bos = ek seceneksiz kontrol blogu; ortaya ve sona kontrol blogu koyun).
# Her blok: CS2'yi kapatir -> steam -applaunch 730 <ek secenekler> (Steam'deki kayitli seceneklere eklenir, kayitli secenekler degismez)
# -> cs2.exe komut satirini dogrular -> 40 sn bekler -> gpu\Compare-GpuProfile.ps1 ile 2 isinma + 3 kayit kosusu (Afterburner Profil 1, CPU 0 haric)
# -> bench\Backup-ConsoleLog.ps1 ile console.log yedegi (CS2 her acilista dosyayi sifirlar). Sonuc: VProf satirlari console.log yedeklerinde.
# Steam acik olmali. Yonetici gerekir (Compare-GpuProfile). FACEIT kapali olmali. Durdurmak icin bench\bench_stop.txt olusturun.
# Yalniz ASCII.
$scripts = Split-Path $PSScriptRoot
$gpuAb = Join-Path $scripts 'gpu\Compare-GpuProfile.ps1'
$backup = Join-Path $scripts 'bench\Backup-ConsoleLog.ps1'
$stopFile = Join-Path $scripts 'bench\bench_stop.txt'
New-Item -ItemType Directory -Force $OutDir | Out-Null
$out = Join-Path $OutDir ('launch_ab_{0}_{1}.txt' -f $Tag, (Get-Date -Format 'yyyyMMdd_HHmm'))
function Log([string]$m) { $l = '[' + (Get-Date -Format 'HH:mm:ss') + '] ' + $m; $l; Add-Content -Path $out -Value $l -Encoding UTF8 }
function CloseCs2 {
  $c = Get-Process cs2 -ErrorAction SilentlyContinue
  if (-not $c) { return }
  [void]$c.CloseMainWindow()
  for ($i = 0; $i -lt 40 -and -not $c.HasExited; $i++) { Start-Sleep 1; $c.Refresh() }
  if (-not $c.HasExited) { Stop-Process -Id $c.Id -Force; Log 'cs2 kapanmadi, sonlandirildi' }
  Start-Sleep 8
}
if (-not (Test-Path $SteamExe)) { throw "Steam yok: $SteamExe" }
Log "--- Compare-LaunchOption basladi | plan $Plan"
foreach ($b in ($Plan -split ';' | Where-Object { $_ })) {
  $kv = $b -split '=', 2; $n = $kv[0].Trim(); $extra = if ($kv.Count -gt 1) { $kv[1].Trim() } else { '' }
  if (Test-Path $stopFile) { Log 'bench_stop.txt var, durdu'; break }
  CloseCs2
  $st = Get-Process steam -ErrorAction SilentlyContinue
  if (-not $st) { Log 'Steam acik degil, durdu'; break }
  $st.ProcessorAffinity = [IntPtr]0xFFFE
  Log ("blok $n | ek secenek: '" + $extra + "'")
  Start-Process $SteamExe -ArgumentList (@('-applaunch', '730') + @($extra -split ' ' | Where-Object { $_ }))
  $c = $null; for ($i = 0; $i -lt 90 -and -not $c; $i++) { Start-Sleep 2; $c = Get-Process cs2 -ErrorAction SilentlyContinue }
  if (-not $c) { Log 'CS2 baslamadi, durdu'; break }
  Start-Sleep 3
  $cl = (Get-CimInstance Win32_Process -Filter "ProcessId=$($c.Id)").CommandLine
  Log ('cs2 PID {0} | komut: {1}' -f $c.Id, ($cl -replace '^.*cs2\.exe"?\s*', ''))
  if ($extra -and $cl -notlike ('*' + $extra + '*')) { Log 'UYARI: ek secenek komut satirinda yok, blok atlandi'; continue }
  Start-Sleep 40
  $order = ('{0}W1:1:0xFFFE,{0}W2:1:0xFFFE,{0}1:1:0xFFFE,{0}2:1:0xFFFE,{0}3:1:0xFFFE' -f $n)
  & $gpuAb -Order $order -EndProfile 1 -Tag ('LA_' + $n) -OutDir $OutDir | ForEach-Object { if ($_ -match 'GPU:|sonrasi|basladi|bitti|UYARI|EKRAN|FACEIT') { Log $_ } }
  & $backup -Label ('LA_' + $Tag + '_' + $n) | ForEach-Object { Log $_ }
  if (-not (Get-Process cs2 -ErrorAction SilentlyContinue)) { Log "UYARI: blok $n sonunda CS2 kapali" }
}
CloseCs2
Log '--- Compare-LaunchOption bitti'
