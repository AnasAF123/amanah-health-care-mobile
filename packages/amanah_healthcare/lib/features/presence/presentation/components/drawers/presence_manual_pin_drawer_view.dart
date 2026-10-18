import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_otp_input.dart';

class PresenceManualPinDrawerView extends StatelessWidget {
  const PresenceManualPinDrawerView({
    required this.manualPin,
    required this.onChanged,
    required this.onBack,
    required this.onSubmit,
    super.key,
    this.pinError,
  });

  final String manualPin;
  final String? pinError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                size: 16,
                color: AmanahColorTokens.brandPrimary,
              ),
              label: const Text(
                'Kembali',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AmanahColorTokens.brandPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 6-Grid OTP Input
        AmanahOtpInput(
          length: 6,
          error: pinError,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),

        // Verification Button
        AmanahButton.primary(
          text: 'Verifikasi Presensi',
          isFullWidth: true,
          isDisabled: manualPin.trim().length < 6,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}
