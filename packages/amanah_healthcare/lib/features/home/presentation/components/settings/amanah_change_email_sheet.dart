import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:amanah_healthcare/features/authentication/data/datasources/google_auth_service.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/change_email_with_google.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/request_email_change.dart';
import 'package:amanah_healthcare/features/authentication/domain/usecases/verify_email_change.dart';
import 'package:amanah_healthcare/features/home/presentation/components/settings/amanah_credential_email_change_view.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahChangeEmailSheet extends StatefulWidget {
  const AmanahChangeEmailSheet({
    required this.requestEmailChangeUseCase,
    required this.verifyEmailChangeUseCase,
    required this.changeEmailWithGoogleUseCase,
    required this.currentEmail,
    this.hasPassword = true,
    this.hasGoogle = false,
    super.key,
  });

  final RequestEmailChangeUseCase requestEmailChangeUseCase;
  final VerifyEmailChangeUseCase verifyEmailChangeUseCase;
  final ChangeEmailWithGoogleUseCase changeEmailWithGoogleUseCase;
  final String currentEmail;
  final bool hasPassword;
  final bool hasGoogle;

  static Future<bool?> show({
    required BuildContext context,
    required RequestEmailChangeUseCase requestEmailChangeUseCase,
    required VerifyEmailChangeUseCase verifyEmailChangeUseCase,
    required ChangeEmailWithGoogleUseCase changeEmailWithGoogleUseCase,
    required String currentEmail,
    bool hasPassword = true,
    bool hasGoogle = false,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => AmanahChangeEmailSheet(
        requestEmailChangeUseCase: requestEmailChangeUseCase,
        verifyEmailChangeUseCase: verifyEmailChangeUseCase,
        changeEmailWithGoogleUseCase: changeEmailWithGoogleUseCase,
        currentEmail: currentEmail,
        hasPassword: hasPassword,
        hasGoogle: hasGoogle,
      ),
    );
  }

  @override
  State<AmanahChangeEmailSheet> createState() => _AmanahChangeEmailSheetState();
}

class _AmanahChangeEmailSheetState extends State<AmanahChangeEmailSheet> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleGoogleChange() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Clear cached account to guarantee native account chooser is displayed
      await const GoogleAuthService().signOut();
      final String? idToken = await const GoogleAuthService().getIdToken();

      if (idToken == null || idToken.isEmpty) {
        // User dismissed account chooser
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final bool success = await widget.changeEmailWithGoogleUseCase(
        ChangeEmailWithGoogleParams(idToken: idToken),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _errorMessage = 'Gagal mengalihkan akun Google dan email.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceFirst('ServerFailure: ', '')
            .replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AmanahThemeTokens.surface(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color secondaryTextColor = AmanahThemeTokens.textSecondary(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AmanahThemeTokens.divider(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // -----------------------------------------------------------------
            // GOOGLE MODE: Exactly 2 rounded boxes matching the user sketch
            // Box 1: email sekarang
            // Box 2: tautkan ke akun baru [G]
            // -----------------------------------------------------------------
            if (widget.hasGoogle) ...<Widget>[
              Text(
                'Ubah Email Akun',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tautkan akun Google baru untuk mengganti email akun Anda.',
                style: TextStyle(fontSize: 13, color: secondaryTextColor),
              ),
              const SizedBox(height: 20),

              // Error Banner
              if (_errorMessage != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],

              // Box 1: Email Sekarang
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AmanahThemeTokens.surfaceMuted(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AmanahThemeTokens.outlineStrong(context),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Email Sekarang',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.currentEmail,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Box 2: Tautkan ke akun baru + Google Logo
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _handleGoogleChange,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: AmanahThemeTokens.surface(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AmanahThemeTokens.outlineStrong(context),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Tautkan ke akun baru',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_isLoading)
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          )
                        else
                          SvgPicture.asset(
                            'assets/amanah/auth/google_logo.svg',
                            width: 24,
                            height: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Akun Google yang Anda pilih akan langsung diverifikasi dan mengganti email akun Anda tanpa kode OTP.',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                  height: 1.4,
                ),
              ),
            ]

            // -----------------------------------------------------------------
            // CREDENTIAL MODE (for non-Google accounts)
            // -----------------------------------------------------------------
            else ...<Widget>[
              AmanahCredentialEmailChangeView(
                requestEmailChangeUseCase: widget.requestEmailChangeUseCase,
                verifyEmailChangeUseCase: widget.verifyEmailChangeUseCase,
                currentEmail: widget.currentEmail,
                hasPassword: widget.hasPassword,
                onSuccess: () => Navigator.of(context).pop(true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
