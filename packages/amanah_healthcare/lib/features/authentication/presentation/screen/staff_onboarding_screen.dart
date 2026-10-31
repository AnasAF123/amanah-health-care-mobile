import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/data/amanah_auth_repository.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/auth_inline_validation_message.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/onboarding/onboarding_clinical_section.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/onboarding/onboarding_contact_section.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/onboarding/onboarding_domicile_section.dart';
import 'package:amanah_healthcare/features/authentication/presentation/components/onboarding/onboarding_personal_section.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_success_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

class StaffOnboardingScreen extends StatefulWidget {
  const StaffOnboardingScreen({
    required this.user,
    required this.onOnboardingComplete,
    required this.onLogout,
    this.onBack,
    this.repository = const AmanahAuthRepository(),
    this.controller,
    super.key,
  });

  final AmanahAuthUser user;
  final ValueChanged<AmanahAuthUser> onOnboardingComplete;
  final VoidCallback onLogout;
  final VoidCallback? onBack;
  final AuthRepository repository;
  final StaffOnboardingController? controller;

  @override
  State<StaffOnboardingScreen> createState() => _StaffOnboardingScreenState();
}

class _StaffOnboardingScreenState extends State<StaffOnboardingScreen> {
  late final StaffOnboardingController _controller;
  int _currentStep = 0;

  int get _totalSteps => _controller.isClinical ? 3 : 2;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        StaffOnboardingController(user: widget.user, repository: widget.repository);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentStep == 0) {
      if (!(_controller.formKey.currentState?.validate() ?? false)) return;
      if (_controller.birthDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih tanggal lahir terlebih dahulu.'),
            backgroundColor: AmanahColorTokens.danger,
          ),
        );
        return;
      }
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (_controller.selectedProvince == null ||
          _controller.selectedRegency == null ||
          _controller.selectedDistrict == null ||
          _controller.selectedVillage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lengkapi pilihan wilayah domisili kependudukan.'),
            backgroundColor: AmanahColorTokens.danger,
          ),
        );
        return;
      }
      if (!(_controller.formKey.currentState?.validate() ?? false)) return;
      if (_controller.isClinical) {
        setState(() => _currentStep = 2);
      } else {
        _handleSubmit();
      }
    } else {
      _handleSubmit();
    }
  }

  Future<void> _handleSubmit() async {
    final AmanahAuthUser? updatedUser = await _controller.submit();
    if (!mounted || updatedUser == null) return;

    bool didNavigate = false;
    void completeAndNavigate() {
      if (didNavigate) return;
      didNavigate = true;
      widget.onOnboardingComplete(updatedUser);
    }

    await AmanahSuccessDrawer.show(
      context,
      title: 'Profil Berhasil Dilengkapi!',
      subtitle:
          'Data staf ${updatedUser.fullName} (${widget.user.roleName}) telah tersimpan dan terverifikasi.',
      primaryButtonText: 'Mulai Bertugas',
      onPrimaryAction: completeAndNavigate,
      onSecondaryAction: completeAndNavigate,
    );

    if (mounted) {
      completeAndNavigate();
    }
  }

  Widget _buildStepContent() {
    return switch (_currentStep) {
      0 => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          OnboardingPersonalSection(controller: _controller),
          const SizedBox(height: VERY_LARGE_SPACE),
          OnboardingContactSection(controller: _controller),
        ],
      ),
      1 => OnboardingDomicileSection(controller: _controller),
      _ => OnboardingClinicalSection(controller: _controller),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        final String stepTitle = switch (_currentStep) {
          0 => 'Data Pribadi Staf',
          1 => 'Alamat Domisili Kependudukan',
          _ => 'Kredensial Medis & Penugasan',
        };

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, _) {
            if (didPop) return;
            if (_currentStep > 0) {
              setState(() => _currentStep--);
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
                  AmanahScreenHeader(
                    title: stepTitle,
                    leadingAction: _currentStep > 0
                        ? AmanahScreenHeaderIconAction(
                            icon: Icons.arrow_back_rounded,
                            semanticsLabel: 'Kembali',
                            onPressed: () => setState(() => _currentStep--),
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
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Form(key: _controller.formKey, child: _buildStepContent()),
                    ),
                  ),
                  _buildStickyFooter(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickyFooter(BuildContext context) {
    final double safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final bool isLastStep = _currentStep == _totalSteps - 1;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AmanahThemeTokens.canvas(context),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, math.max(12, safeBottom)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (_controller.submitErrorMessage != null) ...<Widget>[
                AuthInlineValidationMessage(message: _controller.submitErrorMessage!),
                const SizedBox(height: 10),
              ],
              AmanahButton.primary(
                text: isLastStep ? 'Simpan & Aktifkan Akun' : 'Lanjutkan',
                isFullWidth: true,
                size: AmanahButtonSize.large,
                isLoading: _controller.isSubmitting,
                trailingIcon: isLastStep ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                onPressed: _controller.isSubmitting ? null : _onNext,
              ),
              if (_currentStep > 0) ...<Widget>[
                const SizedBox(height: 10),
                AmanahButton.ghost(
                  text: 'Sebelumnya',
                  size: AmanahButtonSize.large,
                  isFullWidth: true,
                  onPressed: _controller.isSubmitting ? null : () => setState(() => _currentStep--),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
