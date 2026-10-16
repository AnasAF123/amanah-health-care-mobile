import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/doctor_roster.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/session_roster_tile.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/schedule_roster_controller.dart';

class WeeklyScheduleAccordion extends StatefulWidget {
  const WeeklyScheduleAccordion({
    required this.controller,
    this.focusedDate,
    this.onClearFocusedDate,
    super.key,
  });

  final ScheduleRosterController controller;
  final DateTime? focusedDate;
  final VoidCallback? onClearFocusedDate;

  @override
  State<WeeklyScheduleAccordion> createState() =>
      _WeeklyScheduleAccordionState();
}

class _WeeklyScheduleAccordionState extends State<WeeklyScheduleAccordion> {
  final Set<int> _expandedDays = <int>{};

  @override
  void initState() {
    super.initState();
    _syncExpandedState();
  }

  @override
  void didUpdateWidget(covariant WeeklyScheduleAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusedDate != oldWidget.focusedDate &&
        widget.focusedDate != null) {
      _syncExpandedState();
    }
  }

  void _syncExpandedState() {
    if (widget.focusedDate != null) {
      final int focusedDow = widget.focusedDate!.weekday % 7;
      _expandedDays.add(focusedDow);
    } else {
      final int todayDow = DateTime.now().weekday % 7;
      _expandedDays.add(todayDow);
    }
  }

  String _formatFocusedDate(DateTime date) {
    const List<String> days = <String>[
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];
    const List<String> months = <String>[
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final String dayName = days[date.weekday % 7];
    final String monthName = months[(date.month - 1).clamp(0, 11)];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  void _toggleExpanded(int dow) {
    setState(() {
      if (_expandedDays.contains(dow)) {
        _expandedDays.remove(dow);
      } else {
        _expandedDays.add(dow);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final DoctorRoster? roster = widget.controller.roster;
    if (roster == null) {
      return const SizedBox.shrink();
    }

    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final int? focusedDow = widget.focusedDate != null
        ? widget.focusedDate!.weekday % 7
        : null;

    final Widget? focusBanner = widget.focusedDate != null
        ? Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.12)
                  : AmanahColorTokens.brand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dark
                    ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.35)
                    : AmanahColorTokens.brand.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.event_available_rounded,
                  size: 18,
                  color: dark
                      ? AmanahColorTokens.tabActiveDark
                      : AmanahColorTokens.brand,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menyesuaikan Sesi: ${_formatFocusedDate(widget.focusedDate!)}',
                    style: TextStyle(
                      color: dark
                          ? AmanahColorTokens.tabActiveDark
                          : AmanahColorTokens.brand,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (widget.onClearFocusedDate != null)
                  InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: widget.onClearFocusedDate,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                      ),
                    ),
                  ),
              ],
            ),
          )
        : null;

    final Widget listView = ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roster.days.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int index) {
            final DoctorRosterDay day = roster.days[index];
            final bool isFocused = day.dow == focusedDow;
            final bool isExpanded = _expandedDays.contains(day.dow);
            final bool isDayActive = widget.controller.isDayActive(day.dow);
            final bool hasDiff =
                widget.controller.hasDayDiffFromTemplate(day.dow);

            return Container(
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.surfaceDark
                    : AmanahColorTokens.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFocused
                      ? (dark
                          ? AmanahColorTokens.tabActiveDark
                          : AmanahColorTokens.brand)
                      : isDayActive
                          ? (dark
                              ? AmanahColorTokens.tabActiveDark
                                  .withValues(alpha: 0.3)
                              : AmanahColorTokens.brand.withValues(alpha: 0.25))
                          : (dark
                              ? AmanahColorTokens.neutral700
                                  .withValues(alpha: 0.4)
                              : AmanahColorTokens.neutral200),
                  width: isFocused ? 1.8 : 1.0,
                ),
              ),
              child: Column(
                children: <Widget>[
                  // Day Accordion Header
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _toggleExpanded(day.dow),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: <Widget>[
                          // Day Name
                          Text(
                            day.dayName,
                            style: TextStyle(
                              color: dark
                                  ? AmanahColorTokens.surfaceLight
                                  : AmanahColorTokens.neutral900,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),

                          if (isFocused) ...<Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: (dark
                                        ? AmanahColorTokens.tabActiveDark
                                        : AmanahColorTokens.brand)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: (dark
                                          ? AmanahColorTokens.tabActiveDark
                                          : AmanahColorTokens.brand)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                'Fokus Kalender',
                                style: TextStyle(
                                  color: dark
                                      ? AmanahColorTokens.tabActiveDark
                                      : AmanahColorTokens.brand,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],

                      if (!day.isOperatingDay)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AmanahColorTokens.warning.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Klinik Tutup',
                            style: TextStyle(
                              color: AmanahColorTokens.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // Reset day to template button if modified
                      if (hasDiff)
                        IconButton(
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Kembalikan hari ini ke template klinik',
                          color: dark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral500,
                          onPressed: () =>
                              widget.controller.resetDayToTemplate(day.dow),
                        ),
                      if (hasDiff) const SizedBox(width: 8),

                      // Day Active / Libur Label
                      Text(
                        isDayActive ? 'Aktif' : 'Libur',
                        style: TextStyle(
                          color: isDayActive
                              ? (dark
                                  ? AmanahColorTokens.tabActiveDark
                                  : AmanahColorTokens.brand)
                              : (dark
                                  ? AmanahColorTokens.neutral400
                                  : AmanahColorTokens.neutral500),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Day Level Master Switch
                      Switch.adaptive(
                        value: isDayActive,
                        activeThumbColor: dark
                            ? AmanahColorTokens.tabActiveDark
                            : AmanahColorTokens.brand,
                        onChanged: (_) =>
                            widget.controller.toggleDay(day.dow),
                      ),
                      const SizedBox(width: 4),

                      // Expand Chevron
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Expanded 4 Daily Sessions
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Column(
                    children: day.sessions.map((DoctorRosterSession session) {
                      final bool active = widget.controller.isSessionActive(
                        day.dow,
                        session.sessionId,
                      );
                      return SessionRosterTile(
                        session: session,
                        isActive: active,
                        onChanged: (_) => widget.controller.toggleSession(
                          day.dow,
                          session.sessionId,
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ?focusBanner,
        listView,
      ],
    );
  }
}
