param(
  [string]$AvdName = "Pixel_6_API_35"
)

$ErrorActionPreference = "Stop"

$FlutterRoot = "C:\Users\ANAS ABIYYU FALAH\development\flutter"
$AndroidSdk = if ($env:ANDROID_SDK_ROOT) {
  $env:ANDROID_SDK_ROOT
} elseif ($env:ANDROID_HOME) {
  $env:ANDROID_HOME
} else {
  "D:\Android\Sdk"
}

$EmulatorExe = Join-Path $AndroidSdk "emulator\emulator.exe"
$AdbExe = Join-Path $AndroidSdk "platform-tools\adb.exe"
$AvdHome = if ($env:ANDROID_AVD_HOME) {
  $env:ANDROID_AVD_HOME
} else {
  Join-Path $env:USERPROFILE ".android\avd"
}
$AvdDir = Join-Path $AvdHome "$AvdName.avd"
$AvdConfig = Join-Path $AvdDir "config.ini"
$AndroidUserHome = Join-Path $env:USERPROFILE ".android"

function Write-Step([string]$Message) {
  Write-Host "[emulator] $Message" -ForegroundColor Cyan
}

function Stop-IfRunning([string[]]$Names) {
  foreach ($name in $Names) {
    Get-Process -Name $name -ErrorAction SilentlyContinue |
      Stop-Process -Force -ErrorAction SilentlyContinue
  }
}

function Set-AvdConfigValue([string]$Path, [string]$Key, [string]$Value) {
  if (-not (Test-Path -LiteralPath $Path)) {
    return
  }

  $lines = [System.Collections.Generic.List[string]]::new()
  $existing = Get-Content -LiteralPath $Path
  foreach ($line in $existing) {
    if ($line -notmatch "^\s*$([regex]::Escape($Key))\s*=") {
      $lines.Add($line)
    }
  }
  $lines.Add("$Key=$Value")
  Set-Content -LiteralPath $Path -Value $lines -Encoding ASCII
}

if (-not (Test-Path -LiteralPath $AdbExe)) {
  throw "ADB binary not found: $AdbExe"
}
if (-not (Test-Path -LiteralPath $AvdDir)) {
  throw "AVD folder not found: $AvdDir"
}

$env:FLUTTER_ROOT = $FlutterRoot
$env:ANDROID_HOME = $AndroidSdk
$env:ANDROID_SDK_ROOT = $AndroidSdk
$env:ANDROID_AVD_HOME = $AvdHome
$env:ANDROID_USER_HOME = $AndroidUserHome
$env:ADB_VENDOR_KEYS = Join-Path $AndroidUserHome "adbkey"
$env:Path = "$FlutterRoot\bin;$AndroidSdk\platform-tools;$AndroidSdk\emulator;$AndroidSdk\cmdline-tools\latest\bin;$env:Path"

Write-Step "Cleaning stale Flutter, Dart, ADB, and emulator processes"
Stop-IfRunning @("dart", "flutter", "adb", "emulator", "qemu-system-x86_64")
Start-Sleep -Seconds 2

Write-Step "Removing stale AVD lock files"
Get-ChildItem -LiteralPath $AvdDir -Filter "*.lock" -Force -ErrorAction SilentlyContinue |
  Remove-Item -Force -ErrorAction SilentlyContinue

Write-Step "Setting AVD GPU defaults to swiftshader_indirect"
Set-AvdConfigValue -Path $AvdConfig -Key "hw.gpu.enabled" -Value "yes"
Set-AvdConfigValue -Path $AvdConfig -Key "hw.gpu.mode" -Value "swiftshader_indirect"
Set-AvdConfigValue -Path $AvdConfig -Key "fastboot.forceFastBoot" -Value "yes"
Set-AvdConfigValue -Path $AvdConfig -Key "fastboot.forceColdBoot" -Value "no"

Write-Step "Resetting ADB server"
& $AdbExe kill-server | Out-Null
Start-Sleep -Seconds 1
& $AdbExe start-server | Out-Null

Write-Host ""
Write-Step "Clean session complete"
Write-Host "Next:"
Write-Host "1. Ctrl + Shift + P"
Write-Host "2. Flutter: Launch Emulator"
Write-Host "3. Select $AvdName"
Write-Host "4. Run Android - Google Play"
Write-Host ""
exit 0
