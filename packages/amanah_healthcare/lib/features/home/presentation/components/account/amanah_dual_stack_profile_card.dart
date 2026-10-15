import 'dart:io';

import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_watermark_path.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahDualStackProfileCard extends StatelessWidget {
  const AmanahDualStackProfileCard({
    required this.userName,
    required this.roleText,
    required this.phoneText,
    required this.dark,
    required this.onEditTap,
    required this.onAvatarTap,
    required this.onLoyaltyTap,
    this.customAvatarPath,
    this.presetAvatarUrl,
    super.key,
  });

  final String userName;
  final String roleText;
  final String phoneText;
  final String? customAvatarPath;
  final String? presetAvatarUrl;
  final bool dark;
  final VoidCallback onEditTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onLoyaltyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AmanahThemeTokens.surfaceHighlight(context),
        border: Border.all(
          color: dark
              ? AmanahThemeTokens.outlineStrong(context)
              : AmanahColorTokens.brandMuted,
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: dark
                ? AmanahColorTokens.pureBlack.withValues(alpha: 0.40)
                : AmanahColorTokens.sky.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: <Widget>[
            AmanahPixelTexture(
              isDark: dark,
              opacity: dark ? 0.28 : 0.22,
              maskType: AmanahPixelMaskType.horizontalEdges,
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark
                        ? AmanahThemeTokens.surface(context)
                        : AmanahColorTokens.surfaceLight,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: dark
                          ? AmanahThemeTokens.outline(context)
                          : AmanahColorTokens.skyLight,
                      width: 1,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AmanahColorTokens.pureBlack.withValues(
                          alpha: dark ? 0.35 : 0.06,
                        ),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: onAvatarTap,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: dark
                                  ? AmanahColorTokens.brand
                                  : AmanahColorTokens.skySubtle,
                              width: 2.2,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AmanahColorTokens.pureBlack.withValues(alpha: 0.10),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(child: _buildAvatar()),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: dark
                                    ? AmanahColorTokens.surfaceLight
                                    : AmanahColorTokens.brandNavy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$roleText • $phoneText',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: dark
                                    ? AmanahColorTokens.neutral400
                                    : AmanahColorTokens.neutral600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        iconSize: 20,
                        tooltip: 'Edit Profil',
                        style: IconButton.styleFrom(
                          backgroundColor: dark
                              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.06)
                              : AmanahColorTokens.skyLight.withValues(alpha: 0.60),
                          foregroundColor: dark
                              ? AmanahColorTokens.cyanLight
                              : AmanahColorTokens.brandNavy,
                        ),
                        onPressed: onEditTap,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: onLoyaltyTap,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color: dark
                                    ? AmanahColorTokens.cyanLight
                                    : AmanahColorTokens.brandNavy,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'SIP Terverifikasi',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: dark
                                        ? AmanahColorTokens.surfaceLight
                                        : AmanahColorTokens.brandNavy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Kartu ID Dokter',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: dark
                                    ? AmanahColorTokens.cyanLight
                                    : AmanahColorTokens.skyDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dark
                                    ? AmanahColorTokens.tabActiveDark
                                    : AmanahColorTokens.brandNavy,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: dark
                                    ? AmanahColorTokens.brandNavy
                                    : AmanahColorTokens.cyanLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (customAvatarPath != null) {
      return Image.file(
        File(customAvatarPath!),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (BuildContext ctx, Object err, StackTrace? st) =>
            _fallbackAvatar(),
      );
    }
    if (presetAvatarUrl != null) {
      return Image.network(
        presetAvatarUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (BuildContext ctx, Object err, StackTrace? st) =>
            _fallbackAvatar(),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return Image.asset(
      'assets/amanah/auth/auth_background.png',
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (BuildContext ctx, Object err, StackTrace? st) => Container(
        color: AmanahColorTokens.sky,
        child: const Icon(Icons.person_rounded, color: AmanahColorTokens.surfaceLight, size: 30),
      ),
    );
  }
}
