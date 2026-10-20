# Setup git hooks path to .githooks for amanah-healthcare-mobile
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot
git config core.hooksPath .githooks
Write-Host "[OK] Git hooks configured to .githooks successfully." -ForegroundColor Green
Write-Host "     pre-commit hook will now automatically run 'dart format' on staged Dart files." -ForegroundColor Cyan
