import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';

/// Molecule: Composes Title, Divider, and Description narrative
/// respecting Amanah typography and design tokens with staggered entrance choreography.
class AmanahResultTypographySection extends StatelessWidget {
  const AmanahResultTypographySection({
    required this.payload,
    required this.palette,
    super.key,
    this.progress = 1.0,
  });

  final PresenceStatusPayload payload;
  final PresenceResultPalette palette;
  final double progress;

  Widget _staggerWrap({
    required Widget child,
    required double start,
    required double duration,
  }) {
    final double raw = ((progress - start) / duration).clamp(0.0, 1.0);
    final double eased = Curves.easeOutCubic.transform(raw);

    return Transform.translate(
      offset: Offset(0, 16.0 * (1.0 - eased)),
      child: Opacity(
        opacity: eased,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // 1. Bold Title (Stagger 1: t=0.05..0.40)
        _staggerWrap(
          start: 0.05,
          duration: 0.35,
          child: Text(
            payload.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              height: 1.25,
              color: palette.title,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 3. Narrative Subtitle Description (Stagger 3: t=0.25..0.60)
        _staggerWrap(
          start: 0.25,
          duration: 0.35,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290.0),
            child: Text(
              payload.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: palette.subtitle,
              ),
            ),
          ),
        ),

        // 4. Optional Duration Suffix (Stagger 4: t=0.35..0.70)
        if (payload.durationHours != null && payload.durationHours! > 0) ...<Widget>[
          const SizedBox(height: 8),
          _staggerWrap(
            start: 0.35,
            duration: 0.35,
            child: Text(
              '${payload.durationHours!.toStringAsFixed(1)} Jam Durasi Dinas',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
                color: palette.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
