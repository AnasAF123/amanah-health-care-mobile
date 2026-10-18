import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahAccountPreferencesCard extends StatelessWidget {
  const AmanahAccountPreferencesCard({
    required this.dark,
    required this.onItemTap,
    super.key,
  });

  final bool dark;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Preferensi',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: dark ? AmanahThemeTokens.surface(context) : AmanahColorTokens.surfaceLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: dark
                  ? AmanahThemeTokens.outline(context)
                  : AmanahColorTokens.neutral200,
              width: 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AmanahColorTokens.pureBlack.withValues(alpha: dark ? 0.35 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              children: <Widget>[
                AmanahPreferenceRowItem(
                  icon: Icons.shield_outlined,
                  title: 'Keamanan akun & PIN',
                  badgeText: 'PIN Aktif',
                  badgeColor: AmanahColorTokens.success,
                  dark: dark,
                  onTap: () => onItemTap('security'),
                ),
                _divider(context),
                AmanahPreferenceRowItem(
                  icon: Icons.badge_outlined,
                  title: 'Akun & identitas dokter',
                  badgeText: 'Terverifikasi',
                  badgeColor: AmanahColorTokens.sky,
                  dark: dark,
                  onTap: () => onItemTap('account'),
                ),
                _divider(context),
                AmanahPreferenceRowItem(
                  icon: Icons.receipt_long_rounded,
                  title: 'Laporan slip gaji & insentif',
                  badgeText: 'Payroll',
                  badgeColor: AmanahColorTokens.success,
                  dark: dark,
                  onTap: () => onItemTap('payroll'),
                ),
                _divider(context),
                AmanahPreferenceRowItem(
                  icon: Icons.storage_rounded,
                  title: 'Data & penyimpanan laporan',
                  dark: dark,
                  onTap: () => onItemTap('data'),
                ),
                _divider(context),
                AmanahPreferenceRowItem(
                  icon: Icons.support_agent_rounded,
                  title: 'Bantuan teknisi IT RS',
                  badgeText: 'Online 24 Jam',
                  badgeColor: AmanahColorTokens.brand,
                  dark: dark,
                  onTap: () => onItemTap('help'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    color: AmanahThemeTokens.divider(context),
  );
}

class AmanahPreferenceRowItem extends StatelessWidget {
  const AmanahPreferenceRowItem({
    required this.icon,
    required this.title,
    required this.dark,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? badgeText;
  final Color? badgeColor;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: AmanahColorTokens.sky),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                        ),
                      ),
                    ),
                    if (badgeText != null) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (badgeColor ?? AmanahColorTokens.sky)
                              .withValues(alpha: dark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: badgeColor ?? AmanahColorTokens.sky,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: dark ? AmanahColorTokens.neutral500 : AmanahColorTokens.neutral400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
