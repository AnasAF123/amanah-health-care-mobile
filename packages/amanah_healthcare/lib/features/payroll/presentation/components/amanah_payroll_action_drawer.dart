import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/widgets/permission_stage_card.dart';

/// Context menu bottom sheet drawer for payroll actions:
/// 1. History Penggajian (Lihat riwayat buku besar penggajian bulanan)
class AmanahPayrollActionDrawer extends StatelessWidget {
  const AmanahPayrollActionDrawer({super.key, required this.onOpenHistory});

  final VoidCallback onOpenHistory;

  static void show(BuildContext context, {required VoidCallback onOpenHistory}) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahPayrollActionDrawer(
        onOpenHistory: () {
          Navigator.of(ctx).pop();
          onOpenHistory();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AmanahBottomSheetScaffold(
      title: 'Tindakan Penggajian',
      subtitle: 'Pilih aksi atau riwayat pembukuan gaji staf',
      hugContent: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PermissionStageCard(
            title: 'History Penggajian',
            subtitle: 'Lihat riwayat buku besar penggajian bulanan dan rincian transaksi',
            icon: Icons.history_rounded,
            isSelected: false,
            onTap: onOpenHistory,
          ),
        ],
      ),
    );
  }
}
