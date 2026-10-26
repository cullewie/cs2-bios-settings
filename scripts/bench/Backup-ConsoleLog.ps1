param([string]$Label = 'snap')
# console.log dosyasinin yedegini yedek klasorune alir (CS2 her acilista dosyayi sifirlar). Salt okunur kaynak.
$src = 'C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\console.log'
$dst = Join-Path (Join-Path (Split-Path $PSScriptRoot) 'console_log\yeni_yedekler') ($Label + '_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '.log')
New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
$fs = [IO.File]::Open($src, 'Open', 'Read', 'ReadWrite')
$out = [IO.File]::Create($dst); $fs.CopyTo($out); $out.Close(); $fs.Close()
'yedek: ' + $dst + '  (' + (Get-Item $dst).Length + ' bayt)'
