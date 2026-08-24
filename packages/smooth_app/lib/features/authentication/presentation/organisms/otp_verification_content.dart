import 'package:flutter/material.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:smooth_app/features/authentication/presentation/components/auth_status_message.dart';
import 'package:smooth_app/features/authentication/presentation/components/otp_code_field.dart';
import 'package:smooth_app/features/authentication/presentation/components/social_auth_button.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class OtpVerificationContent extends StatefulWidget {
  const OtpVerificationContent({
    required this.controllers,
    required this.onVerify,
    super.key,
    this.loadingProvider,
    this.statusMessage,
    this.statusIsError = false,
  });

  final List<TextEditingController> controllers;
  final AuthProviderType? loadingProvider;
  final String? statusMessage;
  final bool statusIsError;
  final VoidCallback onVerify;

  @override
  State<OtpVerificationContent> createState() => _OtpVerificationContentState();
}

class _OtpVerificationContentState extends State<OtpVerificationContent> {
  bool get _complete {
    return widget.controllers.every(
      (TextEditingController controller) => controller.text.trim().length == 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.statusMessage != null) ...<Widget>[
          AuthStatusMessage(
            message: widget.statusMessage!,
            isError: widget.statusIsError,
          ),
          const SizedBox(height: LARGE_SPACE),
        ],
        OtpCodeField(
          controllers: widget.controllers,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        Center(
          child: Text.rich(
            TextSpan(
              text: 'Kirim ulang kode dalam ',
              children: <InlineSpan>[
                TextSpan(
                  text: '00:43',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: LARGE_SPACE),
        AuthPrimaryButton(
          label: 'Verifikasi OTP',
          loading: widget.loadingProvider == AuthProviderType.email,
          onPressed: _complete ? widget.onVerify : null,
        ),
      ],
    );
  }
}
