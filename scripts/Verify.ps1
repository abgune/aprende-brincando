param([switch]$BuildApk)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Use-Tooling.ps1')
Push-Location (Join-Path $PSScriptRoot '..')
try {
    flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed' }
    dart format --output=none --set-exit-if-changed lib test integration_test tool
    if ($LASTEXITCODE -ne 0) { throw 'Formatting check failed' }
    flutter analyze
    if ($LASTEXITCODE -ne 0) { throw 'Analysis failed' }
    flutter test --coverage
    if ($LASTEXITCODE -ne 0) { throw 'Tests failed' }
    if ($BuildApk) {
        flutter build apk --debug
        if ($LASTEXITCODE -ne 0) { throw 'Android build failed' }
    }
} finally { Pop-Location }
