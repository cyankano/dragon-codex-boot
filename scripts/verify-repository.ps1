$ErrorActionPreference='Stop'
$repoRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$files=@(& git -c core.quotePath=false -C $repoRoot ls-files)
if ($LASTEXITCODE -ne 0 -or $files.Count -eq 0) { throw 'No tracked repository files. Initialize and stage the clean source first.' }
foreach ($name in $files) {
    if ($name -match '(^|/)(build|dist|\.local|logs|qa|media|\.integration)/' -or $name -match '\.(mp4|mov|webm|ico|lnk|exe|dll|pdb|zip|pem|key)$') {
        throw ('Private/generated asset tracked: '+$name)
    }
    $text=Get-Content -LiteralPath (Join-Path $repoRoot $name) -Encoding UTF8 -Raw
    if ($text -match '[CE]:[/\\]Users[/\\]' -or $text -match '[EF]:[/\\]' -or
        $text -match 'gh[pousr]_[A-Za-z0-9]{30,}' -or $text -match 'github_pat_[A-Za-z0-9_]{50,}' -or
        $text -match '-----BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY-----') { throw ('Private path or credential marker found: '+$name) }
}
$config=Get-Content -LiteralPath (Join-Path $repoRoot 'config/launcher.example.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($config.Video -ne 'media/startup.mp4') { throw 'Public configuration must use its relative media path.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zips=@(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'dist') -Filter '*-win-x64*.zip' | Sort-Object LastWriteTime -Descending)
if (!$zips) { throw 'Create a program package first.' }
$zip=$zips[0]
$archive=[IO.Compression.ZipFile]::OpenRead($zip.FullName)
try {
    foreach ($entry in $archive.Entries) {
        if ($entry.FullName -match '\.(mp4|mov|webm|ico|lnk)$' -or $entry.FullName -match '(^|/)(logs|qa|\.integration)/') { throw ('Private asset packaged: '+$entry.FullName) }
        if ($entry.Length -eq 0) { continue }
        $stream=$entry.Open()
        try { $null=Get-FileHash -InputStream $stream -Algorithm SHA256 } finally { $stream.Dispose() }
    }
    $cfgEntry=$archive.GetEntry('launcher.json')
    if (!$cfgEntry) { throw 'Packaged config missing.' }
    $reader=New-Object IO.StreamReader($cfgEntry.Open())
    try { $packedConfig=$reader.ReadToEnd() | ConvertFrom-Json } finally { $reader.Dispose() }
    if ($packedConfig.Video -ne 'media/startup.mp4') { throw 'Private config packaged.' }
    $exeEntry=$archive.GetEntry('DragonCodexBoot.exe')
    if (!$exeEntry) { throw 'Packaged executable missing.' }
    $stream=$exeEntry.Open()
    try { $exeHash=(Get-FileHash -InputStream $stream).Hash } finally { $stream.Dispose() }
    if ($exeHash -ne (Get-FileHash -LiteralPath (Join-Path $repoRoot 'build/DragonCodexBoot/DragonCodexBoot.exe')).Hash) { throw 'Packaged binary hash mismatch.' }
} finally { $archive.Dispose() }
$expected=(Get-Content -LiteralPath ($zip.FullName+'.sha256') -Raw).Trim().Split(' ')[0]
if ($expected -ine (Get-FileHash -LiteralPath $zip.FullName).Hash) { throw 'Archive hash mismatch.' }
Write-Output ('PASS: '+$files.Count+' tracked source files; media, private paths and credential markers excluded; package entries and hashes checked.')
