import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

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
    this.title = 'Ganti Foto Profil Dokter',
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
    String title = 'Ganti Foto Profil Dokter',
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
      fixedHeightFactor: hasCustomAvatar ? 0.78 : 0.72,
      minHeight: hasCustomAvatar ? 560 : 520,
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
