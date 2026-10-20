import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_slide_to_confirm.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/camera_permission_viewport.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/scanner_overlay.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';
import 'package:amanah_healthcare/helpers/camera_helper.dart';
import 'package:amanah_healthcare/helpers/global_vars.dart';
import 'package:amanah_healthcare/helpers/permission_helper.dart';

class PresenceScannerCameraViewport extends StatelessWidget {
  const PresenceScannerCameraViewport({
    required this.laserAnimation,
    required this.isFlashOn,
    required this.isDrawerOpen,
    required this.onBarcodeDetected,
    required this.scanMode,
    required this.onSelectScanMode,
    super.key,
    this.enableCameraScanner = true,
    this.bottomNavigationClearance = 0,
    this.onScannerCreated,
    this.hardwareNotifier,
  });

  final Animation<double> laserAnimation;
  final bool isFlashOn;
  final bool isDrawerOpen;
  final ValueChanged<String> onBarcodeDetected;
  final AttendanceScanMode scanMode;
  final ValueChanged<AttendanceScanMode> onSelectScanMode;
  final bool enableCameraScanner;
  final double bottomNavigationClearance;
  final void Function(ScannerHardwareController controller)? onScannerCreated;
  final ValueNotifier<ScannerHardwareController?>? hardwareNotifier;

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

  bool _shouldUseCameraScanner(BuildContext context) {
    if (!enableCameraScanner || !safeHasACamera()) {
      return false;
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    return listener == null ||
        listener.value.status == DevicePermissionStatus.granted;
  }

  Widget _buildCameraPreview(BuildContext context) {
    return Positioned.fill(
      child: GlobalVars.barcodeScanner.getScanner(
        onScan: (String val) async {
          if (!isDrawerOpen) {
            onBarcodeDetected(val);
          }
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
    );
  }

  Widget _buildViewfinderMask(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth;
        final double screenHeight = constraints.maxHeight;
        final double cutoutSize = (screenWidth - 56).clamp(240.0, 360.0);
        final Rect cutoutRect = Rect.fromCenter(
          center: Offset(screenWidth / 2, screenHeight * 0.44),
          width: cutoutSize,
          height: cutoutSize,
        );

        return Stack(
          children: <Widget>[
            // 1. Semi-transparent dark mask with clear cutout
            Positioned.fill(
              child: CustomPaint(
                painter: _ViewfinderMaskPainter(
                  cutoutRect: cutoutRect,
                  maskColor: AmanahColorTokens.pureBlack.withValues(alpha: 0.65),
                  borderRadius: 24.0,
                ),
              ),
            ),

            // 2. Cutout frame border, medical grid and laser scan line
            Positioned(
              left: cutoutRect.left,
              top: cutoutRect.top,
              width: cutoutRect.width,
              height: cutoutRect.height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    const Opacity(
                      opacity: 0.15,
                      child: CustomPaint(painter: MedicalGridPainter()),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: AmanahColorTokens.brandLight.withValues(alpha: 0.75),
                          width: 2.0,
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: RepaintBoundary(
                        child: PresenceScannerTargetOverlay(
                          laserAnimation: laserAnimation,
                          contentPadding: EdgeInsetsDirectional.zero,
                          drawFrame: false,
                        ),
                      ),
                    ),
                    if (hardwareNotifier != null)
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 12,
                        child: _InKernelZoomSlider(
                          hardwareNotifier: hardwareNotifier!,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 3. Attendance Mode Switcher (Direct Slide-To-Confirm with AmanahRadius.md)
            Positioned(
              top: cutoutRect.bottom + 24,
              left: 28,
              right: 28,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: AmanahSlideToConfirm(
                    key: ValueKey<AttendanceScanMode>(scanMode),
                    text: scanMode == AttendanceScanMode.checkIn
                        ? 'Geser ke Presensi Pulang'
                        : 'Geser ke Presensi Masuk',
                    completedText: scanMode == AttendanceScanMode.checkIn
                        ? 'Beralih ke Pulang...'
                        : 'Beralih ke Masuk...',
                    variant: AmanahSlideVariant.brandGradient,
                    height: 52.0,
                    borderRadius: BorderRadius.circular(AmanahRadius.md),
                    onConfirmed: () async {
                      HapticFeedback.mediumImpact();
                      onSelectScanMode(
                        scanMode == AttendanceScanMode.checkIn
                            ? AttendanceScanMode.checkOut
                            : AttendanceScanMode.checkIn,
                      );
                      return false;
                    },
                  ),
                ),
              ),
            ),

            // 4. Torch glow overlay when flash is on
            if (isFlashOn)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: AmanahColorTokens.amberSurfaceSoft.withValues(alpha: 0.18),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldUseCameraScanner(context)) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildCameraPreview(context),
          _buildViewfinderMask(context),
        ],
      );
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    if (enableCameraScanner && safeHasACamera() && listener != null) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(color: AmanahColorTokens.canvasDark),
          CameraPermissionViewport(
            status: listener.value.status,
            onRequestPermission: () {
              listener.askPermission(onRationaleNotAvailable: () async => true);
            },
          ),
        ],
      );
    }

    return Container(color: AmanahColorTokens.canvasDark);
  }
}

/// Custom painter for semi-transparent mask with rounded rectangle window.
class _ViewfinderMaskPainter extends CustomPainter {
  const _ViewfinderMaskPainter({
    required this.cutoutRect,
    required this.maskColor,
    required this.borderRadius,
  });

  final Rect cutoutRect;
  final Color maskColor;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          cutoutRect,
          Radius.circular(borderRadius),
        ),
      );

    final Path maskPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final Paint paint = Paint()
      ..color = maskColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderMaskPainter oldDelegate) {
    return oldDelegate.cutoutRect != cutoutRect ||
        oldDelegate.maskColor != maskColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}

/// In-Kernel Continuous Zoom Slider embedded inside the bottom edge of the camera cutout.
class _InKernelZoomSlider extends StatelessWidget {
  const _InKernelZoomSlider({required this.hardwareNotifier});

  final ValueNotifier<ScannerHardwareController?> hardwareNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ScannerHardwareController?>(
      valueListenable: hardwareNotifier,
      builder: (BuildContext context, ScannerHardwareController? hardware, _) {
        if (hardware == null) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<double>(
          valueListenable: hardware.zoomState,
          builder: (BuildContext context, double currentZoom, _) {
            return Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AmanahColorTokens.pureBlack.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.zoom_out_rounded,
                    size: 14,
                    color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.70),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2.5,
                        activeTrackColor: AmanahColorTokens.brandLight,
                        inactiveTrackColor: AmanahColorTokens.surfaceLight.withValues(alpha: 0.25),
                        thumbColor: AmanahColorTokens.surfaceLight,
                        overlayColor: AmanahColorTokens.brandLight.withValues(alpha: 0.20),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5.5,
                          elevation: 2.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12.0,
                        ),
                      ),
                      child: Slider(
                        value: currentZoom.clamp(0.0, 1.0),
                        min: 0.0,
                        max: 1.0,
                        onChanged: (double val) {
                          hardware.setZoomScale(val);
                        },
                      ),
                    ),
                  ),
                  Icon(
                    Icons.zoom_in_rounded,
                    size: 14,
                    color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.70),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


