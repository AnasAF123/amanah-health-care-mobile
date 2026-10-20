import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/widgets/permission_stage_card.dart';

/// Bottom sheet drawer providing quick schedule actions:
/// 1. Lihat Kalender Praktik
/// 2. Pengaturan Jadwal Shift
class AmanahScheduleActionDrawer extends StatelessWidget {
  const AmanahScheduleActionDrawer({
    super.key,
    required this.onSelectCalendar,
    required this.onOpenSettings,
  });

  final VoidCallback onSelectCalendar;
  final VoidCallback onOpenSettings;

  static void show(
    BuildContext context, {
    required VoidCallback onSelectCalendar,
    required VoidCallback onOpenSettings,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahScheduleActionDrawer(
        onSelectCalendar: () {
          Navigator.of(ctx).pop();
          onSelectCalendar();
        },
        onOpenSettings: () {
          Navigator.of(ctx).pop();
          onOpenSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AmanahBottomSheetScaffold(
      title: 'Tindakan Jadwal',
      subtitle: 'Pilih aksi jadwal praktik atau konfigurasi shift dokter',
      hugContent: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PermissionStageCard(
            title: 'Lihat Kalender Praktik',
            subtitle: 'Tampilkan kalender bulanan dan ketersediaan jadwal dokter',
            icon: Icons.calendar_month_rounded,
            isSelected: false,
            onTap: onSelectCalendar,
          ),
          const SizedBox(height: 12),
          PermissionStageCard(
            title: 'Pengaturan Jadwal Shift',
            subtitle: 'Konfigurasi jam praktik, kuota pasien, dan status cuti dokter',
            icon: Icons.tune_rounded,
            isSelected: false,
            onTap: onOpenSettings,
          ),
        ],
      ),
    );
  }
}
