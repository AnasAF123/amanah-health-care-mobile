import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_primary_button.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

enum StaffOnboardingRoleOption {
  doctor(
    code: 'doctor',
    title: 'Dokter',
    subtitle: 'Dokter umum atau spesialis dengan STR & SIP aktif.',
    icon: Icons.medical_services_rounded,
    defaultProfession: 'Dokter Umum',
  ),
  midwife(
    code: 'midwife',
    title: 'Bidan',
    subtitle: 'Bidan pelaksana atau koordinator dengan STR & SIP.',
    icon: Icons.health_and_safety_rounded,
    defaultProfession: 'Bidan Pelaksana',
  ),
  worker(
    code: 'worker',
    title: 'Staf / Pegawai',
    subtitle: 'Staf administrasi, perawat, atau operasional klinik.',
    icon: Icons.badge_rounded,
    defaultProfession: 'Staf Administrasi',
  );

  const StaffOnboardingRoleOption({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.defaultProfession,
  });

  final String code;
  final String title;
  final String subtitle;
  final IconData icon;
  final String defaultProfession;
}

class StaffOnboardingScreen extends StatefulWidget {
  const StaffOnboardingScreen({
    required this.user,
    required this.onOnboardingComplete,
    required this.onLogout,
    this.repository = const AmanahAuthRepository(),
    super.key,
  });

  final AmanahAuthUser user;
  final ValueChanged<AmanahAuthUser> onOnboardingComplete;
  final VoidCallback onLogout;
  final AmanahAuthRepository repository;

  @override
  State<StaffOnboardingScreen> createState() => _StaffOnboardingScreenState();
}

class _StaffOnboardingScreenState extends State<StaffOnboardingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _licenseController;

  StaffOnboardingRoleOption _selectedRole = StaffOnboardingRoleOption.doctor;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _licenseController = TextEditingController();
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  void _onRoleChanged(StaffOnboardingRoleOption role) {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String fullName = widget.user.fullName.trim();
    final String? phone =
        widget.user.phone.trim().isNotEmpty ? widget.user.phone.trim() : null;
    final String profession = _selectedRole.defaultProfession;
    final String license = _licenseController.text.trim();

    AmanahAuthLogger.logLifecycle(
      'Staff Onboarding form submitted',
      details: <String, dynamic>{
        'role': _selectedRole.code,
        'fullName': fullName,
        'phoneNumber': phone,
        'profession': profession,
        'hasLicense': license.isNotEmpty,
      },
    );

    try {
      final AmanahAuthUser? updatedUser =
          await widget.repository.completeStaffOnboarding(
        role: _selectedRole.code,
        fullName: fullName.isNotEmpty ? fullName : 'Staf Amanah',
        phoneNumber: phone,
        profession: profession,
        licenseNumber: license.isNotEmpty ? license : null,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (updatedUser != null) {
        AmanahAuthLogger.logLifecycle(
          'Staff Onboarding completed successfully',
          details: <String, dynamic>{
            'userId': updatedUser.id,
            'role': updatedUser.role.name,
            'needsOnboarding': updatedUser.needsOnboarding,
            'staffId': updatedUser.staff?.id,
          },
        );
        widget.onOnboardingComplete(updatedUser);
      } else {
        setState(() {
          _errorMessage =
              'Gagal menyelesaikan profil staf. Silakan periksa kembali data Anda.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      AmanahAuthLogger.logLifecycle('Staff Onboarding submission failed: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AmanahThemeTokens.canvas(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Keluar',
          onPressed: widget.onLogout,
        ),
        title: Text(
          'Pilih Peran Staf Klinik',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: widget.onLogout,
            child: Text(
              'Keluar',
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.dangerBorder
                    : AmanahColorTokens.dangerDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Tentukan Peran Anda',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pilih peran klinis Anda di Amanah Healthcare untuk mengaktifkan akses operasional.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AmanahThemeTokens.textSecondary(context),
                  ),
                ),
                const SizedBox(height: VERY_LARGE_SPACE),

                // Role Selection Heading
                Text(
                  'Pilih Peran',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AmanahColorTokens.brand,
                  ),
                ),
                const SizedBox(height: 12),

                // Role Options Cards
                ...StaffOnboardingRoleOption.values.map((
                  StaffOnboardingRoleOption role,
                ) {
                  final bool isSelected = _selectedRole == role;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _onRoleChanged(role),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AmanahColorTokens.brand.withValues(
                                  alpha: dark ? 0.20 : 0.08,
                                )
                              : (dark
                                  ? AmanahThemeTokens.surfaceSecondary(context)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AmanahColorTokens.brand
                                : (dark
                                    ? AmanahThemeTokens.outline(context)
                                    : theme.colorScheme.outline
                                        .withValues(alpha: 0.20)),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AmanahColorTokens.brand
                                    : (dark
                                        ? Colors.white10
                                        : AmanahColorTokens.neutral100),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                role.icon,
                                color: isSelected
                                    ? Colors.white
                                    : AmanahThemeTokens.textPrimary(context),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    role.title,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? AmanahColorTokens.brand
                                          : AmanahThemeTokens.textPrimary(
                                              context,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    role.subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AmanahThemeTokens.textSecondary(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AmanahColorTokens.brand
                                      : (dark
                                          ? Colors.white38
                                          : theme.colorScheme.outline
                                              .withValues(alpha: 0.40)),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AmanahColorTokens.brand,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Optional License Number (STR / SIP) - For doctor / midwife
                if (_selectedRole != StaffOnboardingRoleOption.worker) ...<Widget>[
                  const SizedBox(height: LARGE_SPACE),
                  Text(
                    'Nomor Izin Praktik (Opsional)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                      color: AmanahColorTokens.brand,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AuthInputField(
                    label: _selectedRole == StaffOnboardingRoleOption.doctor
                        ? 'Nomor SIP / STR Dokter'
                        : 'Nomor SIP / STR Bidan',
                    hintText: 'Contoh: SIP.446/123/DISKES/2026 (dapat diisi nanti)',
                    controller: _licenseController,
                    leadingIcon: Icons.verified_outlined,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],

                if (_errorMessage != null) ...<Widget>[
                  const SizedBox(height: MEDIUM_SPACE),
                  AuthInlineValidationMessage(message: _errorMessage!),
                ],

                const SizedBox(height: VERY_LARGE_SPACE),

                // Submit Button
                AuthPrimaryButton(
                  label: 'Simpan & Lanjutkan ke Beranda',
                  loading: _isLoading,
                  onPressed: _submit,
                ),

                const SizedBox(height: LARGE_SPACE),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
