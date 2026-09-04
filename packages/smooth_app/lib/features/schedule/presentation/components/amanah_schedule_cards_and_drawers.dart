import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';
import 'package:smooth_app/features/schedule/presentation/components/amanah_queue_badge.dart';

AmanahTone _badgeTone(AmanahBadgeVariant variant, [BuildContext? context]) {
  switch (variant) {
    case AmanahBadgeVariant.success:
      return AmanahThemeTokens.status(
        AmanahStatusTone.success,
        context: context,
      );
    case AmanahBadgeVariant.primary:
    case AmanahBadgeVariant.live:
      return AmanahThemeTokens.status(AmanahStatusTone.brand, context: context);
    case AmanahBadgeVariant.warning:
      return AmanahThemeTokens.status(
        AmanahStatusTone.warning,
        context: context,
      );
    case AmanahBadgeVariant.trend:
      return AmanahThemeTokens.status(
        AmanahStatusTone.violet,
        context: context,
      );
  }
}

class _ProfileReadabilityMaskLayer extends StatelessWidget {
  const _ProfileReadabilityMaskLayer({
    required this.dark,
    required this.height,
  });

  final bool dark;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: <double>[0.0, 0.22, 0.42, 1.0],
              colors: <Color>[
                Colors.transparent,
                Color(0x73000000),
                Colors.black,
                Colors.black,
              ],
            ).createShader(bounds);
          },
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const <double>[0.0, 0.44, 1.0],
                    colors: dark
                        ? const <Color>[
                            Color(0x00060B18),
                            Color(0xB8060B18),
                            Color(0xF8060B18),
                          ]
                        : const <Color>[
                            Color(0x00FFFFFF),
                            Color(0xDBFFFFFF),
                            Color(0xFAFFFFFF),
                          ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientCardGradientLayer extends StatelessWidget {
  const _AmbientCardGradientLayer({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const <double>[0.0, 0.35, 0.65, 1.0],
              colors: dark
                  ? <Color>[
                      const Color(0x00060B18),
                      const Color(0x00060B18),
                      const Color(0x99060B18),
                      const Color(0xF5060B18),
                    ]
                  : <Color>[
                      const Color(0x00FFFFFF),
                      const Color(0x00FFFFFF),
                      const Color(0x99FFFFFF),
                      const Color(0xF8FFFFFF),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 4. Booked Patient Card (335px 1:1 Progressive Liquid Glass with Master Texture)
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

    final String rawSlot = patient.timeSlot;
    final String startTime = rawSlot.contains(' - ')
        ? rawSlot.split(' - ').first.trim()
        : '08:00';
    final String endTime = rawSlot.contains(' - ')
        ? rawSlot.split(' - ').last.replaceAll(' WIB', '').trim()
        : '09:30';

    return Semantics(
      button: true,
      label: 'Pasien ${patient.patientName}, Antrean ${patient.queueNumber}',
      child: GestureDetector(
        onTap: onTapDetail,
        child: Container(
          height: 335,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: AmanahThemeTokens.surface(context),
            border: Border.all(
              color: AmanahThemeTokens.outline(context),
              width: 1,
            ),
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
                                    Color(0xFF0D1B2A),
                                    Color(0xFF060B18),
                                  ]
                                : const <Color>[
                                    Color(0xFFE0F2FE),
                                    Color(0xFFF8FAFF),
                                  ],
                          ),
                        ),
                      ),
                ),
              ),

              // Layer 2: Profile-to-bottom readability blur with a soft top fade
              _ProfileReadabilityMaskLayer(dark: dark, height: 210),

              // Layer 3: Smooth High-Contrast Ambient Gradient (Masking Putih / Obsidian)
              _AmbientCardGradientLayer(dark: dark),

              // Layer 4: Top Badges (Status on Left, 3D Queue Medal on Right)
              Positioned(
                top: 14,
                left: 14,
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
                            ? const Color(0xFF0A0E1A).withValues(alpha: 0.70)
                            : Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: _badgeTone(patient.badgeVariant).primary,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox(width: 8, height: 8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            patient.badge,
                            style: TextStyle(
                              color: dark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontFamily: 'PlusJakartaSans',
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

              // Top-Right: 3D Crystal Queue Badge Medal
              Positioned(
                top: 8,
                right: 8,
                child: AmanahQueueBadge(
                  queueNumber: patient.queueNumber,
                  size: 68,
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
                      // Avatar & Patient Details Row
                      Row(
                        children: <Widget>[
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E293B),
                              border: Border.all(
                                color: dark ? Colors.white : Colors.white,
                                width: 2,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
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
                                    (
                                      BuildContext context,
                                      Object error,
                                      StackTrace? stack,
                                    ) => ColoredBox(
                                      color: const Color(0xFF334155),
                                      child: Center(
                                        child: Text(
                                          patient.patientName.isNotEmpty
                                              ? patient.patientName.substring(
                                                  0,
                                                  1,
                                                )
                                              : 'P',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
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
                                    color: AmanahThemeTokens.textPrimary(
                                      context,
                                    ),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  patient.patientRm,
                                  style: TextStyle(
                                    color: AmanahThemeTokens.textSecondary(
                                      context,
                                    ),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Specifications Row: Exactly 3 Slots (Slot 1: Poli & Room | Slot 2: Mulai | Slot 3: Selesai)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Slot 1: Poli & Room
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  schedule.poli,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AmanahThemeTokens.textPrimary(
                                      context,
                                    ),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  schedule.room,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AmanahThemeTokens.textTertiary(
                                      context,
                                    ),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Separator Line 1
                          Container(
                            width: 1,
                            height: 28,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            color: AmanahThemeTokens.divider(context),
                          ),

                          // Slot 2: Jam Mulai
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
                                      color: AmanahThemeTokens.textPrimary(
                                        context,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      startTime,
                                      style: TextStyle(
                                        color: AmanahThemeTokens.textPrimary(
                                          context,
                                        ),
                                        fontFamily: 'PlusJakartaSans',
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
                                    color: AmanahThemeTokens.textTertiary(
                                      context,
                                    ),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Separator Line 2
                          Container(
                            width: 1,
                            height: 28,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            color: AmanahThemeTokens.divider(context),
                          ),

                          // Slot 3: Jam Selesai
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.schedule_rounded,
                                      size: 13,
                                      color: AmanahThemeTokens.textPrimary(
                                        context,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      endTime,
                                      style: TextStyle(
                                        color: AmanahThemeTokens.textPrimary(
                                          context,
                                        ),
                                        fontFamily: 'PlusJakartaSans',
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
                                    color: AmanahThemeTokens.textTertiary(
                                      context,
                                    ),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Glass Line Separator
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: dark
                            ? Colors.white.withValues(alpha: 0.15)
                            : const Color(0xFFE2E8F0),
                      ),
                      const SizedBox(height: 12),

                      // Action Button: Detail Pasien (.btn-crisp-blue)
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
                                  color: Colors.white,
                                  fontFamily: 'PlusJakartaSans',
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

/// 5. Doctor Practice Session Card (360px Liquid Glass with Master Texture)
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
            color: dark ? const Color(0xFF060B18) : Colors.white,
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.10)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: dark
                    ? Colors.black.withValues(alpha: 0.50)
                    : const Color(0xFF03045E).withValues(alpha: 0.08),
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
                                    Color(0xFF0D1B2A),
                                    Color(0xFF060B18),
                                  ]
                                : const <Color>[
                                    Color(0xFFE0F2FE),
                                    Color(0xFFF8FAFF),
                                  ],
                          ),
                        ),
                      ),
                ),
              ),

              // Layer 2: Lower text readability blur with a soft top fade
              _ProfileReadabilityMaskLayer(dark: dark, height: 220),

              // Layer 3: Smooth High-Contrast Ambient Gradient (Masking Putih / Obsidian)
              _AmbientCardGradientLayer(dark: dark),

              // Layer 4: Top Badges (Status on Left, Booked Count on Right)
              Positioned(
                top: 14,
                left: 14,
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
                            ? const Color(0xFF0A0E1A).withValues(alpha: 0.70)
                            : Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: _badgeTone(schedule.badgeVariant).primary,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox(width: 8, height: 8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            schedule.badge,
                            style: TextStyle(
                              color: dark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontFamily: 'PlusJakartaSans',
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
                            ? const Color(0xFF0A0E1A).withValues(alpha: 0.70)
                            : Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
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
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$bookedCount Pasien Booking',
                            style: TextStyle(
                              color: dark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontFamily: 'PlusJakartaSans',
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
                          color: dark ? Colors.white : const Color(0xFF0F172B),
                          fontFamily: 'PlusJakartaSans',
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
                                Text(
                                  schedule.poli,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: dark
                                        ? Colors.white
                                        : const Color(0xFF0F172B),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  schedule.room,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: dark
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF64748B),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                                            ? Colors.white
                                            : const Color(0xFF0F172B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        startTime,
                                        style: TextStyle(
                                          color: dark
                                              ? Colors.white
                                              : const Color(0xFF0F172B),
                                          fontFamily: 'PlusJakartaSans',
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
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF64748B),
                                      fontFamily: 'PlusJakartaSans',
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
                                    ? Colors.white.withValues(alpha: 0.20)
                                    : const Color(0xFFE2E8F0),
                              ),
                              Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 13,
                                        color: dark
                                            ? Colors.white
                                            : const Color(0xFF0F172B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        endTime,
                                        style: TextStyle(
                                          color: dark
                                              ? Colors.white
                                              : const Color(0xFF0F172B),
                                          fontFamily: 'PlusJakartaSans',
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
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF64748B),
                                      fontFamily: 'PlusJakartaSans',
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

                      // Divider
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: dark
                            ? Colors.white.withValues(alpha: 0.15)
                            : const Color(0xFFE2E8F0),
                      ),
                      const SizedBox(height: 14),

                      // Main read action. Edit/delete live in contextual overflow.
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

/// 6. Schedule Session Detail Drawer (Detail Sesi Praktik - Read Only)
/// Matching 1:1 with lines 2377-2584 in ScheduleTabScreen.tsx (.web)
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
                        color: dark ? Colors.white : const Color(0xFF020617),
                        fontFamily: 'PlusJakartaSans',
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
                            ? const Color(0xFFA1A1AA)
                            : const Color(0xFF64748B),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDayCuti
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.20)
                      : (schedule.badgeVariant == AmanahBadgeVariant.success
                            ? (dark
                                  ? const Color(
                                      0xFF10B981,
                                    ).withValues(alpha: 0.20)
                                  : const Color(0xFFECFDF5))
                            : schedule.badgeVariant ==
                                  AmanahBadgeVariant.warning
                            ? (dark
                                  ? const Color(
                                      0xFFF59E0B,
                                    ).withValues(alpha: 0.20)
                                  : const Color(0xFFFEF3C7))
                            : (dark
                                  ? const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: 0.20)
                                  : const Color(0xFFEFF6FF))),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: isDayCuti
                            ? const Color(0xFFF59E0B)
                            : _badgeTone(schedule.badgeVariant).primary,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 6, height: 6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isDayCuti ? 'Cuti' : schedule.badge,
                      style: TextStyle(
                        color: isDayCuti
                            ? const Color(0xFFF59E0B)
                            : (schedule.badgeVariant ==
                                      AmanahBadgeVariant.success
                                  ? (dark
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF047857))
                                  : schedule.badgeVariant ==
                                        AmanahBadgeVariant.warning
                                  ? (dark
                                        ? const Color(0xFFFBBF24)
                                        : const Color(0xFFD97706))
                                  : (dark
                                        ? const Color(0xFF60A5FA)
                                        : const Color(0xFF1D4ED8))),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFF1F5F9),
                ),
                bottom: BorderSide(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFF1F5F9),
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                _PatientSpecRow(
                  label: 'Sesi Praktik',
                  value: schedule.sessionType.isNotEmpty
                      ? 'Sesi ${schedule.sessionType}'
                      : schedule.title,
                  dark: dark,
                ),
                _PatientSpecRow(
                  label: 'Jam Praktik',
                  value: schedule.time,
                  dark: dark,
                ),
                _PatientSpecRow(
                  label: 'Ruang Praktik',
                  value: schedule.room,
                  dark: dark,
                ),
                _PatientSpecRow(
                  label: 'Poli / Spesialisasi',
                  value: schedule.poli,
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
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFF000000).withValues(alpha: 0.06),
                ),
                bottom: BorderSide(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFF000000).withValues(alpha: 0.06),
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
                                  ? const Color(0xFF60A5FA)
                                  : const Color(0xFF2563EB),
                              fontFamily: 'PlusJakartaSans',
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
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB),
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
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFF1F5F9),
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
              color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
              fontFamily: 'PlusJakartaSans',
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
                color: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                fontFamily: 'PlusJakartaSans',
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
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE2E8F0),
          border: Border.all(
            color: dark ? const Color(0xFF0A0E1A) : Colors.white,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '0',
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF334155),
            fontFamily: 'PlusJakartaSans',
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
                color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                border: Border.all(
                  color: dark ? const Color(0xFF0A0E1A) : Colors.white,
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
                                ? const Color(0xFF334155)
                                : const Color(0xFFCBD5E1),
                            child: Center(
                              child: Text(
                                p.patientName.isNotEmpty
                                    ? p.patientName.substring(0, 1)
                                    : 'P',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: dark
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
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

/// 7. Patient Detail & Complaint Bottom Sheet Modal
class AmanahPatientDetailModal extends StatelessWidget {
  const AmanahPatientDetailModal({
    required this.patient,
    required this.schedule,
    super.key,
  });

  final BookedPatient patient;
  final DoctorSchedule schedule;

  static void show(
    BuildContext context,
    BookedPatient patient,
    DoctorSchedule schedule,
  ) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) =>
          AmanahPatientDetailModal(patient: patient, schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return AmanahBottomSheetScaffold(
      title: 'Detail rekam pasien',
      fixedHeightFactor: 0.92,
      minHeight: 540,
      bodyPadding: EdgeInsets.zero,
      extendBodyBehindHeader: true,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: CustomPaint(
              painter: _PatientDetailAuroraPainter(dark: dark),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AmanahSpacing.xxl,
              AmanahSpacing.md,
              AmanahSpacing.xxl,
              AmanahSpacing.xxl,
            ),
            child: Column(
              children: <Widget>[
                _PatientProfileHeader(patient: patient, dark: dark),
                const SizedBox(height: AmanahSpacing.lg),
                _PatientSpecificationTable(
                  patient: patient,
                  schedule: schedule,
                  dark: dark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientProfileHeader extends StatelessWidget {
  const _PatientProfileHeader({required this.patient, required this.dark});

  final BookedPatient patient;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 98,
          height: 94,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.20),
                    width: 3,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    patient.avatarUrl ??
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=300&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stack,
                        ) => ColoredBox(
                          color: dark
                              ? const Color(0xFF334155)
                              : const Color(0xFFCBD5E1),
                          child: Center(
                            child: Text(
                              patient.patientName.isNotEmpty
                                  ? patient.patientName.substring(0, 1)
                                  : 'P',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: dark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 3,
                child: CustomPaint(
                  size: const Size(38, 45),
                  painter: _QueueBadgePainter(patient.queueNumber),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          patient.patientName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF020617),
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w900,
            height: 1.1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        _PatientMetaInline(patient: patient, dark: dark),
      ],
    );
  }
}

class _PatientMetaInline extends StatelessWidget {
  const _PatientMetaInline({required this.patient, required this.dark});

  final BookedPatient patient;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(patient.patientRm, style: _style),
          _PatientMetaDivider(dark: dark),
          Text('Usia ${patient.patientAge}', style: _style),
          _PatientMetaDivider(dark: dark),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: patient.badgeVariant == AmanahBadgeVariant.success
                  ? (dark
                        ? const Color(0xFF10B981).withValues(alpha: 0.20)
                        : const Color(0xFFECFDF5))
                  : (dark
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.20)
                        : const Color(0xFFEFF6FF)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              patient.badge,
              style: TextStyle(
                color: patient.badgeVariant == AmanahBadgeVariant.success
                    ? (dark ? const Color(0xFF34D399) : const Color(0xFF047857))
                    : (dark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF1D4ED8)),
                fontFamily: 'PlusJakartaSans',
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _style => TextStyle(
    color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}

class _PatientMetaDivider extends StatelessWidget {
  const _PatientMetaDivider({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: dark
          ? Colors.white.withValues(alpha: 0.20)
          : const Color(0xFFCBD5E1),
    );
  }
}

class _PatientSpecificationTable extends StatelessWidget {
  const _PatientSpecificationTable({
    required this.patient,
    required this.schedule,
    required this.dark,
  });

  final BookedPatient patient;
  final DoctorSchedule schedule;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _dividerColor),
          bottom: BorderSide(color: _dividerColor),
        ),
      ),
      child: Column(
        children: <Widget>[
          _PatientSpecRow(
            label: 'Waktu / jam booking',
            value: patient.timeSlot,
            dark: dark,
          ),
          _PatientSpecRow(
            label: 'Sesi praktik',
            value: '${schedule.title} (${schedule.poli})',
            dark: dark,
          ),
          _PatientSpecRow(
            label: 'Ruang praktik',
            value: schedule.room,
            dark: dark,
          ),
          if (patient.patientGuardian != null)
            _PatientSpecRow(
              label: 'Nama pendamping',
              value: patient.patientGuardian!,
              dark: dark,
            ),
          _PatientComplaintBlock(
            complaint: patient.patientComplaint.isEmpty
                ? 'Tidak ada catatan keluhan khusus.'
                : patient.patientComplaint,
            dark: dark,
          ),
        ],
      ),
    );
  }

  Color get _dividerColor =>
      dark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9);
}

class _PatientSpecRow extends StatelessWidget {
  const _PatientSpecRow({
    required this.label,
    required this.value,
    required this.dark,
  });

  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: dark ? Colors.white : const Color(0xFF0F172A),
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientComplaintBlock extends StatelessWidget {
  const _PatientComplaintBlock({required this.complaint, required this.dark});

  final String complaint;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Keluhan & catatan medis pasien',
            style: TextStyle(
              color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              complaint,
              style: TextStyle(
                color: dark ? const Color(0xFFE5E7EB) : const Color(0xFF1E293B),
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientDetailAuroraPainter extends CustomPainter {
  const _PatientDetailAuroraPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());

    final Paint baseGlow = Paint()
      ..color = (dark ? const Color(0xFF07247A) : const Color(0xFF0A44FF))
          .withValues(alpha: dark ? 0.60 : 0.50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 62);
    final Paint secondaryGlow = Paint()
      ..color = (dark ? const Color(0xFF1D4ED8) : const Color(0xFF3B82F6))
          .withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 56);

    final double baseHeight = dark ? 200 : 180;
    final double secondaryHeight = dark ? 140 : 130;
    final double baseTop = dark ? -size.height * 0.15 : -size.height * 0.10;
    final Rect baseOval = Rect.fromLTWH(
      -size.width * 0.20,
      baseTop,
      size.width * 1.40,
      baseHeight,
    );
    final Rect secondaryOval = Rect.fromLTWH(
      size.width * 0.20,
      size.height * 0.05,
      size.width,
      secondaryHeight,
    );

    canvas.drawOval(baseOval, baseGlow);
    canvas.drawOval(secondaryOval, secondaryGlow);

    final Paint fadeMask = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Colors.black, Colors.black, Colors.transparent],
        stops: <double>[0, 0.25, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, fadeMask);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PatientDetailAuroraPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class _QueueBadgePainter extends CustomPainter {
  _QueueBadgePainter(this.queueNumber);

  final String queueNumber;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 48;
    canvas.save();
    canvas.scale(scale, scale);

    final Paint ribbon = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFF93C5FD),
          Color(0xFF3B82F6),
          Color(0xFF1D4ED8),
        ],
      ).createShader(const Rect.fromLTWH(12, 20, 24, 32));
    canvas.drawPath(
      Path()
        ..moveTo(13.5, 22)
        ..lineTo(12.5, 50)
        ..lineTo(24, 43.5)
        ..lineTo(35.5, 50)
        ..lineTo(34.5, 22)
        ..close(),
      ribbon,
    );

    const Offset center = Offset(24, 21.5);
    final Paint outer = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.30, -0.40),
        radius: 0.80,
        colors: <Color>[
          Color(0xFF60A5FA),
          Color(0xFF2563EB),
          Color(0xFF1D4ED8),
          Color(0xFF172554),
        ],
        stops: <double>[0, 0.45, 0.85, 1],
      ).createShader(Rect.fromCircle(center: center, radius: 19));
    canvas.drawCircle(center, 19, outer);
    canvas.drawCircle(
      center,
      19,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF93C5FD),
    );
    canvas.drawArc(
      const Rect.fromLTWH(7.5, 4.5, 33, 33),
      math.pi * 1.08,
      math.pi * 0.84,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.55),
    );

    final Path rosette = Path();
    for (int i = 0; i < 20; i++) {
      final double angle = -math.pi / 2 + (math.pi * 2 / 20) * i;
      final double radius = i.isEven ? 15.3 : 12.2;
      final Offset p =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (i == 0) {
        rosette.moveTo(p.dx, p.dy);
      } else {
        rosette.lineTo(p.dx, p.dy);
      }
    }
    rosette.close();
    canvas.drawPath(rosette, Paint()..color = const Color(0xFFF0F9FF));
    canvas.drawPath(
      rosette,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFF3B82F6),
    );
    canvas.drawCircle(center, 10.5, Paint()..color = const Color(0xFFFFFFFF));
    canvas.drawCircle(
      center,
      10.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75
        ..color = const Color(0xFF93C5FD),
    );

    final String raw = queueNumber.replaceFirst('#', '');
    final String display = raw.isEmpty
        ? '01'
        : raw.length == 1
        ? '0$raw'
        : raw;
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: display,
        style: TextStyle(
          color: const Color(0xFF1D4ED8),
          fontFamily: 'PlusJakartaSans',
          fontSize: display.length > 2 ? 11 : 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(24 - painter.width / 2, 21.5 - painter.height / 2 + 1.8),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _QueueBadgePainter oldDelegate) {
    return oldDelegate.queueNumber != queueNumber;
  }
}
