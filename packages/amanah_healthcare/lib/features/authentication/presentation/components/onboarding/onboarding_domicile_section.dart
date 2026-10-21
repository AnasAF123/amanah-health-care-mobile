import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/components/settings/amanah_region_picker_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class OnboardingDomicileSection extends StatelessWidget {
  const OnboardingDomicileSection({required this.controller, super.key});

  final StaffOnboardingController controller;

  Future<void> _pickProvince(BuildContext context) async {
    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: 'Pilih Provinsi',
      loader: () => controller.provinces.isNotEmpty
          ? Future<List<RegionItem>>.value(controller.provinces)
          : controller.loadProvinces().then((_) => controller.provinces),
      selectedId: controller.selectedProvince?.id,
    );
    if (picked != null) {
      await controller.onProvinceChanged(picked);
    }
  }

  Future<void> _pickRegency(BuildContext context) async {
    if (controller.selectedProvince == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih provinsi terlebih dahulu.'),
          backgroundColor: AmanahColorTokens.danger,
        ),
      );
      return;
    }
    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: 'Pilih Kabupaten / Kota',
      loader: () => Future<List<RegionItem>>.value(controller.regencies),
      selectedId: controller.selectedRegency?.id,
    );
    if (picked != null) {
      await controller.onRegencyChanged(picked);
    }
  }

  Future<void> _pickDistrict(BuildContext context) async {
    if (controller.selectedRegency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kabupaten/kota terlebih dahulu.'),
          backgroundColor: AmanahColorTokens.danger,
        ),
      );
      return;
    }
    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: 'Pilih Kecamatan',
      loader: () => Future<List<RegionItem>>.value(controller.districts),
      selectedId: controller.selectedDistrict?.id,
    );
    if (picked != null) {
      await controller.onDistrictChanged(picked);
    }
  }

  Future<void> _pickVillage(BuildContext context) async {
    if (controller.selectedDistrict == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kecamatan terlebih dahulu.'),
          backgroundColor: AmanahColorTokens.danger,
        ),
      );
      return;
    }
    final RegionItem? picked = await AmanahRegionPickerSheet.show(
      context: context,
      title: 'Pilih Kelurahan / Desa',
      loader: () => Future<List<RegionItem>>.value(controller.villages),
      selectedId: controller.selectedVillage?.id,
    );
    if (picked != null) {
      controller.onVillageChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color activeBrand = isDark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (controller.regionErrorMessage != null) ...<Widget>[
          AuthInlineValidationMessage(message: controller.regionErrorMessage!),
          const SizedBox(height: MEDIUM_SPACE),
        ],

        // SettingSection for cascading regions (100% harmonized with Identity Address Section)
        AmanahSettingSection(
          title: 'Wilayah Domisili Kependudukan',
          children: <Widget>[
            AmanahSettingEditableRow(
              label: 'Provinsi *',
              value: controller.selectedProvince?.name ?? 'Pilih Provinsi',
              onEdit: () => _pickProvince(context),
            ),
            AmanahSettingEditableRow(
              label: 'Kabupaten / Kota *',
              value:
                  controller.selectedRegency?.name ??
                  (controller.selectedProvince != null
                      ? (controller.isLoadingRegencies
                            ? 'Memuat data...'
                            : 'Pilih Kabupaten / Kota')
                      : 'Pilih provinsi terlebih dahulu'),
              onEdit: () => _pickRegency(context),
            ),
            AmanahSettingEditableRow(
              label: 'Kecamatan *',
              value:
                  controller.selectedDistrict?.name ??
                  (controller.selectedRegency != null
                      ? (controller.isLoadingDistricts ? 'Memuat data...' : 'Pilih Kecamatan')
                      : 'Pilih kabupaten/kota terlebih dahulu'),
              onEdit: () => _pickDistrict(context),
            ),
            AmanahSettingEditableRow(
              label: 'Kelurahan / Desa *',
              value:
                  controller.selectedVillage?.name ??
                  (controller.selectedDistrict != null
                      ? (controller.isLoadingVillages ? 'Memuat data...' : 'Pilih Kelurahan / Desa')
                      : 'Pilih kecamatan terlebih dahulu'),
              onEdit: () => _pickVillage(context),
            ),
          ],
        ),
        const SizedBox(height: LARGE_SPACE),

        // Detail Alamat Lengkap
        Text(
          'Alamat Lengkap (Jalan, RT/RW, No. Rumah) *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.addressController,
          maxLines: 3,
          style: TextStyle(fontSize: 14, color: AmanahThemeTokens.textPrimary(context)),
          decoration: InputDecoration(
            hintText: 'Contoh: Jl. Merdeka No. 10, RT 01/RW 02',
            hintStyle: TextStyle(fontSize: 14, color: AmanahThemeTokens.textSecondary(context)),
            filled: true,
            fillColor: isDark
                ? AmanahThemeTokens.surfaceSecondary(context)
                : AmanahColorTokens.neutral50.withValues(alpha: 0.72),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? AmanahThemeTokens.outline(context)
                    : theme.colorScheme.outline.withValues(alpha: 0.34),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? AmanahThemeTokens.outline(context)
                    : theme.colorScheme.outline.withValues(alpha: 0.34),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: activeBrand, width: 1.5),
            ),
          ),
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isEmpty) return 'Alamat lengkap wajib diisi.';
            return null;
          },
        ),
      ],
    );
  }
}
