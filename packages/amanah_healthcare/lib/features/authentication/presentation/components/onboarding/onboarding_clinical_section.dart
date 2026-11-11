import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/authentication/domain/staff_onboarding_poli_option.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
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
    final String roleName = controller.user.roleName.trim();
    final bool isPoliAssignedByAdmin =
        controller.user.staff?.poliklinikId != null &&
        controller.user.staff!.poliklinikId!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (controller.poliklinikErrorMessage != null) ...<Widget>[
          AuthInlineValidationMessage(message: controller.poliklinikErrorMessage!),
          const SizedBox(height: SMALL_SPACE),
        ],
        AmanahSettingSection(
          title: 'Kredensial Medis & Penugasan',
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Unit Poliklinik Penugasan *',
                    style: TextStyle(
                      color: AmanahThemeTokens.textTertiary(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<StaffOnboardingPoliOption>(
                      initialValue: controller.selectedPoliklinik,
                      isExpanded: true,
                      icon: isPoliAssignedByAdmin
                          ? Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: AmanahThemeTokens.textTertiary(context),
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
                                fontSize: 13,
                                color: AmanahThemeTokens.textTertiary(context),
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
                              fontSize: 13.5,
                              color: isPoliAssignedByAdmin
                                  ? AmanahThemeTokens.textPrimary(context).withValues(alpha: 0.85)
                                  : AmanahThemeTokens.textPrimary(context),
                              fontWeight: isPoliAssignedByAdmin ? FontWeight.w700 : FontWeight.w600,
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
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AmanahSettingFormInputRow(
              label: roleName.isNotEmpty ? 'Nomor SIP / STR ($roleName)' : 'Nomor SIP / STR',
              hintText: 'Contoh: SIP.446/123/DISKES/2026',
              controller: controller.licenseController,
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
        ),
        if (isPoliAssignedByAdmin) ...<Widget>[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: <Widget>[
                Icon(Icons.lock_rounded, size: 14, color: activeBrand),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Unit poliklinik dikunci sesuai penugasan Administrator Klinik',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: activeBrand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
