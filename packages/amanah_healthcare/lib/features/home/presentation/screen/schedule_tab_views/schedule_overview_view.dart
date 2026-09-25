import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/amanah_presence_history_screen.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_components.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart';

class AmanahScheduleOverviewView extends StatelessWidget {
  const AmanahScheduleOverviewView({
    required this.selectedDate,
    required this.daySetting,
    required this.isCuti,
    required this.schedules,
    required this.bookedPatients,
    required this.capacityPercentage,
    required this.dark,
    required this.onSelectDate,
    required this.onOpenSessionsView,
    required this.onOpenAddSchedule,
    required this.formatDateSubtitle,
    super.key,
  });

  final DateTime selectedDate;
  final DayScheduleSetting daySetting;
  final bool isCuti;
  final List<DoctorSchedule> schedules;
  final List<({BookedPatient patient, DoctorSchedule schedule})> bookedPatients;
  final int capacityPercentage;
  final bool dark;
  final ValueChanged<DateTime> onSelectDate;
  final VoidCallback onOpenSessionsView;
  final VoidCallback onOpenAddSchedule;
  final String Function(DateTime) formatDateSubtitle;

  @override
  Widget build(BuildContext context) {
    final int totalScheduleCapacity = schedules.fold<int>(
      0,
      (int sum, DoctorSchedule s) => sum + s.capacity,
    );
    final int effectiveTotalSlots = totalScheduleCapacity > 0
        ? totalScheduleCapacity
        : (daySetting.targetQuota > 0 ? daySetting.targetQuota : 0);
    final int effectiveCapacityPercentage = effectiveTotalSlots > 0
        ? ((bookedPatients.length / effectiveTotalSlots) * 100).round().clamp(0, 100)
        : (isCuti ? 0 : capacityPercentage);

    final List<({BookedPatient patient, DoctorSchedule schedule})> activePatients =
        bookedPatients.where((item) {
      if (item.patient.isCompleted || item.patient.isCancelled) {
        return false;
      }
      final bool isExpired = isTemporalSlotPast(
        scheduleDateStr: item.schedule.scheduleDate ?? item.schedule.date,
        timeSlotOrEndTime: item.patient.timeSlot,
      );
      return !isExpired;
    }).toList();

    final List<({BookedPatient patient, DoctorSchedule schedule})> completedPatients =
        bookedPatients.where((item) {
      if (item.patient.isCompleted || item.patient.isCancelled) {
        return true;
      }
      return isTemporalSlotPast(
        scheduleDateStr: item.schedule.scheduleDate ?? item.schedule.date,
        timeSlotOrEndTime: item.patient.timeSlot,
      );
    }).toList();

    return Column(
      key: const ValueKey<String>('view-overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top Row: Radial Capacity Gauge & Lihat Schedule Trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: AmanahRadialCapacityGauge(
                capacityPercentage: effectiveCapacityPercentage,
                bookedCount: bookedPatients.length,
                totalSlots: effectiveTotalSlots,
                isCuti: isCuti,
                onTapInfo: () {
                  AmanahScheduleCapacityInfoDrawer.show(
                    context,
                    bookedCount: bookedPatients.length,
                    totalSlots: effectiveTotalSlots,
                    schedules: schedules,
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            AmanahButton.text(
              text: 'Lihat jadwal',
              trailingIcon: Icons.chevron_right_rounded,
              size: AmanahButtonSize.small,
              customForegroundColor: dark
                  ? AmanahColorTokens.tabActiveDark
                  : AmanahColorTokens.brand,
              onPressed: () {
                AmanahDocScheduleCalendarDrawer.show(
                  context,
                  selectedDate: selectedDate,
                  baseToday: AmanahScheduleStore.baseToday,
                  onSelectDate: (DateTime d) {
                    onSelectDate(d);
                    onOpenSessionsView();
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Date Carousel Strip
        AmanahDateCarouselStrip(
          selectedDate: selectedDate,
          baseToday: AmanahScheduleStore.baseToday,
          onSelectDate: onSelectDate,
          onDateTap: (DateTime d) {
            onSelectDate(d);
            onOpenSessionsView();
          },
          hasSchedulesForDate: (DateTime d) =>
              AmanahScheduleStore.instance.getSchedulesForDate(d).isNotEmpty,
          isCutiForDate: (DateTime d) =>
              AmanahScheduleStore.instance.getDaySettingForDate(d).isCuti,
        ),
        const SizedBox(height: 12),

        // Section Title: Date & Patient Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                formatDateSubtitle(selectedDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.neutral400
                      : AmanahColorTokens.neutral500,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              activePatients.isNotEmpty
                  ? '${activePatients.length} Pasien Aktif'
                  : '${bookedPatients.length} Pasien Booking',
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral500,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Showcase Pasien Booking Cards
        if (activePatients.isNotEmpty) ...<Widget>[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activePatients.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              final ({BookedPatient patient, DoctorSchedule schedule}) item =
                  activePatients[index];
              return AmanahBookedPatientCard(
                patient: item.patient,
                schedule: item.schedule,
                imageIndex: index,
                onTapDetail: () {
                  AmanahPatientDetailModal.show(
                    context,
                    item.patient,
                    item.schedule,
                  );
                },
              );
            },
          ),
          if (completedPatients.isNotEmpty)
            _buildCompletedPatientsBanner(context, dark, completedPatients.length),
        ] else if (completedPatients.isNotEmpty) ...<Widget>[
          _buildAllCompletedEmptyState(
            context,
            dark,
            completedPatients.length,
          ),
        ] else
          AmanahEmptyState.box(
            title: 'Belum Ada Pasien Booking',
            message: isCuti
                ? 'Dokter sedang cuti pada tanggal ini.'
                : 'Belum ada pasien yang mendaftar pada sesi praktik di tanggal ini.',
            actionText: 'Tambah Jadwal',
            actionLeadingIcon: Icons.add_rounded,
            onAction: onOpenAddSchedule,
            secondaryActionText: 'Lihat Sesi Dokter',
            secondaryActionLeadingIcon: Icons.calendar_month_outlined,
            onSecondaryAction: onOpenSessionsView,
          ),
      ],
    );
  }

  Widget _buildCompletedPatientsBanner(
    BuildContext context,
    bool dark,
    int count,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.surfaceDark
            : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
              : AmanahColorTokens.neutral200,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AmanahColorTokens.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AmanahColorTokens.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$count Pasien Selesai',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: dark
                        ? AmanahColorTokens.pureWhite
                        : AmanahColorTokens.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Konsultasi telah selesai atau melewati jam praktik.',
                  style: TextStyle(
                    fontSize: 11,
                    color: dark
                        ? AmanahColorTokens.neutral400
                        : AmanahColorTokens.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AmanahButton.secondary(
            text: 'Riwayat',
            trailingIcon: Icons.chevron_right_rounded,
            size: AmanahButtonSize.small,
            onPressed: () {
              Navigator.of(context).push(
                AmanahPresenceHistoryScreen.route(initialTab: 1),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllCompletedEmptyState(
    BuildContext context,
    bool dark,
    int count,
  ) {
    return Column(
      children: <Widget>[
        AmanahEmptyState.box(
          title: 'Semua Konsultasi Selesai',
          message:
              'Sebanyak $count pasien pada tanggal ini telah selesai berkonsultasi atau melewati waktu praktik.',
          actionText: 'Lihat Riwayat Pasien',
          actionLeadingIcon: Icons.history_rounded,
          onAction: () {
            Navigator.of(context).push(
              AmanahPresenceHistoryScreen.route(initialTab: 1),
            );
          },
          secondaryActionText: 'Lihat Sesi Dokter',
          secondaryActionLeadingIcon: Icons.calendar_month_outlined,
          onSecondaryAction: onOpenSessionsView,
        ),
      ],
    );
  }
}
