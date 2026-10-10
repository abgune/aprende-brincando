param([string]$FlutterSdk = $env:FLUTTER_ROOT, [string]$AndroidSdk = $env:ANDROID_HOME)
$ErrorActionPreference = 'Stop'
$taskTooling = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../../work/tooling'))
if (-not $FlutterSdk -and (Test-Path (Join-Path $taskTooling 'flutter/bin/flutter.bat'))) { $FlutterSdk = Join-Path $taskTooling 'flutter' }
if (-not $AndroidSdk -and (Test-Path (Join-Path $taskTooling 'android-sdk'))) { $AndroidSdk = Join-Path $taskTooling 'android-sdk' }
if ($FlutterSdk) { $env:FLUTTER_ROOT = $FlutterSdk; $env:PATH = (Join-Path $FlutterSdk 'bin') + ';' + $env:PATH }
if ($AndroidSdk) { $env:ANDROID_HOME = $AndroidSdk; $env:ANDROID_SDK_ROOT = $AndroidSdk; $env:PATH = (Join-Path $AndroidSdk 'platform-tools') + ';' + $env:PATH }
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) { throw 'Flutter not found. Install it, or pass -FlutterSdk to this script.' }
Write-Host 'Flutter and Android tools are available in this PowerShell session.'
