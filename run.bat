@echo off
setlocal

set "PUB_CACHE=D:\PubCache"
set "GRADLE_USER_HOME=D:\Gradle"

cd /d "%~dp0packages\smooth_app"
flutter run -t lib\entrypoints\android\main_google_play.dart
