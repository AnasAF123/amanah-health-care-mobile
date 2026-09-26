import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';

class AmanahScheduleSessionPatientsView extends StatelessWidget {
  const AmanahScheduleSessionPatientsView({
    required this.selectedSession,
    required this.dark,
    required this.onBackToSessions,
    super.key,
  });

  final DoctorSchedule? selectedSession;
  final bool dark;
  final VoidCallback onBackToSessions;

  @override
  Widget build(BuildContext context) {
    final DoctorSchedule? sch = selectedSession;
    final List<BookedPatient> patients =
        sch?.bookedPatients ?? const <BookedPatient>[];

    return Column(
      key: const ValueKey<String>('view-session-patients'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Session Header Overview
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
                            ? AmanahColorTokens.pureWhite
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
              Builder(
                builder: (BuildContext context) {
                  final int activeCount =
                      patients.where((BookedPatient p) => !p.isCancelled).length;
                  final int cancelledCount = patients.length - activeCount;
                  final String countLabel = cancelledCount > 0
                      ? '$activeCount Aktif • $cancelledCount Batal'
                      : '${patients.length} Pasien';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (dark
                                  ? AmanahColorTokens.cyanAccent
                                  : AmanahColorTokens.brand)
                              .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      countLabel,
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.cyanAccent
                            : AmanahColorTokens.brand,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  );
                },
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
