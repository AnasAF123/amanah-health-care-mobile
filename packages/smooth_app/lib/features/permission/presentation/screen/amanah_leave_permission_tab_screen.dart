import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_empty_state.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_filter_bar.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/features/permission/data/amanah_permission_store.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';
import 'package:smooth_app/features/permission/presentation/components/amanah_permission_card.dart';
import 'package:smooth_app/features/permission/presentation/components/amanah_permission_detail_drawer.dart';
import 'package:smooth_app/features/permission/presentation/components/amanah_permission_form_drawer.dart';

/// Master Leave & Permission Screen
/// Matching 1:1 with LeavePermissionTabScreen.tsx (.web)
class AmanahLeavePermissionTabScreen extends StatefulWidget {
  const AmanahLeavePermissionTabScreen({
    this.onBack,
    this.doctorName = 'dr. Rayhan Pratama, Sp.A',
    this.doctorRole = 'Dokter Spesialis Anak',
    this.doctorAvatarUrl = 'assets/amanah/auth/auth_background.png',
    super.key,
  });

  final VoidCallback? onBack;
  final String doctorName;
  final String doctorRole;
  final String doctorAvatarUrl;

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
  final AmanahPermissionStore _store = AmanahPermissionStore.instance;
  AmanahPermissionStatus? _statusFilter;
  String? _toastMessage;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreUpdated);
    _toastTimer?.cancel();
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
    });
    _toastTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
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
      _store.createPermission(
        startDate: result.startDate,
        endDate: result.endDate,
        type: result.type,
        reason: result.reason,
        substituteDoctor: result.substituteDoctor,
        doctorName: widget.doctorName,
        doctorRole: widget.doctorRole,
      );
      _showToast('Pengajuan izin berhasil dikirim.');
    }
  }

  Future<void> _handleOpenEditForm(AmanahPermissionRecord record) async {
    final AmanahPermissionFormData? result =
        await AmanahPermissionFormDrawer.show(
          context: context,
          doctorName: widget.doctorName,
          doctorRole: widget.doctorRole,
          doctorAvatarUrl: widget.doctorAvatarUrl,
          editingRecord: record,
        );

    if (result != null && mounted) {
      final ({AmanahPermissionRecord? record, String message, bool success})
      updateRes = _store.updatePermission(
        id: record.id,
        startDate: result.startDate,
        endDate: result.endDate,
        type: result.type,
        reason: result.reason,
        substituteDoctor: result.substituteDoctor,
      );

      if (updateRes.success) {
        _showToast('Perubahan perizinan berhasil disimpan.');
      } else {
        _showToast(updateRes.message);
      }
    }
  }

  void _handleOpenDetail(AmanahPermissionRecord record) {
    AmanahPermissionDetailDrawer.show(
      context: context,
      item: record,
      onEdit: () => _handleOpenEditForm(record),
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

    final ({AmanahPermissionRecord? record, String message, bool success})
    cancelRes = _store.cancelPermission(record.id);
    if (cancelRes.success) {
      _showToast('Pengajuan izin berhasil dibatalkan.');
    } else {
      _showToast(cancelRes.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final List<AmanahPermissionRecord> filteredList = _store.getFiltered(
      _statusFilter,
    );
    final int pendingCount = _store.pendingCount;

    return Scaffold(
      backgroundColor: AmanahThemeTokens.canvas(context),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // 1. Header (Clean Title, Back Button, Plus Button)
                AmanahScreenHeader(
                  title: 'Perizinan',
                  onBack: widget.onBack,
                  rightAction: AmanahButton.icon(
                    icon: Icons.add_rounded,
                    onPressed: _handleOpenCreateForm,
                    customBackgroundColor: Colors.transparent,
                    customBorder: Border.all(color: Colors.transparent),
                    customForegroundColor: dark
                        ? AmanahColorTokens.brandSoft
                        : AmanahColorTokens.brand,
                    semanticsLabel: 'Tambah Perizinan Baru',
                  ),
                ),

                // 2. Filter Chips (shared master filter bar)
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

                // 3. Cards List Viewport
                Expanded(
                  child: filteredList.isEmpty
                      ? _EmptyPermissionView(dark: dark)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length,
                          separatorBuilder: (BuildContext context, int index) =>
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
              ],
            ),

            // Ephemeral Toast Banner
            if (_toastMessage != null)
              Positioned(
                top: 60,
                left: 24,
                right: 24,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Text(
                      _toastMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPermissionView extends StatelessWidget {
  const _EmptyPermissionView({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: AmanahEmptyState.card(
          icon: Icons.calendar_today_rounded,
          iconShape: AmanahEmptyStateIconShape.squircle,
          title: 'Tidak ada perizinan',
          message:
              'Belum ada riwayat perizinan pada filter ini. Tekan tombol tambah di atas untuk membuat izin baru.',
        ),
      ),
    );
  }
}
