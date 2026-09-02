import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_app/features/authentication/domain/amanah_auth_user.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_doctor_id_card_components.dart';

class AmanahDoctorIdCardScreen extends StatefulWidget {
  const AmanahDoctorIdCardScreen({
    required this.user,
    required this.profile,
    super.key,
  });

  final AmanahAuthUser user;
  final AmanahDoctorProfile profile;

  static Route<void> route({
    required AmanahAuthUser user,
    required AmanahDoctorProfile profile,
  }) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return AmanahDoctorIdCardScreen(user: user, profile: profile);
          },
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Animation<double> curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.95, end: 1).animate(curved),
                child: child,
              ),
            );
          },
    );
  }

  @override
  State<AmanahDoctorIdCardScreen> createState() =>
      _AmanahDoctorIdCardScreenState();
}

class _AmanahDoctorIdCardScreenState extends State<AmanahDoctorIdCardScreen> {
  bool _isDownloading = false;

  AmanahDoctorProfile get _profile => widget.profile;

  Future<void> _shareDoctorId() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          title: 'ID Card Dokter - ${_profile.name}',
          text:
              '${_profile.name} (${_profile.role}) - ${_profile.hospital}\nSIP: ${_profile.sip}',
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_snackBar('Nomor SIP berhasil disalin untuk dibagikan'));
    }
  }

  Future<void> _downloadPdf() async {
    if (_isDownloading) {
      return;
    }
    setState(() => _isDownloading = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) {
      return;
    }
    setState(() => _isDownloading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(_snackBar('ID Card dokter berhasil disiapkan (PDF)'));
  }

  SnackBar _snackBar(String message) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'PlusJakartaSans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFF0F172A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final EdgeInsets safePadding = MediaQuery.paddingOf(context);
    final Color bgColor = dark
        ? const Color(0xFF070B14)
        : const Color(0xFFF8FAFF);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: ColoredBox(color: bgColor)),
          Positioned.fill(
            child: AmanahDoctorIdCardStage(profile: _profile),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: AmanahDoctorIdCardHeader(
                onBack: () => Navigator.of(context).pop(),
                onInfo: () => AmanahDoctorIdInfoDrawer.show(context),
                onQr: () => AmanahDoctorIdQrDialog.show(context, _profile),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: safePadding.bottom + 28,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: AmanahButton.secondary(
                    text: 'Bagikan',
                    leadingIcon: Icons.share_outlined,
                    onPressed: _shareDoctorId,
                    size: AmanahButtonSize.medium,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AmanahButton.primary(
                    text: _isDownloading ? 'Membuat PDF...' : 'Unduh PDF',
                    leadingIcon: Icons.download_rounded,
                    onPressed: _downloadPdf,
                    isLoading: _isDownloading,
                    size: AmanahButtonSize.medium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
