# Amanah Healthcare - Release Guide

Welcome to the release guide for the Amanah Healthcare Mobile App.

## 1. Pre-release Checklist

Before proceeding with a release:
- Ensure all targeted features and fixes are merged and verified.
- Verify unit and widget tests pass.
- Update version numbers in `pubspec.yaml` according to semantic versioning.

## 2. Build & Deployment

- **Android**: Build App Bundle using `flutter build appbundle -t lib/entrypoints/android/main_google_play.dart`
- **iOS**: Build IPA using `flutter build ipa -t lib/entrypoints/ios/main_ios.dart`

## 3. Verification

- Deploy to internal testing tracks on Google Play Console and TestFlight.
- Perform sanity testing across supported devices.
