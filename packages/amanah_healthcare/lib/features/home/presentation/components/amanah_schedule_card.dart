import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_card_widgets.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_ticket_painters.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_schedule_card_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

/// Molecule: Single Doctor Schedule Card with 3D crystal architecture texture,
/// C-notch silhouette, liquid glass gradient, dashed perforated line, and tokenized typography.
/// Matching ScheduleCard.tsx (.web) 1:1
class AmanahScheduleCard extends StatelessWidget {
  const AmanahScheduleCard({
    required this.schedule,
    required this.onDismiss,
    this.onCardTap,
    super.key,
  });

  final DoctorSchedule schedule;
  final VoidCallback onDismiss;
  final VoidCallback? onCardTap;

  String _formatPatientCount() {
    return '${schedule.bookedPatients.length} Pasien';
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String primaryTitle = schedule.title.startsWith('Jadwal')
        ? schedule.title
        : 'Jadwal Hari Ini';
    final String sessionLabel = schedule.sessionType.isNotEmpty
        ? 'Sesi ${schedule.sessionType}'
        : (!schedule.title.startsWith('Jadwal') ? schedule.title : '');

    final String bgAsset = dark
        ? AmanahScheduleCardTokens.bgImageDark
        : AmanahScheduleCardTokens.bgImageLight;

    return Semantics(
      label: 'Jadwal Hari Ini, ${schedule.title}, ${schedule.time}',
      child: Container(
        height: AmanahScheduleCardTokens.cardHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: dark
              ? AmanahScheduleCardTokens.cardShadowDark
              : AmanahScheduleCardTokens.cardShadowLight,
        ),
        child: ClipPath(
          clipper: const AmanahTicketClipper(),
          child: Stack(
            children: <Widget>[
              // Layer 1: Solid Card Base & Outer Border
              Positioned.fill(
                child: CustomPaint(painter: AmanahCardBasePainter(dark: dark)),
              ),

              // Layer 2: Authentic 3D Geometric Crystal Texture Asset
              Positioned.fill(
                child: Image.asset(
                  bgAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stack) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? const <Color>[
                                  AmanahColorTokens.surfaceSecondaryDark,
                                  AmanahColorTokens.canvasDark,
                                ]
                              : const <Color>[
                                  AmanahColorTokens.brandSurface,
                                  AmanahColorTokens.canvasLight,
                                ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Layer 3: Seamless Liquid Glass Gradient Mask
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: dark
                        ? AmanahScheduleCardTokens.liquidGlassGradientDark
                        : AmanahScheduleCardTokens.liquidGlassGradientLight,
                  ),
                ),
              ),

              // Layer 4: Top-to-Bottom Glass Specular Sheen
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: dark
                        ? AmanahScheduleCardTokens.glassSpecularSheenDark
                        : AmanahScheduleCardTokens.glassSpecularSheenLight,
                  ),
                ),
              ),

              // Layer 5: Wall-to-Wall Perforated Dashed Line between C-Notches
              Positioned.fill(
                child: CustomPaint(
                  painter: AmanahPerforatedLinePainter(dark: dark),
                ),
              ),

              // Layer 6: Foreground Content
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCardTap,
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
                                                ? AmanahScheduleCardTokens
                                                      .titleColorDark
                                                : AmanahScheduleCardTokens
                                                      .titleColorLight,
                                          ),
                                        ),
                                      ),
                                      if (sessionLabel.isNotEmpty) ...<Widget>[
                                        Container(
                                          width: 1.5,
                                          height: 11,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: dark
                                                ? Colors.white.withValues(
                                                    alpha: 0.25,
                                                  )
                                                : AmanahColorTokens.neutral300,
                                            borderRadius: BorderRadius.circular(
                                              1,
                                            ),
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
                                    schedule.date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: dark
                                          ? AmanahScheduleCardTokens
                                                .dateColorDark
                                          : AmanahScheduleCardTokens
                                                .dateColorLight,
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
                                            ? AmanahScheduleCardTokens
                                                  .poliColorDark
                                            : AmanahScheduleCardTokens
                                                  .poliColorLight,
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
                                            ? AmanahScheduleCardTokens
                                                  .roomColorDark
                                            : AmanahScheduleCardTokens
                                                  .roomColorLight,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
