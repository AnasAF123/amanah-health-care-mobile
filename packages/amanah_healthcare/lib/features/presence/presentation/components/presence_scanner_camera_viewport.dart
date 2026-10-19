import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
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
    this.onScannerCreated,
  });

  final Animation<double> laserAnimation;
  final bool isFlashOn;
  final bool isDrawerOpen;
  final ValueChanged<String> onBarcodeDetected;
  final bool enableCameraScanner;
  final double bottomNavigationClearance;
  final void Function(ScannerHardwareController controller)? onScannerCreated;

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
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AmanahColorTokens.brandLight.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      color: AmanahColorTokens.pureBlack.withValues(alpha: 0.4),
                    ),
                    child: IgnorePointer(
                      child: PresenceScannerTargetOverlay(
                        laserAnimation: laserAnimation,
                        contentPadding: EdgeInsetsDirectional.zero,
                      ),
                    ),
                  ),
                ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AmanahColorTokens.brandLight.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
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
                    contentPadding: EdgeInsetsDirectional.zero,
                    onScannerCreated: onScannerCreated,
                    showDefaultVisor: false,
                    showDefaultBottomControls: false,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: RepaintBoundary(
                        child: PresenceScannerTargetOverlay(
                          laserAnimation: laserAnimation,
                          contentPadding: EdgeInsetsDirectional.zero,
                          drawFrame: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
    if (enableCameraScanner && safeHasACamera() && listener != null) {
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
