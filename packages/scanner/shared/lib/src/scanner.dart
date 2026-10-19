import 'package:flutter/material.dart';

/// Base class for the Scanner interface…
abstract class Scanner {
  const Scanner();

  static const String ANALYTICS_CATEGORY = 'scanning';
  static const String ANALYTICS_STRANGE_RESTART = 'strange restart';
  static const String ANALYTICS_STRANGE_RESTOP = 'strange restop';

  String getType();

  Widget getScanner({
    required Future<bool> Function(String) onScan,
    required Future<void> Function() hapticFeedback,
    required Function(BuildContext)? onCameraFlashError,
    required Function(
      String msg,
      String category, {
      int? eventValue,
      String? barcode,
    })
    trackCustomEvent,
    required bool hasMoreThanOneCamera,
    required Widget barcodeScannerIcon,
    required Widget torchOnIcon,
    required Widget torchOffIcon,
    Color? visorColor,

    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,

    /// Padding to apply to the content (eg: the visor)
    EdgeInsetsGeometry? contentPadding,

    /// Optional callback when underlying hardware controller is ready
    void Function(ScannerHardwareController controller)? onScannerCreated,

    /// Whether to render legacy Smooth App visor
    bool showDefaultVisor = true,

    /// Whether to render legacy Smooth App bottom controls
    bool showDefaultBottomControls = true,
  });
}

/// Abstract contract for controlling hardware camera features (flash & flip)
abstract class ScannerHardwareController {
  Future<void> toggleTorch();
  Future<void> switchCamera();
  bool get isTorchOn;
  bool get isFrontCamera;
  ValueNotifier<bool?> get torchState;
}
