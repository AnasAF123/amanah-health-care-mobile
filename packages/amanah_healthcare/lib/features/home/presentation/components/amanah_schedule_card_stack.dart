import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_dual_stack_ticket_shell.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_card.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_empty_card.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_schedule_card_tokens.dart';
import 'package:amanah_healthcare/features/payroll/presentation/screen/amanah_payroll_history_screen.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

export 'package:amanah_healthcare/features/home/presentation/components/amanah_dual_stack_ticket_shell.dart';
export 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_card.dart';
export 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_card_widgets.dart';
export 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_empty_card.dart';
export 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_ticket_painters.dart';
export 'package:amanah_healthcare/features/home/presentation/components/amanah_ticket_card_shell.dart';

/// Organism: Stack of 3D Doctor Schedule Cards on the Home Screen.
/// Provides drag swipe mechanics, 3D card layering depth, dismiss animations,
/// and an integrated dual-stack pixelated bottom lip for payroll reports.
class AmanahScheduleCardStack extends StatefulWidget {
  const AmanahScheduleCardStack({
    required this.schedules,
    this.onCardTap,
    this.onCreateSchedule,
    this.onSalaryReportTap,
    this.showSalaryLip = true,
    super.key,
  });

  final List<DoctorSchedule> schedules;
  final ValueChanged<DoctorSchedule>? onCardTap;
  final VoidCallback? onCreateSchedule;
  final VoidCallback? onSalaryReportTap;
  final bool showSalaryLip;

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
    _shuffleController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 380),
          )
          ..addListener(() {
            if (mounted) {
              setState(() {});
            }
          })
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed && mounted) {
              setState(() {
                _currentIndex = (_currentIndex + 1) % widget.schedules.length;
                _dragOffset = 0.0;
                _startDragX = 0.0;
                _shuffleController.reset();
              });
            }
          });

    _cancelController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 220),
          )
          ..addListener(() {
            if (mounted) {
              setState(() {});
            }
          })
          ..addStatusListener((AnimationStatus status) {
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

    final double velocity = details?.primaryVelocity ?? 0.0;
    final bool strongSwipe = velocity.abs() > 400;
    final bool passedThreshold = _dragOffset.abs() > 80.0;

    if (strongSwipe || passedThreshold) {
      _shuffleDirection = velocity != 0 ? velocity.sign : _dragOffset.sign;
      if (_shuffleDirection == 0) {
        _shuffleDirection = 1.0;
      }
      _startDragX = _dragOffset;
      final double currentFrac = (_dragOffset.abs() / 200.0).clamp(0.0, 0.45);
      _shuffleController.forward(from: currentFrac);
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

  Widget _wrapWithDualStack(Widget coreContent) {
    if (!widget.showSalaryLip) {
      return coreContent;
    }

    return AmanahDualStackTicketShell(
      bottomTitle: 'Laporan Slip Gaji & Insentif',
      bottomActionLabel: 'Lihat Gaji',
      bottomLeadingIcon: Icons.receipt_long_rounded,
      onBottomActionTap: () {
        if (widget.onSalaryReportTap != null) {
          widget.onSalaryReportTap!();
        } else {
          Navigator.of(context).push<void>(
            AmanahPayrollHistoryScreen.route(),
          );
        }
      },
      child: coreContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedules.isEmpty) {
      return _wrapWithDualStack(
        SizedBox(
          height: AmanahScheduleCardTokens.cardHeight,
          width: double.infinity,
          child: RepaintBoundary(
            child: AmanahScheduleEmptyCard(
              onCreateSchedule: widget.onCreateSchedule,
            ),
          ),
        ),
      );
    }

    final int total = widget.schedules.length;

    if (total == 1) {
      return _wrapWithDualStack(
        SizedBox(
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
        ),
      );
    }

    final bool isShuffling = _shuffleController.isAnimating;
    final bool isCancelling = _cancelController.isAnimating;
    final double tShuffle = _shuffleController.value;
    final double tCancel = _cancelController.value;

    final DoctorSchedule schedule0 = widget.schedules[_currentIndex % total];
    final DoctorSchedule schedule1 =
        widget.schedules[(_currentIndex + 1) % total];
    final DoctorSchedule schedule2 =
        widget.schedules[(_currentIndex + (total > 2 ? 2 : 0)) % total];

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
      final double peakX =
          _shuffleDirection * (screenW * 0.72).clamp(240.0, 320.0);

      if (tShuffle < 0.48) {
        // Phase 1: Fly outward
        final double p1 = (tShuffle / 0.48).clamp(0.0, 1.0);
        final double curve1 = Curves.easeOutQuad.transform(p1);

        card0X = _startDragX + (peakX - _startDragX) * curve1;
        card0Y = 10.0 * curve1;
        card0Scale = 1.0 - 0.06 * curve1;
        card0Rot =
            (_startDragX * 0.035 + _shuffleDirection * 7.0 * curve1) *
            (math.pi / 180.0);
        card0Opacity = 1.0 - 0.08 * curve1;
        card0InBack = false;
      } else {
        // Phase 2: Slip behind stack and glide into bottom slot
        final double p2 = ((tShuffle - 0.48) / 0.52).clamp(0.0, 1.0);
        final double curve2 = Curves.easeOutCubic.transform(p2);

        card0X = peakX * (1.0 - curve2);
        card0Y = 10.0 + (28.0 - 10.0) * curve2;
        card0Scale = 0.94 - 0.10 * curve2;
        card0Rot =
            (_shuffleDirection * 7.0 * (1.0 - curve2)) * (math.pi / 180.0);
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

    final Widget stackWidget = GestureDetector(
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
        child: Stack(clipBehavior: Clip.none, children: stackChildren),
      ),
    );

    return _wrapWithDualStack(stackWidget);
  }
}
