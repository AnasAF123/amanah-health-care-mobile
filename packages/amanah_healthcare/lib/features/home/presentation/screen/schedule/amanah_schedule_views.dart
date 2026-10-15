import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_date_carousel_strip.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_doc_schedule_calendar_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_patient_detail_modal.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_booked_patient_card.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_doctor_session_card.dart';

class AmanahScheduleOverviewView extends StatelessWidget {
  const AmanahScheduleOverviewView({
    super.key,
    required this.selectedDate,
    required this.baseToday,
    required this.daySetting,
    required this.isCuti,
    required this.schedules,
    required this.bookedPatients,
    required this.dark,
    required this.dateSubtitle,
    required this.onSelectDate,
    required this.onSelectCalendarDate,
    required this.onReopenSchedule,
    required this.onAddSchedule,
    required this.onViewSessions,
    required this.hasSchedulesForDate,
    required this.isCutiForDate,
  });

  final DateTime selectedDate;
  final DateTime baseToday;
  final DayScheduleSetting daySetting;
  final bool isCuti;
  final List<DoctorSchedule> schedules;
  final List<({BookedPatient patient, DoctorSchedule schedule})> bookedPatients;
  final bool dark;
  final String dateSubtitle;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onSelectCalendarDate;
  final VoidCallback onReopenSchedule;
  final VoidCallback onAddSchedule;
  final VoidCallback onViewSessions;
  final bool Function(DateTime) hasSchedulesForDate;
  final bool Function(DateTime) isCutiForDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('view-overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top Action Row: Section Title & Calendar Drawer Trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                'Jadwal & Ketersediaan',
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.surfaceLight
                      : AmanahColorTokens.neutral900,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            AmanahButton.text(
              text: 'Lihat kalender',
              trailingIcon: Icons.calendar_month_outlined,
              size: AmanahButtonSize.small,
              customForegroundColor: dark
                  ? AmanahColorTokens.tabActiveDark
                  : AmanahColorTokens.brand,
              onPressed: () {
                AmanahDocScheduleCalendarDrawer.show(
                  context,
                  selectedDate: selectedDate,
                  baseToday: baseToday,
                  onSelectDate: onSelectCalendarDate,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Date Carousel Strip
        AmanahDateCarouselStrip(
          selectedDate: selectedDate,
          baseToday: baseToday,
          onSelectDate: onSelectDate,
          hasSchedulesForDate: hasSchedulesForDate,
          isCutiForDate: isCutiForDate,
        ),
        const SizedBox(height: 12),

        // Cuti Alert Banner if Day is on Cuti
        if (isCuti) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AmanahColorTokens.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AmanahColorTokens.warning.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AmanahColorTokens.warning,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Dokter Cuti Praktik: Seluruh jadwal dinonaktifkan.',
                    style: TextStyle(
                      color: AmanahColorTokens.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AmanahButton.secondary(
                  text: 'Buka Jadwal',
                  size: AmanahButtonSize.small,
                  customForegroundColor: AmanahColorTokens.warning,
                  customBackgroundColor: AmanahColorTokens.warning.withValues(
                    alpha: 0.12,
                  ),
                  onPressed: onReopenSchedule,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Section Title: Date & Patient Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                dateSubtitle,
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
              '${bookedPatients.length} Pasien Booking',
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
        if (bookedPatients.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookedPatients.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              final ({BookedPatient patient, DoctorSchedule schedule}) item =
                  bookedPatients[index];
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
          )
        else
          AmanahEmptyState.box(
            title: 'Belum Ada Pasien Booking',
            message: isCuti
                ? 'Dokter sedang cuti pada tanggal ini.'
                : 'Belum ada pasien yang mendaftar pada sesi praktik di tanggal ini.',
            actionText: 'Tambah Jadwal',
            actionLeadingIcon: Icons.add_rounded,
            onAction: onAddSchedule,
            secondaryActionText: 'Lihat Sesi Dokter',
            secondaryActionLeadingIcon: Icons.calendar_month_outlined,
            onSecondaryAction: onViewSessions,
          ),
      ],
    );
  }
}

class AmanahScheduleSessionsView extends StatelessWidget {
  const AmanahScheduleSessionsView({
    super.key,
    required this.schedules,
    required this.isCuti,
    required this.dark,
    required this.onTapDetail,
    required this.onTapEdit,
    required this.onTapDelete,
    required this.onAddSchedule,
  });

  final List<DoctorSchedule> schedules;
  final bool isCuti;
  final bool dark;
  final ValueChanged<DoctorSchedule> onTapDetail;
  final ValueChanged<DoctorSchedule> onTapEdit;
  final ValueChanged<DoctorSchedule> onTapDelete;
  final VoidCallback onAddSchedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('view-sessions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                'Daftar Sesi Praktik Dokter',
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
              '${schedules.length} Sesi Aktif',
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

        if (schedules.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedules.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              final DoctorSchedule sch = schedules[index];
              return AmanahDoctorSessionCard(
                schedule: sch,
                imageIndex: index,
                onTapDetail: () => onTapDetail(sch),
                onTapEdit: () => onTapEdit(sch),
                onTapDelete: () => onTapDelete(sch),
              );
            },
          )
        else
          AmanahEmptyState.box(
            title: 'Belum Ada Sesi Praktik',
            message: isCuti
                ? 'Dokter sedang cuti pada tanggal ini.'
                : 'Belum ada sesi praktik dokter yang ditambahkan pada tanggal ini.',
            actionText: 'Tambah Jadwal Dokter',
            actionLeadingIcon: Icons.add_rounded,
            onAction: onAddSchedule,
          ),
      ],
    );
  }
}

class AmanahScheduleSessionPatientsView extends StatelessWidget {
  const AmanahScheduleSessionPatientsView({
    super.key,
    required this.session,
    required this.dark,
    required this.onBackToSessions,
  });

  final DoctorSchedule? session;
  final bool dark;
  final VoidCallback onBackToSessions;

  @override
  Widget build(BuildContext context) {
    final DoctorSchedule? sch = session;
    final List<BookedPatient> patients =
        sch?.bookedPatients ?? const <BookedPatient>[];

    return Column(
      key: const ValueKey<String>('view-session-patients'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${sch?.title} • ${sch?.poli}',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.surfaceLight
                            : AmanahColorTokens.neutral900,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sch?.room} • ${sch?.time}',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (dark
                          ? AmanahColorTokens.brandAccent
                          : AmanahColorTokens.brand)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${patients.length} Pasien',
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.brandAccent
                        : AmanahColorTokens.brand,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (patients.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patients.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              final BookedPatient patient = patients[index];
              return AmanahBookedPatientCard(
                patient: patient,
                schedule: sch!,
                imageIndex: index,
                onTapDetail: () {
                  AmanahPatientDetailModal.show(context, patient, sch);
                },
              );
            },
          )
        else
          AmanahEmptyState.box(
            title: 'Belum Ada Pasien Booking',
            message: 'Belum ada pasien yang mendaftar pada sesi praktik ini.',
            actionText: 'Kembali ke Sesi Praktik',
            actionLeadingIcon: Icons.arrow_back_rounded,
            onAction: onBackToSessions,
          ),
      ],
    );
  }
}
