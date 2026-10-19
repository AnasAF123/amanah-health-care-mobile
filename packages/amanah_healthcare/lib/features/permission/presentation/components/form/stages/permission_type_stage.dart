import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/presentation/components/form/widgets/permission_stage_card.dart';

/// Stage 1: Select leave type via vertical cards with instant auto-advance.
class PermissionTypeStage extends StatelessWidget {
  final AmanahPermissionType selectedType;
  final ValueChanged<AmanahPermissionType> onTypeSelected;

  const PermissionTypeStage({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Pilih kategori perizinan yang sesuai dengan kebutuhan pengajuan Anda.',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 16),
        PermissionStageCard(
          title: 'Cuti Tahunan',
          subtitle: 'Pengajuan cuti berkala hak tahunan staf',
          icon: Icons.beach_access_rounded,
          isSelected: selectedType == AmanahPermissionType.cutiTahunan,
          onTap: () => onTypeSelected(AmanahPermissionType.cutiTahunan),
        ),
        const SizedBox(height: 10),
        PermissionStageCard(
          title: 'Izin Sakit',
          subtitle: 'Izin istirahat karena kondisi medis / sakit',
          icon: Icons.local_hospital_rounded,
          isSelected: selectedType == AmanahPermissionType.izinSakit,
          onTap: () => onTypeSelected(AmanahPermissionType.izinSakit),
        ),
        const SizedBox(height: 10),
        PermissionStageCard(
          title: 'Seminar / Simposium',
          subtitle: 'Kegiatan ilmiah atau peningkatan kompetensi profesi',
          icon: Icons.school_rounded,
          isSelected: selectedType == AmanahPermissionType.seminarSimposium,
          onTap: () => onTypeSelected(AmanahPermissionType.seminarSimposium),
        ),
        const SizedBox(height: 10),
        PermissionStageCard(
          title: 'Urusan Keluarga',
          subtitle: 'Keperluan penting mendesak atau keluarga inti',
          icon: Icons.family_restroom_rounded,
          isSelected: selectedType == AmanahPermissionType.urusanKeluarga,
          onTap: () => onTypeSelected(AmanahPermissionType.urusanKeluarga),
        ),
        const SizedBox(height: 10),
        PermissionStageCard(
          title: 'Tugas Luar RS',
          subtitle: 'Penugasan dinas resmi di luar faskes',
          icon: Icons.work_outline_rounded,
          isSelected: selectedType == AmanahPermissionType.tugasLuarRS,
          onTap: () => onTypeSelected(AmanahPermissionType.tugasLuarRS),
        ),
      ],
    );
  }
}
