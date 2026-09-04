import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
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
    required this.imagePath,
  });

  final String id;
  final String eyebrow;
  final String title;
  final String description;
  final String ctaText;
  final IconData ctaIcon;
  final String iconType;
  final String imagePath;
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
    imagePath: 'assets/amanah/images/carousel/konsultasi-anak.jpg',
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
    imagePath: 'assets/amanah/images/carousel/imunasi-anak.jpg',
  ),
  AmanahClinicSlide(
    id: 'slide-3',
    eyebrow: 'Layanan USG',
    title: 'Pemeriksaan USG Spesialis',
    description:
        'Layanan ultrasonografi diagnostik akurat dengan dokter spesialis terpadu.',
    ctaText: 'Reservasi',
    ctaIcon: Icons.event_available_rounded,
    iconType: 'dna',
    imagePath: 'assets/amanah/images/carousel/usg.jpg',
  ),
  AmanahClinicSlide(
    id: 'slide-4',
    eyebrow: 'Ibu & Anak',
    title: 'Persalinan & Rawat Inap',
    description:
        'Fasilitas persalinan terpadu dan rawat inap ibu & buah hati siaga 24 jam.',
    ctaText: 'Lihat Fasilitas',
    ctaIcon: Icons.favorite_rounded,
    iconType: 'shield',
    imagePath: 'assets/amanah/images/carousel/persalinan-ibu-anak.jpg',
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animController;
  Animation<double>? _posAnimation;

  static double _savedPagePosition = 0.0;
  late double _pagePosition;
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

  void _snapToInteger() {
    if (widget.slides.isEmpty || _isDragging || _animController.isAnimating) {
      return;
    }
    final int total = widget.slides.length;
    final double snapped =
        (_pagePosition.roundToDouble() % total + total) % total;
    if ((_pagePosition - snapped).abs() > 0.001) {
      if (mounted) {
        setState(() {
          _pagePosition = snapped;
          _savedPagePosition = snapped;
        });
      } else {
        _pagePosition = snapped;
        _savedPagePosition = snapped;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final int total = widget.slides.isEmpty ? 1 : widget.slides.length;
    _pagePosition = (_savedPagePosition.roundToDouble() % total + total) % total;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final bool isVisible = route?.isCurrent ?? true;
    final bool tickerActive = TickerMode.of(context);

    if (!isVisible || !tickerActive) {
      _stopAutoplay();
      _snapToInteger();
    } else if (_autoplayTimer == null && mounted) {
      _snapToInteger();
      _startAutoplay();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _snapToInteger();
      _startAutoplay();
    } else {
      _stopAutoplay();
      _snapToInteger();
    }
  }

  void _startAutoplay() {
    _autoplayTimer?.cancel();
    _autoplayTimer = Timer.periodic(
      const Duration(milliseconds: AmanahCarouselTokens.autoplayDelayMs),
      (_) {
        if (!mounted || _isDragging || widget.slides.isEmpty) {
          return;
        }
        if (!TickerMode.of(context)) {
          return;
        }
        final ModalRoute<dynamic>? route = ModalRoute.of(context);
        if (route != null && !route.isCurrent) {
          return;
        }
        _animateToOffsetDelta(1.0);
      },
    );
  }

  void _stopAutoplay() {
    _autoplayTimer?.cancel();
    _autoplayTimer = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAutoplay();
    _animController.dispose();
    super.dispose();
  }

  void _animateToOffsetDelta(double delta) {
    if (widget.slides.isEmpty || !mounted) {
      return;
    }
    _animController.stop();

    final int total = widget.slides.length;
    final double start = _pagePosition;
    // Always target an exact integer card index to prevent fractional drift
    final double target = (_pagePosition + delta).roundToDouble();

    _posAnimation = Tween<double>(begin: start, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController
        .forward(from: 0.0)
        .orCancel
        .then((_) {
          if (mounted) {
            setState(() {
              _pagePosition = (target.roundToDouble() % total + total) % total;
              _savedPagePosition = _pagePosition;
            });
          }
        })
        .catchError((_) {
          if (mounted && !_isDragging) {
            setState(() {
              _pagePosition =
                  (_pagePosition.roundToDouble() % total + total) % total;
              _savedPagePosition = _pagePosition;
            });
          }
        });
  }

  void _animateToTargetIndex(int targetIndex) {
    if (widget.slides.isEmpty || !mounted) {
      return;
    }
    final int total = widget.slides.length;
    final double currentMod =
        ((_pagePosition.roundToDouble() % total) + total) % total;
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

    final int total = widget.slides.length;
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
              _pagePosition = (target.roundToDouble() % total + total) % total;
              _savedPagePosition = _pagePosition;
            });
          }
        })
        .catchError((_) {
          if (mounted && !_isDragging) {
            setState(() {
              _pagePosition =
                  (_pagePosition.roundToDouble() % total + total) % total;
              _savedPagePosition = _pagePosition;
            });
          }
        });

    _startAutoplay();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    // Safety guard: if resting and not actively dragging or animating, guarantee snapped integer
    if (!_isDragging && !_animController.isAnimating) {
      final int total = widget.slides.length;
      final double snapped =
          (_pagePosition.roundToDouble() % total + total) % total;
      if ((_pagePosition - snapped).abs() > 0.001) {
        _pagePosition = snapped;
      }
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
      decoration: BoxDecoration(
        boxShadow: widget.isDark
            ? AmanahCarouselTokens.cardShadowDark
            : AmanahCarouselTokens.cardShadow,
      ),
      child: ClipPath(
        clipper: const AmanahCarouselInwardNotchClipper(),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double cardWidth = constraints.maxWidth;

            return Stack(
              children: <Widget>[
                // Layer 1: Solid Base Card Compartment (Clean White in light mode, Slate-900 in dark mode)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? const Color(0xFF0F172A)
                          : Colors.white,
                    ),
                  ),
                ),

                // Layer 2: Photographic Artwork with Wide Feathered Masking Blend
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: <double>[0.0, 0.26, 0.42, 0.58, 0.74, 0.88, 1.0],
                        colors: <Color>[
                          Colors.transparent,
                          Colors.transparent,
                          Color(0x24FFFFFF), // ~14% opacity
                          Color(0x66FFFFFF), // ~40% opacity
                          Color(0xB3FFFFFF), // ~70% opacity
                          Color(0xF0FFFFFF), // ~94% opacity
                          Colors.white,      // 100% full opacity
                        ],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      widget.slide.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),

                // Layer 3: Dark theme ambient integration (seamless blend into slate-900)
                if (widget.isDark)
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: <double>[0.0, 0.35, 0.75, 1.0],
                          colors: <Color>[
                            Color(0xFF0F172A),
                            Color(0xBF0F172A),
                            Color(0x330F172A),
                            Color(0x000F172A),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Layer 4: Foreground Content Hierarchy (Left White Compartment)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Top Left: Title and Description with Morph Animation
                      SizedBox(
                        width: cardWidth * 0.49,
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
                                        fontSize: 15.0,
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
                                            ? AmanahCarouselTokens
                                                .descriptionDarkColor
                                            : AmanahCarouselTokens
                                                .descriptionColor,
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
            );
          },
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
                          ? AmanahCarouselTokens.indicatorActiveDarkColor
                          : AmanahCarouselTokens.indicatorActiveColor)
                    : (isDark
                          ? AmanahCarouselTokens.indicatorInactiveDarkColor
                          : AmanahCarouselTokens.indicatorInactiveColor),
                borderRadius: BorderRadius.circular(999),
                boxShadow: isActive
                    ? <BoxShadow>[
                        BoxShadow(
                          color: (isDark
                                  ? const Color(0x6638BDF8)
                                  : AmanahCarouselTokens
                                        .indicatorActiveColor
                                        .withValues(alpha: 0.35)),
                          blurRadius: isDark ? 8 : 4,
                          offset: isDark ? Offset.zero : const Offset(0, 1),
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
                ? AmanahCarouselTokens.navBtnDarkBg
                : AmanahCarouselTokens.navBtnBg,
            border: Border.all(
              color: isDark
                  ? AmanahCarouselTokens.navBtnDarkBorder
                  : AmanahCarouselTokens.navBtnBorder,
              width: 1.0,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.08),
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
                  ? AmanahCarouselTokens.navBtnDarkIconColor
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
          ? AmanahCarouselTokens.rimStrokeDarkColor
          : AmanahCarouselTokens.rimStrokeColor
      ..strokeWidth = AmanahCarouselTokens.rimStrokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _InwardNotchRimPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}


