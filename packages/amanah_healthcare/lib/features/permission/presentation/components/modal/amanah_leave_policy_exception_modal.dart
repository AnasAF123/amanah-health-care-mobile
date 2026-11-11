import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/functions/format_localized_date.dart';
import 'package:amanah_healthcare/features/permission/domain/failures/permission_failure.dart';
import 'package:amanah_healthcare/features/presence/domain/entities/presence_status_payload.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/drawers/amanah_presence_result_drawer.dart';

/// Modal presenter for leave/permission policy exceptions.
///
/// Reuses the animated presence master drawer ([AmanahPresenceResultDrawer]) to present
/// policy outcomes (conflicts, limit reached, clinic closed) with 3D hexagon badge animations,
/// ambient ripples, human-readable Indonesian formatted dates, and zero text redundancy.
abstract final class AmanahLeavePolicyExceptionModal {
  static Future<void> show({
    required BuildContext context,
    required PermissionPolicyFailure failure,
  }) {
    final String cleanMessage = _formatMessageText(failure.message);

    final PresenceStatusPayload payload = PresenceStatusPayload(
      type: PresenceStatusType.outOfSchedule,
      title: failure.title,
      message: cleanMessage,
      actionLabel: 'Saya Mengerti',
    );

    return AmanahPresenceResultDrawer.show(
      context,
      payload: payload,
    );
  }

  static String _formatMessageText(String message) {
    return message.replaceAllMapped(
      RegExp(r'\b\d{4}-\d{2}-\d{2}\b'),
      (Match m) {
        final DateTime? d = DateTime.tryParse(m.group(0)!);
        if (d != null) {
          return formatLocalizedDate(d, style: 'human_short');
        }
        return m.group(0)!;
      },
    );
  }
}

