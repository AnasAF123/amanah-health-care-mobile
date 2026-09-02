import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_status_badge.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_schedule_card_tokens.dart';
import 'package:smooth_app/features/schedule/domain/amanah_schedule_model.dart';

/// Organism: Stack of 3D Doctor Schedule Cards on the Home Screen.
/// Provides drag swipe mechanics, 3D card layering depth, and dismiss animations.
/// Matching ScheduleCardStack.tsx (.web) 1:1
class AmanahScheduleCardStack extends StatefulWidget {
  const AmanahScheduleCardStack({
    required this.schedules,
    this.onCardTap,
    super.key,
  });

  final List<DoctorSchedule> schedules;
  final ValueChanged<DoctorSchedule>? onCardTap;

  @override
  State<AmanahScheduleCardStack> createState() =>
      _AmanahScheduleCardStackState();
}

class _AmanahScheduleCardStackState extends State<AmanahScheduleCardStack>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  double _dragOffset = 0.0;
  bool _isDragging = false;

  late final AnimationController _shuffleController;
  late final AnimationController _cancelController;
  double _shuffleDirection = 1.0;
  double _startDragX = 0.0;
  double _cancelStartOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.schedules.length;
            _dragOffset = 0.0;
            _startDragX = 0.0;
            _shuffleController.reset();
          });
        }
      });

    _cancelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _dragOffset = 0.0;
            _cancelController.reset();
          });
        }
      });
  }

  void _dismissCard() {
    if (widget.schedules.isEmpty || _shuffleController.isAnimating) {
      return;
    }
    _cancelController.stop();
    _shuffleDirection = 1.0;
    _startDragX = 0.0;
    _isDragging = false;
    _shuffleController.forward(from: 0.0);
  }

  void _handleDragEnd([DragEndDetails? details]) {
    if (!_isDragging) {
      return;
    }
    _isDragging = false;

    // Detect simple tap to trigger onCardTap
    if (_dragOffset.abs() < 6) {
      final int safeIndex = _currentIndex % widget.schedules.length;
      widget.onCardTap?.call(widget.schedules[safeIndex]);
      setState(() {
        _dragOffset = 0;
      });
      return;
    }

    final double vx = details?.velocity.pixelsPerSecond.dx ?? 0.0;
    // Drag past 45px or swift flick triggers shuffle animation
    if (_dragOffset.abs() > 45 || vx.abs() > 300) {
      _shuffleDirection = _dragOffset != 0 ? _dragOffset.sign : (vx != 0 ? vx.sign : 1.0);
      _startDragX = _dragOffset;
      _shuffleController.forward(from: 0.0);
    } else {
      _cancelStartOffset = _dragOffset;
      _cancelController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    _cancelController.dispose();
    super.dispose();
  }

  Widget _buildCardItem({
    required DoctorSchedule schedule,
    required double x,
    required double y,
    required double scale,
    required double rotation,
    required double opacity,
    required bool isInteractive,
  }) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.translationValues(x, y, 0.0)
            ..rotateZ(rotation)
            ..scaleByDouble(scale, scale, 1.0, 1.0),
          child: IgnorePointer(
            ignoring: !isInteractive,
            child: RepaintBoundary(
              child: AmanahScheduleCard(
                schedule: schedule,
                onDismiss: _dismissCard,
                onCardTap: widget.onCardTap != null
                    ? () => widget.onCardTap!(schedule)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedules.isEmpty) {
      return const SizedBox.shrink();
    }

    final int total = widget.schedules.length;

    if (total == 1) {
      return SizedBox(
        height: AmanahScheduleCardTokens.cardHeight,
        width: double.infinity,
        child: RepaintBoundary(
          child: AmanahScheduleCard(
            schedule: widget.schedules[0],
            onDismiss: () {},
            onCardTap: widget.onCardTap != null
                ? () => widget.onCardTap!(widget.schedules[0])
                : null,
          ),
        ),
      );
    }

    final bool isShuffling = _shuffleController.isAnimating;
    final bool isCancelling = _cancelController.isAnimating;
    final double tShuffle = _shuffleController.value;
    final double tCancel = _cancelController.value;

    final DoctorSchedule schedule0 = widget.schedules[_currentIndex % total];
    final DoctorSchedule schedule1 = widget.schedules[(_currentIndex + 1) % total];
    final DoctorSchedule schedule2 = widget.schedules[(_currentIndex + (total > 2 ? 2 : 0)) % total];

    double card0X = 0.0;
    double card0Y = 0.0;
    double card0Scale = 1.0;
    double card0Rot = 0.0;
    double card0Opacity = 1.0;

    const double card1X = 0.0;
    double card1Y = 14.0;
    double card1Scale = 0.92;
    const double card1Rot = 0.0;
    double card1Opacity = 0.95;

    const double card2X = 0.0;
    double card2Y = 28.0;
    double card2Scale = 0.84;
    const double card2Rot = 0.0;
    double card2Opacity = 0.80;

    bool card0InBack = false;

    if (_isDragging) {
      final double dragProg = (_dragOffset.abs() / 200.0).clamp(0.0, 1.0);
      card0X = _dragOffset;
      card0Rot = _dragOffset * 0.035 * (math.pi / 180.0);
      card0Y = 0.0;
      card0Scale = 1.0;
      card0Opacity = 1.0;

      card1Y = 14.0 * (1.0 - dragProg);
      card1Scale = 0.92 + 0.08 * dragProg;
      card1Opacity = 0.95 + 0.05 * dragProg;

      card2Y = 28.0 - 14.0 * dragProg;
      card2Scale = 0.84 + 0.08 * dragProg;
      card2Opacity = 0.80 + 0.15 * dragProg;
    } else if (isCancelling) {
      final double cancelProgress = Curves.easeOutCubic.transform(tCancel);
      final double currentDrag = _cancelStartOffset * (1.0 - cancelProgress);
      final double dragProg = (currentDrag.abs() / 200.0).clamp(0.0, 1.0);

      card0X = currentDrag;
      card0Rot = currentDrag * 0.035 * (math.pi / 180.0);

      card1Y = 14.0 * (1.0 - dragProg);
      card1Scale = 0.92 + 0.08 * dragProg;
      card1Opacity = 0.95 + 0.05 * dragProg;

      card2Y = 28.0 - 14.0 * dragProg;
      card2Scale = 0.84 + 0.08 * dragProg;
      card2Opacity = 0.80 + 0.15 * dragProg;
    } else if (isShuffling) {
      final double screenW = MediaQuery.sizeOf(context).width;
      final double peakX = _shuffleDirection * (screenW * 0.72).clamp(240.0, 320.0);

      if (tShuffle < 0.48) {
        // Phase 1: Fly outward
        final double p1 = (tShuffle / 0.48).clamp(0.0, 1.0);
        final double curve1 = Curves.easeOutQuad.transform(p1);

        card0X = _startDragX + (peakX - _startDragX) * curve1;
        card0Y = 10.0 * curve1;
        card0Scale = 1.0 - 0.06 * curve1;
        card0Rot = (_startDragX * 0.035 + _shuffleDirection * 7.0 * curve1) * (math.pi / 180.0);
        card0Opacity = 1.0 - 0.08 * curve1;
        card0InBack = false;
      } else {
        // Phase 2: Slip behind stack and glide into bottom slot
        final double p2 = ((tShuffle - 0.48) / 0.52).clamp(0.0, 1.0);
        final double curve2 = Curves.easeOutCubic.transform(p2);

        card0X = peakX * (1.0 - curve2);
        card0Y = 10.0 + (28.0 - 10.0) * curve2;
        card0Scale = 0.94 - 0.10 * curve2;
        card0Rot = (_shuffleDirection * 7.0 * (1.0 - curve2)) * (math.pi / 180.0);
        card0Opacity = 0.92 - 0.12 * curve2;
        card0InBack = true;
      }

      final double tElevate = Curves.easeOutCubic.transform(tShuffle);
      card1Y = 14.0 * (1.0 - tElevate);
      card1Scale = 0.92 + 0.08 * tElevate;
      card1Opacity = 0.95 + 0.05 * tElevate;

      card2Y = 28.0 - 14.0 * tElevate;
      card2Scale = 0.84 + 0.08 * tElevate;
      card2Opacity = 0.80 + 0.15 * tElevate;
    }

    final Widget card0Widget = _buildCardItem(
      schedule: schedule0,
      x: card0X,
      y: card0Y,
      scale: card0Scale,
      rotation: card0Rot,
      opacity: card0Opacity,
      isInteractive: !_isDragging && !isShuffling && !isCancelling,
    );

    final Widget card1Widget = _buildCardItem(
      schedule: schedule1,
      x: card1X,
      y: card1Y,
      scale: card1Scale,
      rotation: card1Rot,
      opacity: card1Opacity,
      isInteractive: false,
    );

    final Widget card2Widget = _buildCardItem(
      schedule: schedule2,
      x: card2X,
      y: card2Y,
      scale: card2Scale,
      rotation: card2Rot,
      opacity: card2Opacity,
      isInteractive: false,
    );

    final List<Widget> stackChildren = total == 2
        ? (card0InBack
            ? <Widget>[card0Widget, card1Widget]
            : <Widget>[card1Widget, card0Widget])
        : (card0InBack
            ? <Widget>[card0Widget, card2Widget, card1Widget]
            : <Widget>[card2Widget, card1Widget, card0Widget]);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.schedules.isNotEmpty && !isShuffling) {
          final int safeIndex = _currentIndex % widget.schedules.length;
          widget.onCardTap?.call(widget.schedules[safeIndex]);
        }
      },
      onHorizontalDragStart: (DragStartDetails details) {
        if (isShuffling) {
          return;
        }
        if (isCancelling) {
          _cancelController.stop();
        }
        setState(() {
          _isDragging = true;
        });
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (isShuffling) {
          return;
        }
        setState(() {
          _dragOffset += details.delta.dx;
        });
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        _handleDragEnd(details);
      },
      onHorizontalDragCancel: () {
        _handleDragEnd();
      },
      child: SizedBox(
        height: AmanahScheduleCardTokens.stackHeight,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: stackChildren,
        ),
      ),
    );
  }
}

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

  String _formatSlotText() {
    if (schedule.bookedPatients.isNotEmpty) {
      return '${schedule.bookedPatients.length} Pasien';
    }
    final String raw =
        schedule.slotCount.replaceAll(RegExp(r'\s*/\s*\d+'), '').trim();
    if (int.tryParse(raw) != null) {
      return '$raw Pasien';
    }
    if (schedule.slotCount.isNotEmpty) {
      return '${schedule.slotCount} Pasien';
    }
    return '12 Pasien';
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
                child: CustomPaint(
                  painter: _AmanahCardBasePainter(dark: dark),
                ),
              ),

              // Layer 2: Authentic 3D Geometric Crystal Texture Asset
              Positioned.fill(
                child: Image.asset(
                  bgAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
                    return Container(
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
                  painter: _AmanahPerforatedLinePainter(dark: dark),
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
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.2,
                                            height: 1.15,
                                            color: dark
                                                ? AmanahScheduleCardTokens.titleColorDark
                                                : AmanahScheduleCardTokens.titleColorLight,
                                          ),
                                        ),
                                      ),
                                      if (sessionLabel.isNotEmpty) ...<Widget>[
                                        Container(
                                          width: 1.5,
                                          height: 11,
                                          margin: const EdgeInsets.symmetric(horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: dark
                                                ? Colors.white.withValues(alpha: 0.25)
                                                : const Color(0xFFCBD5E1),
                                            borderRadius: BorderRadius.circular(1),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            sessionLabel,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: dark
                                                  ? const Color(0xFF3B82F6)
                                                  : const Color(0xFF0D66E9),
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
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: dark
                                          ? AmanahScheduleCardTokens.dateColorDark
                                          : AmanahScheduleCardTokens.dateColorLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            AmanahDismissButton(onTap: onDismiss),
                          ],
                        ),

                        // Center Row: Compact Primary Time & Status Badge
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                schedule.time,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
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
                            const SizedBox(width: 8),
                            AmanahStatusBadge(
                              variant: schedule.badgeVariant,
                              text: schedule.badge,
                            ),
                          ],
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
                                  Text(
                                    schedule.poli,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                      color: dark
                                          ? AmanahScheduleCardTokens.poliColorDark
                                          : AmanahScheduleCardTokens.poliColorLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    schedule.room,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w500,
                                      height: 1.15,
                                      color: dark
                                          ? AmanahScheduleCardTokens.roomColorDark
                                          : AmanahScheduleCardTokens.roomColorLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Right: Clean Integrated Booking Pill
                            Flexible(
                              flex: 0,
                              child: AmanahBookingPill(
                                patientCount: _formatSlotText(),
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

/// Atom: Clean minimalist circular dismiss button matching Web ScheduleCard.tsx
class AmanahDismissButton extends StatelessWidget {
  const AmanahDismissButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: 'Tutup jadwal',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: dark
                  ? AmanahScheduleCardTokens.dismissBtnBgDark
                  : AmanahScheduleCardTokens.dismissBtnBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: dark
                  ? AmanahScheduleCardTokens.dismissBtnIconColorDark
                  : AmanahScheduleCardTokens.dismissBtnIconColorLight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Atom: Clean Integrated Booking Pill matching Web ScheduleCard.tsx
class AmanahBookingPill extends StatelessWidget {
  const AmanahBookingPill({
    required this.patientCount,
    this.statusText = 'Terdaftar',
    super.key,
  });

  final String patientCount;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: dark
            ? AmanahScheduleCardTokens.bookingPillBgDark
            : AmanahScheduleCardTokens.bookingPillBgLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            patientCount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: dark
                  ? AmanahScheduleCardTokens.bookingPillTextDark
                  : AmanahScheduleCardTokens.bookingPillTextLight,
            ),
          ),
          if (statusText.isNotEmpty) ...<Widget>[
            const SizedBox(width: 3.5),
            Text(
              statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: dark
                    ? AmanahScheduleCardTokens.roomColorDark
                    : AmanahScheduleCardTokens.roomColorLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom Clipper for Ticket Silhouette with smooth corner radii and C-notches.
/// Matching SVG Ticket Path from ScheduleCard.tsx (.web)
class AmanahTicketClipper extends CustomClipper<Path> {
  const AmanahTicketClipper();

  @override
  Path getClip(Size size) {
    const double radius = AmanahScheduleCardTokens.cornerRadius;
    const double notchRadius = AmanahScheduleCardTokens.notchRadius;
    const double notchCenterY = AmanahScheduleCardTokens.notchCenterY;

    final Path path = Path()
      // Top Left Corner
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      // Top Right Corner
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      // Right Edge to Top of Right Notch
      ..lineTo(size.width, notchCenterY - notchRadius)
      // Inward Right "C" Notch
      ..arcToPoint(
        Offset(size.width, notchCenterY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      // Right Edge to Bottom Right Corner
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      // Bottom Edge to Bottom Left Corner
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      // Left Edge to Bottom of Left Notch
      ..lineTo(0, AmanahScheduleCardTokens.notchEndY)
      // Inward Left "C" Notch
      ..arcToPoint(
        const Offset(0, AmanahScheduleCardTokens.notchStartY),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      // Left Edge to Top Left Corner
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant AmanahTicketClipper oldClipper) => false;
}

/// Custom Painter for Solid Base Fill & Ticket Border Stroke
class _AmanahCardBasePainter extends CustomPainter {
  const _AmanahCardBasePainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = const AmanahTicketClipper().getClip(size);

    // Solid Background Fill
    final Paint fillPaint = Paint()
      ..color = dark
          ? AmanahScheduleCardTokens.cardBgDark
          : AmanahScheduleCardTokens.cardBgLight
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Subtle Outer Stroke
    final Paint strokePaint = Paint()
      ..color = dark
          ? AmanahScheduleCardTokens.borderStrokeDark
          : AmanahScheduleCardTokens.borderStrokeLight
      ..strokeWidth = AmanahScheduleCardTokens.borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _AmanahCardBasePainter oldDelegate) =>
      oldDelegate.dark != dark;
}

/// Custom Painter for the Wall-to-Wall Perforated Dashed Line between C-Notches
class _AmanahPerforatedLinePainter extends CustomPainter {
  const _AmanahPerforatedLinePainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dashPaint = Paint()
      ..color = dark
          ? AmanahScheduleCardTokens.dashedLineColorDark
          : AmanahScheduleCardTokens.dashedLineColorLight
      ..strokeWidth = AmanahScheduleCardTokens.dashedLineWidth
      ..style = PaintingStyle.stroke;

    const double startX = 10.0;
    final double endX = size.width - 10.0;
    const double y = AmanahScheduleCardTokens.notchCenterY;

    const double dashWidth = 4.0;
    const double dashGap = 4.0;

    double currentX = startX;
    while (currentX < endX) {
      final double nextX = (currentX + dashWidth).clamp(startX, endX);
      canvas.drawLine(Offset(currentX, y), Offset(nextX, y), dashPaint);
      currentX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _AmanahPerforatedLinePainter oldDelegate) =>
      oldDelegate.dark != dark;
}
