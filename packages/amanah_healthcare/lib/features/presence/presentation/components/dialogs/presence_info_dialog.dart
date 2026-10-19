import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Modal dialog presented when attendance status conflicts, requires attention,
/// or reports an error (with a single 'Saya Mengerti' action).
class PresenceInfoDialog extends StatelessWidget {
  const PresenceInfoDialog({
    required this.message,
    super.key,
  });

  final String message;

  static Future<void> show(BuildContext context, {required String message}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PresenceInfoDialog(message: message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AmanahColorTokens.canvasDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.15),
        ),
      ),
      title: const Row(
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            color: AmanahColorTokens.warning,
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Informasi Presensi',
              style: TextStyle(
                color: AmanahColorTokens.surfaceLight,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.85),
          fontSize: 14,
          height: 1.4,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Saya Mengerti',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AmanahColorTokens.brand,
            ),
          ),
        ),
      ],
    );
  }
}

/// Help modal guide for QR attendance and manual PIN.
class PresenceHelpDialog extends StatelessWidget {
  const PresenceHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PresenceHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: <Widget>[
          Icon(
            Icons.help_outline_rounded,
            color: AmanahColorTokens.brandPrimary,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Panduan Presensi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: const Text(
        'Arahkan kamera smartphone ke QR Code presensi dinas RS Amanah Sehat, atau gunakan Presensi Manual dengan kode 6-digit.',
        style: TextStyle(fontSize: 13, height: 1.4),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Mengerti',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AmanahColorTokens.brandPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
