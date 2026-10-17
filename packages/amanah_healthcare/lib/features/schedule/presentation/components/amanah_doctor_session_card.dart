import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_card_layers.dart';

class AmanahDoctorSessionCard extends StatelessWidget {
  const AmanahDoctorSessionCard({
    required this.schedule,
    required this.imageIndex,
    required this.onTapDetail,
    this.onTapEdit,
    this.onTapDelete,
    super.key,
  });

  final DoctorSchedule schedule;
  final int imageIndex;
  final VoidCallback onTapDetail;
  final VoidCallback? onTapEdit;
  final VoidCallback? onTapDelete;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String cardBgAsset = dark
        ? 'assets/amanah/images/booking-card-bg-dark.png'
        : 'assets/amanah/images/booking-card-bg-light.png';

    final String startTime =
        schedule.startTime ?? schedule.time.split(' - ').first;
    final String endTime =
        schedule.endTime ??
        schedule.time.split(' - ').last.replaceAll(' WIB', '');
    final int bookedCount = schedule.bookedPatients.length;

    return Semantics(
      button: true,
      label: '${schedule.title}, ${schedule.poli}, $bookedCount Pasien',
      child: GestureDetector(
        onTap: onTapDetail,
        child: Container(
          height: 360,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: dark ? AmanahColorTokens.brandNavyDark : AmanahColorTokens.surfaceLight,
            border: Border.all(
              color: dark
                  ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                  : AmanahColorTokens.neutral200,
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: dark
                    ? AmanahColorTokens.pureBlack.withValues(alpha: 0.50)
                    : AmanahColorTokens.navy.withValues(alpha: 0.08),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
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
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => Container(
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

              // Layer 2: Lower text readability blur with a soft top fade
              ProfileReadabilityMaskLayer(dark: dark, height: 220),

              // Layer 3: Smooth High-Contrast Ambient Gradient (Masking Putih / Obsidian)
              AmbientCardGradientLayer(dark: dark),

              // Layer 4: Top Badges (Status on Left, Booked Count on Right)
              Positioned(
                top: 14,
                left: 14,
                child: AmanahStatusBadge(
                  text: schedule.badge,
                  variant: schedule.badgeVariant,
                ),
              ),

              Positioned(
                top: 14,
                right: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? AmanahColorTokens.canvasDark.withValues(alpha: 0.70)
                            : AmanahColorTokens.surfaceLight.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: dark
                              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                              : AmanahColorTokens.neutral200,
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AmanahColorTokens.pureBlack.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.people_alt_rounded,
                            size: 14,
                            color: dark
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral900,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$bookedCount Pasien Booking',
                            style: TextStyle(
                              color: dark
                                  ? AmanahColorTokens.surfaceLight
                                  : AmanahColorTokens.neutral900,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                      // Session Name
                      Text(
                        schedule.title,
                        style: TextStyle(
                          color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Details: Room & Poli on Left, Start & End Time on Right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
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
                                      color: dark
                                          ? AmanahColorTokens.surfaceLight
                                          : AmanahColorTokens.neutral900,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
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
                                      color: dark
                                          ? AmanahColorTokens.neutral300
                                          : AmanahColorTokens.neutral500,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Time Specifications (Start | Finish)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: dark
                                            ? AmanahColorTokens.surfaceLight
                                            : AmanahColorTokens.neutral900,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        startTime,
                                        style: TextStyle(
                                          color: dark
                                              ? AmanahColorTokens.surfaceLight
                                              : AmanahColorTokens.neutral900,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Mulai',
                                    style: TextStyle(
                                      color: dark
                                          ? AmanahColorTokens.neutral300
                                          : AmanahColorTokens.neutral500,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                width: 1,
                                height: 26,
                                color: dark
                                    ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.20)
                                    : AmanahColorTokens.neutral200,
                              ),
                              Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: dark
                                            ? AmanahColorTokens.surfaceLight
                                            : AmanahColorTokens.neutral900,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        endTime,
                                        style: TextStyle(
                                          color: dark
                                              ? AmanahColorTokens.surfaceLight
                                              : AmanahColorTokens.neutral900,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Selesai',
                                    style: TextStyle(
                                      color: dark
                                          ? AmanahColorTokens.neutral300
                                          : AmanahColorTokens.neutral500,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        height: 1,
                        color: dark
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
                            : AmanahColorTokens.neutral200,
                      ),
                      const SizedBox(height: 14),

                      AmanahButton.primary(
                        text: 'Detail Sesi',
                        isFullWidth: true,
                        size: AmanahButtonSize.medium,
                        onPressed: onTapDetail,
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
