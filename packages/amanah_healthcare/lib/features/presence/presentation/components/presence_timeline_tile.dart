import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_drawers.dart';

/// Single item tile in the attendance presence vertical timeline.
class PresenceTimelineTile extends StatelessWidget {
  const PresenceTimelineTile({
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
        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
        : AmanahColorTokens.neutral300;
    Color iconBgColor = dark
        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
        : AmanahColorTokens.canvasLight;
    Color iconColor = subtextColor;
    Color titleColor = textColor;
    IconData iconData = Icons.login_rounded;
    Color lineColor = dark
        ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
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

/// Date tick label under the attendance distribution bar.
class PresenceDateTickText extends StatelessWidget {
  const PresenceDateTickText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AmanahColorTokens.neutral400,
      ),
    );
  }
}

/// Status legend indicator with colored dot and text label.
class PresenceLegendIndicator extends StatelessWidget {
  const PresenceLegendIndicator({
    required this.color,
    required this.label,
    super.key,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AmanahColorTokens.neutral500,
          ),
        ),
      ],
    );
  }
}
