import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../domain/amanah_home_data.dart';
import 'amanah_local_asset_server.dart';

/// Service responsible for pre-warming the 3D Doctor ID Card WebGL WebView
/// immediately after cold-boot idle frame, ensuring 0ms opening latency.
///
/// When the card screen is closed or in the background, this service commands
/// the Three.js physics & RAF loop to pause (0% CPU/GPU overhead).
/// When reopened, it immediately resumes without reloading.
class AmanahDoctorIdCardWarmService {
  AmanahDoctorIdCardWarmService._();

  static final AmanahDoctorIdCardWarmService instance =
      AmanahDoctorIdCardWarmService._();

  WebViewController? _controller;
  bool _isWarming = false;
  bool _isReady = false;
  bool _isDisplayed = false;
  String? _currentProfileSignature;

  final ValueNotifier<bool> isReadyNotifier = ValueNotifier<bool>(false);

  WebViewController? get controller => _controller;
  bool get isReady => _isReady;
  bool get isWarming => _isWarming;

  /// Starts the warm-up procedure in background. Safe to call multiple times.
  Future<void> warmUp(AmanahDoctorProfile profile) async {
    if (_controller != null) {
      updateProfile(profile);
      return;
    }

    if (_isWarming) {
      return;
    }

    // In unit/widget tests or environments where webview platform is not registered,
    // gracefully skip warming up and let native fallback render.
    if (kIsWeb || WebViewPlatform.instance == null) {
      return;
    }

    _isWarming = true;

    try {
      final Uri baseUri = await AmanahLocalAssetServer.instance.getBaseUri();
      final Uri loadUri = baseUri.replace(
        path: '/index.html',
        queryParameters: <String, String>{
          'name': profile.name,
          'role': profile.role,
          'sip': profile.sip,
          'hospital': profile.hospital.toUpperCase(),
          'department': profile.department,
          'avatarUrl': './assets/images/doctors/woman-doctor-4.png',
        },
      );

      _currentProfileSignature = _computeSignature(profile);

      final WebViewController controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..addJavaScriptChannel(
          'AmanahChannel',
          onMessageReceived: (JavaScriptMessage message) {
            if (message.message == 'WEBVIEW_READY') {
              _markReady();
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              _markReady();
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('Doctor ID Card Warm WebView error: ${error.description}');
            },
          ),
        );

      _controller = controller;
      await controller.loadRequest(loadUri);
    } catch (error) {
      debugPrint('AmanahDoctorIdCardWarmService warmUp fallback: $error');
      _isWarming = false;
    }
  }

  void _markReady() {
    if (!_isReady) {
      _isReady = true;
      _isWarming = false;
      isReadyNotifier.value = true;
      if (!_isDisplayed) {
        pauseAnimation();
      }
    }
  }

  /// Called when the ID Card screen becomes visible to user.
  void onCardOpened(AmanahDoctorProfile profile) {
    _isDisplayed = true;
    updateProfile(profile);
    resumeAnimation();
  }

  /// Called when the ID Card screen is closed or dismissed.
  void onCardClosed() {
    _isDisplayed = false;
    pauseAnimation();
  }

  /// Resumes the Three.js RAF and Rapier physics loop.
  void resumeAnimation() {
    if (_controller == null || !_isReady) {
      return;
    }
    try {
      _controller!.runJavaScript(
        'window.resumeCardAnimation && window.resumeCardAnimation();',
      );
    } catch (error) {
      debugPrint('Error resuming card animation: $error');
    }
  }

  /// Pauses the Three.js RAF and Rapier physics loop (0% GPU).
  void pauseAnimation() {
    if (_controller == null) {
      return;
    }
    try {
      _controller!.runJavaScript(
        'window.pauseCardAnimation && window.pauseCardAnimation();',
      );
    } catch (error) {
      debugPrint('Error pausing card animation: $error');
    }
  }

  /// Dynamically updates the doctor profile textures without reloading the webview.
  void updateProfile(AmanahDoctorProfile profile) {
    if (_controller == null) {
      return;
    }

    final String sig = _computeSignature(profile);
    if (sig == _currentProfileSignature) {
      return;
    }
    _currentProfileSignature = sig;

    final String payloadJson = jsonEncode(<String, String>{
      'name': profile.name,
      'role': profile.role,
      'sip': profile.sip,
      'hospital': profile.hospital.toUpperCase(),
      'department': profile.department,
      'avatarUrl': './assets/images/doctors/woman-doctor-4.png',
    });

    try {
      _controller!.runJavaScript(
        'window.updateDoctorProfile && window.updateDoctorProfile($payloadJson);',
      );
    } catch (error) {
      debugPrint('Error updating doctor profile in webview: $error');
    }
  }

  String _computeSignature(AmanahDoctorProfile profile) {
    return '${profile.name}|${profile.role}|${profile.sip}|${profile.hospital}|${profile.department}';
  }

  /// Resets the warm service state (useful in tests).
  @visibleForTesting
  void reset() {
    _controller = null;
    _isWarming = false;
    _isReady = false;
    _isDisplayed = false;
    _currentProfileSignature = null;
    isReadyNotifier.value = false;
  }
}
