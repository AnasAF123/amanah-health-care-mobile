import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_queue_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_confetti_canvas.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/amanah_queue_3d_carousel.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_patient_detail_modal.dart';

class AmanahQueueActivationOverlay extends StatefulWidget {
  const AmanahQueueActivationOverlay({
    super.key,
    required this.card,
    required this.isGenieSettled,
    required this.isGenieRunning,
    required this.onClose,
    required this.onRedraw,
    required this.onActionClick,
  });

  final AmanahQueueCardData card;
  final bool isGenieSettled;
  final bool isGenieRunning;
  final VoidCallback onClose;
  final VoidCallback onRedraw;
  final VoidCallback onActionClick;

  @override
  State<AmanahQueueActivationOverlay> createState() =>
      _AmanahQueueActivationOverlayState();
}

class _AmanahQueueActivationOverlayState
    extends State<AmanahQueueActivationOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  final GlobalKey<AmanahConfettiCanvasState> _confettiKey =
      GlobalKey<AmanahConfettiCanvasState>();

  double _tiltX = 0.0;
  double _tiltY = 0.0;
  bool _hapticFired = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );
    _flipAnimation = Tween<double>(begin: math.pi, end: 0.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeOutCubic),
    );

    _flipController.addListener(() {
      if (_flipController.value >= 0.45 && !_hapticFired) {
        _hapticFired = true;
        HapticFeedback.mediumImpact();
        _confettiKey.currentState?.fire();
      }
      setState(() {});
    });

    if (widget.isGenieSettled) {
      _flipController.value = 1.0;
      _hapticFired = true;
    }
  }

  @override
  void didUpdateWidget(covariant AmanahQueueActivationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGenieSettled && !oldWidget.isGenieSettled) {
      _hapticFired = false;
      _flipController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _openDetailModal() {
    AmanahPatientDetailModal.show(
      context,
      BookedPatient(
        id: widget.card.id,
        patientName: widget.card.patientName,
        patientComplaint: widget.card.complaint,
        queueNumber: widget.card.queueNumber,
        timeSlot: widget.card.timeSlot,
        avatarUrl: widget.card.doctorImage,
        patientAge: '${widget.card.age} Thn',
        patientRm: widget.card.patientRm,
        badge: widget.card.priority,
        badgeVariant: widget.card.priority == 'Prioritas'
            ? AmanahBadgeVariant.warning
            : AmanahBadgeVariant.primary,
      ),
      DoctorSchedule(
        id: 'sch_${widget.card.id}',
        title: 'Praktik Dokter',
        date: 'Hari ini',
        time: widget.card.timeSlot,
        poli: widget.card.poly,
        room: widget.card.room,
        badge: widget.card.priority,
        badgeVariant: AmanahBadgeVariant.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Size size = MediaQuery.sizeOf(context);
    final double cardW = math.min(size.width - 64, 320.0);
    final double cardH = cardW / 0.718;

    final double flipAngle = _flipAnimation.value;
    final bool isBackface = flipAngle > (math.pi / 2);

    return Positioned.fill(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              opacity: widget.isGenieSettled
                  ? 1.0
                  : (widget.isGenieRunning ? 0.0 : 0.95),
              child: Container(
                color: isDark
                    ? AmanahColorTokens.canvasDark.withValues(alpha: 0.95)
                    : AmanahColorTokens.canvasLight.withValues(alpha: 0.97),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: <Widget>[
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: widget.isGenieSettled ? 1.0 : 0.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(
                      0,
                      widget.isGenieSettled ? 0.0 : -14.0,
                      0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            onPressed: widget.onClose,
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: isDark
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral800,
                          ),
                          Text(
                            'Antrean terpilih',
                            style: TextStyle(
                              color: isDark
                                  ? AmanahColorTokens.surfaceLight
                                  : AmanahColorTokens.darkNavy,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onPanUpdate: (DragUpdateDetails d) {
                        setState(() {
                          _tiltX = (d.localPosition.dy / cardH - 0.5) * -0.35;
                          _tiltY = (d.localPosition.dx / cardW - 0.5) * 0.35;
                        });
                      },
                      onPanEnd: (_) {
                        setState(() {
                          _tiltX = 0;
                          _tiltY = 0;
                        });
                      },
                      onTap: _openDetailModal,
                      child: Opacity(
                        opacity: widget.isGenieRunning ? 0.0 : 1.0,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(_tiltX)
                            ..rotateY(_tiltY + flipAngle),
                          child: isBackface
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..rotateY(math.pi),
                                  child: SizedBox(
                                    width: cardW,
                                    height: cardH,
                                    child: AmanahQueueCardCover(
                                      card: widget.card,
                                      width: cardW,
                                      height: cardH,
                                    ),
                                  ),
                                )
                              : AmanahRevealedHeroCard(
                                  card: widget.card,
                                  width: cardW,
                                  height: cardH,
                                  onDetailTap: _openDetailModal,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: widget.isGenieSettled ? 1.0 : 0.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(
                      0,
                      widget.isGenieSettled ? 0.0 : 28.0,
                      0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        children: <Widget>[
                          AmanahButton.primary(
                            text: 'Panggil & Proses Pasien',
                            size: AmanahButtonSize.hero,
                            isFullWidth: true,
                            borderRadius: BorderRadius.circular(18),
                            onPressed: widget.onActionClick,
                          ),

                          const SizedBox(height: 12),

                          AmanahButton.secondary(
                            text: 'Pilih Antrean Lain',
                            size: AmanahButtonSize.medium,
                            isFullWidth: true,
                            borderRadius: BorderRadius.circular(18),
                            onPressed: widget.onRedraw,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned.fill(child: AmanahConfettiCanvas(key: _confettiKey)),
        ],
      ),
    );
  }
}

class AmanahRevealedHeroCard extends StatelessWidget {
  const AmanahRevealedHeroCard({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    required this.onDetailTap,
  });

  final AmanahQueueCardData card;
  final double width;
  final double height;
  final VoidCallback onDetailTap;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const <Color>[
                  AmanahColorTokens.surfaceElevatedDark,
                  AmanahColorTokens.neutral900,
                  AmanahColorTokens.canvasDark,
                ]
              : const <Color>[
                  AmanahColorTokens.surfaceLight,
                  AmanahColorTokens.canvasLight,
                  AmanahColorTokens.brandSurface,
                ],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDark
                ? AmanahColorTokens.pureBlack.withValues(alpha: 0.70)
                : AmanahColorTokens.navy.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 18),
            spreadRadius: isDark ? -4 : -12,
          ),
        ],
        border: Border.all(
          color: isDark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.14)
              : AmanahColorTokens.surfaceLight,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -16,
              left: -24,
              child: AmanahWatermarkLogo(
                size: 200,
                color: isDark
                    ? AmanahColorTokens.brandSoft
                    : AmanahColorTokens.brandPrimary,
                opacity: isDark ? 0.18 : 0.25,
              ),
            ),

            AmanahPixelTexture(
              isDark: isDark,
              opacity: isDark ? 0.30 : 0.22,
              maskType: AmanahPixelMaskType.bottomLeft,
            ),

            Positioned(
              top: 16,
              left: 20,
              child: Text(
                card.queueNumber,
                style: TextStyle(
                  color: isDark
                      ? AmanahColorTokens.brandSoft
                      : AmanahColorTokens.brandPrimary,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
            ),

            Positioned(
              right: 0,
              top: 36,
              bottom: 74,
              width: width * 0.76,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      AmanahColorTokens.pureBlack,
                      AmanahColorTokens.pureBlack,
                      Colors.transparent,
                    ],
                    stops: <double>[0.0, 0.68, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  card.doctorImage,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomRight,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),

            Positioned(
              bottom: 48,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.arrow_outward_rounded,
                        color: isDark
                            ? AmanahColorTokens.brandSoft
                            : AmanahColorTokens.brandPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          card.patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral900,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card.complaint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? AmanahColorTokens.neutral400
                          : AmanahColorTokens.neutral500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 16,
              right: 20,
              child: Text(
                card.poly,
                style: TextStyle(
                  color: isDark
                      ? AmanahColorTokens.brandSoft
                      : AmanahColorTokens.brandPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
