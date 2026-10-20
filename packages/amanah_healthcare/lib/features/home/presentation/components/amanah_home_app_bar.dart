import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/widgets/amanah_avatar.dart';

/// Organism: DoctorProfileHeader App Bar matching DoctorProfileHeader.tsx (.web)
/// Renders doctor avatar, doctor name with drop shadow, greeting, and frosted unread notification bell.
class AmanahHomeAppBar extends StatelessWidget {
  const AmanahHomeAppBar({
    required this.user,
    required this.onNotificationTap,
    required this.onProfileTap,
    super.key,
    this.greeting = 'Selamat Pagi',
    this.unreadNotifications = 3,
  });

  final AmanahAuthUser user;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final String greeting;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    return AmanahScreenHeader(
      leading: AmanahScreenHeaderLeading.none,
      titleAlignment: AmanahScreenHeaderTitleAlignment.start,
      backgroundColor: Colors.transparent,
      contentPadding: const EdgeInsets.symmetric(horizontal: AmanahSpacing.lg),
      titleWidget: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(AmanahRadius.pill),
          child: SizedBox(
            height: AmanahComponentSize.iconButton,
            child: Row(
              children: <Widget>[
                _DoctorAvatar(
                  avatar: user.avatar,
                  name: user.fullName,
                ),
                const SizedBox(width: AmanahSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AmanahColorTokens.surfaceLight,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                          height: 1.15,
                          shadows: <Shadow>[
                            Shadow(
                              color: AmanahColorTokens.textShadowBlack20,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AmanahSpacing.xxs),
                      Text(
                        greeting,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AmanahColorTokens.textWhite85,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      trailing: _NotificationButton(
        unreadNotifications: unreadNotifications,
        onTap: onNotificationTap,
      ),
    );
  }
}

/// Atom: Doctor Avatar with circular border and dynamic AmanahAvatar
class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({
    required this.avatar,
    required this.name,
  });

  final UserAvatar avatar;
  final String name;

  @override
  Widget build(BuildContext context) {
    return AmanahAvatar(
      avatar: avatar,
      radius: 20,
      border: Border.all(
        color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.35),
        width: 1.5,
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: AmanahColorTokens.pureBlack.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      semanticsLabel: 'Foto profil dokter $name',
    );
  }
}

/// Atom: Frosted Notification Bell Button
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.unreadNotifications,
    required this.onTap,
  });

  final int unreadNotifications;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Notifikasi',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: AmanahComponentSize.iconButton,
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.20),
                    width: 1.0,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AmanahColorTokens.pureBlack.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AmanahColorTokens.surfaceLight,
                    ),
                    if (unreadNotifications > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AmanahColorTokens.danger,
                            shape: BoxShape.circle,
                            border: Border.all(color: AmanahColorTokens.surfaceLight, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
