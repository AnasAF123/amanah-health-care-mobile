import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_facets.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_replacement_opportunity_card.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/replacement/amanah_replacement_date_strip.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/replacement/amanah_replacement_staff_facet_chips.dart';

/// Decoupled, self-contained viewport for "Jadwal Pengganti" (Replacements).
/// Combines the KAI Access-style horizontal date strip, staff facet chips,
/// and day-scoped deterministic replacement card list.
class AmanahReplacementScheduleViewport extends StatefulWidget {
  const AmanahReplacementScheduleViewport({
    required this.items,
    required this.facets,
    required this.onRefresh,
    required this.onQueryChanged,
    required this.onItemTap,
    required this.onClaim,
    required this.staffProfileId,
    required this.doctorName,
    this.initialDate,
    this.timeService,
    super.key,
  });

  final List<ReplacementItem> items;
  final ReplacementFacets facets;
  final Future<void> Function() onRefresh;
  final Future<void> Function({String? exactDate, String? staffProfileId}) onQueryChanged;
  final ValueChanged<ReplacementItem> onItemTap;
  final Future<bool> Function(ReplacementItem) onClaim;
  final String staffProfileId;
  final String doctorName;
  final DateTime? initialDate;
  final TimeService? timeService;

  @override
  State<AmanahReplacementScheduleViewport> createState() =>
      _AmanahReplacementScheduleViewportState();
}

class _AmanahReplacementScheduleViewportState extends State<AmanahReplacementScheduleViewport> {
  late final TimeService _timeService;
  late DateTime _selectedDate;
  String? _selectedStaffProfileId;
  bool _initializedDate = false;

  @override
  void initState() {
    super.initState();
    _timeService = widget.timeService ?? DefaultTimeService();
    _selectedDate = normalizeToCalendarDate(widget.initialDate ?? _timeService.today());
    _tryApplySmartDate();
  }

  @override
  void didUpdateWidget(AmanahReplacementScheduleViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != null && !_timeService.isSameDay(widget.initialDate, _selectedDate)) {
      _selectedDate = normalizeToCalendarDate(widget.initialDate!);
    }
    _tryApplySmartDate();
  }

  void _tryApplySmartDate() {
    if (!_initializedDate && widget.facets.availableDates.isNotEmpty) {
      final String todayIso = formatIsoDateString(_timeService.today());
      final bool todayHasShifts = widget.facets.availableDates.any(
        (ReplacementDateFacet d) => d.workDate == todayIso,
      );

      if (!todayHasShifts) {
        try {
          final DateTime earliest = DateTime.parse(widget.facets.availableDates.first.workDate);
          _selectedDate = normalizeToCalendarDate(earliest);
          _initializedDate = true;
          widget.onQueryChanged(
            exactDate: formatIsoDateString(_selectedDate),
            staffProfileId: _selectedStaffProfileId,
          );
          return;
        } catch (_) {}
      }
      _initializedDate = true;
    }
  }

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = normalizeToCalendarDate(date);
    });
    widget.onQueryChanged(
      exactDate: formatIsoDateString(_selectedDate),
      staffProfileId: _selectedStaffProfileId,
    );
  }

  void _handleStaffSelected(ReplacementStaffFacet? staff) {
    setState(() {
      _selectedStaffProfileId = staff?.staffProfileId;
    });

    if (staff != null && staff.earliestDate.isNotEmpty) {
      try {
        final DateTime staffDate = normalizeToCalendarDate(DateTime.parse(staff.earliestDate));
        setState(() {
          _selectedDate = staffDate;
        });
        widget.onQueryChanged(exactDate: staff.earliestDate, staffProfileId: staff.staffProfileId);
        return;
      } catch (_) {}
    }

    widget.onQueryChanged(
      exactDate: formatIsoDateString(_selectedDate),
      staffProfileId: _selectedStaffProfileId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Set<String> availableDatesSet = widget.facets.availableDates
        .map((ReplacementDateFacet d) => d.workDate)
        .toSet();

    final String selectedIso = formatIsoDateString(_selectedDate);

    // Strictly scope items to the active selected date and optional staff filter
    final List<ReplacementItem> scopedItems = widget.items.where((item) {
      if (item.workDate != selectedIso) {
        return false;
      }
      if (_selectedStaffProfileId != null &&
          item.originalStaffProfileId != _selectedStaffProfileId) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: <Widget>[
        const SizedBox(height: 6),

        // 1. KAI-Style Horizontal Date Strip
        AmanahReplacementDateStrip(
          selectedDate: _selectedDate,
          onDateSelected: _handleDateSelected,
          availableDates: availableDatesSet,
          timeService: _timeService,
        ),

        const SizedBox(height: 10),

        // 2. Horizontal Staff Facet Chips
        AmanahReplacementStaffFacetChips(
          staffFacets: widget.facets.distinctStaff,
          totalOpenCount: widget.facets.totalOpenOpportunities,
          selectedStaffProfileId: _selectedStaffProfileId,
          onStaffSelected: _handleStaffSelected,
        ),

        const SizedBox(height: 12),

        // 3. Day-Scoped Replacement Opportunities List
        Expanded(
          child: AmanahPullToRefresh(
            onRefresh: widget.onRefresh,
            child: scopedItems.isEmpty
                ? const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: AmanahEmptyState.box(
                      title: 'Tidak Ada Jadwal Pengganti',
                      message:
                          'Silakan pilih tanggal lain yang bertanda titik aktif pada kalender di atas.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                    itemCount: scopedItems.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final ReplacementItem item = scopedItems[index];
                      return AmanahReplacementOpportunityCard(
                        item: item,
                        onTap: () => widget.onItemTap(item),
                        onClaim: () => widget.onClaim(item),
                        currentStaffProfileId: widget.staffProfileId,
                        currentUserName: widget.doctorName,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
