import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_card_layers.dart';

class AmanahScheduleDetailDrawer extends StatelessWidget {
  const AmanahScheduleDetailDrawer({
    required this.schedule,
    required this.isDayCuti,
    required this.onViewPatients,
    required this.onTapEdit,
    required this.onTapDelete,
    super.key,
  });

  final DoctorSchedule schedule;
  final bool isDayCuti;
  final VoidCallback onViewPatients;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  static void show(
    BuildContext context, {
    required DoctorSchedule schedule,
    required bool isDayCuti,
    required VoidCallback onViewPatients,
    required VoidCallback onTapEdit,
    required VoidCallback onTapDelete,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahScheduleDetailDrawer(
        schedule: schedule,
        isDayCuti: isDayCuti,
        onViewPatients: onViewPatients,
        onTapEdit: onTapEdit,
        onTapDelete: onTapDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return AmanahBottomSheetScaffold(
      title: 'Detail Sesi Praktik',
      fixedHeightFactor: 0.85,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.xl,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahButton.primary(
        text: 'Edit Jadwal',
        isFullWidth: true,
        size: AmanahButtonSize.medium,
        onPressed: () {
          Navigator.of(context).pop();
          onTapEdit();
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title & Date Heading + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      schedule.title,
                      style: TextStyle(
                        color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral950,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      schedule.date,
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AmanahStatusBadge(
                text: isDayCuti ? 'Cuti' : schedule.badge,
                variant: isDayCuti
                    ? AmanahBadgeVariant.warning
                    : schedule.badgeVariant,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Specification Records List
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                      : AmanahColorTokens.neutral100,
                ),
                bottom: BorderSide(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                      : AmanahColorTokens.neutral100,
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                PatientSpecRow(
                  label: 'Sesi Praktik',
                  value: schedule.sessionType.isNotEmpty
                      ? 'Sesi ${schedule.sessionType}'
                      : schedule.title,
                  dark: dark,
                ),
                PatientSpecRow(
                  label: 'Jam Praktik',
                  value: schedule.time,
                  dark: dark,
                ),
                if (schedule.room != null && schedule.room!.trim().isNotEmpty)
                  PatientSpecRow(
                    label: 'Ruang Praktik',
                    value: schedule.room!,
                    dark: dark,
                  ),
                if (schedule.poli != null && schedule.poli!.trim().isNotEmpty)
                  PatientSpecRow(
                    label: 'Poli / Spesialisasi',
                    value: schedule.poli!,
                    dark: dark,
                  ),
                _SessionSpecTotalPatientsRow(
                  bookedCount: schedule.bookedPatients.length,
                  dark: dark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Stacked Avatars Trigger Bar (Lihat Pasien Booking)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                      : AmanahColorTokens.pureBlack.withValues(alpha: 0.06),
                ),
                bottom: BorderSide(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                      : AmanahColorTokens.pureBlack.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                onViewPatients();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        _StackedPatientAvatars(
                          patients: schedule.bookedPatients,
                          dark: dark,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Lihat Pasien Booking (${schedule.bookedPatients.length} Pasien)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: dark
                                  ? AmanahColorTokens.brandSoft
                                  : AmanahColorTokens.brandAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: dark
                        ? AmanahColorTokens.brandSoft
                        : AmanahColorTokens.brandAccent,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}

class _SessionSpecTotalPatientsRow extends StatelessWidget {
  const _SessionSpecTotalPatientsRow({
    required this.bookedCount,
    required this.dark,
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
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
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
                color: dark ? AmanahColorTokens.brandSoft : AmanahColorTokens.brandAccent,
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

class _StackedPatientAvatars extends StatelessWidget {
  const _StackedPatientAvatars({required this.patients, required this.dark});

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
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
              : AmanahColorTokens.neutral200,
          border: Border.all(
            color: dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.surfaceLight,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '0',
          style: TextStyle(
            color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral700,
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
                  color: dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.surfaceLight,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  p.avatarUrl ??
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stack) =>
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
                                      ? AmanahColorTokens.surfaceLight
                                      : AmanahColorTokens.neutral800,
                                ),
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
