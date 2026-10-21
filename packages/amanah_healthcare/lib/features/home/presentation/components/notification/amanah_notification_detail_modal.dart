import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_visual_role.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_clay_icon.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/presentation/screen/amanah_leave_permission_tab_screen.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/amanah_presence_history_screen.dart';

class AmanahNotificationDetailModal extends StatelessWidget {
  const AmanahNotificationDetailModal({super.key, required this.item});

  final AmanahNotificationItem item;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? dt = DateTime.tryParse(item.timestamp)?.toLocal();
    final String formattedSubtitle = dt != null
        ? '${formatLocalizedDate(dt, style: 'human_full')} • ${formatLocalizedTime(dt)} WIB'
        : item.timestamp;

    return AmanahBottomSheetScaffold(
      title: 'Detail notifikasi',
      subtitle: formattedSubtitle,
      hugContent: true,
      trailing: AmanahClayIcon(size: 36, tone: item.visual.tone, icon: item.visual.icon),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.desc,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
              height: 1.45,
            ),
          ),
          if (item.sourceType == 'leave' ||
              item.sourceType == 'replacement' ||
              item.actionUrl == '/permission') ...<Widget>[
            const SizedBox(height: 24),
            AmanahButton(
              text: 'Buka Modul Cuti & Pengganti',
              leadingIcon: Icons.calendar_month_rounded,
              isFullWidth: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(AmanahLeavePermissionTabScreen.route());
              },
            ),
          ] else if (item.sourceType == 'attendance') ...<Widget>[
            const SizedBox(height: 24),
            AmanahButton(
              text: 'Buka Riwayat Presensi',
              leadingIcon: Icons.history_rounded,
              isFullWidth: true,
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(AmanahPresenceHistoryScreen.route());
              },
            ),
          ],
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
