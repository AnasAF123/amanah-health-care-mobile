import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_card_widgets.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_ticket_card_shell.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_schedule_card_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

export 'package:amanah_healthcare/features/home/presentation/components/amanah_ticket_card_shell.dart';

/// Molecule: Single Doctor Schedule Card with 3D crystal architecture texture,
/// C-notch silhouette, liquid glass gradient, dashed perforated line, and tokenized typography.
/// Encapsulated using [AmanahTicketCardShell] and respecting [TimeService] formatting.
class AmanahScheduleCard extends StatelessWidget {
  const AmanahScheduleCard({
    required this.schedule,
    required this.onDismiss,
    this.onCardTap,
    this.timeService,
    super.key,
  });

  final DoctorSchedule schedule;
  final VoidCallback onDismiss;
  final VoidCallback? onCardTap;
  final TimeService? timeService;

  String _formatPatientCount() {
    return '${schedule.bookedPatients.length} Pasien';
  }

  String _formatDate(TimeService ts) {
    final DateTime? parsed = parseIsoDateString(schedule.date);
    if (parsed != null) {
      return ts.formatDate(parsed, style: 'human_full');
    }
    return schedule.date;
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final TimeService ts = timeService ?? DefaultTimeService();
    final String primaryTitle = schedule.title.startsWith('Jadwal')
        ? schedule.title
        : 'Jadwal Hari Ini';
    final String sessionLabel = schedule.sessionType.isNotEmpty
        ? 'Sesi ${schedule.sessionType}'
        : (!schedule.title.startsWith('Jadwal') ? schedule.title : '');

    final String displayDate = _formatDate(ts);

    return AmanahTicketCardShell(
      height: AmanahScheduleCardTokens.cardHeight,
      onTap: onCardTap,
      semanticsLabel: 'Jadwal Hari Ini, ${schedule.title}, ${schedule.time}',
      child: Padding(
        padding: AmanahScheduleCardTokens.padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Top Header: Schedule Title, Session Label, Date & Dismiss Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              primaryTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                                height: 1.15,
                                color: dark
                                    ? AmanahScheduleCardTokens.titleColorDark
                                    : AmanahScheduleCardTokens.titleColorLight,
                              ),
                            ),
                          ),
                          if (sessionLabel.isNotEmpty) ...<Widget>[
                            Container(
                              width: 1.5,
                              height: 11,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : AmanahColorTokens.neutral300,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                sessionLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: dark
                                      ? AmanahColorTokens.cyanAccent
                                      : AmanahColorTokens.brand,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: dark
                              ? AmanahScheduleCardTokens.dateColorDark
                              : AmanahScheduleCardTokens.dateColorLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AmanahDismissButton(onTap: onDismiss),
              ],
            ),

            // Center Row: Compact Primary Time
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                schedule.time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  height: 1.0,
                  color: dark
                      ? AmanahScheduleCardTokens.timeColorDark
                      : AmanahScheduleCardTokens.timeColorLight,
                ),
              ),
            ),

            // Footer Row: Poli & Room info on left, Booking Pill on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                // Left: Poli & Room description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (schedule.poli != null &&
                          schedule.poli!.trim().isNotEmpty)
                        Text(
                          schedule.poli!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            color: dark
                                ? AmanahScheduleCardTokens.poliColorDark
                                : AmanahScheduleCardTokens.poliColorLight,
                          ),
                        ),
                      if (schedule.room != null &&
                          schedule.room!.trim().isNotEmpty) ...<Widget>[
                        if (schedule.poli != null &&
                            schedule.poli!.trim().isNotEmpty)
                          const SizedBox(height: 2),
                        Text(
                          schedule.room!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            height: 1.15,
                            color: dark
                                ? AmanahScheduleCardTokens.roomColorDark
                                : AmanahScheduleCardTokens.roomColorLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Right: Clean Integrated Booking Pill
                Flexible(
                  flex: 0,
                  child: AmanahBookingPill(
                    patientCount: _formatPatientCount(),
                    statusText: 'Terdaftar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
