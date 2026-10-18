import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AttendanceProcessingOverlay extends StatelessWidget {
  const AttendanceProcessingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color surface =
        dark ? theme.colorScheme.surface : AmanahColorTokens.surfaceLight;
    final Color title =
        dark ? theme.colorScheme.onSurface : AmanahColorTokens.heading;
    final Color subtitle =
        dark ? theme.colorScheme.onSurfaceVariant : AmanahColorTokens.muted;
    final Color border = dark
        ? theme.colorScheme.outlineVariant.withValues(alpha: 0.34)
        : AmanahColorTokens.brandMuted;

    return AbsorbPointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AmanahColorTokens.pureBlack.withValues(alpha: 0.32),
        ),
        child: Center(
          child: Container(
            width: 248,
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AmanahColorTokens.pureBlack.withValues(
                    alpha: dark ? 0.42 : 0.18,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AmanahColorTokens.brand,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Memproses presensi Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: title,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'QR dikenali. Mengirim data ke sistem klinik.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: subtitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
