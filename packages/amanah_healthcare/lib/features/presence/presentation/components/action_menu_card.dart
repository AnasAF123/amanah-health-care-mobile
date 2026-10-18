import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class ActionMenuCard extends StatelessWidget {
  const ActionMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.dark,
    required this.onTap,
    this.isActive = false,
  });

  final String title;
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color cardBg = dark
        ? AmanahColorTokens.surfaceSecondaryDark
        : AmanahColorTokens.surfaceLight;

    final Color borderColor = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.12)
        : AmanahColorTokens.neutral200;

    final Color textColor =
        dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900;

    final Gradient? bgGradient = isActive
        ? (dark
              ? AmanahColorTokens.btnCrispBlueDarkGradient
              : AmanahColorTokens.btnCrispBlueGradient)
        : null;

    final Color effectiveBorderColor = isActive
        ? (dark
              ? AmanahColorTokens.btnCrispBlueDarkBorder
              : AmanahColorTokens.btnCrispBlueBorder)
        : borderColor;

    final List<BoxShadow> shadows = isActive
        ? <BoxShadow>[
            if (dark)
              AmanahColorTokens.btnCrispBlueDarkShadow
            else
              AmanahColorTokens.btnCrispBlueShadow,
            BoxShadow(
              color: (dark
                      ? AmanahColorTokens.brandAccent
                      : AmanahColorTokens.brand)
                  .withValues(alpha: 0.30),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: AmanahColorTokens.pureBlack.withValues(
                alpha: dark ? 0.25 : 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? null : cardBg,
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: effectiveBorderColor, width: 1.2),
          boxShadow: shadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.22)
                    : (dark
                          ? AmanahColorTokens.brandAccent.withValues(alpha: 0.20)
                          : AmanahColorTokens.brandAccent.withValues(
                              alpha: 0.14,
                            )),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive
                    ? AmanahColorTokens.surfaceLight
                    : (dark
                          ? AmanahColorTokens.brandSoft
                          : AmanahColorTokens.brandAccent),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                color: isActive ? AmanahColorTokens.surfaceLight : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
