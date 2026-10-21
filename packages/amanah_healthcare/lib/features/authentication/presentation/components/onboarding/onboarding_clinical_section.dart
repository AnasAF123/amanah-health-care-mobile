import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class OnboardingClinicalSection extends StatelessWidget {
  const OnboardingClinicalSection({required this.controller, super.key});

  final StaffOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.isClinical) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color activeBrand = isDark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand;
    final bool isDoctor = controller.user.isDoctor;
    final bool isPoliAssignedByAdmin =
        controller.user.staff?.poliklinikId != null &&
        controller.user.staff!.poliklinikId!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Kredensial Medis & Penugasan Klinis',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Unit poliklinik praktik dan nomor Surat Izin Praktik (SIP / STR).',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AmanahThemeTokens.textSecondary(context),
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),

        // 1. Poliklinik Selection
        Text(
          'Unit Poliklinik Penugasan',
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
            color: isPoliAssignedByAdmin
                ? (isDark
                      ? AmanahThemeTokens.surfaceSecondary(context).withValues(alpha: 0.50)
                      : AmanahColorTokens.neutral100.withValues(alpha: 0.70))
                : (isDark
                      ? AmanahThemeTokens.surfaceSecondary(context)
                      : AmanahColorTokens.neutral50.withValues(alpha: 0.72)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AmanahThemeTokens.outline(context)
                  : theme.colorScheme.outline.withValues(alpha: 0.34),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<StaffOnboardingPoliOption>(
              initialValue: controller.selectedPoliklinik,
              isExpanded: true,
              icon: isPoliAssignedByAdmin
                  ? Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AmanahThemeTokens.textSecondary(context),
                    )
                  : const Icon(Icons.arrow_drop_down),
              hint: Row(
                children: <Widget>[
                  if (controller.isLoadingPolikliniks) ...<Widget>[
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: activeBrand),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      controller.isLoadingPolikliniks
                          ? 'Memuat poliklinik dari server...'
                          : 'Pilih unit poliklinik',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AmanahThemeTokens.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
              items: controller.poliklinikOptions.map((StaffOnboardingPoliOption poli) {
                return DropdownMenuItem<StaffOnboardingPoliOption>(
                  value: poli,
                  child: Text(
                    poli.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isPoliAssignedByAdmin
                          ? AmanahThemeTokens.textPrimary(context).withValues(alpha: 0.85)
                          : AmanahThemeTokens.textPrimary(context),
                      fontWeight: isPoliAssignedByAdmin ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (controller.isLoadingPolikliniks || isPoliAssignedByAdmin)
                  ? null
                  : controller.onPoliklinikChanged,
              validator: (StaffOnboardingPoliOption? value) {
                if (value == null) return 'Unit poliklinik wajib dipilih.';
                return null;
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        if (isPoliAssignedByAdmin) ...<Widget>[
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Icon(Icons.lock_rounded, size: 14, color: activeBrand),
              const SizedBox(width: 6),
              Text(
                'Unit poliklinik dikunci sesuai penugasan Administrator Klinik',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: activeBrand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
        if (controller.poliklinikErrorMessage != null) ...<Widget>[
          const SizedBox(height: SMALL_SPACE),
          AuthInlineValidationMessage(message: controller.poliklinikErrorMessage!),
        ],
        const SizedBox(height: LARGE_SPACE),

        // 2. Nomor SIP / STR
        AuthInputField(
          label: isDoctor ? 'Nomor SIP / STR Dokter' : 'Nomor SIP / STR Bidan',
          hintText: 'Contoh: SIP.446/123/DISKES/2026',
          controller: controller.licenseController,
          leadingIcon: Icons.verified_outlined,
          textInputAction: TextInputAction.done,
          maxLength: 35,
          inputFormatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(35)],
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isNotEmpty && input.length < 5) {
              return 'Nomor SIP/STR minimal 5 karakter.';
            }
            return null;
          },
        ),
      ],
    );
  }
}
