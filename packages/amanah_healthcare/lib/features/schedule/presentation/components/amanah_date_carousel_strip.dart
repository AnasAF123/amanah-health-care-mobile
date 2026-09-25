import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';

/// Horizontal Continuous 3D Coverflow Date Carousel Strip
/// Matching 1:1 with DateCarouselStrip.tsx in .web (scale, opacity, centered snapping physics)
class AmanahDateCarouselStrip extends StatefulWidget {
  const AmanahDateCarouselStrip({
    required this.selectedDate,
    required this.baseToday,
    required this.onSelectDate,
    required this.hasSchedulesForDate,
    required this.isCutiForDate,
    this.onDateTap,
    super.key,
  });

  final DateTime selectedDate;
  final DateTime baseToday;
  final ValueChanged<DateTime> onSelectDate;
  final bool Function(DateTime date) hasSchedulesForDate;
  final bool Function(DateTime date) isCutiForDate;
  final ValueChanged<DateTime>? onDateTap;

  @override
  State<AmanahDateCarouselStrip> createState() =>
      _AmanahDateCarouselStripState();
}

class _AmanahDateCarouselStripState extends State<AmanahDateCarouselStrip> {
  final ScrollController _scrollController = ScrollController();
  List<DateTime> _calendarDays = const <DateTime>[];

  static const double _itemWidth = 66.0;
  static const double _itemGap = 12.0;
  static const double _totalItemSpace = _itemWidth + _itemGap; // 78.0

  double _scrollOffset = 0.0;
  bool _isProgrammaticScroll = false;

  @override
  void initState() {
    super.initState();
    _calendarDays = List<DateTime>.generate(
      25,
      (int i) => widget.baseToday.add(Duration(days: i - 8)),
    );
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerDate(widget.selectedDate, animate: false);
    });
  }

  @override
  void didUpdateWidget(covariant AmanahDateCarouselStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _centerDate(widget.selectedDate, animate: true);
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  void _centerDate(DateTime date, {bool animate = true}) {
    final int index = _calendarDays.indexWhere(
      (DateTime d) => _isSameDay(d, date),
    );
    if (index == -1 || !_scrollController.hasClients) {
      return;
    }
    final double viewportWidth = _scrollController.position.viewportDimension;
    if (viewportWidth <= 0) {
      return;
    }

    final double leadingPadding = math.max(0, (viewportWidth - _itemWidth) / 2);
    final double targetOffset =
        leadingPadding +
        index * _totalItemSpace +
        _itemWidth / 2 -
        (viewportWidth / 2);
    final double clampedOffset = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    _isProgrammaticScroll = true;
    if (animate) {
      _scrollController
          .animateTo(
            clampedOffset,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
          )
          .then((_) => _isProgrammaticScroll = false);
    } else {
      _scrollController.jumpTo(clampedOffset);
      _isProgrammaticScroll = false;
    }
  }

  void _snapToNearest() {
    if (!_scrollController.hasClients || _isProgrammaticScroll) {
      return;
    }
    final double viewportWidth = _scrollController.position.viewportDimension;
    if (viewportWidth <= 0) {
      return;
    }

    final double leadingPadding = math.max(0, (viewportWidth - _itemWidth) / 2);
    final double centerOffset = _scrollOffset + viewportWidth / 2;
    final int targetIndex =
        ((centerOffset - leadingPadding - _itemWidth / 2) / _totalItemSpace)
            .round()
            .clamp(0, _calendarDays.length - 1);
    final DateTime targetDate = _calendarDays[targetIndex];

    if (!_isSameDay(targetDate, widget.selectedDate)) {
      widget.onSelectDate(targetDate);
    }
    _centerDate(targetDate, animate: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthAbbr(int month) {
    const List<String> months = <String>[
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGS',
      'SEP',
      'OKT',
      'NOV',
      'DES',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double viewportWidth = constraints.maxWidth > 0
            ? constraints.maxWidth
            : 360.0;
        final double leadingPadding = math.max(
          0,
          (viewportWidth - _itemWidth) / 2,
        );
        final double viewportCenter = _scrollOffset + viewportWidth / 2;

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollEndNotification) {
              _snapToNearest();
            }
            return false;
          },
          child: SizedBox(
            height: 124,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: leadingPadding,
                vertical: 14,
              ),
              itemCount: _calendarDays.length,
              itemBuilder: (BuildContext context, int index) {
                final DateTime date = _calendarDays[index];
                final bool isToday = _isSameDay(date, widget.baseToday);
                final bool isCuti = widget.isCutiForDate(date);
                final bool hasSchedules = widget.hasSchedulesForDate(date);

                // Continuous mathematical distance from viewport center (matching Web GSAP Coverflow)
                final double itemCenter =
                    leadingPadding + index * _totalItemSpace + _itemWidth / 2;
                final double distanceRatio =
                    (itemCenter - viewportCenter).abs() / _totalItemSpace;

                final double scale = (1.14 - distanceRatio * 0.22).clamp(
                  0.72,
                  1.14,
                );
                final double opacity = (1.0 - distanceRatio * 0.35).clamp(
                  0.35,
                  1.0,
                );
                final bool isCloseToCenter = distanceRatio < 0.45;

                return Container(
                  width: _totalItemSpace,
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: SizedBox(
                        width: _itemWidth,
                        height: 84,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: isCloseToCenter
                                ? (isCuti
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: <Color>[
                                            AmanahColorTokens.warning,
                                            AmanahColorTokens.warningDark,
                                          ],
                                        )
                                      : (dark
                                            ? AmanahColorTokens
                                                  .btnCrispBlueDarkGradient
                                            : AmanahColorTokens
                                                  .btnCrispBlueGradient))
                                : null,
                            color: isCloseToCenter
                                ? null
                                : (dark
                                      ? AmanahColorTokens.pureWhite
                                            .withValues(alpha: 0.05)
                                      : AmanahColorTokens.surfaceLight),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isCloseToCenter
                                  ? (isCuti
                                        ? AmanahColorTokens.amberDark
                                        : (dark
                                              ? AmanahColorTokens
                                                    .btnCrispBlueDarkBorder
                                              : AmanahColorTokens
                                                    .btnCrispBlueBorder))
                                  : (dark
                                        ? AmanahColorTokens.pureWhite
                                              .withValues(alpha: 0.10)
                                        : AmanahColorTokens.neutral200),
                              width: 1,
                            ),
                            boxShadow: isCloseToCenter
                                ? <BoxShadow>[
                                    if (isCuti)
                                      BoxShadow(
                                        color: AmanahColorTokens.warning
                                            .withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    else if (dark)
                                      AmanahColorTokens.btnCrispBlueDarkShadow
                                    else
                                      AmanahColorTokens.btnCrispBlueShadow,
                                  ]
                                : <BoxShadow>[
                                    BoxShadow(
                                      color: AmanahColorTokens.pureBlack
                                          .withValues(alpha: 0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                widget.onSelectDate(date);
                                _centerDate(date, animate: true);
                                widget.onDateTap?.call(date);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    _getMonthAbbr(date.month),
                                    style: TextStyle(
                                      color: isCloseToCenter
                                          ? AmanahColorTokens.surfaceLight
                                          : (dark
                                                ? AmanahColorTokens
                                                      .pureWhite
                                                      .withValues(alpha: 0.70)
                                                : AmanahColorTokens
                                                      .neutral500),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: isCloseToCenter
                                          ? AmanahColorTokens.surfaceLight
                                          : (dark
                                                ? AmanahColorTokens
                                                      .pureWhite
                                                : AmanahColorTokens
                                                      .neutral900),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      height: 1.0,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        isToday
                                            ? 'Hari ini'
                                            : (isCuti
                                                  ? ScheduleFormConstants.statusCuti
                                                  : '${date.year}'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isCloseToCenter
                                              ? AmanahColorTokens.surfaceLight
                                                    .withValues(alpha: 0.95)
                                              : (dark
                                                    ? AmanahColorTokens
                                                          .pureWhite
                                                          .withValues(
                                                            alpha: 0.55,
                                                          )
                                                    : AmanahColorTokens
                                                          .neutral400),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (isCuti)
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: isCloseToCenter
                                                ? AmanahColorTokens
                                                      .surfaceLight
                                                : AmanahColorTokens.warning,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      else if (hasSchedules)
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: isCloseToCenter
                                                ? AmanahColorTokens
                                                      .surfaceLight
                                                : (dark
                                                      ? AmanahColorTokens
                                                            .tabActiveDark
                                                      : AmanahColorTokens
                                                            .brand),
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      else
                                        const SizedBox(width: 5, height: 5),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            ),
          ),
        );
      },
    );
  }
}
