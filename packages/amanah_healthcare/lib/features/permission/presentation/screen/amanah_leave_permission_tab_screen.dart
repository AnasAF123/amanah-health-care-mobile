import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_filter_bar.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/leave_request_entity.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_item.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_card.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_detail_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/amanah_permission_form_drawer.dart';
import 'package:amanah_healthcare/features/permission/presentation/state/permission_controller.dart';

/// Master Leave & Permission Screen
/// Backed by real Feature-First Clean Architecture and backend endpoints
class AmanahLeavePermissionTabScreen extends StatefulWidget {
  const AmanahLeavePermissionTabScreen({
    this.onBack,
    this.doctorName = '',
    this.doctorRole = '',
    this.doctorAvatarUrl = 'assets/amanah/auth/auth_background.png',
    this.controller,
    super.key,
  });

  final VoidCallback? onBack;
  final String doctorName;
  final String doctorRole;
  final String doctorAvatarUrl;
  final PermissionController? controller;

  static Route<void> route({VoidCallback? onBack}) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) =>
          AmanahLeavePermissionTabScreen(onBack: onBack),
    );
  }

  @override
  State<AmanahLeavePermissionTabScreen> createState() =>
      _AmanahLeavePermissionTabScreenState();
}

class _AmanahLeavePermissionTabScreenState
    extends State<AmanahLeavePermissionTabScreen> {
  late final PermissionController _controller;
  AmanahPermissionStatus? _statusFilter;
  int _activeSegment = 0; // 0: Izin Saya, 1: Peluang Pengganti

  @override
  void initState() {
    super.initState();
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
      userAvatarUrl: widget.doctorAvatarUrl,
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

  Future<void> _handleClaimReplacement(ReplacementItem item) async {
    final bool confirmed = await showAmanahConfirmationDialog(
      context: context,
      title: 'Klaim Jadwal Pengganti?',
      message:
          'Apakah Anda bersedia mengambil alih dinas pengganti untuk tanggal ${item.workDate}? Jadwal ini akan otomatis ditambahkan ke daftar hadir dan kompensasi lembur Anda.',
      confirmLabel: 'Ya, Ambil Jadwal Ini',
      cancelLabel: 'Batal',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await _controller.claimReplacement(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final List<LeaveRequestEntity> rawLeaves = _controller.myLeaves;
    final List<AmanahPermissionRecord> allRecords =
        rawLeaves.map(_mapEntityToRecord).toList();

    final List<AmanahPermissionRecord> filteredList =
        _statusFilter == null
            ? allRecords
            : allRecords
                .where((AmanahPermissionRecord r) => r.status == _statusFilter)
                .toList();

    final int pendingCount =
        allRecords.where((r) => r.status == AmanahPermissionStatus.menunggu).length;
    final int openReplacementsCount = _controller.availableReplacements.length;

    return Scaffold(
      backgroundColor: AmanahThemeTokens.canvas(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // 1. Header
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

            // 2. Segment Switcher (Izin Saya vs Peluang Pengganti)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                      : AmanahColorTokens.neutral100,
                  borderRadius: BorderRadius.circular(100),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeSegment = 0),
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeSegment == 0
                                ? (dark
                                    ? AmanahColorTokens.surfaceLight
                                        .withValues(alpha: 0.15)
                                    : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: _activeSegment == 0
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Izin Saya (${allRecords.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _activeSegment == 0
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _activeSegment == 0
                                  ? (dark
                                      ? Colors.white
                                      : AmanahColorTokens.neutral900)
                                  : AmanahColorTokens.neutral500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeSegment = 1),
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _activeSegment == 1
                                ? (dark
                                    ? AmanahColorTokens.surfaceLight
                                        .withValues(alpha: 0.15)
                                    : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: _activeSegment == 1
                                ? <BoxShadow>[
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'Jadwal Pengganti',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _activeSegment == 1
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _activeSegment == 1
                                      ? (dark
                                          ? Colors.white
                                          : AmanahColorTokens.neutral900)
                                      : AmanahColorTokens.neutral500,
                                ),
                              ),
                              if (openReplacementsCount > 0) ...<Widget>[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AmanahColorTokens.brand,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    '$openReplacementsCount',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_activeSegment == 0) ...<Widget>[
              // Filter Chips
              AmanahFilterBar<AmanahPermissionStatus?>(
                selectedValue: _statusFilter,
                onSelected: (AmanahPermissionStatus? status) {
                  setState(() => _statusFilter = status);
                },
                items: <AmanahFilterBarItem<AmanahPermissionStatus?>>[
                  const AmanahFilterBarItem<AmanahPermissionStatus?>(
                    value: null,
                    label: 'Semua',
                  ),
                  AmanahFilterBarItem<AmanahPermissionStatus?>(
                    value: AmanahPermissionStatus.menunggu,
                    label: 'Menunggu',
                    badgeCount: pendingCount,
                  ),
                  const AmanahFilterBarItem<AmanahPermissionStatus?>(
                    value: AmanahPermissionStatus.disetujui,
                    label: 'Disetujui',
                  ),
                  const AmanahFilterBarItem<AmanahPermissionStatus?>(
                    value: AmanahPermissionStatus.ditolak,
                    label: 'Ditolak',
                  ),
                  const AmanahFilterBarItem<AmanahPermissionStatus?>(
                    value: AmanahPermissionStatus.dibatalkan,
                    label: 'Dibatalkan',
                  ),
                ],
              ),

              // Cards List Viewport
              Expanded(
                child: AmanahPullToRefresh(
                  onRefresh: () async {
                    await _controller.fetchMyLeaves();
                  },
                  child: _controller.isLoading && allRecords.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : filteredList.isEmpty
                          ? _EmptyPermissionView(
                              onAddPermission: _handleOpenCreateForm,
                              selectedStatus: _statusFilter,
                              onResetFilter: _statusFilter != null
                                  ? () => setState(() => _statusFilter = null)
                                  : null,
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              itemCount: filteredList.length,
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const SizedBox(height: 14),
                              itemBuilder: (BuildContext context, int index) {
                                final AmanahPermissionRecord item =
                                    filteredList[index];
                                return AmanahPermissionCard(
                                  item: item,
                                  onTap: () => _handleOpenDetail(item),
                                );
                              },
                            ),
                ),
              ),
            ] else ...<Widget>[
              // Peluang Pengganti Segment
              Expanded(
                child: AmanahPullToRefresh(
                  onRefresh: () async {
                    await _controller.fetchAvailableReplacements();
                  },
                  child: _controller.availableReplacements.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: AmanahEmptyState.box(
                              title: 'Tidak Ada Jadwal Pengganti Terbuka',
                              message:
                                  'Saat rekan kerja mengajukan izin dan disetujui, sesi dinas yang kosong akan muncul di sini agar dapat Anda klaim.',
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                          itemCount: _controller.availableReplacements.length,
                          separatorBuilder:
                              (BuildContext context, int index) =>
                                  const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int index) {
                            final ReplacementItem item =
                                _controller.availableReplacements[index];
                            return _ReplacementOpportunityCard(
                              item: item,
                              onClaim: () => _handleClaimReplacement(item),
                              dark: dark,
                            );
                          },
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReplacementOpportunityCard extends StatelessWidget {
  const _ReplacementOpportunityCard({
    required this.item,
    required this.onClaim,
    required this.dark,
  });

  final ReplacementItem item;
  final VoidCallback onClaim;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
              : AmanahColorTokens.neutral200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AmanahColorTokens.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'PELUANG DINAS TERBUKA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AmanahColorTokens.brand,
                  ),
                ),
              ),
              Text(
                item.workDate,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Sesi Dinas: ${item.sessionCode ?? item.sessionId}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Menggantikan jadwal rekan yang berhalangan hadir. Insentif dinas pengganti dihitung secara otomatis pada periode penggajian.',
            style: TextStyle(
              fontSize: 11.5,
              color: dark
                  ? AmanahColorTokens.neutral400
                  : AmanahColorTokens.neutral600,
            ),
          ),
          const SizedBox(height: 14),
          AmanahButton.primary(
            text: 'Ambil Jadwal Pengganti Ini',
            isFullWidth: true,
            size: AmanahButtonSize.small,
            onPressed: onClaim,
          ),
        ],
      ),
    );
  }
}

class _EmptyPermissionView extends StatelessWidget {
  const _EmptyPermissionView({
    required this.onAddPermission,
    this.selectedStatus,
    this.onResetFilter,
  });

  final VoidCallback onAddPermission;
  final AmanahPermissionStatus? selectedStatus;
  final VoidCallback? onResetFilter;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: AmanahEmptyState.box(
        title: selectedStatus == null
            ? 'Belum Ada Pengajuan Izin'
            : 'Tidak Ada Izin ${selectedStatus!.label}',
        message: selectedStatus == null
            ? 'Belum ada riwayat perizinan cuti, sakit, atau dinas luar yang terdaftar.'
            : 'Tidak ditemukan riwayat perizinan dengan status "${selectedStatus!.label}".',
        actionText: 'Ajukan Izin',
        actionLeadingIcon: Icons.add_rounded,
        onAction: onAddPermission,
        secondaryActionText: selectedStatus != null ? 'Tampilkan Semua' : null,
        secondaryActionLeadingIcon:
            selectedStatus != null ? Icons.filter_alt_off_rounded : null,
        onSecondaryAction: onResetFilter,
      ),
    );
  }
}
