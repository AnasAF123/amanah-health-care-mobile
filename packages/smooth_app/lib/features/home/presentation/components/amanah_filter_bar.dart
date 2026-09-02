import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahFilterBarItem<T> {
  const AmanahFilterBarItem({
    required this.value,
    required this.label,
    this.badgeCount = 0,
  });

  final T value;
  final String label;
  final int badgeCount;
}

class AmanahFilterBar<T> extends StatelessWidget {
  const AmanahFilterBar({
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    super.key,
    this.horizontalPadding = 16,
  });

  final List<AmanahFilterBarItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AmanahComponentSize.filterBar,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 6,
        ),
        child: Row(
          children: <Widget>[
            for (int index = 0; index < items.length; index++) ...<Widget>[
              if (index > 0) const SizedBox(width: AmanahSpacing.sm),
              _AmanahFilterChip<T>(
                item: items[index],
                selected: items[index].value == selectedValue,
                onSelected: onSelected,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AmanahFilterChip<T> extends StatelessWidget {
  const _AmanahFilterChip({
    required this.item,
    required this.selected,
    required this.onSelected,
  });

  final AmanahFilterBarItem<T> item;
  final bool selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Color backgroundColor;
    final Color foregroundColor;
    final Color badgeBackgroundColor;
    final Color badgeForegroundColor;

    if (selected) {
      backgroundColor = AmanahColorTokens.brand;
      foregroundColor = Colors.white;
      badgeBackgroundColor = Colors.white.withValues(alpha: 0.24);
      badgeForegroundColor = Colors.white;
    } else {
      backgroundColor = dark
          ? Colors.white.withValues(alpha: 0.05)
          : AmanahColorTokens.neutral100;
      foregroundColor = dark
          ? AmanahColorTokens.neutral300
          : AmanahColorTokens.neutral600;
      badgeBackgroundColor = dark
          ? Colors.white.withValues(alpha: 0.10)
          : AmanahColorTokens.neutral200;
      badgeForegroundColor = dark
          ? AmanahColorTokens.neutral300
          : AmanahColorTokens.neutral700;
    }

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(item.value),
          borderRadius: BorderRadius.circular(AmanahRadius.pill),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(
              minHeight: 36,
              minWidth: AmanahComponentSize.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AmanahRadius.pill),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                    letterSpacing: 0,
                  ),
                ),
                if (item.badgeCount > 0) ...<Widget>[
                  const SizedBox(width: AmanahSpacing.sm),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: badgeBackgroundColor,
                      borderRadius: BorderRadius.circular(AmanahRadius.pill),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: badgeForegroundColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
