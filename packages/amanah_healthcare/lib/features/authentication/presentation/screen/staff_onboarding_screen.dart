import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_logger.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_input_field.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_edit_profile_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_success_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/widgets/amanah_avatar.dart';

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
    this.onBack,
    this.initialStep = 0,
    this.initialRole,
    this.initialLicenseNumber,
    this.onProgressChanged,
    this.repository = const AmanahAuthRepository(),
    super.key,
  });

  final AmanahAuthUser user;
  final ValueChanged<AmanahAuthUser> onOnboardingComplete;
  final VoidCallback onLogout;
  final VoidCallback? onBack;
  final int initialStep;
  final StaffOnboardingRoleOption? initialRole;
  final String? initialLicenseNumber;
  final void Function(
    int step,
    StaffOnboardingRoleOption? role,
    String licenseNumber,
  )? onProgressChanged;
  final AmanahAuthRepository repository;

  @override
  State<StaffOnboardingScreen> createState() => _StaffOnboardingScreenState();
}

class _StaffOnboardingScreenState extends State<StaffOnboardingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _licenseController;

  int _currentStep = 0;
  StaffOnboardingRoleOption? _selectedRole;
  StaffOnboardingPoliOption? _selectedPoli;
  List<StaffOnboardingPoliOption> _poliklinikOptions =
      const <StaffOnboardingPoliOption>[];
  bool _isLoading = false;
  bool _isPoliklinikLoading = false;
  String? _errorMessage;
  String? _poliklinikErrorMessage;
  late UserAvatar _avatar;
  bool _isAvatarUploading = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _selectedRole = widget.initialRole;
    _selectedPoli = null;
    _licenseController = TextEditingController(
      text: widget.initialLicenseNumber ?? '',
    );
    _avatar = widget.user.avatar;
    _licenseController.addListener(_notifyProgress);
    if (widget.initialRole != null &&
        widget.initialRole != StaffOnboardingRoleOption.worker) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadPolikliniks());
    }
  }

  @override
  void dispose() {
    _licenseController.removeListener(_notifyProgress);
    _licenseController.dispose();
    super.dispose();
  }

  void _notifyProgress() {
    widget.onProgressChanged?.call(
      _currentStep,
      _selectedRole,
      _licenseController.text,
    );
  }

  bool get _requiresPoliklinik =>
      _selectedRole != null &&
      _selectedRole != StaffOnboardingRoleOption.worker;

  IconData _poliklinikIconFor(StaffOnboardingPoliOption poli) {
    final String label = '${poli.code} ${poli.name}'.toLowerCase();
    if (label.contains('kia') || label.contains('anak')) {
      return Icons.child_care_rounded;
    }
    return Icons.local_hospital_rounded;
  }

  String _poliklinikSubtitle(StaffOnboardingPoliOption poli) {
    final String? description = poli.description?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }
    return 'Unit layanan aktif dari database klinik.';
  }

  Future<void> _loadPolikliniks() async {
    if (_isPoliklinikLoading) return;

    setState(() {
      _isPoliklinikLoading = true;
      _poliklinikErrorMessage = null;
    });

    try {
      final List<StaffOnboardingPoliOption> options =
          await widget.repository.fetchStaffOnboardingPolikliniks();
      if (!mounted) return;

      final StaffOnboardingPoliOption? current = _selectedPoli;
      final StaffOnboardingPoliOption? selected =
          current != null && options.any((option) => option.id == current.id)
              ? options.firstWhere((option) => option.id == current.id)
              : (options.isNotEmpty ? options.first : null);

      setState(() {
        _poliklinikOptions = options;
        _selectedPoli = selected;
        _isPoliklinikLoading = false;
        _poliklinikErrorMessage = options.isEmpty
            ? 'Belum ada poliklinik aktif dari server.'
            : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPoliklinikLoading = false;
        _poliklinikErrorMessage =
            e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onRoleChanged(StaffOnboardingRoleOption role) {
    setState(() {
      _selectedRole = role;
      if (role == StaffOnboardingRoleOption.worker) {
        _selectedPoli = null;
        _poliklinikErrorMessage = null;
      }
    });
    if (role != StaffOnboardingRoleOption.worker) {
      _loadPolikliniks();
    }
    _notifyProgress();
  }

  void _onPoliChanged(StaffOnboardingPoliOption poli) {
    setState(() => _selectedPoli = poli);
    _notifyProgress();
  }

  Future<void> _openAvatarPicker() async {
    final AmanahAvatarPhotoResult? result = await AmanahAvatarPhotoSheet.show(
      context,
      title: 'Foto Profil Tenaga Medis',
      hasCustomAvatar: _avatar.hasCustomAvatar,
    );

    if (result == null || !mounted) return;

    if (result.isDelete || result.isReset) {
      setState(() => _isAvatarUploading = true);
      try {
        await widget.repository.deleteAvatar();
        if (!mounted) return;
        setState(() {
          _isAvatarUploading = false;
          _avatar = UserAvatar.fromFallback(
            userId: widget.user.id,
            name: widget.user.fullName,
          );
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _isAvatarUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AmanahColorTokens.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (result.pickedFile != null ||
        result.pickedBytes != null ||
        result.customImagePath != null ||
        result.presetAvatarUrl != null) {
      setState(() => _isAvatarUploading = true);
      try {
        final UserAvatar updated;
        if (result.pickedBytes != null) {
          updated = await widget.repository.uploadAvatar(
            fileBytes: result.pickedBytes!,
            fileName: result.fileName ?? 'avatar.jpg',
            useAuthAlias: true,
          );
        } else if (result.pickedFile != null) {
          updated = await widget.repository.uploadAvatar(
            filePath: result.pickedFile!.path,
            fileName: result.pickedFile!.name,
            useAuthAlias: true,
          );
        } else if (result.customImagePath != null) {
          updated = await widget.repository.uploadAvatar(
            filePath: result.customImagePath!,
            fileName: 'avatar.jpg',
            useAuthAlias: true,
          );
        } else if (result.presetAvatarUrl != null) {
          updated = UserAvatar.custom(
            url: result.presetAvatarUrl!,
            initials: UserAvatar.extractInitials(widget.user.fullName),
          );
        } else {
          return;
        }

        if (!mounted) return;
        setState(() {
          _isAvatarUploading = false;
          _avatar = updated;
        });

        // Langsung selesaikan pendaftaran setelah foto terpilih/diunggah,
        // tanpa menampilkan halaman gabungan yang mengintersep proses.
        await _submit();
      } catch (e) {
        if (!mounted) return;
        setState(() => _isAvatarUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AmanahColorTokens.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

    final StaffOnboardingRoleOption selectedRole =
        _selectedRole ?? StaffOnboardingRoleOption.doctor;
    final String? poliklinikId = selectedRole == StaffOnboardingRoleOption.worker
        ? null
        : _selectedPoli?.id;

    if (selectedRole != StaffOnboardingRoleOption.worker &&
        (poliklinikId == null || poliklinikId.isEmpty)) {
      setState(() {
        _currentStep = 1;
        _poliklinikErrorMessage =
            'Pilih poliklinik utama dari daftar server terlebih dahulu.';
      });
      return;
    }

    final String fullName = widget.user.fullName.trim();
    final String? phone =
        widget.user.phone.trim().isNotEmpty ? widget.user.phone.trim() : null;
    final String profession = selectedRole.defaultProfession;
    final String license = _licenseController.text.trim();

    AmanahAuthLogger.logLifecycle(
      'Staff Onboarding form submitted',
      details: <String, dynamic>{
        'role': selectedRole.code,
        'fullName': fullName,
        'phoneNumber': phone,
        'profession': profession,
        'poliklinikId': poliklinikId,
        'hasLicense': license.isNotEmpty,
      },
    );

    try {
      final AmanahAuthUser? updatedUser =
          await widget.repository.completeStaffOnboarding(
        role: selectedRole.code,
        fullName: fullName.isNotEmpty ? fullName : 'Staf Amanah',
        phoneNumber: phone,
        profession: profession,
        licenseNumber: license.isNotEmpty ? license : null,
        poliklinikId: poliklinikId,
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
        final AmanahAuthUser finalUser =
            (updatedUser.avatar.hasCustomAvatar
                ? updatedUser
                : updatedUser.copyWith(avatar: _avatar))
            .copyWith(needsOnboarding: false);

        if (!mounted) return;
        bool didNavigate = false;
        void completeAndNavigate() {
          if (didNavigate) return;
          didNavigate = true;
          widget.onOnboardingComplete(finalUser);
        }

        await AmanahSuccessDrawer.show(
          context,
          title: 'Selamat Bergabung!',
          subtitle:
              'Profil staf ${finalUser.fullName} (${selectedRole.title}) berhasil diaktifkan.',
          primaryButtonText: 'Mulai Bertugas',
          onPrimaryAction: completeAndNavigate,
          onSecondaryAction: completeAndNavigate,
        );

        if (mounted) {
          completeAndNavigate();
        }
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

  Widget _buildScreenHeader(BuildContext context, bool dark) {
    final String headerTitle = switch (_currentStep) {
      0 => 'Pilih Peran Staf Klinik',
      1 => 'Kredensial SIP & STR',
      _ => 'Foto Profil Tenaga Medis',
    };

    return AmanahScreenHeader(
      title: headerTitle,
      leadingAction: _currentStep > 0
          ? AmanahScreenHeaderIconAction(
              icon: Icons.arrow_back_rounded,
              semanticsLabel: 'Kembali ke langkah sebelumnya',
              onPressed: () {
                setState(() => _currentStep--);
                _notifyProgress();
              },
            )
          : AmanahScreenHeaderIconAction(
              icon: Icons.arrow_back_rounded,
              semanticsLabel: 'Kembali',
              onPressed: widget.onBack ?? widget.onLogout,
            ),
      trailing: AmanahScreenHeaderIconAction(
        icon: Icons.logout_rounded,
        semanticsLabel: 'Keluar',
        onPressed: widget.onLogout,
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    StaffOnboardingRoleOption role,
    bool dark,
    ThemeData theme,
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
                      : theme.colorScheme.outline.withValues(alpha: 0.20)),
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? AmanahColorTokens.brand
                            : AmanahThemeTokens.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AmanahThemeTokens.textSecondary(context),
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
  }

  Widget _buildPoliCard(
    BuildContext context,
    StaffOnboardingPoliOption poli,
    bool dark,
    ThemeData theme,
  ) {
    final bool isSelected = _selectedPoli?.id == poli.id;
    return InkWell(
      onTap: () => _onPoliChanged(poli),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
                    : theme.colorScheme.outline.withValues(alpha: 0.20)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AmanahColorTokens.brand
                        : (dark
                            ? Colors.white10
                            : AmanahColorTokens.neutral100),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _poliklinikIconFor(poli),
                    color: isSelected
                        ? Colors.white
                        : AmanahThemeTokens.textPrimary(context),
                    size: 19,
                  ),
                ),
                const Spacer(),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? AmanahColorTokens.brand
                      : AmanahThemeTokens.textSecondary(context),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              poli.name,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? AmanahColorTokens.brand
                    : AmanahThemeTokens.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _poliklinikSubtitle(poli),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AmanahThemeTokens.textSecondary(context),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1RoleSelection(
    BuildContext context,
    bool dark,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Pilih peran Anda untuk menyesuaikan hak akses di aplikasi.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AmanahThemeTokens.textSecondary(context),
            height: 1.45,
          ),
        ),
        const SizedBox(height: AmanahSpacing.lg),
        for (final StaffOnboardingRoleOption role
            in StaffOnboardingRoleOption.values)
          _buildRoleCard(context, role, dark, theme),
      ],
    );
  }

  Widget _buildStep2License(
    BuildContext context,
    bool dark,
    ThemeData theme,
  ) {
    if (_selectedRole == StaffOnboardingRoleOption.worker) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Informasi Kredensial Praktik',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AmanahThemeTokens.textPrimary(context),
            ),
          ),
          const SizedBox(height: AmanahSpacing.xs),
          Text(
            'Peran Staf / Pegawai Operasional tidak memerlukan Surat Izin Praktik (SIP) atau STR medis.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AmanahThemeTokens.textSecondary(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AmanahSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AmanahSpacing.lg),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.brand.withValues(alpha: 0.12)
                  : AmanahColorTokens.brandSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AmanahColorTokens.brand.withValues(alpha: 0.30),
              ),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AmanahColorTokens.brand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Akses Staf Operasional',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.brand,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Peran ini tidak memerlukan SIP/STR. Anda dapat langsung melanjutkan ke langkah foto profil.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AmanahThemeTokens.textSecondary(context),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final bool isDoctor = _selectedRole == StaffOnboardingRoleOption.doctor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isDoctor
              ? 'Surat Izin Praktik (SIP) & STR Dokter'
              : 'Surat Izin Praktik (SIP) & STR Bidan',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: AmanahSpacing.xs),
        Text(
          'Masukkan nomor SIP atau STR aktif Anda (opsional).',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AmanahThemeTokens.textSecondary(context),
            height: 1.45,
          ),
        ),
        const SizedBox(height: AmanahSpacing.lg),
        AuthInputField(
          label: isDoctor ? 'Nomor SIP / STR Dokter' : 'Nomor SIP / STR Bidan',
          hintText: 'Contoh: SIP.446/123/DISKES/2026 (opsional)',
          controller: _licenseController,
          leadingIcon: Icons.verified_outlined,
          textInputAction: TextInputAction.done,
          validator: (String? val) {
            final String trimmed = val?.trim() ?? '';
            if (trimmed.isNotEmpty && trimmed.length < 5) {
              return 'Nomor SIP / STR minimal 5 karakter';
            }
            return null;
          },
          onFieldSubmitted: (_) {
            if (_requiresPoliklinik && _selectedPoli == null) {
              setState(() {
                _poliklinikErrorMessage =
                    'Pilih poliklinik utama dari daftar server terlebih dahulu.';
              });
              return;
            }
            if (_formKey.currentState?.validate() ?? true) {
              setState(() => _currentStep = 2);
              _notifyProgress();
            }
          },
        ),
        const SizedBox(height: AmanahSpacing.lg),
        Text(
          'Poliklinik Utama',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: AmanahSpacing.xs),
        Text(
          'Pilih unit layanan tempat Anda akan praktik.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AmanahThemeTokens.textSecondary(context),
            height: 1.45,
          ),
        ),
        const SizedBox(height: AmanahSpacing.md),
        if (_isPoliklinikLoading)
          Row(
            children: <Widget>[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AmanahColorTokens.brand,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Memuat poliklinik dari server...',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AmanahThemeTokens.textSecondary(context),
                ),
              ),
            ],
          )
        else if (_poliklinikErrorMessage != null)
          AuthInlineValidationMessage(message: _poliklinikErrorMessage!)
        else
          Column(
            children: <Widget>[
              for (int index = 0;
                  index < _poliklinikOptions.length;
                  index++) ...<Widget>[
                _buildPoliCard(
                  context,
                  _poliklinikOptions[index],
                  dark,
                  theme,
                ),
                if (index < _poliklinikOptions.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ),
        const SizedBox(height: AmanahSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AmanahThemeTokens.textSecondary(context),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Daftar poliklinik diambil dari data klinik yang aktif di server.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AmanahThemeTokens.textSecondary(context),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3Avatar(
    BuildContext context,
    bool dark,
    ThemeData theme,
  ) {
    return Column(
      children: <Widget>[
        Text(
          'Lengkapi foto profil untuk akun staf Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AmanahThemeTokens.textSecondary(context),
            height: 1.45,
          ),
        ),
        const SizedBox(height: AmanahSpacing.xxl),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              AmanahAvatar(
                avatar: _avatar,
                radius: 76,
                isLoading: _isAvatarUploading || _isLoading,
                onTap: (_isLoading || _isAvatarUploading)
                    ? null
                    : _openAvatarPicker,
                border: Border.all(
                  color: AmanahColorTokens.brand.withValues(alpha: 0.35),
                  width: 3.0,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AmanahColorTokens.pureBlack.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: GestureDetector(
                  onTap: (_isLoading || _isAvatarUploading)
                      ? null
                      : _openAvatarPicker,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.brand,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dark
                            ? AmanahColorTokens.surfaceDark
                            : AmanahColorTokens.pureWhite,
                        width: 3.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AmanahSpacing.md),
        Text(
          widget.user.fullName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: AmanahSpacing.lg),
        AmanahButton.secondary(
          text: _avatar.hasCustomAvatar
              ? 'Ganti Foto Profil'
              : 'Pilih Foto Profil',
          leadingIcon: Icons.photo_camera_rounded,
          size: AmanahButtonSize.medium,
          onPressed: (_isLoading || _isAvatarUploading)
              ? null
              : _openAvatarPicker,
        ),
        if (_errorMessage != null) ...<Widget>[
          const SizedBox(height: AmanahSpacing.md),
          AuthInlineValidationMessage(message: _errorMessage!),
        ],
      ],
    );
  }

  Widget _buildCurrentStepContent(
    BuildContext context,
    bool dark,
    ThemeData theme,
  ) {
    return switch (_currentStep) {
      0 => _buildStep1RoleSelection(context, dark, theme),
      1 => _buildStep2License(context, dark, theme),
      _ => _buildStep3Avatar(context, dark, theme),
    };
  }

  Widget _buildStickyFooter(BuildContext context) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    final String buttonText = switch (_currentStep) {
      0 => _selectedRole == StaffOnboardingRoleOption.worker
          ? 'Lanjut ke Langkah 2'
          : 'Lanjut ke Data Izin',
      1 => 'Sedikit Lagi',
      _ => 'Selesai',
    };

    final bool isNextEnabled = switch (_currentStep) {
      0 => _selectedRole != null,
      1 => !_isPoliklinikLoading &&
          (!_requiresPoliklinik || _selectedPoli != null),
      _ => !_isLoading,
    };

    final VoidCallback? onNextPressed = switch (_currentStep) {
      0 => _selectedRole != null
          ? () {
              setState(() => _currentStep = 1);
              _notifyProgress();
            }
          : null,
      1 => () {
          if (_requiresPoliklinik && _selectedPoli == null) {
            setState(() {
              _poliklinikErrorMessage =
                  'Pilih poliklinik utama dari daftar server terlebih dahulu.';
            });
            return;
          }
          if (_formKey.currentState?.validate() ?? true) {
            setState(() => _currentStep = 2);
            _notifyProgress();
          }
        },
      _ => _isLoading ? null : _submit,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AmanahThemeTokens.canvas(context),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AmanahSpacing.xxl,
            AmanahSpacing.sm,
            AmanahSpacing.xxl,
            math.max(AmanahSpacing.lg, safeBottom > 0 ? 12 : AmanahSpacing.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AmanahButton.primary(
                text: buttonText,
                isFullWidth: true,
                size: AmanahButtonSize.large,
                isLoading: _currentStep == 2 && _isLoading,
                trailingIcon: _currentStep == 2
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_rounded,
                onPressed: isNextEnabled ? onNextPressed : null,
              ),
              if (_currentStep > 0) ...<Widget>[
                const SizedBox(height: 10),
                AmanahButton.ghost(
                  text: 'Sebelumnya',
                  size: AmanahButtonSize.large,
                  isFullWidth: true,
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() => _currentStep--);
                          _notifyProgress();
                        },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (_currentStep > 0) {
          setState(() => _currentStep--);
          _notifyProgress();
        } else {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            widget.onLogout();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AmanahThemeTokens.canvas(context),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              _buildScreenHeader(context, dark),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AmanahSpacing.xxl,
                    vertical: AmanahSpacing.md,
                  ),
                  child: Form(
                    key: _formKey,
                    child: _buildCurrentStepContent(context, dark, theme),
                  ),
                ),
              ),
              _buildStickyFooter(context),
            ],
          ),
        ),
      ),
    );
  }
}
