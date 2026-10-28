import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_palette.dart';

class AmanahResultActions extends StatelessWidget {
  const AmanahResultActions({
    required this.payload,
    required this.palette,
    required this.onClose,
    this.onGoHome,
    this.onViewHistory,
    this.onSwitchToCheckIn,
    super.key,
  });

  final PresenceStatusPayload payload;
  final PresenceResultPalette palette;
  final VoidCallback onClose;
  final VoidCallback? onGoHome;
  final VoidCallback? onViewHistory;
  final VoidCallback? onSwitchToCheckIn;

  @override
  Widget build(BuildContext context) {
    if (payload.isSuccess) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AmanahButton.primary(
            text: 'Lihat Riwayat Absensi',
            isFullWidth: true,
            size: AmanahButtonSize.medium,
            onPressed: onViewHistory ?? onClose,
          ),
          const SizedBox(height: 8),
          AmanahButton.text(
            text: 'Selesai',
            customForegroundColor: palette.subtitle,
            onPressed: onGoHome ?? onClose,
          ),
        ],
      );
    }

    final VoidCallback actionPressed =
        (payload.type == PresenceStatusType.notCheckedIn && onSwitchToCheckIn != null)
        ? () {
            onClose();
            onSwitchToCheckIn!();
          }
        : onClose;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AmanahButton.primary(
          text: payload.actionLabel,
          isFullWidth: true,
          size: AmanahButtonSize.medium,
          onPressed: actionPressed,
        ),
      ],
    );
  }
}
