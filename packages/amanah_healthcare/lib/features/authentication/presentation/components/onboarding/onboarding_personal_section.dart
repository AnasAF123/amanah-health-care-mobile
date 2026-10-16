import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/core/constants/gender_constants.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class OnboardingPersonalSection extends StatelessWidget {
  const OnboardingPersonalSection({
    required this.controller,
    super.key,
  });

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
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final String birthDateDisplay = controller.birthDate != null
        ? '${controller.birthDate!.day.toString().padLeft(2, '0')}/${controller.birthDate!.month.toString().padLeft(2, '0')}/${controller.birthDate!.year}'
        : 'Pilih tanggal lahir';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Data Pribadi Staf',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Informasi identitas kependudukan resmi sesuai KTP.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AmanahThemeTokens.textSecondary(context),
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        AuthInputField(
          label: 'Nama Lengkap (sesuai KTP / Gelar)',
          hintText: 'Contoh: dr. Budi Santoso, Sp.A',
          controller: controller.fullNameController,
          leadingIcon: Icons.badge_outlined,
          textInputAction: TextInputAction.next,
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isEmpty) return 'Nama lengkap wajib diisi.';
            if (input.length < 3) return 'Nama minimal 3 karakter.';
            return null;
          },
        ),
        const SizedBox(height: LARGE_SPACE),
        AuthInputField(
          label: 'NIK (Nomor Induk Kependudukan)',
          hintText: '16 digit angka NIK KTP',
          controller: controller.nikController,
          leadingIcon: Icons.credit_card_outlined,
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
        const SizedBox(height: LARGE_SPACE),
        AuthInputField(
          label: 'Tempat Lahir',
          hintText: 'Contoh: Jakarta',
          controller: controller.birthPlaceController,
          leadingIcon: Icons.location_city_outlined,
          textInputAction: TextInputAction.next,
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isEmpty) return 'Tempat lahir wajib diisi.';
            return null;
          },
        ),
        const SizedBox(height: LARGE_SPACE),
        // Tanggal Lahir Picker
        Text(
          'Tanggal Lahir',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _pickBirthDate(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.42),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    birthDateDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.birthDate != null
                          ? AmanahThemeTokens.textPrimary(context)
                          : AmanahThemeTokens.textSecondary(context),
                      fontWeight: controller.birthDate != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AmanahThemeTokens.textSecondary(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: LARGE_SPACE),
        // Jenis Kelamin Selector
        Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
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
            const SizedBox(width: 12),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AmanahColorTokens.brand.withValues(alpha: isDark ? 0.20 : 0.08)
              : (isDark
                  ? AmanahThemeTokens.surfaceSecondary(context)
                  : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AmanahColorTokens.brand
                : (isDark
                    ? AmanahThemeTokens.outline(context)
                    : theme.colorScheme.outline.withValues(alpha: 0.25)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AmanahColorTokens.brand
                  : AmanahThemeTokens.textSecondary(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? AmanahColorTokens.brand
                    : AmanahThemeTokens.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
