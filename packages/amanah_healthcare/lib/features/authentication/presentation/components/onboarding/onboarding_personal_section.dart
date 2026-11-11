import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/core/constants/gender_constants.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class OnboardingPersonalSection extends StatelessWidget {
  const OnboardingPersonalSection({required this.controller, super.key});

  final StaffOnboardingController controller;

  Future<void> _pickBirthDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initial = controller.birthDate ?? DateTime(1995, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1940),
      lastDate: now,
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      controller.setBirthDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String birthDateDisplay = controller.birthDate != null
        ? '${controller.birthDate!.day.toString().padLeft(2, '0')}/${controller.birthDate!.month.toString().padLeft(2, '0')}/${controller.birthDate!.year}'
        : 'Pilih tanggal lahir';

    return AmanahSettingSection(
      title: 'Data Pribadi & Kependudukan',
      children: <Widget>[
        AmanahSettingFormInputRow(
          label: 'Nama Lengkap (sesuai KTP / Gelar) *',
          hintText: 'Contoh: dr. Budi Santoso, Sp.A',
          controller: controller.fullNameController,
          textInputAction: TextInputAction.next,
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isEmpty) return 'Nama lengkap wajib diisi.';
            if (input.length < 3) return 'Nama minimal 3 karakter.';
            return null;
          },
        ),
        AmanahSettingFormInputRow(
          label: 'NIK (Nomor Induk Kependudukan) *',
          hintText: '16 digit angka NIK KTP',
          controller: controller.nikController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: 16,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isEmpty) return 'NIK wajib diisi.';
            if (input.length != 16 || !RegExp(r'^\d{16}$').hasMatch(input)) {
              return 'NIK harus terdiri dari 16 digit angka.';
            }
            return null;
          },
        ),
        AmanahSettingFormInputRow(
          label: 'Tempat Lahir *',
          hintText: 'Contoh: Jakarta',
          controller: controller.birthPlaceController,
          textInputAction: TextInputAction.next,
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isEmpty) return 'Tempat lahir wajib diisi.';
            return null;
          },
        ),
        AmanahSettingEditableRow(
          label: 'Tanggal Lahir *',
          value: birthDateDisplay,
          onEdit: () => _pickBirthDate(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Jenis Kelamin *',
                style: TextStyle(
                  color: AmanahThemeTokens.textTertiary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _GenderChip(
                      label: GenderConstants.maleLabel,
                      icon: Icons.male_rounded,
                      isSelected: controller.gender == GenderConstants.male,
                      onTap: () => controller.setGender(GenderConstants.male),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GenderChip(
                      label: GenderConstants.femaleLabel,
                      icon: Icons.female_rounded,
                      isSelected: controller.gender == GenderConstants.female,
                      onTap: () => controller.setGender(GenderConstants.female),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color activeBrand = isDark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeBrand.withValues(alpha: isDark ? 0.20 : 0.08)
              : (isDark ? AmanahThemeTokens.surfaceSecondary(context) : AmanahColorTokens.neutral50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activeBrand
                : (isDark
                      ? AmanahThemeTokens.outline(context)
                      : theme.colorScheme.outline.withValues(alpha: 0.20)),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: isSelected ? activeBrand : AmanahThemeTokens.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeBrand : AmanahThemeTokens.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
