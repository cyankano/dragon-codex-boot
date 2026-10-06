[CmdletBinding()]
param([string]$IconPath)
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$outputRoot = Join-Path $repoRoot 'build/DragonCodexBoot'
$tempRoot = Join-Path $repoRoot '.local/tmp'
New-Item -ItemType Directory -Path $outputRoot,$tempRoot -Force | Out-Null
$env:TEMP = $tempRoot
$env:TMP = $tempRoot
$frameworkRoot = Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319'
$compiler = Join-Path $frameworkRoot 'csc.exe'
if (!(Test-Path -LiteralPath $compiler -PathType Leaf)) {
    throw '.NET Framework x64 compiler is unavailable. Use Windows with .NET Framework 4.8.'
}
$references = @('System.dll','System.Core.dll','System.Xaml.dll','System.Web.Extensions.dll','System.Drawing.dll','System.Windows.Forms.dll')
foreach ($name in @('WindowsBase.dll','PresentationCore.dll','PresentationFramework.dll')) {
    $references += Join-Path $frameworkRoot ('WPF/' + $name)
}
$argsList = @('/nologo','/target:winexe','/platform:x64','/optimize+',('/win32manifest:' + (Join-Path $repoRoot 'src/app.manifest')),('/out:' + (Join-Path $outputRoot 'DragonCodexBoot.exe')))
foreach ($reference in $references) { $argsList += '/reference:' + $reference }
if ($IconPath) {
    $resolvedIcon = (Resolve-Path -LiteralPath $IconPath).Path
    $argsList += '/win32icon:' + $resolvedIcon
}
$argsList += Join-Path $repoRoot 'src/DragonCodexBoot.cs'
& $compiler @argsList
if ($LASTEXITCODE -ne 0) { throw 'Compilation failed.' }
$configPath = Join-Path $outputRoot 'launcher.json'
if (!(Test-Path -LiteralPath $configPath)) {
    Copy-Item -LiteralPath (Join-Path $repoRoot 'config/launcher.example.json') -Destination $configPath
}
Write-Output ('Built: ' + (Join-Path $outputRoot 'DragonCodexBoot.exe'))
