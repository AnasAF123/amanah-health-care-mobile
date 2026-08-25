import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/domain/amanah_home_data.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class AmanahQuickAccessSection extends StatelessWidget {
  const AmanahQuickAccessSection({
    required this.actions,
    required this.onActionTap,
    super.key,
  });

  final List<AmanahQuickAction> actions;
  final ValueChanged<AmanahQuickAction> onActionTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(VERY_SMALL_SPACE, 0, VERY_SMALL_SPACE, 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: actions
            .map(
              (AmanahQuickAction action) => AmanahQuickActionButton(
                action: action,
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
    super.key,
  });

  final AmanahQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color foreground = dark
        ? theme.colorScheme.primary
        : const Color(0xFF0A44FF);
    final Color labelColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Semantics(
      button: true,
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
                      color: dark
                          ? const Color(0xE6171717)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.15)
                            : const Color(0xFFF8FAFC),
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
