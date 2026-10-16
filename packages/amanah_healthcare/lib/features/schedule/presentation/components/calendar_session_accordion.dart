import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/my_schedule_session.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_patient_detail_modal.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/calendar_patient_card.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/calendar_sheet_controller.dart';

class CalendarSessionAccordion extends StatelessWidget {
  const CalendarSessionAccordion({
    required this.controller,
    super.key,
  });

  final CalendarSheetController controller;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final List<MyScheduleSession> sessions = controller.activeSessions;

    if (sessions.isEmpty) {
      return AmanahEmptyState.box(
        title: 'Tidak Ada Sesi Buka',
        message: 'Tidak ada sesi praktik yang aktif pada tanggal ini.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final MyScheduleSession session = sessions[index];
        final bool isExpanded = controller.isExpanded(session.sessionId);
        final bool isLoading =
            controller.isLoadingPatientsForSession(session.sessionId);
        final List<SessionPatient>? patients =
            controller.getPatientsForSession(session.sessionId);

        return Container(
          decoration: BoxDecoration(
            color: dark
                ? AmanahColorTokens.surfaceDark
                : AmanahColorTokens.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded
                  ? (dark
                      ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.35)
                      : AmanahColorTokens.brand.withValues(alpha: 0.3))
                  : (dark
                      ? AmanahColorTokens.neutral700.withValues(alpha: 0.4)
                      : AmanahColorTokens.neutral200),
            ),
          ),
          child: Column(
            children: <Widget>[
              // Session Header
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => controller.toggleSessionExpanded(session.sessionId),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      // Shift Icon Badge
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (dark
                                  ? AmanahColorTokens.tabActiveDark
                                  : AmanahColorTokens.brand)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: dark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brand,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Session Title & Room/Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              session.sessionLabel,
                              style: TextStyle(
                                color: dark
                                    ? AmanahColorTokens.surfaceLight
                                    : AmanahColorTokens.neutral900,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${session.timeRange ?? ''}${session.roomName != null ? ' • ${session.roomName}' : ''}',
                              style: TextStyle(
                                color: dark
                                    ? AmanahColorTokens.neutral400
                                    : AmanahColorTokens.neutral500,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Patient count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: dark
                              ? AmanahColorTokens.surfaceSecondaryDark
                              : AmanahColorTokens.neutral100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${session.bookedCount} Pasien',
                          style: TextStyle(
                            color: dark
                                ? AmanahColorTokens.neutral300
                                : AmanahColorTokens.neutral700,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded Patients List
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                        )
                      : (patients == null || patients.isEmpty)
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              alignment: Alignment.center,
                              child: Text(
                                'Belum ada pasien terdaftar di sesi ini.',
                                style: TextStyle(
                                  color: dark
                                      ? AmanahColorTokens.neutral400
                                      : AmanahColorTokens.neutral500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : Column(
                              children: patients
                                  .map(
                                    (SessionPatient p) => CalendarPatientCard(
                                      patient: p,
                                      onTap: () {
                                        AmanahPatientDetailModal.show(
                                          context,
                                          p.toBookedPatient(),
                                          DoctorSchedule(
                                            id: session.sessionId,
                                            title: session.sessionLabel,
                                            date: session.scheduleDate,
                                            time: session.timeRange ?? 'Sesi Praktik',
                                            poli: session.poliklinikName,
                                            room: session.roomName,
                                            badge: session.status,
                                            badgeVariant: AmanahBadgeVariant.primary,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                ),
            ],
          ),
        );
      },
    );
  }
}
