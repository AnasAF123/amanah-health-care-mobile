import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

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

    // Vector color matches the active color used in the App Bar
    final Color activeColor = dark
        ? AmanahColorTokens.tabActiveDark
        : AmanahColorTokens.tabActiveLight;
    final Color inactiveColor = dark
        ? AmanahColorTokens.tabInactiveDark
        : AmanahColorTokens.tabInactiveLight;
    final Color foreground = isActive ? activeColor : inactiveColor;

    final Color labelColor = AmanahThemeTokens.textSecondary(context);
    final Color buttonBg = AmanahThemeTokens.surface(context);
    final Color buttonBorder = AmanahThemeTokens.outline(context);

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
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: buttonBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: buttonBorder,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: dark ? 0.36 : 0.06,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: -6,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Icon(
                        amanahQuickActionIconData(action.icon),
                        color: foreground,
                        size: 25,
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
