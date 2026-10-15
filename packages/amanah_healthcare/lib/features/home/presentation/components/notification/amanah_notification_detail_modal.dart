import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_visual_role.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_clay_icon.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahNotificationDetailModal extends StatelessWidget {
  const AmanahNotificationDetailModal({
    super.key,
    required this.item,
  });

  final AmanahNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return AmanahBottomSheetScaffold(
      title: 'Detail notifikasi',
      subtitle: '${item.timestamp} WIB',
      maxHeightFactor: 0.58,
      minHeight: 320,
      trailing: AmanahClayIcon(
        size: 36,
        tone: item.visual.tone,
        icon: item.visual.icon,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.category.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AmanahColorTokens.brandAccent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: dark
                  ? AmanahColorTokens.surfaceLight
                  : AmanahColorTokens.neutral900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.desc,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: dark
                  ? AmanahColorTokens.neutral400
                  : AmanahColorTokens.neutral600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

extension AmanahNotificationVisualResolver on AmanahNotificationVisual {
  AmanahIconTone get tone {
    switch (this) {
      case AmanahNotificationVisual.queueVitals:
        return AmanahIconTone.queue;
      case AmanahNotificationVisual.clinicalCritical:
        return AmanahIconTone.clinicalCritical;
      case AmanahNotificationVisual.clinicalConsult:
        return AmanahIconTone.clinicalConsult;
      case AmanahNotificationVisual.shiftSchedule:
        return AmanahIconTone.shift;
      case AmanahNotificationVisual.clinicalReport:
        return AmanahIconTone.documents;
      case AmanahNotificationVisual.shiftReminder:
        return AmanahIconTone.success;
    }
  }

  IconData get icon {
    switch (this) {
      case AmanahNotificationVisual.queueVitals:
        return Icons.monitor_heart_outlined;
      case AmanahNotificationVisual.clinicalCritical:
        return Icons.error_outline_rounded;
      case AmanahNotificationVisual.clinicalConsult:
        return Icons.chat_bubble_outline_rounded;
      case AmanahNotificationVisual.shiftSchedule:
        return Icons.calendar_today_outlined;
      case AmanahNotificationVisual.clinicalReport:
        return Icons.description_outlined;
      case AmanahNotificationVisual.shiftReminder:
        return Icons.access_time_rounded;
    }
  }
}
