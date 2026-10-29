import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/data/mappers/permission_mapper.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_facets.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_my_permissions_view.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_detail_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_form_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_segment_switcher.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_replacement_detail_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/replacement/amanah_replacement_schedule_viewport.dart';
import 'package:amanah_healthcare/features/permission/presentation/state/permission_controller.dart';

/// Master Leave & Permission Screen (Orchestrator).
/// Backed by real Feature-First Clean Architecture and backend endpoints.
/// Orchestrates the segment switcher and delegates view rendering to atomic components.
class AmanahLeavePermissionTabScreen extends StatefulWidget {
  const AmanahLeavePermissionTabScreen({
    this.onBack,
    this.doctorName = '',
    this.doctorRole = '',
    this.avatarUrl,
    this.staffProfileId = '',
    this.controller,
    this.timeService,
    super.key,
  });

  final VoidCallback? onBack;
  final String doctorName;
  final String doctorRole;
  final String? avatarUrl;
  final String staffProfileId;
  final PermissionController? controller;
  final TimeService? timeService;

  static Route<void> route({
    VoidCallback? onBack,
    String doctorName = '',
    String doctorRole = '',
    String? avatarUrl,
    String staffProfileId = '',
    TimeService? timeService,
  }) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => AmanahLeavePermissionTabScreen(
        onBack: onBack,
        doctorName: doctorName,
        doctorRole: doctorRole,
        avatarUrl: avatarUrl,
        staffProfileId: staffProfileId,
        timeService: timeService,
      ),
    );
  }

  @override
  State<AmanahLeavePermissionTabScreen> createState() => _AmanahLeavePermissionTabScreenState();
}

class _AmanahLeavePermissionTabScreenState extends State<AmanahLeavePermissionTabScreen> {
  late final TimeService _timeService;
  late final PermissionController _controller;
  late final PageController _pageController;
  AmanahPermissionStatus? _statusFilter;
  int _activeSegment = 0; // 0: Izin Saya, 1: Peluang Pengganti
  DateTime? _selectedReplacementDate;

  @override
  void initState() {
    super.initState();
    _timeService = widget.timeService ?? DefaultTimeService();
    _pageController = PageController(initialPage: _activeSegment);
    _controller = widget.controller ?? PermissionController();
    _controller.addListener(_onControllerUpdated);
    _controller.fetchMyLeaves();
    _initReplacements();
    AmanahPushService.instance.addMessageListener(_onPushReceived);
  }

  Future<void> _initReplacements() async {
    await _controller.fetchReplacementFacets();
    if (!mounted) {
      return;
    }

    final String todayIso = formatIsoDateString(_timeService.today());
    final List<ReplacementDateFacet> dates = _controller.replacementFacets.availableDates;
    final bool todayHasShifts = dates.any((d) => d.workDate == todayIso);

    String targetDateIso = todayIso;
    if (!todayHasShifts && dates.isNotEmpty) {
      targetDateIso = dates.first.workDate;
    }

    _selectedReplacementDate = DateTime.parse(targetDateIso);
    await _controller.fetchAvailableReplacements(exactDate: targetDateIso);
  }

  @override
  void dispose() {
    AmanahPushService.instance.removeMessageListener(_onPushReceived);
    _controller.removeListener(_onControllerUpdated);
    _pageController.dispose();
    super.dispose();
  }

  void _onPushReceived(RemoteMessage message) {
    if (mounted) {
      _controller.fetchMyLeaves();
      _controller.fetchReplacementFacets();
      _controller.fetchAvailableReplacements(
        exactDate: _selectedReplacementDate != null
            ? formatIsoDateString(_selectedReplacementDate!)
            : null,
      );
    }
  }

  void _onControllerUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  AmanahPermissionRecord _mapEntityToRecord(LeaveRequestEntity entity) {
    return PermissionMapper.toPermissionRecord(
      entity,
      doctorName: widget.doctorName,
      doctorRole: widget.doctorRole,
      avatarUrl: widget.avatarUrl,
    );
  }

  Future<void> _handleOpenCreateForm() async {
    final AmanahPermissionFormData? result = await AmanahPermissionFormDrawer.show(
      context: context,
      doctorName: widget.doctorName,
      doctorRole: widget.doctorRole,
      avatarUrl: widget.avatarUrl,
    );

    if (result != null && mounted) {
      await _controller.submitLeave(formData: result, context: context);
    }
  }

  void _handleOpenDetail(AmanahPermissionRecord record) {
    AmanahPermissionDetailDrawer.show(
      context: context,
      item: record,
      onCancel: () => _showCancelConfirmation(record),
    );
  }

  Future<void> _showCancelConfirmation(AmanahPermissionRecord record) async {
    final bool confirmed = await showAmanahConfirmationDialog(
      context: context,
      title: 'Batalkan pengajuan perizinan?',
      message:
          'Apakah Anda yakin ingin membatalkan pengajuan izin ini (${record.formattedDateRange})? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Ya, Batalkan Izin',
      cancelLabel: 'Kembali',
      destructive: true,
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _controller.cancelLeave(record.id);
  }

  void _handleOpenReplacementDetail(ReplacementItem item) {
    AmanahReplacementDetailDrawer.show(
      context: context,
      item: item,
      currentStaffProfileId: widget.staffProfileId,
      currentUserName: widget.doctorName,
      onClaim: () async {
        return await _controller.claimReplacement(item.id, context: context);
      },
    );
  }

  Future<bool> _handleClaimReplacement(ReplacementItem item) async {
    return await _controller.claimReplacement(item.id, context: context);
  }

  Future<void> _handlePickReplacementDate() async {
    final DateTime today = normalizeToCalendarDate(DateTime.now());
    final DateTime lastDate = DateTime(today.year + 2, today.month, today.day);
    final DateTime initial = _selectedReplacementDate ?? today;
    final DateTime safeInitial = initial.isBefore(today)
        ? today
        : (initial.isAfter(lastDate) ? lastDate : initial);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: today,
      lastDate: lastDate,
      helpText: 'Pilih Tanggal Peluang Pengganti',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      final DateTime normalized = normalizeToCalendarDate(picked);
      setState(() {
        _selectedReplacementDate = normalized;
      });
      await _controller.fetchAvailableReplacements(exactDate: formatIsoDateString(normalized));
    }
  }

  void _switchSegment(int index) {
    if (_activeSegment != index) {
      setState(() => _activeSegment = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final List<LeaveRequestEntity> rawLeaves = _controller.myLeaves;
    final List<AmanahPermissionRecord> allRecords = rawLeaves.map(_mapEntityToRecord).toList();

    final VoidCallback? effectiveBack = _activeSegment == 1
        ? () => _switchSegment(0)
        : widget.onBack;

    return PopScope(
      canPop: _activeSegment == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _activeSegment == 1) {
          _switchSegment(0);
        }
      },
      child: Scaffold(
        backgroundColor: AmanahThemeTokens.canvas(context),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              // 1. Header with Add / Calendar Action
              AmanahScreenHeader(
                title: 'Perizinan',
                onBack: effectiveBack,
                rightAction: _activeSegment == 0
                    ? AmanahButton.icon(
                        icon: Icons.add_rounded,
                        onPressed: _handleOpenCreateForm,
                        customBackgroundColor: Colors.transparent,
                        customBorder: Border.all(color: Colors.transparent),
                        customForegroundColor: dark
                            ? AmanahColorTokens.tabActiveDark
                            : AmanahColorTokens.brand,
                        semanticsLabel: 'Tambah Perizinan Baru',
                      )
                    : AmanahButton.icon(
                        icon: Icons.calendar_month_rounded,
                        onPressed: _handlePickReplacementDate,
                        customBackgroundColor: Colors.transparent,
                        customBorder: Border.all(color: Colors.transparent),
                        customForegroundColor: dark
                            ? AmanahColorTokens.tabActiveDark
                            : AmanahColorTokens.brand,
                        semanticsLabel: 'Pilih Tanggal Jadwal Pengganti',
                      ),
              ),

              // 2. Orchestrated Segment Switcher
              AmanahPermissionSegmentSwitcher(
                activeSegment: _activeSegment,
                onSegmentChanged: _switchSegment,
                myLeavesCount: allRecords.length,
                openReplacementsCount: _controller.availableReplacements.length,
                dark: dark,
              ),

              // 3. Tab Body Viewports (Swipeable PageView)
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int index) {
                    if (_activeSegment != index) {
                      setState(() => _activeSegment = index);
                    }
                  },
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    AmanahMyPermissionsView(
                      records: allRecords,
                      statusFilter: _statusFilter,
                      onFilterSelected: (AmanahPermissionStatus? status) {
                        setState(() => _statusFilter = status);
                      },
                      onRefresh: () async {
                        await _controller.fetchMyLeaves();
                      },
                      onItemTap: _handleOpenDetail,
                      onAddPermission: _handleOpenCreateForm,
                      isLoading: _controller.isLoading,
                    ),
                    AmanahReplacementScheduleViewport(
                      items: _controller.availableReplacements,
                      facets: _controller.replacementFacets,
                      initialDate: _selectedReplacementDate,
                      timeService: _timeService,
                      onRefresh: () async {
                        await _controller.fetchReplacementFacets();
                        final String todayIso = formatIsoDateString(_timeService.today());
                        final List<ReplacementDateFacet> dates =
                            _controller.replacementFacets.availableDates;
                        final bool todayHasShifts = dates.any((d) => d.workDate == todayIso);

                        String targetDateIso = todayIso;
                        if (_selectedReplacementDate != null) {
                          targetDateIso = formatIsoDateString(_selectedReplacementDate!);
                        } else if (!todayHasShifts && dates.isNotEmpty) {
                          targetDateIso = dates.first.workDate;
                        }

                        _selectedReplacementDate = DateTime.parse(targetDateIso);
                        await _controller.fetchAvailableReplacements(exactDate: targetDateIso);
                      },
                      onQueryChanged: ({String? exactDate, String? staffProfileId}) async {
                        if (exactDate != null) {
                          _selectedReplacementDate = DateTime.parse(exactDate);
                        }
                        await _controller.fetchAvailableReplacements(
                          exactDate: exactDate,
                          staffProfileId: staffProfileId,
                        );
                      },
                      onItemTap: _handleOpenReplacementDetail,
                      onClaim: _handleClaimReplacement,
                      staffProfileId: widget.staffProfileId,
                      doctorName: widget.doctorName,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
