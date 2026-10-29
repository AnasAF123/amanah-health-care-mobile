import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

const List<String> _shortDays = <String>['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

/// KAI Access-style horizontal date strip / date carousel.
/// Renders a horizontal scrollable row of calendar days starting from today.
/// Highlights the active date and indicates days with available replacement opportunities.
class AmanahReplacementDateStrip extends StatefulWidget {
  const AmanahReplacementDateStrip({
    required this.selectedDate,
    required this.onDateSelected,
    this.availableDates = const <String>{},
    this.startDate,
    this.daysCount = 60,
    this.scrollController,
    this.timeService,
    super.key,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Set<String> availableDates;
  final DateTime? startDate;
  final int daysCount;
  final ScrollController? scrollController;
  final TimeService? timeService;

  static const double itemWidth = 72.0;
  static const double itemSpacing = 8.0;

  @override
  State<AmanahReplacementDateStrip> createState() => _AmanahReplacementDateStripState();
}

class _AmanahReplacementDateStripState extends State<AmanahReplacementDateStrip> {
  late final ScrollController _controller;
  late final TimeService _timeService;
  late final DateTime _baseStart;
  bool _internalController = false;

  @override
  void initState() {
    super.initState();
    _timeService = widget.timeService ?? DefaultTimeService();
    _baseStart = normalizeToCalendarDate(widget.startDate ?? _timeService.today());
    if (widget.scrollController != null) {
      _controller = widget.scrollController!;
    } else {
      _controller = ScrollController();
      _internalController = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToDate(widget.selectedDate, animate: false);
    });
  }

  @override
  void didUpdateWidget(AmanahReplacementDateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!isSameCalendarDay(oldWidget.selectedDate, widget.selectedDate)) {
      _scrollToDate(widget.selectedDate, animate: true);
    }
  }

  @override
  void dispose() {
    if (_internalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _scrollToDate(DateTime target, {bool animate = true}) {
    final int index = target.difference(_baseStart).inDays;
    if (index < 0 || index >= widget.daysCount) {
      return;
    }

    final double offset =
        index * (AmanahReplacementDateStrip.itemWidth + AmanahReplacementDateStrip.itemSpacing);
    final double maxScroll = _controller.hasClients ? _controller.position.maxScrollExtent : 0.0;
    final double targetOffset = offset.clamp(0.0, maxScroll);

    if (_controller.hasClients) {
      if (animate) {
        _controller.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _controller.jumpTo(targetOffset);
      }
    }
  }

  String _formatShortMonth(int month) {
    const List<String> m = <String>[
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return (month >= 1 && month <= 12) ? m[month] : '';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 78,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: widget.daysCount,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AmanahReplacementDateStrip.itemSpacing),
        itemBuilder: (BuildContext context, int index) {
          final DateTime date = _baseStart.add(Duration(days: index));
          final bool isSelected = isSameCalendarDay(date, widget.selectedDate);
          final String isoDate = formatIsoDateString(date);
          final bool hasOpportunities = widget.availableDates.contains(isoDate);

          final Color bgColor = isSelected
              ? (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
              : (dark ? AmanahColorTokens.surfaceDark : AmanahColorTokens.surfaceLight);

          final Color dayColor = isSelected
              ? Colors.white.withValues(alpha: 0.9)
              : AmanahThemeTokens.textSecondary(context);

          final Color dateColor = isSelected
              ? Colors.white
              : AmanahThemeTokens.textPrimary(context);

          final Color borderColor = isSelected
              ? (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
              : (dark ? AmanahColorTokens.neutral700 : AmanahColorTokens.neutral200);

          return Semantics(
            button: true,
            selected: isSelected,
            label: '${_shortDays[date.weekday]}, ${date.day} ${_formatShortMonth(date.month)}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  widget.onDateSelected(date);
                  _scrollToDate(date, animate: true);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: AmanahReplacementDateStrip.itemWidth,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.2),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color:
                                  (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
                                      .withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            _shortDays[date.weekday],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: dayColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: dateColor,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            _formatShortMonth(date.month),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: dayColor,
                            ),
                          ),
                        ],
                      ),
                      // Indicator Dot for available replacement opportunities
                      if (hasOpportunities)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : (dark ? const Color(0xFF10B981) : const Color(0xFF059669)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
