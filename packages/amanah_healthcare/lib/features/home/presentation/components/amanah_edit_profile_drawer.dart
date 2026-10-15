import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

export 'package:amanah_healthcare/features/home/presentation/components/amanah_avatar_photo_sheet.dart';

class AmanahEditProfileResult {
  const AmanahEditProfileResult({
    required this.phone,
    required this.email,
    required this.bio,
  });

  final String phone;
  final String email;
  final String bio;
}

class AmanahEditProfileDrawer extends StatefulWidget {
  const AmanahEditProfileDrawer({
    required this.doctorName,
    required this.initialPhone,
    required this.initialEmail,
    required this.initialBio,
    super.key,
  });

  final String doctorName;
  final String initialPhone;
  final String initialEmail;
  final String initialBio;

  static Future<AmanahEditProfileResult?> show({
    required BuildContext context,
    required String doctorName,
    required String initialPhone,
    required String initialEmail,
    required String initialBio,
  }) {
    return showAmanahBottomSheet<AmanahEditProfileResult>(
      context: context,
      builder: (BuildContext ctx) => AmanahEditProfileDrawer(
        doctorName: doctorName,
        initialPhone: initialPhone,
        initialEmail: initialEmail,
        initialBio: initialBio,
      ),
    );
  }

  @override
  State<AmanahEditProfileDrawer> createState() =>
      _AmanahEditProfileDrawerState();
}

class _AmanahEditProfileDrawerState extends State<AmanahEditProfileDrawer> {
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);
    _bioController = TextEditingController(text: widget.initialBio);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() {
    setState(() => _isSaved = true);
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Navigator.of(context).pop(
          AmanahEditProfileResult(
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            bio: _bioController.text.trim(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final Color fieldBg = dark
        ? AmanahThemeTokens.surfaceSecondary(context)
        : AmanahColorTokens.surfaceLight;
    final Color fieldBorder = AmanahThemeTokens.outline(context);

    return AmanahBottomSheetScaffold(
      title: 'Edit Profil Dokter',
      subtitle: 'Perbarui kontak dan bio profil',
      fixedHeightFactor: 0.70,
      minHeight: 420,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahActionRow(
        axis: AmanahActionRowAxis.vertical,
        spacing: AmanahSpacing.sm,
        primary: AmanahButton.primary(
          text: _isSaved ? 'Tersimpan' : 'Simpan Perubahan',
          leadingIcon: _isSaved ? Icons.check_rounded : null,
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          onPressed: _isSaved ? null : _handleSave,
        ),
        secondary: AmanahButton.ghost(
          text: 'Batal',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          customForegroundColor: subtextColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Nama Lengkap & Gelar (Read-only verified)
          Text(
            'Nama Lengkap & Gelar',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                  : AmanahColorTokens.neutral50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: fieldBorder),
            ),
            child: Text(
              widget.doctorName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Terverifikasi oleh manajemen',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 16),

          // 2. Nomor WhatsApp / Telepon
          Text(
            'Nomor WhatsApp / Telepon',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: '+62 812-xxxx-xxxx',
              hintStyle: TextStyle(
                fontSize: 12,
                color: subtextColor.withValues(alpha: 0.60),
              ),
              prefixIcon: Icon(
                Icons.phone_outlined,
                size: 16,
                color: subtextColor,
              ),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AmanahColorTokens.brandPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Email Resmi
          Text(
            'Email Resmi',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: 'dokter@rsamanah.co.id',
              hintStyle: TextStyle(
                fontSize: 12,
                color: subtextColor.withValues(alpha: 0.60),
              ),
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: subtextColor,
              ),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AmanahColorTokens.brandPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Bio Medis
          Text(
            'Bio Medis',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _bioController,
            maxLines: 3,
            minLines: 2,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: 'Tuliskan bio atau catatan singkat profil...',
              hintStyle: TextStyle(
                fontSize: 12,
                color: subtextColor.withValues(alpha: 0.60),
              ),
              filled: true,
              fillColor: fieldBg,
              contentPadding: const EdgeInsets.all(14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AmanahColorTokens.brandPrimary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}

