import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

String _quickActionImageAsset(AmanahQuickActionIcon icon, {required bool dark}) {
  final String suffix = dark ? '' : '-light';
  return switch (icon) {
    AmanahQuickActionIcon.history =>
      'assets/amanah/images/quick_access/quick-access-history$suffix.png',
    AmanahQuickActionIcon.presence =>
      'assets/amanah/images/quick_access/quick-access-history$suffix.png',
    AmanahQuickActionIcon.schedule =>
      'assets/amanah/images/quick_access/quick-access-schedule$suffix.png',
    AmanahQuickActionIcon.search =>
      'assets/amanah/images/quick_access/quick-access-queue$suffix.png',
    AmanahQuickActionIcon.idCard =>
      'assets/amanah/images/quick_access/quick-access-id-card$suffix.png',
  };
}

class AmanahQuickAccessSection extends StatelessWidget {
  const AmanahQuickAccessSection({
    required this.actions,
    required this.onActionTap,
    this.activeActionId,
    super.key,
  });

  final List<AmanahQuickAction> actions;
  final ValueChanged<AmanahQuickAction> onActionTap;
  final String? activeActionId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VERY_SMALL_SPACE),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions
            .map(
              (AmanahQuickAction action) => AmanahQuickActionButton(
                action: action,
                isActive: activeActionId == null || activeActionId == action.id,
                onTap: () => onActionTap(action),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class AmanahQuickActionButton extends StatelessWidget {
  const AmanahQuickActionButton({
    required this.action,
    required this.onTap,
    this.isActive = true,
    super.key,
  });

  final AmanahQuickAction action;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color labelColor = AmanahThemeTokens.textSecondary(context);
    final String iconAsset = _quickActionImageAsset(action.icon, dark: dark);

    return Semantics(
      button: true,
      selected: isActive,
      label: action.label,
      child: SizedBox(
        width: 72,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: VERY_SMALL_SPACE),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Opacity(
                        opacity: isActive ? 1.0 : 0.42,
                        child: Image.asset(
                          iconAsset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SMALL_SPACE),
                  Text(
                    action.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: labelColor,
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
