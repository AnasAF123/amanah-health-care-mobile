import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/helpers/permission_helper.dart';

class CameraPermissionViewport extends StatefulWidget {
  const CameraPermissionViewport({
    super.key,
    required this.status,
    required this.onRequestPermission,
  });

  final DevicePermissionStatus status;
  final VoidCallback onRequestPermission;

  @override
  State<CameraPermissionViewport> createState() =>
      _CameraPermissionViewportState();
}

class _CameraPermissionViewportState extends State<CameraPermissionViewport> {
  @override
  void initState() {
    super.initState();
    if (widget.status == DevicePermissionStatus.unknown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onRequestPermission();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == DevicePermissionStatus.checking) {
      return const ColoredBox(
        color: AmanahColorTokens.canvasDark,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return ColoredBox(
      color: AmanahColorTokens.canvasDark,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.photo_camera_outlined,
                size: 40,
                color: AmanahColorTokens.surfaceLight,
              ),
              const SizedBox(height: 12),
              const Text(
                'Izin kamera diperlukan untuk presensi QR.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AmanahColorTokens.surfaceLight,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: widget.onRequestPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AmanahColorTokens.brandAccent,
                  foregroundColor: AmanahColorTokens.surfaceLight,
                  elevation: 0,
                ),
                child: const Text(
                  'Aktifkan Kamera',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
