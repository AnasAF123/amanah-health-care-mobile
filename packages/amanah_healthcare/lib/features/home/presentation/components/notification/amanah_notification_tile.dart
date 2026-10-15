import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_notification_model.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_clay_icon.dart';
import 'package:amanah_healthcare/features/home/presentation/components/notification/amanah_notification_detail_modal.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahNotificationTile extends StatelessWidget {
  const AmanahNotificationTile({
    super.key,
    required this.item,
    required this.dark,
    required this.onTap,
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
              // Left Leading 3D ClayIcon + Urgent Badge
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

              // Middle Title + Desc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.isUnread
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: dark
                            ? AmanahColorTokens.surfaceLight
                            : AmanahColorTokens.neutral900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.desc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Right Time + Status Dot + Chevron
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
                            color: AmanahColorTokens.brandAccent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AmanahColorTokens.brandLight.withValues(
                                  alpha: 0.60,
                                ),
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
