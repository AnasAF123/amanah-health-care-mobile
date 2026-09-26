#!/usr/bin/env pwsh
# capture_http_log.ps1
# Captures Flutter HTTP logs from ADB logcat to a timestamped file.
# Usage:
#   .\scripts\capture_http_log.ps1              # capture all HTTP logs
#   .\scripts\capture_http_log.ps1 -Filter "my-schedules"  # filter by URL fragment
#
# Press Ctrl+C to stop capture.

param(
    [string]$Filter = "",
    [string]$OutputDir = "scripts"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outFile = "$OutputDir\http_log_$timestamp.txt"

Write-Host "🚀 Clearing ADB logcat buffer..." -ForegroundColor Cyan
adb logcat -c

Write-Host "📡 Capturing Flutter HTTP logs → $outFile" -ForegroundColor Green
if ($Filter) {
    Write-Host "   Filter: '$Filter'" -ForegroundColor Yellow
}
Write-Host "   Press Ctrl+C to stop.`n" -ForegroundColor Gray

# Stream logcat, filter for flutter tag, optionally grep by URL fragment
if ($Filter) {
    adb logcat -s flutter | Where-Object { $_ -match $Filter } | Tee-Object -FilePath $outFile
} else {
    adb logcat -s flutter | Tee-Object -FilePath $outFile
}

Write-Host "`n✅ Saved to $outFile" -ForegroundColor Green
