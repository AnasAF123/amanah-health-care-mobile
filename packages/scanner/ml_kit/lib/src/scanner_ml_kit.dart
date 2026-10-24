import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:scanner_ml_kit/src/mobile_scanner_controller.dart';
import 'package:scanner_shared/scanner_shared.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Scanner implementation using ML Kit
class ScannerMLKit extends Scanner {
  const ScannerMLKit();

  @override
  String getType() => 'ML Kit';

  @override
  Widget getScanner({
    required Future<bool> Function(String) onScan,
    required Future<void> Function() hapticFeedback,
    required Function(BuildContext)? onCameraFlashError,
    required Function(String msg, String category, {int? eventValue, String? barcode})
    trackCustomEvent,
    required bool hasMoreThanOneCamera,
    required Widget barcodeScannerIcon,
    required Widget torchOnIcon,
    required Widget torchOffIcon,
    Color? visorColor,
    String? toggleCameraModeTooltip,
    String? toggleFlashModeTooltip,
    EdgeInsetsGeometry? contentPadding,
    void Function(ScannerHardwareController controller)? onScannerCreated,
    bool showDefaultVisor = true,
    bool showDefaultBottomControls = true,
  }) {
    return _SmoothBarcodeScannerMLKit(
      onScan: onScan,
      hapticFeedback: hapticFeedback,
      trackCustomEvent: trackCustomEvent,
      onCameraFlashError: onCameraFlashError,
      hasMoreThanOneCamera: hasMoreThanOneCamera,
      toggleCameraModeTooltip: toggleCameraModeTooltip,
      toggleFlashModeTooltip: toggleFlashModeTooltip,
      barcodeScannerIcon: barcodeScannerIcon,
      torchOnIcon: torchOnIcon,
      torchOffIcon: torchOffIcon,
      visorColor: visorColor,
      contentPadding: contentPadding,
      onScannerCreated: onScannerCreated,
      showDefaultVisor: showDefaultVisor,
      showDefaultBottomControls: showDefaultBottomControls,
    );
  }
}

/// Barcode scanner based on MLKit.
class _SmoothBarcodeScannerMLKit extends StatefulWidget {
  const _SmoothBarcodeScannerMLKit({
    required this.onScan,
    required this.hapticFeedback,
    required this.trackCustomEvent,
    required this.onCameraFlashError,
    required this.hasMoreThanOneCamera,
    required this.barcodeScannerIcon,
    required this.torchOnIcon,
    required this.torchOffIcon,
    this.visorColor,
    this.toggleCameraModeTooltip,
    this.toggleFlashModeTooltip,
    this.contentPadding,
    this.onScannerCreated,
    this.showDefaultVisor = true,
    this.showDefaultBottomControls = true,
  });

  final Future<bool> Function(String) onScan;
  final Future<void> Function() hapticFeedback;

  final Function(String msg, String category, {int? eventValue, String? barcode}) trackCustomEvent;
  final Function(BuildContext)? onCameraFlashError;
  final bool hasMoreThanOneCamera;

  final Widget barcodeScannerIcon;
  final Widget torchOnIcon;
  final Widget torchOffIcon;
  final Color? visorColor;

  final EdgeInsetsGeometry? contentPadding;
  final String? toggleCameraModeTooltip;
  final String? toggleFlashModeTooltip;
  final void Function(ScannerHardwareController controller)? onScannerCreated;
  final bool showDefaultVisor;
  final bool showDefaultBottomControls;

  @override
  State<StatefulWidget> createState() => _SmoothBarcodeScannerMLKitState();
}

class _SmoothBarcodeScannerMLKitState extends State<_SmoothBarcodeScannerMLKit>
    with SingleTickerProviderStateMixin {
  static const List<BarcodeFormat> _barcodeFormats = <BarcodeFormat>[BarcodeFormat.qrCode];

  static const ValueKey<String> _visibilityKey = ValueKey<String>('VisibilityDetector');

  late CustomScannerController _cameraController;
  late final AppLifecycleListener _lifecycleListener;
  bool _screenVisible = false;

  @override
  void initState() {
    super.initState();

    _cameraController = CustomScannerController(
      controller: MobileScannerController(
        autoStart: true,
        torchEnabled: false,
        formats: _barcodeFormats,
        facing: CameraFacing.back,
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 150,
        cameraResolution: const Size(1280, 720),
        returnImage: false,
      ),
    );
    _lifecycleListener = AppLifecycleListener(onPause: _onPause, onResume: _onResume);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onScannerCreated?.call(_cameraController);
      _cameraController.start();
    });
  }

  static Barcode? _pickBestBarcode(List<Barcode> barcodes) {
    if (barcodes.isEmpty) return null;
    Barcode? best;
    double maxArea = -1;
    for (final Barcode b in barcodes) {
      final String? val = b.rawValue ?? b.displayValue;
      if (val == null || val.trim().isEmpty) continue;
      final double area = (b.size.width > 0 && b.size.height > 0)
          ? b.size.width * b.size.height
          : 1.0;
      if (area > maxArea) {
        maxArea = area;
        best = b;
      }
    }
    return best;
  }

  Future<void> _onResume() async {
    if (_screenVisible) {
      return _cameraController.start();
    }
  }

  Future<void> _onPause() => _cameraController.stop();

  @override
  Widget build(BuildContext context) {
    return Provider<CustomScannerController>.value(
      value: _cameraController,
      child: VisibilityDetector(
        key: _visibilityKey,
        onVisibilityChanged: (final VisibilityInfo info) async {
          _screenVisible = info.visibleFraction > 0;
          _onScreenVisibilityChanged(_screenVisible);
        },
        child: Stack(
          children: <Widget>[
            MobileScanner(
              controller: _cameraController.controller,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, MobileScannerException error, Widget? child) {
                debugPrint(
                  '[MobileScanner] Camera error: ${error.errorCode} - ${error.errorDetails?.message}',
                );
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Icon(Icons.camera_alt_outlined, color: Colors.amber, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          'Kamera tidak dapat dimulai (${error.errorCode.name})',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _cameraController.start(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              },
              onDetect: (final BarcodeCapture capture) async {
                final Barcode? best = _pickBestBarcode(capture.barcodes);
                final String? string = best?.rawValue ?? best?.displayValue;
                if (string != null && string.trim().isNotEmpty) {
                  await widget.onScan(string.trim());
                }
              },
            ),
            if (widget.showDefaultVisor)
              Center(
                child: SmoothBarcodeScannerVisor(
                  icon: widget.barcodeScannerIcon,
                  contentPadding: widget.contentPadding,
                  color: widget.visorColor ?? Colors.white,
                ),
              ),
            if (widget.showDefaultBottomControls)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: SmoothBarcodeScannerVisor.CORNER_PADDING,
                    end: SmoothBarcodeScannerVisor.CORNER_PADDING,
                    bottom:
                        SmoothBarcodeScannerVisor.CORNER_PADDING +
                        MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _ToggleCameraIcon(
                        toggleCameraModeTooltip: widget.toggleCameraModeTooltip,
                        hapticFeedback: widget.hapticFeedback,
                      ),
                      _TorchIcon(
                        torchOnIcon: widget.torchOnIcon,
                        torchOffIcon: widget.torchOffIcon,
                        toggleFlashModeTooltip: widget.toggleFlashModeTooltip,
                        hapticFeedback: widget.hapticFeedback,
                        onCameraFlashError: widget.onCameraFlashError,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onScreenVisibilityChanged(bool visible) {
    if (visible) {
      _cameraController.start();
    } else {
      _cameraController.stop();
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _cameraController.dispose();
    super.dispose();
  }
}

class _TorchIcon extends StatefulWidget {
  const _TorchIcon({
    required this.hapticFeedback,
    required this.onCameraFlashError,
    required this.torchOnIcon,
    required this.torchOffIcon,
    this.toggleFlashModeTooltip,
  });

  final Widget torchOnIcon;
  final Widget torchOffIcon;

  final String? toggleFlashModeTooltip;
  final Future<void> Function() hapticFeedback;
  final Function(BuildContext)? onCameraFlashError;

  @override
  State<_TorchIcon> createState() => _TorchIconState();
}

class _TorchIconState extends State<_TorchIcon> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: context.watch<CustomScannerController>().hasTorchState,
      builder: (BuildContext context, bool? hasTorch, _) {
        if (hasTorch == null) {
          return EMPTY_WIDGET;
        }

        final CustomScannerController controller = context.watch<CustomScannerController>();
        final bool isTorchOn = controller.isTorchOn;

        return VisorButton(
          tooltip: widget.toggleFlashModeTooltip ?? 'Turn ON or OFF the flash of the camera',
          onTap: () async {
            widget.hapticFeedback.call();

            try {
              context.read<CustomScannerController>().toggleTorch();
            } catch (err) {
              if (context.mounted) {
                widget.onCameraFlashError?.call(context);
              }
            }
          },
          child: switch (isTorchOn) {
            true => widget.torchOnIcon,
            false => widget.torchOffIcon,
          },
        );
      },
    );
  }
}

class _ToggleCameraIcon extends StatelessWidget {
  const _ToggleCameraIcon({required this.hapticFeedback, this.toggleCameraModeTooltip});

  final Future<void> Function() hapticFeedback;
  final String? toggleCameraModeTooltip;

  @override
  Widget build(BuildContext context) {
    final CustomScannerController controller = context.watch<CustomScannerController>();

    return ValueListenableBuilder<int>(
      valueListenable: controller.availableCameras,
      builder: (BuildContext context, int cameras, _) {
        if (cameras <= 1) {
          return EMPTY_WIDGET;
        }

        return VisorButton(
          onTap: () async {
            hapticFeedback.call();
            await controller.toggleCamera();
          },
          tooltip: toggleCameraModeTooltip ?? 'Switch between back and front camera',
          child: ValueListenableBuilder<CameraFacing>(
            valueListenable: controller.cameraFacing,
            builder: (BuildContext context, CameraFacing state, Widget? child) {
              return switch (state) {
                CameraFacing.front => const Icon(Icons.camera_front),
                CameraFacing.back => const Icon(Icons.camera_rear),
              };
            },
          ),
        );
      },
    );
  }
}
