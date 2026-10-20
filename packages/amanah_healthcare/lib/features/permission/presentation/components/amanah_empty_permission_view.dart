import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';

/// Empty state viewport for Leave Permissions list.
class AmanahEmptyPermissionView extends StatelessWidget {
  const AmanahEmptyPermissionView({
    required this.onAddPermission,
    this.selectedStatus,
    this.onResetFilter,
    super.key,
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
