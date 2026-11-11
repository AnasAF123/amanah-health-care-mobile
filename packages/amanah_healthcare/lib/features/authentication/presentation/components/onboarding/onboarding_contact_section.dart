import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class OnboardingContactSection extends StatelessWidget {
  const OnboardingContactSection({
    required this.controller,
    super.key,
  });

  final StaffOnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return AmanahSettingSection(
      title: 'Kontak & Profesi',
      children: <Widget>[
        AmanahSettingFormInputRow(
          label: 'Nomor WhatsApp / Handphone *',
          hintText: 'Contoh: 081234567890',
          controller: controller.phoneController,
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
        AmanahSettingInfoRow(
          label: 'Profesi / Jabatan (Ditetapkan Admin)',
          value: controller.professionController.text.isNotEmpty
              ? controller.professionController.text
              : controller.user.roleName,
          trailing: Icon(
            Icons.lock_rounded,
            size: 16,
            color: AmanahThemeTokens.textTertiary(context),
          ),
        ),
      ],
    );
  }
}
