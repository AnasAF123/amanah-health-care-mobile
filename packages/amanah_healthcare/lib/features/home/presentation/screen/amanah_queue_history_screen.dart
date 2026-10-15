import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_patient_detail_modal.dart';

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
                  ? SingleChildScrollView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: AmanahEmptyState.box(
                        title: 'Belum Ada Antrean Diproses',
                        message:
                            'Tarik kartu antrean pasien ke bawah pada rel 3D untuk memproses dan memanggil pasien.',
                        actionText: 'Kembali ke Antrean',
                        actionLeadingIcon: Icons.arrow_back_rounded,
                        onAction: () => Navigator.of(context).pop(),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(AmanahSpacing.lg),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.15,
                          ),
                      itemCount: collectedCards.length,
                      itemBuilder: (BuildContext context, int index) {
                        final AmanahQueueCardData card = collectedCards[index];
                        return GestureDetector(
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
                                badge: card.priority,
                                badgeVariant: AmanahBadgeVariant.primary,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AmanahColorTokens.pureBlack.withValues(
                                    alpha: dark ? 0.30 : 0.04,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: <Widget>[
                                  const Positioned(
                                    top: -6,
                                    left: -8,
                                    child: Opacity(
                                      opacity: 0.07,
                                      child: AmanahWatermarkLogo(size: 72),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Text(
                                              card.queueNumber,
                                              style: TextStyle(
                                                color: dark
                                                    ? AmanahColorTokens
                                                          .brandAccent
                                                    : AmanahColorTokens
                                                          .brandPrimary,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: dark
                                                      ? AmanahColorTokens.brand
                                                            .withValues(
                                                              alpha: 0.15,
                                                            )
                                                      : AmanahColorTokens
                                                            .brandSurface,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  border: Border.all(
                                                    color: dark
                                                        ? AmanahColorTokens
                                                              .brand
                                                              .withValues(
                                                                alpha: 0.30,
                                                              )
                                                        : AmanahColorTokens
                                                              .brandMuted,
                                                  ),
                                                ),
                                                child: Text(
                                                  card.poly,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: dark
                                                        ? AmanahColorTokens
                                                            .brandAccent
                                                        : AmanahColorTokens
                                                            .brandPrimary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    child: Image.asset(
                                                      card.doctorImage,
                                                      width: 24,
                                                      height: 24,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            BuildContext
                                                            context,
                                                            Object error,
                                                            StackTrace?
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color: dark
                                                                  ? AmanahColorTokens
                                                                        .brand
                                                                        .withValues(
                                                                          alpha:
                                                                              0.20,
                                                                        )
                                                                  : AmanahColorTokens
                                                                        .brandSurface,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Icon(
                                                                Icons.person,
                                                                size: 14,
                                                                color: dark
                                                                    ? AmanahColorTokens
                                                                          .brandAccent
                                                                    : AmanahColorTokens
                                                                          .brandPrimary,
                                                              ),
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    card.patientName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: textColor,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              card.complaint,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: subtextColor,
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w500,
                                                height: 1.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AmanahSpacing.lg,
            8,
            AmanahSpacing.lg,
            16,
          ),
          child: AmanahButton.primary(
            text: 'Panggil Antrean Lain',
            isFullWidth: true,
            size: AmanahButtonSize.large,
            onPressed: () {
              Navigator.of(context).pop();
              onRedraw();
            },
          ),
        ),
      ),
    );
  }
}
