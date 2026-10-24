import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_slide_to_confirm.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/camera_permission_viewport.dart';
import 'package:amanah_healthcare/features/presence/presentation/state/presence_scanner_controller.dart';
import 'package:amanah_healthcare/helpers/camera_helper.dart';
import 'package:amanah_healthcare/helpers/global_vars.dart';
import 'package:amanah_healthcare/helpers/permission_helper.dart';

class PresenceScannerCameraViewport extends StatelessWidget {
  const PresenceScannerCameraViewport({
    required this.isFlashOn,
    required this.isDrawerOpen,
    required this.onBarcodeDetected,
    required this.scanMode,
    required this.onSelectScanMode,
    super.key,
    this.isFrontCamera = false,
    this.enableCameraScanner = true,
    this.bottomNavigationClearance = 0,
    this.onScannerCreated,
    this.hardwareNotifier,
  });

  final bool isFlashOn;
  final bool isFrontCamera;
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  bool _shouldUseCameraScanner(BuildContext context) {
    if (!enableCameraScanner || !safeHasACamera()) {
      return false;
    }

    final PermissionListener? listener = context.watch<PermissionListener?>();
    return listener == null || listener.value.status == DevicePermissionStatus.granted;
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
        trackCustomEvent: (String msg, String category, {int? eventValue, String? barcode}) {},
        hasMoreThanOneCamera: safeHasMoreThanOneCamera(),
        toggleCameraModeTooltip: '',
        toggleFlashModeTooltip: '',
        barcodeScannerIcon: const SizedBox.shrink(),
        torchOnIcon: const SizedBox.shrink(),
        torchOffIcon: const SizedBox.shrink(),
        visorColor: AmanahColorTokens.brand,
        contentPadding: EdgeInsetsDirectional.zero,
        onScannerCreated: onScannerCreated,
        showDefaultVisor: false,
        showDefaultBottomControls: false,
      ),
    );
  }

  Widget _buildViewfinderMask(BuildContext context) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final double effectiveBottomClearance = bottomNavigationClearance > 0
        ? bottomNavigationClearance
        : safeBottom;

    final bool effectiveFront = isFrontCamera || (hardwareNotifier?.value?.isFrontCamera ?? false);

    return Stack(
      children: <Widget>[
        // 1. Front Camera Ring Light Vignette Overlay (Screen Flash)
        if (effectiveFront && isFlashOn)
          const Positioned.fill(child: IgnorePointer(child: _FrontCameraRingLightOverlay())),

        // 2. Floating Continuous Zoom Slider (Clean capsule floating above slide control)
        if (hardwareNotifier != null)
          Positioned(
            left: 28,
            right: 28,
            bottom: effectiveBottomClearance + 84,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: _InKernelZoomSlider(hardwareNotifier: hardwareNotifier!),
              ),
            ),
          ),

        // 3. Attendance Mode Switcher (Direct Slide-To-Confirm)
        Positioned(
          left: 28,
          right: 28,
          bottom: effectiveBottomClearance + 18,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AmanahSlideToConfirm(
                key: ValueKey<AttendanceScanMode>(scanMode),
                text: scanMode == AttendanceScanMode.checkIn
                    ? 'Geser ke Presensi Pulang'
                    : 'Geser ke Presensi Masuk',
                targetText: scanMode == AttendanceScanMode.checkIn
                    ? 'Presensi Pulang'
                    : 'Presensi Masuk',
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldUseCameraScanner(context)) {
      return Stack(
        fit: StackFit.expand,
        children: <Widget>[_buildCameraPreview(context), _buildViewfinderMask(context)],
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

/// Screen flash ring light vignette for front camera scanning.
/// Features solid beaming white borders on all edges and a transparent hollow center.
class _FrontCameraRingLightOverlay extends StatelessWidget {
  const _FrontCameraRingLightOverlay();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _RingLightVignettePainter());
  }
}

class _RingLightVignettePainter extends CustomPainter {
  const _RingLightVignettePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const double solidBorder = 32.0;
    const double featherDepth = 120.0;
    const double totalDepth = solidBorder + featherDepth;

    // 1. Solid pure white outer perimeter frame (lights up device screen edges)
    final Paint solidPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Top & Bottom solid edges
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, solidBorder), solidPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - solidBorder, size.width, solidBorder),
      solidPaint,
    );
    // Left & Right solid edges
    canvas.drawRect(Rect.fromLTWH(0, 0, solidBorder, size.height), solidPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width - solidBorder, 0, solidBorder, size.height),
      solidPaint,
    );

    const List<Color> gradientColors = <Color>[
      Colors.white,
      Color(0xCCFFFFFF), // 80% white
      Color(0x66FFFFFF), // 40% white
      Color(0x00FFFFFF), // 0% hollow transparent
    ];
    const List<double> gradientStops = <double>[0.0, 0.30, 0.65, 1.0];

    // 2. Continuous 4-directional inward linear gradients (spanning full width & height so corners blend seamlessly)
    final Rect topRect = Rect.fromLTWH(0, solidBorder, size.width, featherDepth);
    final Paint topPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
        stops: gradientStops,
      ).createShader(topRect);
    canvas.drawRect(topRect, topPaint);

    final Rect bottomRect = Rect.fromLTWH(0, size.height - totalDepth, size.width, featherDepth);
    final Paint bottomPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: gradientColors,
        stops: gradientStops,
      ).createShader(bottomRect);
    canvas.drawRect(bottomRect, bottomPaint);

    final Rect leftRect = Rect.fromLTWH(solidBorder, 0, featherDepth, size.height);
    final Paint leftPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: gradientColors,
        stops: gradientStops,
      ).createShader(leftRect);
    canvas.drawRect(leftRect, leftPaint);

    final Rect rightRect = Rect.fromLTWH(size.width - totalDepth, 0, featherDepth, size.height);
    final Paint rightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: gradientColors,
        stops: gradientStops,
      ).createShader(rightRect);
    canvas.drawRect(rightRect, rightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
                        activeTrackColor: AmanahColorTokens.brand,
                        inactiveTrackColor: AmanahColorTokens.surfaceLight.withValues(alpha: 0.25),
                        thumbColor: AmanahColorTokens.surfaceLight,
                        overlayColor: AmanahColorTokens.brand.withValues(alpha: 0.20),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 5.5,
                          elevation: 2.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
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
