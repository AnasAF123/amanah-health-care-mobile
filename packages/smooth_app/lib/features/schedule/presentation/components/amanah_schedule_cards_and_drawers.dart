import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';

const List<String> kNatureImagesPool = <String>[
  'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=800&auto=format&fit=crop',
  'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=800&auto=format&fit=crop',
];

const ColorFilter _kSaturate160 = ColorFilter.matrix(<double>[
  1.424,
  -0.376,
  -0.048,
  0,
  0,
  -0.076,
  1.124,
  -0.048,
  0,
  0,
  -0.076,
  -0.376,
  1.452,
  0,
  0,
  0,
  0,
  0,
  1,
  0,
]);

class _LiquidGlassMaskLayer extends StatelessWidget {
  const _LiquidGlassMaskLayer();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                Colors.black,
                Colors.black,
                Color(0x4D000000),
                Colors.transparent,
              ],
              stops: <double>[0.0, 0.35, 0.55, 0.75],
            ).createShader(bounds);
          },
          child: ColorFiltered(
            colorFilter: _kSaturate160,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: const ColoredBox(color: Color(0x01000000)),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmbientCardGradientLayer extends StatelessWidget {
  const _AmbientCardGradientLayer();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                const Color(0xFF0C140F).withValues(alpha: 0.82),
                const Color(0xFF0C140F).withValues(alpha: 0.40),
                const Color(0xFF0C140F).withValues(alpha: 0.0),
              ],
              stops: const <double>[0.0, 0.40, 0.70],
            ),
          ),
        ),
      ),
    );
  }
}

/// 4. Booked Patient Card (320px Liquid Glass with Nature Background)
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
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final String bgUrl =
        kNatureImagesPool[imageIndex % kNatureImagesPool.length];

    return Semantics(
      button: true,
      label: 'Pasien ${patient.patientName}, Antrean ${patient.queueNumber}',
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            // Layer 1: Nature Background
            Positioned.fill(
              child: Image.network(
                bgUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) => Container(color: const Color(0xFF0F172A)),
              ),
            ),

            // Layer 2: Full-card liquid-glass blur with a progressive top mask.
            const _LiquidGlassMaskLayer(),

            // Layer 3: High-contrast ambient gradient for readable text.
            const _AmbientCardGradientLayer(),

            // Layer 4: Top Badges (Status on Left, Queue on Right)
            Positioned(
              top: 16,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF0A0E1A).withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
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
                            color: patient.badgeVariant.color,
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

            Positioned(
              top: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF0A0E1A).withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Antrean ${patient.queueNumber}',
                      style: TextStyle(
                        color: dark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Layer 5: Content Overlay at Bottom
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
                    // Avatar & Patient Details
                    Row(
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E293B),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              patient.avatarUrl ??
                                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error,
                                      StackTrace? stack) =>
                                  ColoredBox(
                                color: const Color(0xFF334155),
                                child: Center(
                                  child: Text(
                                    patient.patientName.isNotEmpty
                                        ? patient.patientName.substring(0, 1)
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${patient.patientRm} • Usia ${patient.patientAge}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
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
                    const SizedBox(height: 10),

                    // Session, Poli, Room
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            '${schedule.title} • ${schedule.poli}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          schedule.room,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Time Slot
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.access_time_filled_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          patient.timeSlot,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Glass Divider
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                    const SizedBox(height: 12),

                    // Action Button: Detail Pasien
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: onTapDetail,
                        child: const Text(
                          'Detail Pasien',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
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
    );
  }
}

/// 5. Doctor Practice Session Card (360px Liquid Glass)
class AmanahDoctorSessionCard extends StatelessWidget {
  const AmanahDoctorSessionCard({
    required this.schedule,
    required this.imageIndex,
    required this.onTapDetail,
    required this.onTapEdit,
    required this.onTapDelete,
    super.key,
  });

  final DoctorSchedule schedule;
  final int imageIndex;
  final VoidCallback onTapDetail;
  final VoidCallback onTapEdit;
  final VoidCallback onTapDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final String bgUrl =
        kNatureImagesPool[imageIndex % kNatureImagesPool.length];
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
            border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
          children: <Widget>[
            // Layer 1: Nature Background
            Positioned.fill(
              child: Image.network(
                bgUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) => Container(color: const Color(0xFF0F172A)),
              ),
            ),

            // Layer 2: Full-card liquid-glass blur with the same mask as patient cards.
            const _LiquidGlassMaskLayer(),

            // Layer 3: Ambient contrast wash.
            const _AmbientCardGradientLayer(),

            // Layer 4: Top Badges (Status & Booked Count)
            Positioned(
              top: 16,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF0A0E1A).withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
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
                            color: schedule.badgeVariant.color,
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
              top: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF0A0E1A).withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
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
                          color: dark ? Colors.white : const Color(0xFF0F172A),
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

            // Layer 5: Content Overlay at Bottom
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
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
                                '${schedule.poli} • ${schedule.room}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                schedule.date,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
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
                                    const Icon(
                                      Icons.access_time_filled_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      startTime,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mulai',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 1,
                              height: 24,
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.access_time_filled_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      endTime,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Selesai',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Divider
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                    const SizedBox(height: 12),

                    // Action Buttons (Detail Sesi + Edit + Delete)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0F172A),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: onTapDetail,
                              child: const Text(
                                'Detail Sesi',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Edit Button
                        Semantics(
                          button: true,
                          label: 'Edit Jadwal',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: onTapEdit,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Delete Button
                        Semantics(
                          button: true,
                          label: 'Hapus Jadwal',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: onTapDelete,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE11D48,
                                ).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(
                                    0xFFE11D48,
                                  ).withValues(alpha: 0.40),
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Color(0xFFFECDD3),
                              ),
                            ),
                          ),
                        ),
                      ],
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
    super.key,
  });

  final DoctorSchedule schedule;
  final bool isDayCuti;
  final VoidCallback onViewPatients;
  final VoidCallback onTapEdit;

  static void show(
    BuildContext context, {
    required DoctorSchedule schedule,
    required bool isDayCuti,
    required VoidCallback onViewPatients,
    required VoidCallback onTapEdit,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (BuildContext ctx) => AmanahScheduleDetailDrawer(
        schedule: schedule,
        isDayCuti: isDayCuti,
        onViewPatients: onViewPatients,
        onTapEdit: onTapEdit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double targetHeight = screenHeight * 0.85;

    return SizedBox(
      height: targetHeight,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0A0E1A) : Colors.white,
            border: Border(
              top: BorderSide(
                color: dark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0xFFF5F5F5),
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 45,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              // Interactive Drag Handle
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.25)
                            : const Color(0xFFD4D4D8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),

              // Master Header (Detail Sesi Praktik)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 2, 24, 12),
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
                  children: <Widget>[
                    Text(
                      'Detail Sesi Praktik',
                      style: TextStyle(
                        color: dark ? Colors.white : const Color(0xFF0F172A),
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: dark
                              ? const Color(0xFFD4D4D8)
                              : const Color(0xFF52525B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Detail Content Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    20,
                    24,
                    28 + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
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
                                    color: dark
                                        ? Colors.white
                                        : const Color(0xFF020617),
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
                                  : (schedule.badgeVariant ==
                                          AmanahBadgeVariant.success
                                      ? (dark
                                          ? const Color(0xFF10B981)
                                              .withValues(alpha: 0.20)
                                          : const Color(0xFFECFDF5))
                                      : schedule.badgeVariant ==
                                              AmanahBadgeVariant.warning
                                          ? (dark
                                              ? const Color(0xFFF59E0B)
                                                  .withValues(alpha: 0.20)
                                              : const Color(0xFFFEF3C7))
                                          : (dark
                                              ? const Color(0xFF3B82F6)
                                                  .withValues(alpha: 0.20)
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
                                        : schedule.badgeVariant.color,
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
                                              ? const Color(0xFF22D3EE)
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
                                    ? const Color(0xFF22D3EE)
                                    : const Color(0xFF2563EB),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Button: Ubah Sesi Praktik
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dark
                                ? const Color(0xFF06B6D4)
                                : const Color(0xFF2563EB),
                            foregroundColor:
                                dark ? const Color(0xFF083344) : Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: dark
                                ? const Color(0xFF06B6D4).withValues(alpha: 0.30)
                                : const Color(0xFF2563EB).withValues(alpha: 0.30),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            onTapEdit();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.edit_outlined, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Ubah Sesi Praktik',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
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
            ],
          ),
        ),
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
                color: dark ? const Color(0xFF22D3EE) : const Color(0xFF2563EB),
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (BuildContext ctx) =>
          AmanahPatientDetailModal(patient: patient, schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final double maxHeight = MediaQuery.sizeOf(context).height * 0.92;
    final double minHeight = math.min(540, maxHeight);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight, minHeight: minHeight),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0A0E1A) : Colors.white,
            border: Border(
              top: BorderSide(
                color: dark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0xFFF5F5F5),
              ),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 45,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 320,
                child: CustomPaint(
                  painter: _PatientDetailAuroraPainter(dark: dark),
                ),
              ),
              Column(
                children: <Widget>[
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.25)
                                : const Color(0xFFD4D4D8),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 2, 24, 10),
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
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Detail Rekam Pasien',
                            style: TextStyle(
                              color: dark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: dark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : const Color(
                                      0xFFF5F5F5,
                                    ).withValues(alpha: 0.80),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: dark
                                  ? const Color(0xFFD4D4D8)
                                  : const Color(0xFF52525B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                      child: Column(
                        children: <Widget>[
                          _PatientProfileHeader(patient: patient, dark: dark),
                          const SizedBox(height: 16),
                          _PatientSpecificationTable(
                            patient: patient,
                            schedule: schedule,
                            dark: dark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      8,
                      24,
                      28 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: _PatientCloseButton(
                      dark: dark,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
                    errorBuilder: (BuildContext context, Object error,
                            StackTrace? stack) =>
                        ColoredBox(
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
                            color:
                                dark ? Colors.white : const Color(0xFF1E293B),
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
            label: 'Waktu / Jam Booking',
            value: patient.timeSlot,
            dark: dark,
          ),
          _PatientSpecRow(
            label: 'Sesi Praktik',
            value: '${schedule.title} (${schedule.poli})',
            dark: dark,
          ),
          _PatientSpecRow(
            label: 'Ruang Praktik',
            value: schedule.room,
            dark: dark,
          ),
          if (patient.patientGuardian != null)
            _PatientSpecRow(
              label: 'Nama Pendamping',
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
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
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
            'Keluhan & Catatan Medis Pasien',
            style: TextStyle(
              color: dark ? const Color(0xFFA1A1AA) : const Color(0xFF64748B),
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
                fontWeight: FontWeight.w700,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientCloseButton extends StatefulWidget {
  const _PatientCloseButton({required this.dark, required this.onTap});

  final bool dark;
  final VoidCallback onTap;

  @override
  State<_PatientCloseButton> createState() => _PatientCloseButtonState();
}

class _PatientCloseButtonState extends State<_PatientCloseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 90),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: widget.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.dark
                    ? Colors.white.withValues(alpha: 0.15)
                    : const Color(0xFFE2E8F0),
              ),
              boxShadow: widget.dark
                  ? null
                  : <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Tutup Detail Pasien',
              style: TextStyle(
                color: widget.dark
                    ? const Color(0xFFD4D4D8)
                    : const Color(0xFF334155),
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
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
    final Paint cyanGlow = Paint()
      ..color = (dark ? const Color(0xFF0088CC) : const Color(0xFF00D4FF))
          .withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 56);

    final double baseHeight = dark ? 200 : 180;
    final double cyanHeight = dark ? 140 : 130;
    final double baseTop = dark ? -size.height * 0.15 : -size.height * 0.10;
    final Rect baseOval = Rect.fromLTWH(
      -size.width * 0.20,
      baseTop,
      size.width * 1.40,
      baseHeight,
    );
    final Rect cyanOval = Rect.fromLTWH(
      size.width * 0.20,
      size.height * 0.05,
      size.width,
      cyanHeight,
    );

    canvas.drawOval(baseOval, baseGlow);
    canvas.drawOval(cyanOval, cyanGlow);

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
          Color(0xFF7DD3FC),
          Color(0xFF38BDF8),
          Color(0xFF0284C7),
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
    canvas.drawPath(
      Path()
        ..moveTo(19.5, 22)
        ..lineTo(19.5, 46.2)
        ..lineTo(24, 43.5)
        ..lineTo(28.5, 46.2)
        ..lineTo(28.5, 22)
        ..close(),
      Paint()..color = const Color(0xFFE0F2FE),
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
        ..color = const Color(0xFF38BDF8),
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
