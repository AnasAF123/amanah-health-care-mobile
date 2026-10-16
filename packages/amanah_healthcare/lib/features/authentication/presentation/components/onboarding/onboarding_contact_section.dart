import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class OnboardingContactSection extends StatelessWidget {
  const OnboardingContactSection({
    required this.controller,
    super.key,
  });

  final StaffOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Kontak & Profesi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Nomor kontak operasional dan deskripsi profesi staf.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AmanahThemeTokens.textSecondary(context),
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        AuthInputField(
          label: 'Nomor WhatsApp / Handphone',
          hintText: 'Contoh: 081234567890',
          controller: controller.phoneController,
          leadingIcon: Icons.phone_android_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          maxLength: 15,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isEmpty) return 'Nomor handphone wajib diisi.';
            if (input.length < 9) return 'Nomor handphone minimal 9 digit.';
            return null;
          },
        ),
        const SizedBox(height: LARGE_SPACE),
        AuthInputField(
          label: 'Profesi / Jabatan',
          hintText: 'Profesi Staf',
          controller: controller.professionController,
          leadingIcon: Icons.badge_outlined,
          readOnly: true,
          helperText: 'Ditetapkan resmi oleh Administrator Klinik',
          textInputAction: TextInputAction.next,
          validator: (String? val) {
            final String input = val?.trim() ?? '';
            if (input.isEmpty) return 'Profesi wajib diisi.';
            return null;
          },
        ),
      ],
    );
  }
}
