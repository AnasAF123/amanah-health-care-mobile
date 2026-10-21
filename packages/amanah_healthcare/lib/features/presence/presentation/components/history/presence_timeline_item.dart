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

    final String dateHeader = item.dayName.isNotEmpty ? '${item.dayName}, ${item.date}' : item.date;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(
                  child: Container(
                    width: item.isLatest ? 2 : 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Content Box: Space Between rows (compact and clean)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 1. Header: [ Hari, Tanggal <--- space-between ---> Shift ]
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          dateHeader,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: item.isLatest ? FontWeight.w700 : FontWeight.w600,
                          color: titleColor,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 2. Row Masuk: [ Masuk <--- space-between ---> Jam Masuk ]
                  if (item.checkInTimeFormatted != null) ...<Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                        Text(
                          item.checkInTimeFormatted!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // 3. Row Keluar: [ Keluar <--- space-between ---> Jam Keluar ]
                  if (item.checkOutTimeFormatted != null) ...<Widget>[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                        Text(
                          item.checkOutTimeFormatted!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // 4. Missing / Cuti details
                  if (item.checkInTimeFormatted == null &&
                      item.checkOutTimeFormatted == null &&
                      item.status != AttendanceStatus.cuti) ...<Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Keterangan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                        Text(
                          item.status == AttendanceStatus.missed
                              ? 'Tidak Tercatat Presensi'
                              : (item.notes?.isNotEmpty == true ? item.notes! : '-'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (item.status == AttendanceStatus.cuti) ...<Widget>[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Izin / Cuti Resmi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                        InkWell(
                          onTap: () => AmanahPresenceLeaveReasonDrawer.show(context, record: item),
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
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
