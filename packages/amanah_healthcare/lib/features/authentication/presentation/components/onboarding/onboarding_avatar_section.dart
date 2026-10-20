import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/authentication/presentation/state/staff_onboarding_controller.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_avatar_photo_sheet.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';
import 'package:amanah_healthcare/widgets/amanah_avatar.dart';

class OnboardingAvatarSection extends StatelessWidget {
  const OnboardingAvatarSection({
    required this.controller,
    super.key,
  });

  final StaffOnboardingController controller;

  Future<void> _openAvatarPicker(BuildContext context) async {
    final AmanahAvatarPhotoResult? result = await AmanahAvatarPhotoSheet.show(
      context,
      title: 'Foto Profil Staf Medis',
      hasCustomAvatar: controller.avatar.hasCustomAvatar,
    );

    if (result == null) return;

    if (result.isDelete || result.isReset) {
      try {
        await controller.deleteAvatarPhoto();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: AmanahColorTokens.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      return;
    }

    if (result.pickedFile != null ||
        result.pickedBytes != null ||
        result.customImagePath != null ||
        result.presetAvatarUrl != null) {
      try {
        if (result.pickedBytes != null) {
          await controller.uploadAvatarPhoto(
            fileBytes: result.pickedBytes!,
            fileName: result.fileName ?? 'avatar.jpg',
            useAuthAlias: true,
          );
        } else if (result.pickedFile != null) {
          await controller.uploadAvatarPhoto(
            filePath: result.pickedFile!.path,
            fileName: result.pickedFile!.name,
            useAuthAlias: true,
          );
        } else if (result.customImagePath != null) {
          await controller.uploadAvatarPhoto(
            filePath: result.customImagePath!,
            fileName: 'avatar.jpg',
            useAuthAlias: true,
          );
        } else if (result.presetAvatarUrl != null) {
          controller.setAvatar(
            UserAvatar.custom(
              url: result.presetAvatarUrl!,
              initials: UserAvatar.extractInitials(controller.user.fullName),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Foto Profil Akun Staf',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AmanahThemeTokens.textPrimary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Unggah foto formal untuk identitas badge dan penugasan klinik.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AmanahThemeTokens.textSecondary(context),
          ),
        ),
        const SizedBox(height: LARGE_SPACE),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              AmanahAvatar(
                avatar: controller.avatar,
                radius: 64,
                isLoading: controller.isAvatarUploading || controller.isSubmitting,
                onTap: (controller.isSubmitting || controller.isAvatarUploading)
                    ? null
                    : () => _openAvatarPicker(context),
                border: Border.all(
                  color: AmanahColorTokens.brand.withValues(alpha: 0.35),
                  width: 3.0,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AmanahColorTokens.pureBlack.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: (controller.isSubmitting || controller.isAvatarUploading)
                      ? null
                      : () => _openAvatarPicker(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.brand,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? AmanahColorTokens.surfaceDark
                            : AmanahColorTokens.pureWhite,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        AmanahButton.secondary(
          text: controller.avatar.hasCustomAvatar
              ? 'Ganti Foto Profil'
              : 'Pilih Foto Profil',
          leadingIcon: Icons.photo_camera_rounded,
          size: AmanahButtonSize.medium,
          onPressed: (controller.isSubmitting || controller.isAvatarUploading)
              ? null
              : () => _openAvatarPicker(context),
        ),
      ],
    );
  }
}
