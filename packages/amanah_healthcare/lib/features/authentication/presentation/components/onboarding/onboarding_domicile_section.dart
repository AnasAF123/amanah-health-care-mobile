import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/region_item.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class OnboardingDomicileSection extends StatelessWidget {
  const OnboardingDomicileSection({
    required this.controller,
    super.key,
  });

  final StaffOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Alamat Domisili Kependudukan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Data wilayah resmi sesuai master data Kemendagri RI.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AmanahThemeTokens.textSecondary(context),
          ),
        ),
        if (controller.regionErrorMessage != null) ...<Widget>[
          const SizedBox(height: SMALL_SPACE),
          AuthInlineValidationMessage(message: controller.regionErrorMessage!),
        ],
        const SizedBox(height: MEDIUM_SPACE),

        // 1. Provinsi Dropdown
        _RegionDropdownField(
          label: 'Provinsi',
          hint: 'Pilih Provinsi',
          isLoading: controller.isLoadingProvinces,
          items: controller.provinces,
          selectedItem: controller.selectedProvince,
          onChanged: controller.onProvinceChanged,
          isRequired: true,
        ),
        const SizedBox(height: LARGE_SPACE),

        // 2. Kabupaten / Kota Dropdown
        _RegionDropdownField(
          label: 'Kabupaten / Kota',
          hint: controller.selectedProvince == null
              ? 'Pilih provinsi terlebih dahulu'
              : 'Pilih Kabupaten / Kota',
          isLoading: controller.isLoadingRegencies,
          items: controller.regencies,
          selectedItem: controller.selectedRegency,
          onChanged: controller.selectedProvince != null
              ? controller.onRegencyChanged
              : null,
          isRequired: true,
        ),
        const SizedBox(height: LARGE_SPACE),

        // 3. Kecamatan Dropdown
        _RegionDropdownField(
          label: 'Kecamatan',
          hint: controller.selectedRegency == null
              ? 'Pilih kabupaten/kota terlebih dahulu'
              : 'Pilih Kecamatan',
          isLoading: controller.isLoadingDistricts,
          items: controller.districts,
          selectedItem: controller.selectedDistrict,
          onChanged: controller.selectedRegency != null
              ? controller.onDistrictChanged
              : null,
          isRequired: true,
        ),
        const SizedBox(height: LARGE_SPACE),

        // 4. Kelurahan / Desa Dropdown
        _RegionDropdownField(
          label: 'Kelurahan / Desa',
          hint: controller.selectedDistrict == null
              ? 'Pilih kecamatan terlebih dahulu'
              : 'Pilih Kelurahan / Desa',
          isLoading: controller.isLoadingVillages,
          items: controller.villages,
          selectedItem: controller.selectedVillage,
          onChanged: controller.selectedDistrict != null
              ? controller.onVillageChanged
              : null,
          isRequired: true,
        ),
        const SizedBox(height: LARGE_SPACE),

        // 5. Alamat Lengkap Detail
        Text(
          'Alamat Lengkap (Jalan, RT/RW, No. Rumah)',
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
          style: TextStyle(
            fontSize: 14,
            color: AmanahThemeTokens.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: Jl. Merdeka No. 10, RT 01/RW 02',
            hintStyle: TextStyle(
              fontSize: 14,
              color: AmanahThemeTokens.textSecondary(context),
            ),
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
              borderSide: const BorderSide(
                color: AmanahColorTokens.brand,
                width: 1.5,
              ),
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

class _RegionDropdownField extends StatelessWidget {
  const _RegionDropdownField({
    required this.label,
    required this.hint,
    required this.isLoading,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.isRequired = false,
  });

  final String label;
  final String hint;
  final bool isLoading;
  final List<RegionItem> items;
  final RegionItem? selectedItem;
  final ValueChanged<RegionItem?>? onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? AmanahThemeTokens.surfaceSecondary(context)
                : AmanahColorTokens.neutral50.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AmanahThemeTokens.outline(context)
                  : theme.colorScheme.outline.withValues(alpha: 0.34),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<RegionItem>(
              initialValue: selectedItem,
              isExpanded: true,
              hint: Row(
                children: <Widget>[
                  if (isLoading) ...<Widget>[
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AmanahColorTokens.brand,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      isLoading ? 'Memuat data dari server...' : hint,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AmanahThemeTokens.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
              items: items.map((RegionItem item) {
                return DropdownMenuItem<RegionItem>(
                  value: item,
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AmanahThemeTokens.textPrimary(context),
                    ),
                  ),
                );
              }).toList(),
              onChanged: isLoading ? null : onChanged,
              validator: isRequired
                  ? (RegionItem? value) {
                      if (value == null) return '$label wajib dipilih.';
                      return null;
                    }
                  : null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
