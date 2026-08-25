import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_status_badge.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AmanahScheduleCardStack extends StatefulWidget {
  const AmanahScheduleCardStack({required this.schedules, super.key});

  final List<AmanahSchedule> schedules;

  @override
  State<AmanahScheduleCardStack> createState() =>
      _AmanahScheduleCardStackState();
}

class _AmanahScheduleCardStackState extends State<AmanahScheduleCardStack> {
  int _currentIndex = 0;
  double _dragOffset = 0;

  void _showNext() {
    if (widget.schedules.isEmpty) {
      return;
    }
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.schedules.length;
      _dragOffset = 0;
    });
  }

  void _showPrevious() {
    if (widget.schedules.isEmpty) {
      return;
    }
    setState(() {
      _currentIndex =
          (_currentIndex - 1 + widget.schedules.length) %
          widget.schedules.length;
      _dragOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedules.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        setState(() => _dragOffset += details.delta.dx);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_dragOffset.abs() > 65) {
          if (_dragOffset > 0) {
            _showPrevious();
          } else {
            _showNext();
          }
        } else {
          setState(() => _dragOffset = 0);
        }
      },
      child: SizedBox(
        height: 223,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: List<Widget>.generate(3, (int index) {
            final int depth = 2 - index;
            final AmanahSchedule schedule =
                widget.schedules[(_currentIndex + depth) %
                    widget.schedules.length];
            final bool front = depth == 0;
            final double drag = front ? _dragOffset : 0;
            final double depthOffset = depth == 0 ? 0 : depth == 1 ? 14 : 28;
            final double scale = depth == 0 ? 1 : depth == 1 ? 0.92 : 0.84;
            final double opacity = depth == 0 ? 1 : depth == 1 ? 0.95 : 0.8;

            return Positioned(
              top: depthOffset,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: opacity,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  transformAlignment: Alignment.topCenter,
                  transform: Matrix4.identity()
                    ..translate(drag)
                    ..rotateZ(drag * 0.0007)
                    ..scale(scale),
                  child: IgnorePointer(
                    ignoring: !front,
                    child: AmanahScheduleCard(
                      schedule: schedule,
                      onDismiss: _showNext,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class AmanahScheduleCard extends StatelessWidget {
  const AmanahScheduleCard({
    required this.schedule,
    required this.onDismiss,
    super.key,
  });

  final AmanahSchedule schedule;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color heading = dark ? Colors.white : const Color(0xFF1E293B);
    final Color muted = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Semantics(
      label: '${schedule.title}, ${schedule.time}',
      child: SizedBox(
        height: 172,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.24 : 0.06),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipPath(
            clipper: const _AmanahTicketClipper(),
            child: CustomPaint(
              painter: _AmanahScheduleCardPainter(dark: dark),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                schedule.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: heading,
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                schedule.date,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: muted,
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _AmanahDismissButton(onTap: onDismiss, color: muted),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            schedule.time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: dark ? Colors.white : const Color(0xFF0F172A),
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                        AmanahStatusBadge(
                          variant: schedule.badgeVariant,
                          text: schedule.badge,
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: _ScheduleFooterText(
                            title: schedule.poli,
                            subtitle: schedule.room,
                            alignEnd: false,
                            heading: heading,
                            muted: muted,
                          ),
                        ),
                        _ScheduleFooterText(
                          title: schedule.slotCount,
                          subtitle: schedule.slotText,
                          alignEnd: true,
                          heading: heading,
                          muted: muted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AmanahDismissButton extends StatelessWidget {
  const _AmanahDismissButton({required this.onTap, required this.color});

  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tutup jadwal',
      child: SizedBox(
        width: 32,
        height: 32,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(Icons.close_rounded, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

class _ScheduleFooterText extends StatelessWidget {
  const _ScheduleFooterText({
    required this.title,
    required this.subtitle,
    required this.alignEnd,
    required this.heading,
    required this.muted,
  });

  final String title;
  final String subtitle;
  final bool alignEnd;
  final Color heading;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: theme.textTheme.labelMedium?.copyWith(
            color: heading,
            fontFamily: 'PlusJakartaSans',
            fontSize: 13,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

class _AmanahScheduleCardPainter extends CustomPainter {
  const _AmanahScheduleCardPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = const _AmanahTicketClipper().getClip(size);
    final Paint fill = Paint()
      ..color = dark ? const Color(0xF2171717) : Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawPath(path, fill);

    final Paint waveOne = Paint()
      ..shader = LinearGradient(
        colors: dark
            ? <Color>[
                const Color(0xFF1E293B).withValues(alpha: 0.42),
                const Color(0xFF0F172A).withValues(alpha: 0.18),
              ]
            : <Color>[
                Colors.white.withValues(alpha: 0.96),
                const Color(0xFFF8FAFF).withValues(alpha: 0.56),
                const Color(0xFFF1F5F9).withValues(alpha: 0.24),
              ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    final Path waveOnePath = Path()
      ..moveTo(-30, size.height + 18)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.62,
        size.width * 0.38,
        size.height * 0.32,
        size.width + 10,
        15,
      )
      ..lineTo(size.width + 10, size.height + 18)
      ..close();
    canvas.drawPath(waveOnePath, waveOne);

    final Paint waveTwo = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: dark
            ? <Color>[
                const Color(0xFF38BDF8).withValues(alpha: 0.14),
                const Color(0xFF0284C7).withValues(alpha: 0.04),
              ]
            : <Color>[
                Colors.white.withValues(alpha: 0.95),
                const Color(0xFFF8FAFF).withValues(alpha: 0.58),
                const Color(0xFFF1F5F9).withValues(alpha: 0.22),
              ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    final Path waveTwoPath = Path()
      ..moveTo(40, -20)
      ..cubicTo(
        size.width * 0.42,
        42,
        size.width * 0.62,
        size.height * 0.70,
        size.width + 30,
        size.height * 0.55,
      )
      ..lineTo(size.width + 30, -20)
      ..close();
    canvas.drawPath(waveTwoPath, waveTwo);

    final Paint dashPaint = Paint()
      ..color = dark
          ? Colors.white.withValues(alpha: 0.20)
          : const Color(0xFFCBD5E1).withValues(alpha: 0.95)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    _drawDashedLine(
      canvas,
      Offset(10, size.height * 0.66),
      Offset(size.width - 10, size.height * 0.66),
      dashPaint,
    );

    final Paint stroke = Paint()
      ..color = dark
          ? Colors.white.withValues(alpha: 0.16)
          : const Color(0xFFCBD5E1).withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;
    canvas.drawPath(path, stroke);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashWidth = 4;
    const double dashGap = 4;
    final double distance = (end - start).distance;
    final Offset direction = (end - start) / distance;
    double drawn = 0;
    while (drawn < distance) {
      final Offset dashStart = start + direction * drawn;
      final Offset dashEnd =
          start + direction * (drawn + dashWidth).clamp(0, distance);
      canvas.drawLine(dashStart, dashEnd, paint);
      drawn += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _AmanahScheduleCardPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}

class _AmanahTicketClipper extends CustomClipper<Path> {
  const _AmanahTicketClipper();

  @override
  Path getClip(Size size) {
    const double radius = 24;
    const double notchRadius = 11;
    final double notchY = size.height * 0.66;
    final Path path = Path()
      ..moveTo(radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, notchY - notchRadius)
      ..arcToPoint(
        Offset(size.width, notchY + notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, notchY + notchRadius)
      ..arcToPoint(
        Offset(0, notchY - notchRadius),
        radius: const Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _AmanahTicketClipper oldClipper) => false;
}
