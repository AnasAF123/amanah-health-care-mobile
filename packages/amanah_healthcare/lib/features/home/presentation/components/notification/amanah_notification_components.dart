import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_visual_role.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_clay_icon.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahNotificationTile extends StatelessWidget {
  const AmanahNotificationTile({
    required this.item,
    required this.dark,
    required this.onTap,
    super.key,
  });

  final AmanahNotificationItem item;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  AmanahClayIcon(
                    size: 32,
                    tone: item.visual.tone,
                    icon: item.visual.icon,
                  ),
                  if (item.isUrgent)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AmanahColorTokens.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: dark
                                ? AmanahColorTokens.canvasDark
                                : AmanahColorTokens.surfaceLight,
                            width: 1.8,
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AmanahColorTokens.danger.withValues(
                                alpha: 0.60,
                              ),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: item.isUnread
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: item.isUnread
                            ? (dark
                                  ? AmanahColorTokens.pureWhite
                                  : AmanahColorTokens.neutral900)
                            : (dark
                                  ? AmanahColorTokens.neutral300
                                  : AmanahColorTokens.neutral700),
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AmanahColorTokens.neutral400,
                        ),
                      ),
                      if (item.isUnread) ...<Widget>[
                        const SizedBox(height: 4),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dark
                                ? AmanahColorTokens.cyanAccent
                                : AmanahColorTokens.brandAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: (dark
                                        ? AmanahColorTokens.cyanAccent
                                        : AmanahColorTokens.brandLight)
                                    .withValues(alpha: 0.60),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AmanahColorTokens.neutral400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AmanahNotificationOptionsMenu extends StatelessWidget {
  const AmanahNotificationOptionsMenu({
    required this.onMarkAllRead,
    required this.onClearRead,
    required this.dark,
    super.key,
  });

  final VoidCallback onMarkAllRead;
  final VoidCallback onClearRead;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 20,
        color: dark
            ? AmanahColorTokens.neutral200
            : AmanahColorTokens.neutral600,
      ),
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 220),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AmanahThemeTokens.elevatedSurface(context),
      elevation: 12,
      onSelected: (String value) {
        if (value == 'mark_all') {
          onMarkAllRead();
        } else if (value == 'clear_read') {
          onClearRead();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'mark_all',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.done_all_rounded,
                size: 18,
                color: dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brandAccent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tandai Semua Dibaca',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'clear_read',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: AmanahColorTokens.danger,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Bersihkan Terbaca',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: dark
                        ? AmanahColorTokens.dangerBorder
                        : AmanahColorTokens.dangerDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AmanahNotificationDetailModal extends StatelessWidget {
  const AmanahNotificationDetailModal({required this.item, super.key});

  final AmanahNotificationItem item;

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: AmanahSpacing.sm),
          Text(
            item.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AmanahThemeTokens.textPrimary(context),
              height: 1.25,
            ),
          ),
          const SizedBox(height: AmanahSpacing.lg),
          Text(
            item.desc,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AmanahThemeTokens.textSecondary(context),
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
