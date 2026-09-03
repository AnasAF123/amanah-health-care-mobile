import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_medical_3d_icons.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_carousel_tokens.dart';

/// Clinic Promotional Slide Model matching ClinicSlide in MasterCarouselSection.tsx (.web)
class AmanahClinicSlide {
  const AmanahClinicSlide({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.ctaText,
    required this.ctaIcon,
    required this.iconType,
  });

  final String id;
  final String eyebrow;
  final String title;
  final String description;
  final String ctaText;
  final IconData ctaIcon;
  final String iconType;
}

const List<AmanahClinicSlide> kClinicSlides = <AmanahClinicSlide>[
  AmanahClinicSlide(
    id: 'slide-1',
    eyebrow: 'Poli Anak',
    title: 'Konsultasi Spesialis Anak',
    description:
        'Jadwalkan temu dokter spesialis anak responsif dan terpadu RS Amanah.',
    ctaText: 'Jadwalkan',
    ctaIcon: Icons.auto_awesome_rounded,
    iconType: 'briefcase',
  ),
  AmanahClinicSlide(
    id: 'slide-2',
    eyebrow: 'Imunisasi',
    title: 'Vaksinasi & Booster Anak',
    description:
        'Paket imunisasi balita primer lengkap dengan sertifikat medis resmi.',
    ctaText: 'Lihat Paket',
    ctaIcon: Icons.verified_user_rounded,
    iconType: 'syringe',
  ),
  AmanahClinicSlide(
    id: 'slide-3',
    eyebrow: 'Tumbuh Kembang',
    title: 'Skrining Tumbuh Kembang',
    description:
        'Evaluasi berkala nutrisi dan motorik buah hati bersama tenaga ahli.',
    ctaText: 'Reservasi',
    ctaIcon: Icons.event_available_rounded,
    iconType: 'dna',
  ),
  AmanahClinicSlide(
    id: 'slide-4',
    eyebrow: 'Layanan 24 Jam',
    title: 'Instalasi Gawat Darurat',
    description:
        'Kesiapan dokter jaga dan fasilitas darurat anak responsif 24 jam.',
    ctaText: 'Hubungi IGD',
    ctaIcon: Icons.phone_in_talk_rounded,
    iconType: 'shield',
  ),
];

// Continuous 3D deck slot interpolation with deterministic algebraic math (no while loops)
double _getContinuousOffset(int cardIndex, double pagePos, int total) {
  if (total <= 0) {
    return 0.0;
  }
  double diff = (cardIndex - pagePos) % total;
  if (diff < -total / 2.0) {
    diff += total;
  } else if (diff > total / 2.0) {
    diff -= total;
  }
  return diff;
}

double _getXPercent(double offset) {
  final double absOffset = offset.abs();
  if (absOffset <= 1.0) {
    return offset * AmanahCarouselTokens.sideXPercent;
  } else {
    final double sign = offset < 0 ? -1.0 : 1.0;
    final double t = (absOffset - 1.0).clamp(0.0, 1.0);
    return sign *
        (AmanahCarouselTokens.sideXPercent +
            t *
                (AmanahCarouselTokens.hiddenXPercent -
                    AmanahCarouselTokens.sideXPercent));
  }
}

double _getScale(double offset) {
  final double absOffset = offset.abs();
  if (absOffset <= 1.0) {
    return ui.lerpDouble(
      AmanahCarouselTokens.frontScale,
      AmanahCarouselTokens.sideScale,
      absOffset,
    )!;
  } else {
    final double t = (absOffset - 1.0).clamp(0.0, 1.0);
    return ui.lerpDouble(
      AmanahCarouselTokens.sideScale,
      AmanahCarouselTokens.hiddenScale,
      t,
    )!;
  }
}

double _getZ(double offset) {
  final double absOffset = offset.abs();
  if (absOffset <= 1.0) {
    return ui.lerpDouble(0.0, AmanahCarouselTokens.sideZ, absOffset)!;
  } else {
    final double t = (absOffset - 1.0).clamp(0.0, 1.0);
    return ui.lerpDouble(
      AmanahCarouselTokens.sideZ,
      AmanahCarouselTokens.hiddenZ,
      t,
    )!;
  }
}

double _getOpacity(double offset) {
  final double absOffset = offset.abs();
  if (absOffset <= 1.0) {
    return 1.0;
  } else {
    final double t = (absOffset - 1.0).clamp(0.0, 1.0);
    return ui.lerpDouble(1.0, 0.0, t)!;
  }
}

/// Master 3D Deck Carousel Section in Flutter matching MasterCarouselSection.tsx (.web)
/// Highly optimized for mobile hardware and Android EGL raster threads.
class AmanahMasterCarouselSection extends StatefulWidget {
  const AmanahMasterCarouselSection({
    super.key,
    this.slides = kClinicSlides,
    this.onSlideAction,
  });

  final List<AmanahClinicSlide> slides;
  final ValueChanged<String>? onSlideAction;

  @override
  State<AmanahMasterCarouselSection> createState() =>
      _AmanahMasterCarouselSectionState();
}

class _AmanahMasterCarouselSectionState
    extends State<AmanahMasterCarouselSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Animation<double>? _posAnimation;

  double _pagePosition = 0.0;
  double _dragStartPos = 0.0;
  double _dragAccumulatedDx = 0.0;
  bool _isDragging = false;
  Timer? _autoplayTimer;

  int get _normalizedActiveIndex {
    if (widget.slides.isEmpty) {
      return 0;
    }
    final int rounded = _pagePosition.round();
    return ((rounded % widget.slides.length) + widget.slides.length) %
        widget.slides.length;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animController.addListener(() {
      if (_posAnimation != null && mounted) {
        setState(() {
          _pagePosition = _posAnimation!.value;
        });
      }
    });

    _startAutoplay();
  }

  void _startAutoplay() {
    _autoplayTimer?.cancel();
    _autoplayTimer = Timer.periodic(
      const Duration(milliseconds: AmanahCarouselTokens.autoplayDelayMs),
      (_) {
        if (mounted && !_isDragging && widget.slides.isNotEmpty) {
          _animateToOffsetDelta(1.0);
        }
      },
    );
  }

  void _stopAutoplay() {
    _autoplayTimer?.cancel();
    _autoplayTimer = null;
  }

  @override
  void dispose() {
    _stopAutoplay();
    _animController.dispose();
    super.dispose();
  }

  void _animateToOffsetDelta(double delta) {
    if (widget.slides.isEmpty || !mounted) {
      return;
    }
    _animController.stop();
    final double start = _pagePosition;
    final double target = start + delta;

    _posAnimation = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController
        .forward(from: 0.0)
        .orCancel
        .then((_) {
          if (mounted) {
            setState(() {
              _pagePosition =
                  (_pagePosition % widget.slides.length +
                      widget.slides.length) %
                  widget.slides.length;
            });
          }
        })
        .catchError((_) {});
  }

  void _animateToTargetIndex(int targetIndex) {
    if (widget.slides.isEmpty || !mounted) {
      return;
    }
    final int total = widget.slides.length;
    final double currentMod = ((_pagePosition % total) + total) % total;
    double delta = targetIndex - currentMod;

    if (delta > total / 2.0) {
      delta -= total;
    } else if (delta < -total / 2.0) {
      delta += total;
    }

    _animateToOffsetDelta(delta);
  }

  void _handleDragStart(DragStartDetails details) {
    _stopAutoplay();
    _animController.stop();
    setState(() {
      _isDragging = true;
      _dragStartPos = _pagePosition;
      _dragAccumulatedDx = 0.0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || !mounted) {
      return;
    }
    setState(() {
      _dragAccumulatedDx += details.delta.dx;
      final double deltaPages = -_dragAccumulatedDx / 280.0;
      _pagePosition = _dragStartPos + deltaPages;
    });
  }

  void _handleDragEnd([DragEndDetails? details]) {
    if (!_isDragging || !mounted) {
      return;
    }
    _isDragging = false;

    final double velocity = details?.primaryVelocity ?? 0.0;
    double target = _pagePosition.roundToDouble();

    if (velocity < -300) {
      target = (_pagePosition + 0.35).ceilToDouble();
    } else if (velocity > 300) {
      target = (_pagePosition - 0.35).floorToDouble();
    }

    final double start = _pagePosition;
    _posAnimation = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController
        .forward(from: 0.0)
        .orCancel
        .then((_) {
          if (mounted) {
            setState(() {
              _pagePosition =
                  (_pagePosition % widget.slides.length +
                      widget.slides.length) %
                  widget.slides.length;
            });
          }
        })
        .catchError((_) {});

    _startAutoplay();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final int total = widget.slides.length;
    final int activeIdx = _normalizedActiveIndex;

    // Sort cards by z-index: cards further from center (higher abs offset) are painted first (beneath)
    final List<int> sortedIndices = List<int>.generate(total, (int i) => i);
    sortedIndices.sort((int a, int b) {
      final double offsetA = _getContinuousOffset(
        a,
        _pagePosition,
        total,
      ).abs();
      final double offsetB = _getContinuousOffset(
        b,
        _pagePosition,
        total,
      ).abs();
      return offsetB.compareTo(offsetA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Carousel Viewport with 3D Perspective Stage
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          onHorizontalDragCancel: () => _handleDragEnd(),
          child: SizedBox(
            height: AmanahCarouselTokens.stageHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: <Widget>[
                // Continuous 3D Transformed Card Stack
                ...sortedIndices.map((int index) {
                  final double offset = _getContinuousOffset(
                    index,
                    _pagePosition,
                    total,
                  );
                  final AmanahClinicSlide slide = widget.slides[index];

                  final double xPercent = _getXPercent(offset);
                  final double scale = _getScale(offset);
                  final double z = _getZ(offset);
                  final double opacity = _getOpacity(offset);
                  final bool isSideCard = offset.abs() > 0.45;

                  if (opacity <= 0.01) {
                    return const SizedBox.shrink();
                  }

                  Widget cardWidget = AmanahDeckCard(
                    key: ValueKey<String>(slide.id),
                    slide: slide,
                    isDark: dark,
                    isActive: index == activeIdx,
                    isSideCard: isSideCard,
                    onActionClick: () {
                      widget.onSlideAction?.call(slide.id);
                    },
                  );

                  if (opacity < 0.99) {
                    cardWidget = Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: cardWidget,
                    );
                  }

                  return Positioned(
                    key: ValueKey<String>('pos-${slide.id}'),
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective depth
                        ..setTranslationRaw(
                          (MediaQuery.sizeOf(context).width - 40) *
                              (xPercent / 100.0),
                          0.0,
                          z,
                        )
                        ..scaleByDouble(scale, scale, 1.0, 1.0),
                      alignment: Alignment.center,
                      child: cardWidget,
                    ),
                  );
                }),

                // Left Compact Navigator Chevron Button (Continuous Dock-to-Dock Rotation)
                Positioned(
                  left: -6,
                  child: AmanahCarouselNavButton(
                    isLeft: true,
                    isDark: dark,
                    onTap: () {
                      _stopAutoplay();
                      _animateToOffsetDelta(-1.0);
                      _startAutoplay();
                    },
                  ),
                ),

                // Right Compact Navigator Chevron Button (Continuous Dock-to-Dock Rotation)
                Positioned(
                  right: -6,
                  child: AmanahCarouselNavButton(
                    isLeft: false,
                    isDark: dark,
                    onTap: () {
                      _stopAutoplay();
                      _animateToOffsetDelta(1.0);
                      _startAutoplay();
                    },
                  ),
                ),

                // Docked Notch Indicator Toolbar (Bottom Center inside Cavity Notch)
                Positioned(
                  bottom: 2,
                  child: AmanahCarouselNotchedIndicator(
                    currentIndex: activeIdx,
                    totalSlides: total,
                    isDark: dark,
                    onSelectSlide: (int targetIdx) {
                      _stopAutoplay();
                      _animateToTargetIndex(targetIdx);
                      _startAutoplay();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Molecule: Single Deck Card with Inward Notched Clipping Path,
/// Subtle Organic Ribbon Waves, 3D Heroic Medical Artwork, Crisp Blue Action Button,
/// and GSAP-style Blurry Morph Text Slide Down Animation.
class AmanahDeckCard extends StatefulWidget {
  const AmanahDeckCard({
    required this.slide,
    required this.isDark,
    required this.isActive,
    required this.isSideCard,
    required this.onActionClick,
    super.key,
  });

  final AmanahClinicSlide slide;
  final bool isDark;
  final bool isActive;
  final bool isSideCard;
  final VoidCallback onActionClick;

  @override
  State<AmanahDeckCard> createState() => _AmanahDeckCardState();
}

class _AmanahDeckCardState extends State<AmanahDeckCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _titleSlideAnim;
  late final Animation<double> _titleOpacityAnim;
  late final Animation<double> _descSlideAnim;
  late final Animation<double> _descOpacityAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    final CurvedAnimation titleCurve = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
    );
    _titleSlideAnim = Tween<double>(begin: -14.0, end: 0.0).animate(titleCurve);
    _titleOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(titleCurve);

    final CurvedAnimation descCurve = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
    );
    _descSlideAnim = Tween<double>(begin: -10.0, end: 0.0).animate(descCurve);
    _descOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(descCurve);

    if (widget.isActive) {
      _animController.forward(from: 0.0).orCancel.catchError((_) {});
    } else {
      _animController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AmanahDeckCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive && mounted) {
      _animController.forward(from: 0.0).orCancel.catchError((_) {});
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: AmanahCarouselTokens.cardShadow,
      ),
      child: ClipPath(
        clipper: const AmanahCarouselInwardNotchClipper(),
        child: Stack(
          children: <Widget>[
            // Layer 1: Solid/Gradient Card Background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: widget.isDark
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[
                            Color(0xFF0F1422),
                            Color(0xFF131B2E),
                            Color(0xFF16233D),
                          ],
                        )
                      : AmanahCarouselTokens.cardBgGradient,
                ),
              ),
            ),

            // Layer 2: Subtle Organic Ribbon Waves (0.09 Opacity)
            Positioned.fill(
              child: CustomPaint(
                painter: _OrganicRibbonWavesPainter(isDark: widget.isDark),
              ),
            ),

            // Layer 3: Heroic 3D SVG Medical Icon - Rotated & Cropped in Bottom-Right Corner
            Positioned(
              right: -8,
              bottom: -12,
              child: Transform.rotate(
                angle: -12 * math.pi / 180,
                child: AmanahMedical3DIcon(
                  name: widget.slide.iconType,
                  size: 130,
                  isDark: widget.isDark,
                ),
              ),
            ),

            // Layer 4: Foreground Content Hierarchy with Smooth Slide-Down Stagger
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Top Left: Title and Description with Morph Animation
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.54,
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (BuildContext context, Widget? child) {
                        final double tSlide = widget.isActive
                            ? _titleSlideAnim.value
                            : 0.0;
                        final double tOpacity = widget.isActive
                            ? _titleOpacityAnim.value
                            : (widget.isSideCard ? 0.70 : 1.0);

                        final double dSlide = widget.isActive
                            ? _descSlideAnim.value
                            : 0.0;
                        final double dOpacity = widget.isActive
                            ? _descOpacityAnim.value
                            : (widget.isSideCard ? 0.65 : 1.0);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Transform.translate(
                              offset: Offset(0, tSlide),
                              child: Opacity(
                                opacity: tOpacity.clamp(0.0, 1.0),
                                child: Text(
                                  widget.slide.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                    height: 1.15,
                                    color: widget.isDark
                                        ? Colors.white
                                        : AmanahCarouselTokens.titleColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Transform.translate(
                              offset: Offset(0, dSlide),
                              child: Opacity(
                                opacity: dOpacity.clamp(0.0, 1.0),
                                child: Text(
                                  widget.slide.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11.0,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                    color: widget.isDark
                                        ? const Color(0xFFCBD5E1)
                                        : AmanahCarouselTokens.descriptionColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Bottom Row: Theme-Respecting Crisp Blue Action Button (.btn-crisp-blue)
                  AmanahCrispActionButton(
                    text: widget.slide.ctaText,
                    icon: widget.slide.ctaIcon,
                    isDark: widget.isDark,
                    onTap: widget.onActionClick,
                  ),
                ],
              ),
            ),

            // Layer 5: Inward Notched Rim Stroke Overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _InwardNotchRimPainter(isDark: widget.isDark),
              ),
            ),

            // Layer 6: Frosted Soft Depth Shade on Side Background Cards (Hardware-Accelerated)
            if (widget.isSideCard)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0x33000000)
                        : const Color(0x1AFFFFFF),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Atom: Crisp Blue Action Button (.btn-crisp-blue) inheriting directly from AmanahButton
class AmanahCrispActionButton extends StatelessWidget {
  const AmanahCrispActionButton({
    required this.text,
    required this.icon,
    required this.isDark,
    required this.onTap,
    super.key,
  });

  final String text;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AmanahButton.primary(
      text: text,
      leadingIcon: icon,
      size: AmanahButtonSize.small,
      customHeight: 32,
      borderRadius: BorderRadius.circular(AmanahCarouselTokens.btnRadius),
      onPressed: onTap,
    );
  }
}

/// Atom: Docked Notch Indicator Toolbar sitting inside the Inward Cavity Notch
class AmanahCarouselNotchedIndicator extends StatelessWidget {
  const AmanahCarouselNotchedIndicator({
    required this.currentIndex,
    required this.totalSlides,
    required this.isDark,
    required this.onSelectSlide,
    super.key,
  });

  final int currentIndex;
  final int totalSlides;
  final bool isDark;
  final ValueChanged<int> onSelectSlide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List<Widget>.generate(totalSlides, (int index) {
          final bool isActive = index == currentIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelectSlide(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: AmanahCarouselTokens.indicatorHeight,
              width: isActive
                  ? AmanahCarouselTokens.indicatorActiveWidth
                  : AmanahCarouselTokens.indicatorInactiveWidth,
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark
                          ? const Color(0xFF3B82F6)
                          : AmanahCarouselTokens.indicatorActiveColor)
                    : (isDark
                          ? const Color(0xFF475569)
                          : AmanahCarouselTokens.indicatorInactiveColor),
                borderRadius: BorderRadius.circular(999),
                boxShadow: isActive
                    ? <BoxShadow>[
                        BoxShadow(
                          color:
                              (isDark
                                      ? const Color(0xFF3B82F6)
                                      : AmanahCarouselTokens
                                            .indicatorActiveColor)
                                  .withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Atom: Compact Circular Navigator Button (Chevron Left / Right)
class AmanahCarouselNavButton extends StatelessWidget {
  const AmanahCarouselNavButton({
    required this.isLeft,
    required this.isDark,
    required this.onTap,
    super.key,
  });

  final bool isLeft;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: AmanahCarouselTokens.navBtnSize,
          height: AmanahCarouselTokens.navBtnSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? const Color(0xD90F1422)
                : AmanahCarouselTokens.navBtnBg,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.20)
                  : AmanahCarouselTokens.navBtnBorder,
              width: 1.0,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isLeft ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
              size: 18,
              color: isDark
                  ? Colors.white
                  : AmanahCarouselTokens.navBtnIconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom Clipper for Inward Notched Deck Card Material Silhouette.
/// Exact formula from SVG ClipPath:
/// M 0.07 0 L 0.93 0 C 0.97 0 1 0.07 1 0.16 L 1 0.84 C 1 0.93 0.97 1 0.93 1
/// L 0.67 1 C 0.635 1 0.62 0.86 0.585 0.86 L 0.415 0.86 C 0.38 0.86 0.365 1 0.33 1
/// L 0.07 1 C 0.03 1 0 0.93 0 0.84 L 0 0.16 C 0 0.07 0.03 0 0.07 0 Z
class AmanahCarouselInwardNotchClipper extends CustomClipper<Path> {
  const AmanahCarouselInwardNotchClipper();

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;

    final Path path = Path()
      // Top Left Start
      ..moveTo(0.07 * w, 0)
      // Top Edge to Top Right
      ..lineTo(0.93 * w, 0)
      ..cubicTo(0.97 * w, 0, 1.0 * w, 0.07 * h, 1.0 * w, 0.16 * h)
      // Right Edge to Bottom Right
      ..lineTo(1.0 * w, 0.84 * h)
      ..cubicTo(1.0 * w, 0.93 * h, 0.97 * w, 1.0 * h, 0.93 * w, 1.0 * h)
      // Bottom Edge to Right Cavity Shoulder
      ..lineTo(0.67 * w, 1.0 * h)
      // Inward Concave Cavity Arch Upward
      ..cubicTo(
        0.635 * w,
        1.0 * h,
        0.62 * w,
        AmanahCarouselTokens.notchDepthRatioY * h,
        0.585 * w,
        AmanahCarouselTokens.notchDepthRatioY * h,
      )
      // Flat Cavity Roof
      ..lineTo(0.415 * w, AmanahCarouselTokens.notchDepthRatioY * h)
      // Inward Concave Cavity Arch Downward
      ..cubicTo(
        0.38 * w,
        AmanahCarouselTokens.notchDepthRatioY * h,
        0.365 * w,
        1.0 * h,
        0.33 * w,
        1.0 * h,
      )
      // Bottom Edge to Bottom Left
      ..lineTo(0.07 * w, 1.0 * h)
      ..cubicTo(0.03 * w, 1.0 * h, 0.0 * w, 0.93 * h, 0.0 * w, 0.84 * h)
      // Left Edge to Top Left
      ..lineTo(0.0 * w, 0.16 * h)
      ..cubicTo(0.0 * w, 0.07 * h, 0.03 * w, 0, 0.07 * w, 0)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant AmanahCarouselInwardNotchClipper oldClipper) =>
      false;
}

/// Custom Painter for the Inward Notched Rim Stroke Overlay
class _InwardNotchRimPainter extends CustomPainter {
  const _InwardNotchRimPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = const AmanahCarouselInwardNotchClipper().getClip(size);

    final Paint strokePaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.15)
          : AmanahCarouselTokens.rimStrokeColor
      ..strokeWidth = AmanahCarouselTokens.rimStrokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _InwardNotchRimPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

/// Custom Painter for Organic Ribbon Waves
class _OrganicRibbonWavesPainter extends CustomPainter {
  const _OrganicRibbonWavesPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    final Paint ribbonPaint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? <Color>[
                const Color(0xFF3B82F6).withValues(alpha: 0.15),
                const Color(0xFF2563EB).withValues(alpha: 0.10),
                const Color(0xFF1D4ED8).withValues(alpha: 0.08),
              ]
            : <Color>[
                Colors.white.withValues(alpha: 0.09),
                const Color(0xFF0D66E9).withValues(alpha: 0.08),
                const Color(0xFF1D58AC).withValues(alpha: 0.06),
              ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round;

    final Path path1 = Path()
      ..moveTo(-20, size.height * 0.33)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.77,
        size.width * 0.45,
        -size.height * 0.11,
        size.width * 0.75,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.90,
        size.height * 0.77,
        size.width * 1.05,
        size.height * 0.38,
        size.width * 1.10,
        size.height * 0.27,
      );
    canvas.drawPath(path1, ribbonPaint1);

    final Paint ribbonPaint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? <Color>[
                const Color(0xFF3B82F6).withValues(alpha: 0.12),
                const Color(0xFF2563EB).withValues(alpha: 0.07),
              ]
            : <Color>[
                Colors.white.withValues(alpha: 0.08),
                const Color(0xFF0D66E9).withValues(alpha: 0.06),
              ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final Path path2 = Path()
      ..moveTo(-10, size.height * 0.72)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.22,
        size.width * 0.55,
        size.height * 1.00,
        size.width * 0.85,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.97,
        size.height * 0.22,
        size.width * 1.07,
        size.height * 0.55,
        size.width * 1.12,
        size.height * 0.61,
      );
    canvas.drawPath(path2, ribbonPaint2);
  }

  @override
  bool shouldRepaint(covariant _OrganicRibbonWavesPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
