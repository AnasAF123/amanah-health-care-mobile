import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/calendar_session_accordion.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/calendar_sheet_controller.dart';

class ScheduleCalendarDetailSheet extends StatefulWidget {
  const ScheduleCalendarDetailSheet({
    required this.selectedDate,
    this.controller,
    super.key,
  });

  final DateTime selectedDate;
  final CalendarSheetController? controller;

  static Future<void> show(
    BuildContext context, {
    required DateTime selectedDate,
    CalendarSheetController? controller,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => ScheduleCalendarDetailSheet(
        selectedDate: selectedDate,
        controller: controller,
      ),
    );
  }

  @override
  State<ScheduleCalendarDetailSheet> createState() =>
      _ScheduleCalendarDetailSheetState();
}

class _ScheduleCalendarDetailSheetState
    extends State<ScheduleCalendarDetailSheet> {
  late final CalendarSheetController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = CalendarSheetController(selectedDate: widget.selectedDate);
      _ownsController = true;
    }
    _controller.loadSessions();
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  String _formatDateHeader(DateTime date) =>
      formatLocalizedDate(date, style: 'human_full');

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, _) {
        return AmanahBottomSheetScaffold(
          title: 'Sesi Praktik Kalender',
          subtitle: _formatDateHeader(widget.selectedDate),
          maxHeightFactor: 0.88,
          minHeight: 460,
          body: _controller.isLoadingSessions
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _controller.errorMessage != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 40,
                              color: AmanahColorTokens.danger,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _controller.errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AmanahColorTokens.danger,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AmanahButton.secondary(
                              text: 'Coba Lagi',
                              size: AmanahButtonSize.small,
                              onPressed: _controller.loadSessions,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: CalendarSessionAccordion(controller: _controller),
                    ),
        );
      },
    );
  }
}
