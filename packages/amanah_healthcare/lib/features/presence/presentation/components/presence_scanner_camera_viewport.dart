import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/camera_permission_viewport.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/scanner_overlay.dart';
import 'package:amanah_healthcare/helpers/camera_helper.dart';
import 'package:amanah_healthcare/helpers/global_vars.dart';
import 'package:amanah_healthcare/helpers/permission_helper.dart';

class PresenceScannerCameraViewport extends StatelessWidget {
  const PresenceScannerCameraViewport({
    required this.laserAnimation,
    required this.isFlashOn,
    required this.isDrawerOpen,
    required this.onBarcodeDetected,
    super.key,
    this.enableCameraScanner = true,
    this.bottomNavigationClearance = 0,
  });

  final Animation<double> laserAnimation;
  final bool isFlashOn;
  final bool isDrawerOpen;
  final ValueChanged<String> onBarcodeDetected;
  final bool enableCameraScanner;
  final double bottomNavigationClearance;

  static bool safeHasACamera() {
    try {
      return CameraHelper.hasACamera;
    } catch (_) {
      return false;
    }
  }

  static bool safeHasMoreThanOneCamera() {
    try {
      return CameraHelper.hasMoreThanOneCamera;
    } catch (_) {
      return false;
    }
  }

  static Future<void> onCameraFlashError(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Flash Error'),
        content: const Text('Could not toggle camera flash.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  EdgeInsetsDirectional _scannerContentPadding() {
    return EdgeInsetsDirectional.only(
      top: 72,
      bottom: isDrawerOpen
          ? 250
          : (bottomNavigationClearance > 0
              ? bottomNavigationClearance + 20
              : 92),
    );
  }

  bool _shouldUseLegacyCameraScanner(BuildContext context) {
    if (!enableCameraScanner || !safeHasACamera()) {
      return false;
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    return listener == null ||
        listener.value.status == DevicePermissionStatus.granted;
  }

  Widget _buildCameraBackground() {
    return Container(
      color: AmanahColorTokens.canvasDark,
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(painter: MedicalGridPainter()),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AmanahColorTokens.pureBlack.withValues(alpha: 0.65),
                    Colors.transparent,
                    AmanahColorTokens.pureBlack.withValues(alpha: 0.80),
                  ],
                  stops: const <double>[0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: PresenceScannerTargetOverlay(
                laserAnimation: laserAnimation,
                contentPadding: _scannerContentPadding(),
              ),
            ),
          ),
          if (isFlashOn)
            Positioned.fill(
              child: Container(
                color: AmanahColorTokens.amberSurfaceSoft.withValues(alpha: 0.20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegacyScanner(BuildContext context) {
    final EdgeInsetsDirectional scannerContentPadding =
        _scannerContentPadding();

    return Stack(
      children: <Widget>[
        GlobalVars.barcodeScanner.getScanner(
          onScan: (String val) async {
            onBarcodeDetected(val);
            return true;
          },
          hapticFeedback: () => HapticFeedback.selectionClick(),
          onCameraFlashError: onCameraFlashError,
          trackCustomEvent: (
            String msg,
            String category, {
            int? eventValue,
            String? barcode,
          }) {},
          hasMoreThanOneCamera: safeHasMoreThanOneCamera(),
          toggleCameraModeTooltip: '',
          toggleFlashModeTooltip: '',
          barcodeScannerIcon: const SizedBox.shrink(),
          torchOnIcon: const SizedBox.shrink(),
          torchOffIcon: const SizedBox.shrink(),
          visorColor: AmanahColorTokens.brandLight,
          contentPadding: scannerContentPadding,
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AmanahColorTokens.pureBlack.withValues(alpha: 0.35),
                    Colors.transparent,
                    AmanahColorTokens.pureBlack.withValues(alpha: 0.50),
                  ],
                  stops: const <double>[0.0, 0.48, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: PresenceScannerTargetOverlay(
              laserAnimation: laserAnimation,
              contentPadding: scannerContentPadding,
              drawFrame: false,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget cameraBase = _buildCameraBackground();

    if (_shouldUseLegacyCameraScanner(context)) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[cameraBase, _buildLegacyScanner(context)],
      );
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    if (enableCameraScanner &&
        safeHasACamera() &&
        listener != null &&
        listener.value.status != DevicePermissionStatus.checking) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          cameraBase,
          CameraPermissionViewport(
            status: listener.value.status,
            onRequestPermission: () {
              listener.askPermission(onRationaleNotAvailable: () async => true);
            },
          ),
        ],
      );
    }

    return cameraBase;
  }
}
