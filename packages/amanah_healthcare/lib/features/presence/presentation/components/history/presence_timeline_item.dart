import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_drawers.dart';

class PresenceTimelineItem extends StatelessWidget {
  const PresenceTimelineItem({
    required this.item,
    required this.isLast,
    required this.dark,
    required this.textColor,
    required this.subtextColor,
    super.key,
  });

  final AttendanceRecord item;
  final bool isLast;
  final bool dark;
  final Color textColor;
  final Color subtextColor;

  @override
  Widget build(BuildContext context) {
    Color iconBorderColor = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
        : AmanahColorTokens.neutral300;
    Color iconBgColor = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
        : AmanahColorTokens.canvasLight;
    Color iconColor = subtextColor;
    Color titleColor = textColor;
    IconData iconData = Icons.login_rounded;
    Color lineColor = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
        : AmanahColorTokens.neutral300;

    if (item.isLatest) {
      switch (item.status) {
        case AttendanceStatus.hadir:
          iconBorderColor = AmanahColorTokens.successDark;
          iconBgColor = AmanahColorTokens.successSurface;
          iconColor = AmanahColorTokens.successDark;
          titleColor = AmanahColorTokens.successDark;
          iconData = Icons.login_rounded;
          lineColor = AmanahColorTokens.success;
        case AttendanceStatus.telat:
          iconBorderColor = AmanahColorTokens.warningDark;
          iconBgColor = AmanahColorTokens.warningSurface;
          iconColor = AmanahColorTokens.warningDark;
          titleColor = AmanahColorTokens.warningDark;
          iconData = Icons.schedule_rounded;
          lineColor = AmanahColorTokens.amberLight;
        case AttendanceStatus.missed:
          iconBorderColor = AmanahColorTokens.dangerDark;
          iconBgColor = AmanahColorTokens.dangerSurface;
          iconColor = AmanahColorTokens.dangerDark;
          titleColor = AmanahColorTokens.dangerDark;
          iconData = Icons.close_rounded;
          lineColor = AmanahColorTokens.danger;
        case AttendanceStatus.cuti:
          iconBorderColor = AmanahColorTokens.violetDark;
          iconBgColor = AmanahColorTokens.violetSurface;
          iconColor = AmanahColorTokens.violetDark;
          titleColor = AmanahColorTokens.violetDark;
          iconData = Icons.event_note_rounded;
          lineColor = AmanahColorTokens.violet;
      }
    } else {
      switch (item.status) {
        case AttendanceStatus.hadir:
          iconData = Icons.login_rounded;
        case AttendanceStatus.telat:
          iconData = Icons.schedule_rounded;
        case AttendanceStatus.missed:
          iconData = Icons.close_rounded;
        case AttendanceStatus.cuti:
          iconData = Icons.event_note_rounded;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Left timeline node & connecting line
        Column(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                border: Border.all(color: iconBorderColor, width: 2),
              ),
              child: Icon(iconData, size: 14, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: item.isLatest ? 2 : 1.5,
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: lineColor,
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Date Column (85px)
        SizedBox(
          width: 85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 4),
              Text(
                item.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),

        // Right details Column (Text aligned right)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  item.title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: item.isLatest
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: titleColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.location,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: subtextColor,
                    height: 1.2,
                  ),
                ),
                if (item.status == AttendanceStatus.cuti) ...<Widget>[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => AmanahPresenceLeaveReasonDrawer.show(
                      context,
                      record: item,
                    ),
                    child: const Text(
                      'Lihat Alasan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AmanahColorTokens.violetDark,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
