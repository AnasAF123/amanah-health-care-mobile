import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/cards/card_decoration_layers.dart';

class SessionDetailStatusBadge extends StatelessWidget {
  const SessionDetailStatusBadge({
    required this.isDayCuti,
    required this.isSessionExpired,
    required this.schedule,
    required this.dark,
    super.key,
  });

  final bool isDayCuti;
  final bool isSessionExpired;
  final DoctorSchedule schedule;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final String label = isDayCuti
        ? ScheduleFormConstants.statusCuti
        : (isSessionExpired
            ? ScheduleFormConstants.badgeSelesai
            : schedule.badge);
    final Color toneColor = isDayCuti
        ? AmanahColorTokens.warning
        : (isSessionExpired
            ? (dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500)
            : scheduleBadgeTone(schedule.badgeVariant).primary);
    final Color bgColor = isDayCuti
        ? AmanahColorTokens.warning.withValues(alpha: 0.20)
        : (isSessionExpired
            ? (dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                : AmanahColorTokens.neutral200)
            : toneColor.withValues(alpha: 0.16));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(color: toneColor, shape: BoxShape.circle),
            child: const SizedBox(width: 6, height: 6),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: toneColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class SessionSpecTotalPatientsRow extends StatelessWidget {
  const SessionSpecTotalPatientsRow({
    required this.bookedCount,
    required this.dark,
    super.key,
  });

  final int bookedCount;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                : AmanahColorTokens.neutral100,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Total Pasien Booking',
            style: TextStyle(
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$bookedCount Pasien',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brandAccent,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StackedPatientAvatars extends StatelessWidget {
  const StackedPatientAvatars({
    required this.patients,
    required this.dark,
    super.key,
  });

  final List<BookedPatient> patients;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (patients.isEmpty) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
              : AmanahColorTokens.neutral200,
          border: Border.all(
            color: dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.pureWhite,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '0',
          style: TextStyle(
            color: dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.neutral700,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final List<BookedPatient> top3 = patients.take(3).toList();
    final double stackWidth = 24.0 + (top3.length - 1) * 16.0;

    return SizedBox(
      width: stackWidth,
      height: 24,
      child: Stack(
        children: List<Widget>.generate(top3.length, (int i) {
          final BookedPatient p = top3[i];
          return Positioned(
            left: i * 16.0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral200,
                border: Border.all(
                  color: dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.pureWhite,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                    ? Image.network(
                        p.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
                            ColoredBox(
                              color: dark
                                  ? AmanahColorTokens.neutral700
                                  : AmanahColorTokens.neutral300,
                              child: Center(
                                child: Text(
                                  p.patientName.isNotEmpty
                                      ? p.patientName.substring(0, 1)
                                      : 'P',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: dark
                                        ? AmanahColorTokens.pureWhite
                                        : AmanahColorTokens.neutral800,
                                  ),
                                ),
                              ),
                            ),
                      )
                    : ColoredBox(
                        color: dark
                            ? AmanahColorTokens.neutral700
                            : AmanahColorTokens.neutral300,
                        child: Center(
                          child: Text(
                            p.patientName.isNotEmpty
                                ? p.patientName.substring(0, 1)
                                : 'P',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: dark
                                  ? AmanahColorTokens.pureWhite
                                  : AmanahColorTokens.neutral800,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
