import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Configuration parameters for the 3D Isometric Empty Box
/// Exactly mirroring SCENE_CONFIG from emptystate.html
class AmanahIsometricBoxConfig {
  const AmanahIsometricBoxConfig._();

  static const double radiusX = 64.0;
  static const double radiusY = 34.0;
  static const double height = 62.0;
  static const double depth = 46.0;
  static const double flapLength = 0.52;
  static const double maxFlapAngle = 3.65;

  static const double cycleDuration = 7.5; // seconds
  static const double boxOpenStart = 0.8;
  static const double boxOpenEnd = 2.2;
  static const double flyEmergeStart = 2.2;
  static const double flyEmergeEnd = 4.6;
  static const double holdEnd = 6.8;
}

/// Color theme for the 3D Isometric Empty Box.
/// Light mode values match 1:1 with emptystate.html.
class AmanahIsometricBoxColors {
  const AmanahIsometricBoxColors({
    required this.exteriorLeft,
    required this.exteriorRight,
    required this.interiorBackLeft,
    required this.interiorBackRight,
    required this.interiorFloor,
    required this.flapBackLeft,
    required this.flapBackRight,
    required this.flapFrontLeft,
    required this.flapFrontRight,
    required this.strokeBox,
    required this.strokeTrail,
    required this.sparkle,
    required this.insectBody,
    required this.insectWing,
    required this.caption,
    required this.groundShadow,
  });

  /// Exact colors from emptystate.html
  factory AmanahIsometricBoxColors.light() {
    return const AmanahIsometricBoxColors(
      exteriorLeft: Color(0xFFF1F5F9),
      exteriorRight: Color(0xFFD8E1ED),
      interiorBackLeft: Color(0xFFB9C6D8),
      interiorBackRight: Color(0xFFA4B4CC),
      interiorFloor: Color(0xFF91A2BC),
      flapBackLeft: Color(0xFFE2E9F3),
      flapBackRight: Color(0xFFCBD6E6),
      flapFrontLeft: Color(0xFFF1F5F9),
      flapFrontRight: Color(0xFFC6D3E4),
      strokeBox: Color(0x73B4C3D7), // rgba(180, 195, 215, 0.45)
      strokeTrail: Color(0xFFA4B3C8),
      sparkle: Color(0xFFB8C5D8),
      insectBody: Color(0xFF59667A),
      insectWing: Color(0xBFC3D0E2), // rgba(195, 208, 226, 0.75)
      caption: Color(0xFF94A3B8),
      groundShadow: Color(0xA6E2E8F0), // rgba(226, 232, 240, 0.65)
    );
  }

  /// Adaptive dark mode palette maintaining identical isometric contrast
  factory AmanahIsometricBoxColors.dark() {
    return const AmanahIsometricBoxColors(
      exteriorLeft: Color(0xFF1E293B),
      exteriorRight: Color(0xFF0F172A),
      interiorBackLeft: Color(0xFF162032),
      interiorBackRight: Color(0xFF0D1524),
      interiorFloor: Color(0xFF0B111C),
      flapBackLeft: Color(0xFF243247),
      flapBackRight: Color(0xFF1A2536),
      flapFrontLeft: Color(0xFF223043),
      flapFrontRight: Color(0xFF182332),
      strokeBox: Color(0x7364748B),
      strokeTrail: Color(0xFF64748B),
      sparkle: Color(0xFF94A3B8),
      insectBody: Color(0xFF94A3B8),
      insectWing: Color(0xA694A3B8),
      caption: Color(0xFF64748B),
      groundShadow: Color(0x66000000),
    );
  }

  final Color exteriorLeft;
  final Color exteriorRight;
  final Color interiorBackLeft;
  final Color interiorBackRight;
  final Color interiorFloor;
  final Color flapBackLeft;
  final Color flapBackRight;
  final Color flapFrontLeft;
  final Color flapFrontRight;
  final Color strokeBox;
  final Color strokeTrail;
  final Color sparkle;
  final Color insectBody;
  final Color insectWing;
  final Color caption;
  final Color groundShadow;
}

/// 3D Isometric Empty Box Illustration and Animation
/// Native Flutter Canvas implementation of emptystate.html
class AmanahIsometricEmptyBox extends StatefulWidget {
  const AmanahIsometricEmptyBox({
    this.size = 240.0,
    this.showCaption = false,
    this.captionText = 'Empty box',
    this.showControls = false,
    this.autoPlay = true,
    super.key,
  });

  /// The width and height footprint of the isometric canvas.
  final double size;

  /// Whether to draw the subtle "Empty box" caption under the box shadow.
  final bool showCaption;

  /// Custom caption text.
  final String captionText;

  /// Whether to show the replay and pause interactive buttons.
  final bool showControls;

  /// Whether animation starts automatically.
  final bool autoPlay;

  @override
  State<AmanahIsometricEmptyBox> createState() =>
      _AmanahIsometricEmptyBoxState();
}

class _AmanahIsometricEmptyBoxState extends State<AmanahIsometricEmptyBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: (AmanahIsometricBoxConfig.cycleDuration * 1000) ~/ 1,
      ),
    );

    final bool isTesting =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (widget.autoPlay && !isTesting) {
      _controller.repeat();
      _isPlaying = true;
    } else {
      _isPlaying = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    _controller.reset();
    _controller.repeat();
    setState(() => _isPlaying = true);
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.stop();
        _isPlaying = false;
      } else {
        _controller.repeat();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final AmanahIsometricBoxColors colors = dark
        ? AmanahIsometricBoxColors.dark()
        : AmanahIsometricBoxColors.light();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _IsometricBoxPainter(
                  progress: _controller.value,
                  colors: colors,
                  showCaption: widget.showCaption,
                  captionText: widget.captionText,
                ),
              );
            },
          ),
        ),
        if (widget.showControls) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _ControlButton(
                text: 'Ulangi Animasi',
                dark: dark,
                onPressed: _replay,
              ),
              const SizedBox(width: 8),
              _ControlButton(
                text: _isPlaying ? 'Jeda Animasi' : 'Mulai Animasi',
                dark: dark,
                onPressed: _togglePlayPause,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.text,
    required this.dark,
    required this.onPressed,
  });

  final String text;
  final bool dark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.12)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'PlusJakartaSans',
              color: dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoxInterior {
  const _BoxInterior({
    required this.backLeft,
    required this.backRight,
    required this.floor,
  });

  final List<Offset> backLeft;
  final List<Offset> backRight;
  final List<Offset> floor;
}

class _BoxExterior {
  const _BoxExterior({required this.left, required this.right});

  final List<Offset> left;
  final List<Offset> right;
}

/// Custom painter executing the exact isometric projection and animation routines.
class _IsometricBoxPainter extends CustomPainter {
  _IsometricBoxPainter({
    required this.progress,
    required this.colors,
    required this.showCaption,
    required this.captionText,
  });

  final double progress; // 0.0 -> 1.0 (represents 0.0 -> 7.5s)
  final AmanahIsometricBoxColors colors;
  final bool showCaption;
  final String captionText;

  static const double _baseWidth = 320.0;
  static const double _baseHeight = 320.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Determine uniform scaling to fit custom canvas sizes while keeping 1:1 aspect
    final double scale = math.min(
      size.width / _baseWidth,
      size.height / _baseHeight,
    );

    canvas.save();
    canvas.translate(
      (size.width - _baseWidth * scale) / 2,
      (size.height - _baseHeight * scale) / 2,
    );
    canvas.scale(scale, scale);

    final double elapsedSeconds =
        progress * AmanahIsometricBoxConfig.cycleDuration;
    final double cycleTime =
        elapsedSeconds % AmanahIsometricBoxConfig.cycleDuration;

    const double cx = _baseWidth / 2;
    const double cy = _baseHeight / 2 + 10;
    const double targetX = cx + 18;
    const double targetY = cy - 110;

    // 1. Draw ground shadow
    _drawGroundShadow(
      canvas,
      cx,
      cy + AmanahIsometricBoxConfig.height,
      AmanahIsometricBoxConfig.radiusX,
    );

    // 2. Compute flap opening animation
    final double openProgress = _computeProgress(
      cycleTime,
      AmanahIsometricBoxConfig.boxOpenStart,
      AmanahIsometricBoxConfig.boxOpenEnd,
    );
    final double openT = _easeInOutCubic(openProgress);
    final double flapAngle = openT * AmanahIsometricBoxConfig.maxFlapAngle;

    // 3. Draw Interior
    final _BoxInterior interior = _computeInterior(
      cx,
      cy,
      AmanahIsometricBoxConfig.depth,
    );
    _drawPolygon(canvas, interior.backLeft, colors.interiorBackLeft);
    _drawPolygon(canvas, interior.backRight, colors.interiorBackRight);
    _drawPolygon(canvas, interior.floor, colors.interiorFloor);

    // 4. Draw Back Flaps
    _drawPolygon(
      canvas,
      _computeFlapBackLeft(flapAngle, cx, cy),
      colors.flapBackLeft,
    );
    _drawPolygon(
      canvas,
      _computeFlapBackRight(flapAngle, cx, cy),
      colors.flapBackRight,
    );

    // 5. Draw Exterior Box
    final _BoxExterior exterior = _computeExterior(cx, cy);
    _drawPolygon(canvas, exterior.left, colors.exteriorLeft);
    _drawPolygon(canvas, exterior.right, colors.exteriorRight);

    // 6. Draw Front Flaps
    _drawPolygon(
      canvas,
      _computeFlapFrontLeft(flapAngle, cx, cy),
      colors.flapFrontLeft,
    );
    _drawPolygon(
      canvas,
      _computeFlapFrontRight(flapAngle, cx, cy),
      colors.flapFrontRight,
    );

    // 7. Compute & Draw Insect Flight Trajectory (Dotted Trail)
    final double flyProgress = _computeProgress(
      cycleTime,
      AmanahIsometricBoxConfig.flyEmergeStart,
      AmanahIsometricBoxConfig.flyEmergeEnd,
    );
    final double flyT = _easeInOutQuad(flyProgress);
    final List<Offset> trajectoryPoints = _buildTrajectoryPoints(
      cx,
      cy,
      targetX,
      targetY,
    );

    _drawDottedTrail(canvas, trajectoryPoints, flyT, elapsedSeconds);

    // 8. Draw Insect
    final Offset flyPos = _getPointAtProgress(trajectoryPoints, flyT);
    final double floatOffset = flyT >= 1
        ? math.sin(elapsedSeconds * 1.8) * 3
        : 0;
    final double insectOpacity = math.min(
      1.0,
      _computeProgress(
        cycleTime,
        AmanahIsometricBoxConfig.flyEmergeStart,
        AmanahIsometricBoxConfig.flyEmergeStart + 0.3,
      ),
    );

    _drawInsect(
      canvas,
      flyPos.dx,
      flyPos.dy + floatOffset,
      elapsedSeconds,
      insectOpacity,
    );

    // 9. Draw Sparkles
    final double sparkleOpacity = _computeProgress(
      cycleTime,
      AmanahIsometricBoxConfig.flyEmergeStart + 1.2,
      AmanahIsometricBoxConfig.flyEmergeEnd,
    );
    _drawSparkles(canvas, cx, cy, elapsedSeconds, sparkleOpacity);

    // 10. Optional Caption
    if (showCaption) {
      _drawCaption(
        canvas,
        cx,
        cy + AmanahIsometricBoxConfig.height + 45,
        captionText,
      );
    }

    canvas.restore();
  }

  // --- Geometry Projection Math ---

  static Offset _project(
    double x,
    double y,
    double z,
    double originX,
    double originY,
  ) {
    return Offset(
      originX + (x - y) * AmanahIsometricBoxConfig.radiusX,
      originY +
          (x + y - 1) * AmanahIsometricBoxConfig.radiusY +
          (1 - z) * AmanahIsometricBoxConfig.height,
    );
  }

  static List<Offset> _computeFlapBackLeft(double angle, double cx, double cy) {
    final double xOffset =
        AmanahIsometricBoxConfig.flapLength * math.cos(angle);
    final double zOffset =
        1 + AmanahIsometricBoxConfig.flapLength * math.sin(angle);
    return <Offset>[
      _project(0, 1, 1, cx, cy),
      _project(0, 0, 1, cx, cy),
      _project(xOffset, 0, zOffset, cx, cy),
      _project(xOffset, 1, zOffset, cx, cy),
    ];
  }

  static List<Offset> _computeFlapBackRight(
    double angle,
    double cx,
    double cy,
  ) {
    final double yOffset =
        AmanahIsometricBoxConfig.flapLength * math.cos(angle);
    final double zOffset =
        1 + AmanahIsometricBoxConfig.flapLength * math.sin(angle);
    return <Offset>[
      _project(0, 0, 1, cx, cy),
      _project(1, 0, 1, cx, cy),
      _project(1, yOffset, zOffset, cx, cy),
      _project(0, yOffset, zOffset, cx, cy),
    ];
  }

  static List<Offset> _computeFlapFrontLeft(
    double angle,
    double cx,
    double cy,
  ) {
    final double yOffset =
        1 - AmanahIsometricBoxConfig.flapLength * math.cos(angle);
    final double zOffset =
        1 + AmanahIsometricBoxConfig.flapLength * math.sin(angle);
    return <Offset>[
      _project(0, 1, 1, cx, cy),
      _project(1, 1, 1, cx, cy),
      _project(1, yOffset, zOffset, cx, cy),
      _project(0, yOffset, zOffset, cx, cy),
    ];
  }

  static List<Offset> _computeFlapFrontRight(
    double angle,
    double cx,
    double cy,
  ) {
    final double xOffset =
        1 - AmanahIsometricBoxConfig.flapLength * math.cos(angle);
    final double zOffset =
        1 + AmanahIsometricBoxConfig.flapLength * math.sin(angle);
    return <Offset>[
      _project(1, 0, 1, cx, cy),
      _project(1, 1, 1, cx, cy),
      _project(xOffset, 1, zOffset, cx, cy),
      _project(xOffset, 0, zOffset, cx, cy),
    ];
  }

  static _BoxInterior _computeInterior(double cx, double cy, double depth) {
    final double zFloor = 1 - depth / AmanahIsometricBoxConfig.height;
    return _BoxInterior(
      backLeft: <Offset>[
        _project(0, 1, 1, cx, cy),
        _project(0, 0, 1, cx, cy),
        _project(0, 0, zFloor, cx, cy),
        _project(0, 1, zFloor, cx, cy),
      ],
      backRight: <Offset>[
        _project(0, 0, 1, cx, cy),
        _project(1, 0, 1, cx, cy),
        _project(1, 0, zFloor, cx, cy),
        _project(0, 0, zFloor, cx, cy),
      ],
      floor: <Offset>[
        _project(0, 1, zFloor, cx, cy),
        _project(0, 0, zFloor, cx, cy),
        _project(1, 0, zFloor, cx, cy),
        _project(1, 1, zFloor, cx, cy),
      ],
    );
  }

  static _BoxExterior _computeExterior(double cx, double cy) {
    return _BoxExterior(
      left: <Offset>[
        _project(0, 1, 1, cx, cy),
        _project(1, 1, 1, cx, cy),
        _project(1, 1, 0, cx, cy),
        _project(0, 1, 0, cx, cy),
      ],
      right: <Offset>[
        _project(1, 1, 1, cx, cy),
        _project(1, 0, 1, cx, cy),
        _project(1, 0, 0, cx, cy),
        _project(1, 1, 0, cx, cy),
      ],
    );
  }

  // --- Flight Trajectory & Bézier Math ---

  static Offset _evaluateCubic(
    Offset p0,
    Offset p1,
    Offset p2,
    Offset p3,
    double t,
  ) {
    final double oneMinusT = 1.0 - t;
    final double u2 = oneMinusT * oneMinusT;
    final double u3 = u2 * oneMinusT;
    final double t2 = t * t;
    final double t3 = t2 * t;

    return Offset(
      u3 * p0.dx + 3 * u2 * t * p1.dx + 3 * oneMinusT * t2 * p2.dx + t3 * p3.dx,
      u3 * p0.dy + 3 * u2 * t * p1.dy + 3 * oneMinusT * t2 * p2.dy + t3 * p3.dy,
    );
  }

  static List<Offset> _buildTrajectoryPoints(
    double cx,
    double cy,
    double targetX,
    double targetY,
  ) {
    final List<List<Offset>> segments = <List<Offset>>[
      <Offset>[
        Offset(cx, cy + 16),
        Offset(cx - 16, cy - 10),
        Offset(cx - 30, cy - 36),
        Offset(cx - 18, cy - 54),
      ],
      <Offset>[
        Offset(cx - 18, cy - 54),
        Offset(cx - 6, cy - 70),
        Offset(cx + 20, cy - 65),
        Offset(cx + 16, cy - 46),
      ],
      <Offset>[
        Offset(cx + 16, cy - 46),
        Offset(cx + 12, cy - 30),
        Offset(cx - 10, cy - 38),
        Offset(cx - 2, cy - 68),
      ],
      <Offset>[
        Offset(cx - 2, cy - 68),
        Offset(cx + 4, cy - 88),
        Offset(cx + 12, cy - 98),
        Offset(targetX, targetY + 6),
      ],
    ];

    const int sampleCount = 100;
    final List<Offset> points = <Offset>[];
    for (int i = 0; i <= sampleCount; i++) {
      final double t = i / sampleCount;
      final int segmentIndex = math.min((t * 4).floor(), 3);
      final double u = t * 4 - segmentIndex;
      final List<Offset> seg = segments[segmentIndex];
      points.add(_evaluateCubic(seg[0], seg[1], seg[2], seg[3], u));
    }
    return points;
  }

  static Offset _getPointAtProgress(List<Offset> points, double progress) {
    final double clamped = progress.clamp(0.0, 1.0);
    final int index = math.min(
      (clamped * (points.length - 1)).floor(),
      points.length - 1,
    );
    return points[index];
  }

  // --- Rendering Routines ---

  void _drawPolygon(Canvas canvas, List<Offset> points, Color fillColor) {
    if (points.isEmpty) {
      return;
    }
    final Path path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final Paint strokePaint = Paint()
      ..color = colors.strokeBox
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, strokePaint);
  }

  void _drawGroundShadow(Canvas canvas, double cx, double cy, double radiusX) {
    final Paint shadowPaint = Paint()
      ..color = colors.groundShadow
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 12),
        width: radiusX * 2.2,
        height: 28,
      ),
      shadowPaint,
    );
  }

  void _drawDottedTrail(
    Canvas canvas,
    List<Offset> points,
    double progress,
    double elapsedSeconds,
  ) {
    if (progress <= 0 || points.isEmpty) {
      return;
    }

    final int targetIndex = math.min(
      (progress * (points.length - 1)).floor(),
      points.length - 1,
    );

    final Path path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= targetIndex; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final Paint trailPaint = Paint()
      ..color = colors.strokeTrail
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Draw dashed path with moving lineDashOffset
    const double dashWidth = 3.0;
    const double dashGap = 4.0;
    const double dashPeriod = dashWidth + dashGap;
    final double dashOffset = (-elapsedSeconds * 12) % dashPeriod;

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = dashOffset < 0 ? dashOffset + dashPeriod : dashOffset;
      while (distance < metric.length) {
        final double end = math.min(distance + dashWidth, metric.length);
        if (end > distance) {
          final Path extract = metric.extractPath(distance, end);
          canvas.drawPath(extract, trailPaint);
        }
        distance += dashPeriod;
      }
    }
  }

  void _drawInsect(
    Canvas canvas,
    double x,
    double y,
    double elapsedSeconds,
    double opacity,
  ) {
    if (opacity <= 0) {
      return;
    }

    canvas.save();
    canvas.translate(x, y);

    final double wingFlap = math.sin(elapsedSeconds * 26) * 0.25;

    // Wing Left
    _drawWing(canvas, -0.8 + wingFlap, opacity);
    // Wing Right
    _drawWing(canvas, 0.8 - wingFlap, opacity);

    // Body
    final Paint bodyPaint = Paint()
      ..color = colors.insectBody.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Oval Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 7.0, height: 10.0),
      bodyPaint,
    );

    // Head
    canvas.drawCircle(const Offset(0, -5), 2.0, bodyPaint);

    canvas.restore();
  }

  void _drawWing(Canvas canvas, double angle, double opacity) {
    canvas.save();
    canvas.rotate(angle);

    final Paint wingPaint = Paint()
      ..color = colors.insectWing.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, -4), width: 12.0, height: 5.0),
      wingPaint,
    );

    canvas.restore();
  }

  void _drawSparkles(
    Canvas canvas,
    double cx,
    double cy,
    double elapsedSeconds,
    double opacity,
  ) {
    if (opacity <= 0) {
      return;
    }

    final double pulse = math.sin(elapsedSeconds * 2.5) * 1.5;

    _drawStar(canvas, cx - 74, cy - 48, 6.5 + pulse, opacity);
    _drawStar(canvas, cx - 82, cy + 44, 5.0 + pulse, opacity);
    _drawStar(canvas, cx + 84, cy + 46, 7.0 - pulse, opacity);

    final Paint dotPaint = Paint()
      ..color = colors.sparkle.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx - 94, cy + 2), 2.2, dotPaint);
    canvas.drawCircle(Offset(cx - 80, cy + 68), 1.8, dotPaint);
    canvas.drawCircle(Offset(cx + 70, cy - 18), 2.4, dotPaint);
    canvas.drawCircle(Offset(cx + 22, cy - 32), 1.5, dotPaint);
  }

  void _drawStar(
    Canvas canvas,
    double x,
    double y,
    double outerRadius,
    double opacity,
  ) {
    final double innerRadius = outerRadius * 0.26;
    final Path path = Path();

    for (int i = 0; i < 8; i++) {
      final double radius = i.isEven ? outerRadius : innerRadius;
      final double angle = (i * math.pi) / 4 - math.pi / 2;
      final double px = x + math.cos(angle) * radius;
      final double py = y + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();

    final Paint starPaint = Paint()
      ..color = colors.sparkle.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, starPaint);
  }

  void _drawCaption(Canvas canvas, double cx, double cy, String text) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
          color: colors.caption,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2),
    );
  }

  // --- Easing Math from POC ---

  static double _easeInOutCubic(double x) {
    return x < 0.5 ? 4 * x * x * x : 1 - math.pow(-2 * x + 2, 3) / 2;
  }

  static double _easeInOutQuad(double x) {
    return x < 0.5 ? 2 * x * x : 1 - math.pow(-2 * x + 2, 2) / 2;
  }

  static double _computeProgress(double t, double start, double end) {
    if (t <= start) {
      return 0.0;
    }
    if (t >= end) {
      return 1.0;
    }
    return (t - start) / (end - start);
  }

  @override
  bool shouldRepaint(covariant _IsometricBoxPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.colors != colors ||
        oldDelegate.captionText != captionText ||
        oldDelegate.showCaption != showCaption;
  }
}
