import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_queue_badge.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_card_layers.dart';

class AmanahBookedPatientCard extends StatelessWidget {
  const AmanahBookedPatientCard({
    required this.patient,
    required this.schedule,
    required this.imageIndex,
    required this.onTapDetail,
    super.key,
  });

  final BookedPatient patient;
  final DoctorSchedule schedule;
  final int imageIndex;
  final VoidCallback onTapDetail;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String cardBgAsset = dark
        ? 'assets/amanah/images/booking-card-bg-dark.png'
        : 'assets/amanah/images/booking-card-bg-light.png';

    String formatTimeOnly(String? rawIsoOrTime) {
      if (rawIsoOrTime == null || rawIsoOrTime.trim().isEmpty) return '-';
      if (rawIsoOrTime.contains('T')) {
        final DateTime? parsed = DateTime.tryParse(rawIsoOrTime)?.toLocal();
        if (parsed != null) {
          return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
        }
      }
      if (rawIsoOrTime.contains(':')) {
        final List<String> parts = rawIsoOrTime.split(':');
        if (parts.length >= 2) {
          return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
        }
      }
      return rawIsoOrTime;
    }

    final String rawSlot = patient.timeSlot;
    final String startTime = patient.actualStartedAt != null
        ? formatTimeOnly(patient.actualStartedAt)
        : (patient.scheduledStartTime != null
              ? formatTimeOnly(patient.scheduledStartTime)
              : (rawSlot.contains(' - ') ? rawSlot.split(' - ').first.trim() : '08:00'));
    final String endTime = patient.actualCompletedAt != null
        ? formatTimeOnly(patient.actualCompletedAt)
        : (patient.scheduledEndTime != null
              ? formatTimeOnly(patient.scheduledEndTime)
              : (rawSlot.contains(' - ')
                    ? rawSlot.split(' - ').last.replaceAll(' WIB', '').trim()
                    : '09:30'));

    return Semantics(
      button: true,
      label: 'Pasien ${patient.patientName}, Antrean ${patient.queueNumber}',
      child: GestureDetector(
        onTap: onTapDetail,
        child: Container(
          height: 355,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: AmanahThemeTokens.surface(context),
            border: Border.all(color: AmanahThemeTokens.outline(context), width: 1),
            boxShadow: <BoxShadow>[AmanahElevation.soft(dark: dark)],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: <Widget>[
              // Layer 1: Background Asset Texture
              Positioned.fill(
                child: Image.asset(
                  cardBgAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: dark
                                ? const <Color>[
                                    AmanahColorTokens.darkNavy,
                                    AmanahColorTokens.brandNavyDark,
                                  ]
                                : const <Color>[
                                    AmanahColorTokens.skyLight,
                                    AmanahColorTokens.canvasLight,
                                  ],
                          ),
                        ),
                      ),
                ),
              ),

              // Layer 2: Profile-to-bottom readability blur with a soft top fade
              ProfileReadabilityMaskLayer(dark: dark, height: 210),

              // Layer 3: Smooth High-Contrast Ambient Gradient (Masking Putih / Obsidian)
              AmbientCardGradientLayer(dark: dark),

              // Layer 4: Top Badges (Status on Left, 3D Queue Medal on Right)
              Positioned(
                top: 14,
                left: 14,
                child: AmanahStatusBadge(text: patient.badge, variant: patient.badgeVariant),
              ),

              // Top-Right: 3D Crystal Queue Badge Medal
              Positioned(
                top: 8,
                right: 8,
                child: AmanahQueueBadge(queueNumber: patient.queueNumber, size: 68),
              ),

              // Layer 5: Text Content Overlay at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Avatar & Patient Details Row
                      Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AmanahColorTokens.neutral800,
                              border: Border.all(color: AmanahColorTokens.surfaceLight, width: 2),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: AmanahColorTokens.pureBlack.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                patient.avatarUrl ??
                                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (BuildContext context, Object error, StackTrace? stack) =>
                                        ColoredBox(
                                          color: AmanahColorTokens.neutral700,
                                          child: Center(
                                            child: Text(
                                              patient.patientName.isNotEmpty
                                                  ? patient.patientName.substring(0, 1)
                                                  : 'P',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: AmanahColorTokens.surfaceLight,
                                              ),
                                            ),
                                          ),
                                        ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  patient.patientName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AmanahThemeTokens.textPrimary(context),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  patient.patientRm,
                                  style: TextStyle(
                                    color: AmanahThemeTokens.textSecondary(context),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Specifications Row: Conditional (Estimasi Giliran vs Mulai & Selesai)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if ((patient.poliklinikName ?? schedule.poli) != null &&
                                    (patient.poliklinikName ?? schedule.poli)!.trim().isNotEmpty)
                                  Text(
                                    (patient.poliklinikName ?? schedule.poli)!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AmanahThemeTokens.textPrimary(context),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                if (schedule.room != null &&
                                    schedule.room!.trim().isNotEmpty) ...<Widget>[
                                  if ((patient.poliklinikName ?? schedule.poli) != null &&
                                      (patient.poliklinikName ?? schedule.poli)!.trim().isNotEmpty)
                                    const SizedBox(height: 1),
                                  Text(
                                    schedule.room!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AmanahThemeTokens.textTertiary(context),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 28,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            color: AmanahThemeTokens.divider(context),
                          ),

                          if (!patient.isCompleted) ...<Widget>[
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 13,
                                        color: AmanahThemeTokens.textPrimary(context),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          patient.etaDisplay,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AmanahThemeTokens.textPrimary(context),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Estimasi Giliran',
                                    style: TextStyle(
                                      color: AmanahThemeTokens.textTertiary(context),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...<Widget>[
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: AmanahThemeTokens.textPrimary(context),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        startTime,
                                        style: TextStyle(
                                          color: AmanahThemeTokens.textPrimary(context),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Mulai',
                                    style: TextStyle(
                                      color: AmanahThemeTokens.textTertiary(context),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 28,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              color: AmanahThemeTokens.divider(context),
                            ),

                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 13,
                                        color: AmanahThemeTokens.textPrimary(context),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        endTime,
                                        style: TextStyle(
                                          color: AmanahThemeTokens.textPrimary(context),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Selesai',
                                    style: TextStyle(
                                      color: AmanahThemeTokens.textTertiary(context),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        height: 1,
                        color: dark
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
                            : AmanahColorTokens.neutral200,
                      ),
                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: dark
                              ? AmanahColorTokens.btnCrispBlueDarkGradient
                              : AmanahColorTokens.btnCrispBlueGradient,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: dark
                                ? AmanahColorTokens.btnCrispBlueDarkBorder
                                : AmanahColorTokens.btnCrispBlueBorder,
                            width: 1,
                          ),
                          boxShadow: <BoxShadow>[
                            if (dark)
                              AmanahColorTokens.btnCrispBlueDarkShadow
                            else
                              AmanahColorTokens.btnCrispBlueShadow,
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: onTapDetail,
                            child: const Center(
                              child: Text(
                                'Detail Pasien',
                                style: TextStyle(
                                  color: AmanahColorTokens.surfaceLight,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
