@echo off
setlocal

set "PUB_CACHE=D:\PubCache"
set "GRADLE_USER_HOME=D:\Gradle"

cd /d "%~dp0packages\amanah_healthcare"

set "TARGET_ENV=dev.device.json"

if /i "%~1"=="emulator" (
  set "TARGET_ENV=dev.emulator.json"
  shift
) else if /i "%~1"=="device" (
  set "TARGET_ENV=dev.device.json"
  shift
) else if /i "%~1"=="staging" (
  set "TARGET_ENV=staging.json"
  shift
) else if /i "%~1"=="prod" (
  set "TARGET_ENV=prod.json"
  shift
)

echo [Amanah] Active Environment Profile: env\%TARGET_ENV%

if "%TARGET_ENV%"=="dev.device.json" (
  echo [Amanah] Ensuring ADB reverse proxy for port 3001...
  adb reverse tcp:3001 tcp:3001 2>nul
)

flutter run -t lib\entrypoints\android\main_google_play.dart --android-skip-build-dependency-validation --dart-define-from-file="env\%TARGET_ENV%" %1 %2 %3 %4 %5 %6 %7 %8 %9
