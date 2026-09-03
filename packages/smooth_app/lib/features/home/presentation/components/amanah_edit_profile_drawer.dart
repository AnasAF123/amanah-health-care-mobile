import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

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
        : Colors.white;
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
        secondary: AmanahButton.ghost(
          text: 'Batal',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          customForegroundColor: subtextColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        primary: AmanahButton.primary(
          text: _isSaved ? 'Tersimpan' : 'Simpan Perubahan',
          leadingIcon: _isSaved ? Icons.check_rounded : null,
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          onPressed: _isSaved ? null : _handleSave,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Nama Lengkap & Gelar (Read-only verified)
          Text(
            'Nama Lengkap & Gelar',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
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
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: fieldBorder),
            ),
            child: Text(
              widget.doctorName,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Terverifikasi oleh manajemen',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
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
              fontFamily: 'PlusJakartaSans',
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
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: '+62 812-xxxx-xxxx',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
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
                  color: Color(0xFF0A44FF),
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
              fontFamily: 'PlusJakartaSans',
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
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: 'dokter@rsamanah.co.id',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
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
                  color: Color(0xFF0A44FF),
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
              fontFamily: 'PlusJakartaSans',
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
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.45,
            ),
            decoration: InputDecoration(
              hintText: 'Tuliskan bio atau catatan singkat profil...',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
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
                  color: Color(0xFF0A44FF),
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

class AmanahAvatarPhotoResult {
  const AmanahAvatarPhotoResult({
    this.customImagePath,
    this.presetAvatarUrl,
    this.isReset = false,
  });

  final String? customImagePath;
  final String? presetAvatarUrl;
  final bool isReset;
}

class AmanahAvatarPhotoSheet extends StatelessWidget {
  const AmanahAvatarPhotoSheet({super.key});

  static const List<String> presetAvatars = <String>[
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1594824813628-984dd2e54133?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=300&auto=format&fit=crop',
  ];

  static Future<AmanahAvatarPhotoResult?> show(BuildContext context) {
    return showAmanahBottomSheet<AmanahAvatarPhotoResult>(
      context: context,
      builder: (BuildContext ctx) => const AmanahAvatarPhotoSheet(),
    );
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null &&
          result.files.single.path != null &&
          context.mounted) {
        Navigator.of(context).pop(
          AmanahAvatarPhotoResult(customImagePath: result.files.single.path),
        );
      }
    } catch (_) {
      // Fallback if platform picker not supported
      if (context.mounted) {
        Navigator.of(
          context,
        ).pop(AmanahAvatarPhotoResult(presetAvatarUrl: presetAvatars.first));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return AmanahBottomSheetScaffold(
      title: 'Ganti Foto Profil Dokter',
      fixedHeightFactor: 0.48,
      minHeight: 340,
      bodyPadding: EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Pick from Gallery Button
          ListTile(
            onTap: () => _pickFromGallery(context),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF2563EB),
                size: 20,
              ),
            ),
            title: Text(
              'Pilih dari Galeri Perangkat',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            subtitle: Text(
              'Unggah gambar JPG / PNG dari galeri',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                color: subtextColor,
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, size: 18),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          // 2. Preset Medical Avatars
          Text(
            'Atau Pilih Preset Avatar Dokter',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: subtextColor,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (int i = 0; i < presetAvatars.length; i++)
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop(
                      AmanahAvatarPhotoResult(
                        presetAvatarUrl: presetAvatars[i],
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0A44FF).withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        presetAvatars[i],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (BuildContext ctx, Object err, StackTrace? st) {
                              return const Icon(
                                Icons.person_rounded,
                                color: Color(0xFF0A44FF),
                              );
                            },
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Reset Option
          Center(
            child: AmanahButton.text(
              text: 'Gunakan Foto Default',
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(const AmanahAvatarPhotoResult(isReset: true));
              },
              customForegroundColor: subtextColor,
            ),
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}
