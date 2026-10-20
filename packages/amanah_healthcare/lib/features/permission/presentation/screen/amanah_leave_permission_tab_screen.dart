import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_my_permissions_view.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_detail_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_form_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_segment_switcher.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_replacement_detail_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_replacement_opportunities_view.dart';
import 'package:amanah_healthcare/features/permission/presentation/state/permission_controller.dart';

/// Master Leave & Permission Screen (Orchestrator).
/// Backed by real Feature-First Clean Architecture and backend endpoints.
/// Orchestrates the segment switcher and delegates view rendering to atomic components.
class AmanahLeavePermissionTabScreen extends StatefulWidget {
  const AmanahLeavePermissionTabScreen({
    this.onBack,
    this.doctorName = '',
    this.doctorRole = '',
    this.doctorAvatarUrl,
    this.staffProfileId = '',
    this.controller,
    super.key,
  });

  final VoidCallback? onBack;
  final String doctorName;
  final String doctorRole;
  final String? doctorAvatarUrl;
  final String staffProfileId;
  final PermissionController? controller;

  static Route<void> route({
    VoidCallback? onBack,
    String doctorName = '',
    String doctorRole = '',
    String? doctorAvatarUrl,
    String staffProfileId = '',
  }) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => AmanahLeavePermissionTabScreen(
        onBack: onBack,
        doctorName: doctorName,
        doctorRole: doctorRole,
        doctorAvatarUrl: doctorAvatarUrl,
        staffProfileId: staffProfileId,
      ),
    );
  }

  @override
  State<AmanahLeavePermissionTabScreen> createState() =>
      _AmanahLeavePermissionTabScreenState();
}

class _AmanahLeavePermissionTabScreenState
    extends State<AmanahLeavePermissionTabScreen> {
  late final PermissionController _controller;
  late final PageController _pageController;
  AmanahPermissionStatus? _statusFilter;
  int _activeSegment = 0; // 0: Izin Saya, 1: Peluang Pengganti

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeSegment);
    _controller = widget.controller ?? PermissionController();
    _controller.addListener(_onControllerUpdated);
    _controller.fetchMyLeaves();
    _controller.fetchAvailableReplacements();
    AmanahPushService.instance.addMessageListener(_onPushReceived);
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
      _controller.fetchAvailableReplacements();
    }
  }

  void _onControllerUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  AmanahPermissionRecord _mapEntityToRecord(LeaveRequestEntity entity) {
    return AmanahPermissionRecord(
      id: entity.id,
      userId: entity.staffId,
      userName:
          widget.doctorName.isNotEmpty ? widget.doctorName : 'Staf Amanah',
      userRole:
          widget.doctorRole.isNotEmpty ? widget.doctorRole : 'Staf Klinik',
      userAvatarUrl: widget.doctorAvatarUrl ?? '',
      startDate: entity.startDate,
      endDate: entity.endDate,
      durationDays: entity.durationDays,
      type: AmanahPermissionType.fromString(entity.type),
      reason: entity.reason,
      status: AmanahPermissionStatus.fromString(entity.status),
      createdAt: entity.createdAt.toIso8601String(),
      reviewerNotes: entity.approvalNotes,
      cancelledAt: entity.cancelledAt?.toIso8601String(),
    );
  }

  Future<void> _handleOpenCreateForm() async {
    final AmanahPermissionFormData? result =
        await AmanahPermissionFormDrawer.show(
      context: context,
      doctorName: widget.doctorName,
      doctorRole: widget.doctorRole,
      doctorAvatarUrl: widget.doctorAvatarUrl,
    );

    if (result != null && mounted) {
      await _controller.submitLeave(
        startDate: DateTime.parse(result.startDate),
        endDate: DateTime.parse(result.endDate),
        reason: result.reason,
        type: result.type.name,
        scope: result.scope,
        sessionIds: result.sessionIds,
      );
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final List<LeaveRequestEntity> rawLeaves = _controller.myLeaves;
    final List<AmanahPermissionRecord> allRecords =
        rawLeaves.map(_mapEntityToRecord).toList();

    return Scaffold(
      backgroundColor: AmanahThemeTokens.canvas(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // 1. Header with Add Action
            AmanahScreenHeader(
              title: 'Perizinan',
              onBack: widget.onBack,
              rightAction: AmanahButton.icon(
                icon: Icons.add_rounded,
                onPressed: _handleOpenCreateForm,
                customBackgroundColor: Colors.transparent,
                customBorder: Border.all(color: Colors.transparent),
                customForegroundColor: dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand,
                semanticsLabel: 'Tambah Perizinan Baru',
              ),
            ),

            // 2. Orchestrated Segment Switcher
            AmanahPermissionSegmentSwitcher(
              activeSegment: _activeSegment,
              onSegmentChanged: (int index) {
                if (_activeSegment != index) {
                  setState(() => _activeSegment = index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOutCubic,
                  );
                }
              },
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
                  AmanahReplacementOpportunitiesView(
                    items: _controller.availableReplacements,
                    onRefresh: () async {
                      await _controller.fetchAvailableReplacements();
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
    );
  }
}
