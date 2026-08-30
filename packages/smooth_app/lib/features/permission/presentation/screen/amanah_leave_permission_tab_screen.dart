import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';
import 'package:smooth_app/features/permission/data/amanah_permission_store.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';
import 'package:smooth_app/features/permission/presentation/components/amanah_permission_card.dart';
import 'package:smooth_app/features/permission/presentation/components/amanah_permission_detail_drawer.dart';
import 'package:smooth_app/features/permission/presentation/components/amanah_permission_form_drawer.dart';

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

  void _showCancelConfirmation(AmanahPermissionRecord record) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogCtx) {
        final bool dark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: dark ? const Color(0xFF111624) : Colors.white,
          title: Text(
            'Batalkan pengajuan perizinan?',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: dark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin membatalkan pengajuan izin ini (${record.formattedDateRange})? Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                'Kembali',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                final ({
                  AmanahPermissionRecord? record,
                  String message,
                  bool success
                }) cancelRes = _store.cancelPermission(record.id);
                if (cancelRes.success) {
                  _showToast('Pengajuan izin berhasil dibatalkan.');
                } else {
                  _showToast(cancelRes.message);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ya, Batalkan Izin',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final List<AmanahPermissionRecord> filteredList =
        _store.getFiltered(_statusFilter);
    final int pendingCount = _store.pendingCount;

    return Scaffold(
      backgroundColor:
          dark ? const Color(0xFF0A0E1A) : const Color(0xFFF8FAFF),
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
                  rightAction: IconButton(
                    onPressed: _handleOpenCreateForm,
                    icon: const Icon(Icons.add_rounded, size: 24),
                    tooltip: 'Tambah Perizinan Baru',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    style: IconButton.styleFrom(
                      foregroundColor: dark
                          ? const Color(0xFF22D3EE)
                          : const Color(0xFF0A44FF),
                    ),
                  ),
                ),

                // 2. Filter Chips (Horizontal Segmented Chips)
                Container(
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: <Widget>[
                        _FilterChipItem(
                          label: 'Semua',
                          isSelected: _statusFilter == null,
                          dark: dark,
                          onTap: () => setState(() => _statusFilter = null),
                        ),
                        const SizedBox(width: 6),
                        _FilterChipItem(
                          label: 'Menunggu',
                          badgeCount: pendingCount,
                          isSelected:
                              _statusFilter == AmanahPermissionStatus.menunggu,
                          dark: dark,
                          onTap: () => setState(
                            () => _statusFilter =
                                AmanahPermissionStatus.menunggu,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _FilterChipItem(
                          label: 'Disetujui',
                          isSelected:
                              _statusFilter == AmanahPermissionStatus.disetujui,
                          dark: dark,
                          onTap: () => setState(
                            () => _statusFilter =
                                AmanahPermissionStatus.disetujui,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _FilterChipItem(
                          label: 'Ditolak',
                          isSelected:
                              _statusFilter == AmanahPermissionStatus.ditolak,
                          dark: dark,
                          onTap: () => setState(
                            () => _statusFilter =
                                AmanahPermissionStatus.ditolak,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _FilterChipItem(
                          label: 'Dibatalkan',
                          isSelected: _statusFilter ==
                              AmanahPermissionStatus.dibatalkan,
                          dark: dark,
                          onTap: () => setState(
                            () => _statusFilter =
                                AmanahPermissionStatus.dibatalkan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Cards List Viewport
                Expanded(
                  child: filteredList.isEmpty
                      ? _EmptyPermissionView(dark: dark)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length,
                          separatorBuilder:
                              (BuildContext context, int index) =>
                                  const SizedBox(height: 12),
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

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.dark,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final bool isSelected;
  final bool dark;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final Color badgeBg;
    final Color badgeText;

    if (isSelected) {
      bgColor = const Color(0xFF0A44FF);
      textColor = Colors.white;
      badgeBg = Colors.white.withValues(alpha: 0.22);
      badgeText = Colors.white;
    } else {
      if (dark) {
        bgColor = Colors.white.withValues(alpha: 0.05);
        textColor = const Color(0xFF94A3B8);
        badgeBg = const Color(0xFFF59E0B).withValues(alpha: 0.20);
        badgeText = const Color(0xFFFCD34D);
      } else {
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFF92400E);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              if (badgeCount > 0) ...<Widget>[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeText,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: dark
                ? Colors.white.withValues(alpha: 0.03)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.calendar_today_rounded,
                size: 36,
                color: dark
                    ? Colors.white.withValues(alpha: 0.30)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada perizinan',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Belum ada riwayat perizinan pada filter ini. Tekan tombol tambah di atas untuk membuat izin baru.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color:
                      dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
