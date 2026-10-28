import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_painters.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';

class AmanahResultEmblem extends StatelessWidget {
  const AmanahResultEmblem({
    required this.palette,
    required this.iconProgress,
    super.key,
  });

  final PresenceResultPalette palette;
  final double iconProgress;

  @override
  Widget build(BuildContext context) {
    final double outlineProgress = (iconProgress / 0.50).clamp(0.0, 1.0);
    final double fillProgress = ((iconProgress - 0.35) / 0.50).clamp(0.0, 1.0);
    final double fillScale = Curves.easeOutBack.transform(fillProgress);
    final double iconScale = ((iconProgress - 0.55) / 0.45).clamp(0.0, 1.0);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomPaint(
            painter: ResultEmblemPainter(
              palette: palette,
              outlineProgress: outlineProgress,
              fillScale: fillScale,
            ),
          ),
          if (iconScale > 0.05)
            Center(
              child: Transform.scale(
                scale: Curves.easeOutBack.transform(iconScale),
                child: Icon(palette.iconData, size: 38, color: palette.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
