import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
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
            readOnly: true,
            enabled: false,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
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
              suffixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: subtextColor.withValues(alpha: 0.70),
              ),
              filled: true,
              fillColor: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                  : AmanahColorTokens.neutral50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: fieldBorder),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Email terdaftar secara permanen untuk keperluan legalitas klinis.',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: subtextColor,
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

class AmanahAvatarPhotoResult {
  const AmanahAvatarPhotoResult({
    this.customImagePath,
    this.pickedFile,
    this.pickedBytes,
    this.fileName,
    this.presetAvatarUrl,
    this.isReset = false,
  });

  factory AmanahAvatarPhotoResult.image(XFile file) {
    return AmanahAvatarPhotoResult(
      customImagePath: file.path,
      pickedFile: file,
      fileName: file.name.isNotEmpty ? file.name : 'avatar.jpg',
    );
  }

  factory AmanahAvatarPhotoResult.bytes(List<int> bytes, String fileName) {
    return AmanahAvatarPhotoResult(
      pickedBytes: bytes,
      fileName: fileName,
    );
  }

  factory AmanahAvatarPhotoResult.preset(String url) {
    return AmanahAvatarPhotoResult(presetAvatarUrl: url);
  }

  factory AmanahAvatarPhotoResult.reset() {
    return const AmanahAvatarPhotoResult(isReset: true);
  }

  final String? customImagePath;
  final XFile? pickedFile;
  final List<int>? pickedBytes;
  final String? fileName;
  final String? presetAvatarUrl;
  final bool isReset;

  bool get isDelete => isReset;
}

class AmanahAvatarPhotoSheet extends StatelessWidget {
  const AmanahAvatarPhotoSheet({
    this.title = 'Foto Profil Dokter',
    this.hasCustomAvatar = false,
    this.onImageSelected,
    this.onDeleteAvatar,
    super.key,
  });

  final String title;
  final bool hasCustomAvatar;
  final ValueChanged<XFile>? onImageSelected;
  final VoidCallback? onDeleteAvatar;

  static const List<String> presetAvatars = <String>[
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1594824813628-984dd2e54133?q=80&w=300&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?q=80&w=300&auto=format&fit=crop',
  ];

  static Future<AmanahAvatarPhotoResult?> show(
    BuildContext context, {
    String title = 'Foto Profil Dokter',
    bool hasCustomAvatar = false,
    ValueChanged<XFile>? onImageSelected,
    VoidCallback? onDeleteAvatar,
  }) {
    return showAmanahBottomSheet<AmanahAvatarPhotoResult>(
      context: context,
      builder: (BuildContext ctx) => AmanahAvatarPhotoSheet(
        title: title,
        hasCustomAvatar: hasCustomAvatar,
        onImageSelected: onImageSelected,
        onDeleteAvatar: onDeleteAvatar,
      ),
    );
  }

  Future<void> _pickWithCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null && context.mounted) {
        onImageSelected?.call(file);
        Navigator.of(context).pop(AmanahAvatarPhotoResult.image(file));
      }
    } catch (_) {}
  }

  Future<void> _pickWithGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null && context.mounted) {
        onImageSelected?.call(file);
        Navigator.of(context).pop(AmanahAvatarPhotoResult.image(file));
        return;
      }
    } catch (_) {}

    // Fallback to FilePicker if platform ImagePicker is not available
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty && context.mounted) {
        final PlatformFile file = result.files.single;
        if (file.bytes != null) {
          Navigator.of(context).pop(
            AmanahAvatarPhotoResult.bytes(
              file.bytes!,
              file.name.isNotEmpty ? file.name : 'avatar.jpg',
            ),
          );
        } else if (file.path != null) {
          final XFile xFile = XFile(file.path!, name: file.name);
          onImageSelected?.call(xFile);
          Navigator.of(context).pop(AmanahAvatarPhotoResult.image(xFile));
        }
      }
    } catch (_) {}
  }

  Future<void> _pickWithExplorer(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty && context.mounted) {
        final PlatformFile file = result.files.single;
        if (file.bytes != null) {
          Navigator.of(context).pop(
            AmanahAvatarPhotoResult.bytes(
              file.bytes!,
              file.name.isNotEmpty ? file.name : 'avatar.jpg',
            ),
          );
        } else if (file.path != null) {
          final XFile xFile = XFile(file.path!, name: file.name);
          onImageSelected?.call(xFile);
          Navigator.of(context).pop(AmanahAvatarPhotoResult.image(xFile));
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final Color iconTileBg = dark
        ? AmanahColorTokens.brandAccent.withValues(alpha: 0.16)
        : AmanahColorTokens.brandAccent.withValues(alpha: 0.10);

    return AmanahBottomSheetScaffold(
      title: title,
      subtitle: 'Pilih kamera, galeri, file disk, atau preset avatar',
      fixedHeightFactor: hasCustomAvatar ? 0.70 : 0.62,
      minHeight: hasCustomAvatar ? 500 : 440,
      bodyPadding: EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.md,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl + MediaQuery.viewPaddingOf(context).bottom,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Ambil dari Kamera
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              onTap: () => _pickWithCamera(context),
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconTileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AmanahColorTokens.brandAccent,
                  size: 20,
                ),
              ),
              title: Text(
                'Ambil Foto dari Kamera',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                'Buka kamera perangkat untuk foto baru',
                style: TextStyle(
                  fontSize: 11,
                  color: subtextColor,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: subtextColor,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // 2. Pilih dari Galeri
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              onTap: () => _pickWithGallery(context),
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconTileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library_outlined,
                  color: AmanahColorTokens.brandAccent,
                  size: 20,
                ),
              ),
              title: Text(
                'Pilih dari Galeri Perangkat',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                'Unggah gambar JPG, PNG, atau WebP dari galeri',
                style: TextStyle(
                  fontSize: 11,
                  color: subtextColor,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: subtextColor,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // 3. Pilih dari File Explorer / Disk HP
          Material(
            type: MaterialType.transparency,
            child: ListTile(
              onTap: () => _pickWithExplorer(context),
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconTileBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  color: AmanahColorTokens.brandAccent,
                  size: 20,
                ),
              ),
              title: Text(
                'Pilih dari File Explorer / Disk HP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                'Jelajahi folder Unduhan (Downloads), Dokumen, atau Disk',
                style: TextStyle(
                  fontSize: 11,
                  color: subtextColor,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: subtextColor,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. Preset Medical Avatars
          Text(
            'Atau Pilih Preset Avatar Klinis',
            style: TextStyle(
              fontSize: 11.5,
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
                      AmanahAvatarPhotoResult.preset(presetAvatars[i]),
                    );
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AmanahColorTokens.brandPrimary.withValues(alpha: 0.35),
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
                                color: AmanahColorTokens.brandPrimary,
                              );
                            },
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Reset or Delete Avatar
          if (hasCustomAvatar) ...<Widget>[
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                onTap: () {
                  onDeleteAvatar?.call();
                  Navigator.of(context).pop(AmanahAvatarPhotoResult.reset());
                },
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AmanahColorTokens.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AmanahColorTokens.danger,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Hapus Foto Profil (Gunakan Inisial)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AmanahColorTokens.danger,
                  ),
                ),
                subtitle: Text(
                  'Kembalikan tampilan profil ke inisial nama klinis',
                  style: TextStyle(
                    fontSize: 11,
                    color: subtextColor,
                  ),
                ),
              ),
            ),
          ] else ...<Widget>[
            Center(
              child: AmanahButton.text(
                text: 'Gunakan Foto Default',
                onPressed: () {
                  onDeleteAvatar?.call();
                  Navigator.of(context).pop(AmanahAvatarPhotoResult.reset());
                },
                customForegroundColor: subtextColor,
              ),
            ),
          ],
          const SizedBox(height: AmanahSpacing.sm),
        ],
      ),
    );
  }
}

