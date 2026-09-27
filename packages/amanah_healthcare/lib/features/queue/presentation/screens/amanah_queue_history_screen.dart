import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';

class AmanahQueueHistoryScreen extends StatelessWidget {
  const AmanahQueueHistoryScreen({
    required this.collectedCards,
    required this.onRedraw,
    super.key,
  });

  final List<AmanahQueueCardData> collectedCards;
  final VoidCallback onRedraw;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color bgColor = AmanahThemeTokens.canvas(context);
    final Color cardBg = AmanahThemeTokens.surface(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final Color borderColor = AmanahThemeTokens.outline(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader.standard(
              title: 'Riwayat antrean diproses',
              onBack: () => Navigator.of(context).pop(),
              showDivider: true,
            ),
            Expanded(
              child: collectedCards.isEmpty
                  ? AmanahEmptyState.viewport(
                      tone: AmanahEmptyStateTone.brand,
                      iconShape: AmanahEmptyStateIconShape.squircle,
                      customIcon: Text(
                        '#',
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.cyanAccent
                              : AmanahColorTokens.brandPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      title: 'Belum Ada Antrean',
                      message:
                          'Tarik kartu ke bawah dan panggil pasien untuk melihat riwayat proses antrean di sini.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: collectedCards.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext ctx, int idx) {
                        final AmanahQueueCardData card = collectedCards[idx];
                        return Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: borderColor.withValues(
                                alpha: dark ? 0.35 : 0.6,
                              ),
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: dark
                                    ? AmanahColorTokens.pureBlack
                                        .withValues(alpha: 0.30)
                                    : AmanahColorTokens.neutral400
                                        .withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                AmanahPatientDetailModal.show(
                                  context,
                                  BookedPatient(
                                    id: card.id,
                                    patientName: card.patientName,
                                    patientComplaint: card.complaint,
                                    queueNumber: card.queueNumber,
                                    timeSlot: card.timeSlot,
                                    avatarUrl: card.doctorImage,
                                    patientAge: '${card.age} Thn',
                                    patientRm: card.patientRm,
                                    badge: card.priority,
                                    badgeVariant: card.priority == 'Prioritas'
                                        ? AmanahBadgeVariant.warning
                                        : AmanahBadgeVariant.primary,
                                  ),
                                  DoctorSchedule(
                                    id: 'sch_${card.id}',
                                    title: 'Praktik Dokter',
                                    date: 'Hari ini',
                                    time: card.timeSlot,
                                    poli: card.poly,
                                    room: card.room,
                                    slotCount: '1',
                                    slotText: 'Antrean',
                                    badge: card.priority,
                                    badgeVariant: AmanahBadgeVariant.primary,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: dark
                                            ? AmanahColorTokens.cyanAccent
                                                .withValues(alpha: 0.15)
                                            : AmanahColorTokens.brandMuted,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        card.queueNumber,
                                        style: TextStyle(
                                          color: dark
                                              ? AmanahColorTokens.cyanAccent
                                              : AmanahColorTokens.brandPrimary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            card.patientName,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${card.poly} • ${card.timeSlot}',
                                            style: TextStyle(
                                              color: subtextColor,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: subtextColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (collectedCards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: AmanahButton.secondary(
                  text: 'Kembali ke Antrean',
                  isFullWidth: true,
                  size: AmanahButtonSize.medium,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRedraw();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
