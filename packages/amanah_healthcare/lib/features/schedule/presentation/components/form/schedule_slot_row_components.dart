import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class SlotFieldColumn extends StatelessWidget {
  const SlotFieldColumn({
    required this.label,
    required this.value,
    required this.dark,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: dark
                ? AmanahColorTokens.neutral400
                : AmanahColorTokens.neutral500,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        MiniSlotButton(value: value, dark: dark, onTap: onTap),
      ],
    );
  }
}

class SlotLabel extends StatelessWidget {
  const SlotLabel({
    required this.text,
    required this.dark,
    super.key,
  });

  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: text == 'From' ? 34 : 20,
      child: Text(
        text,
        style: TextStyle(
          color: dark
              ? AmanahColorTokens.neutral400
              : AmanahColorTokens.neutral500,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class MiniSlotButton extends StatelessWidget {
  const MiniSlotButton({
    required this.value,
    required this.dark,
    this.onTap,
    super.key,
  });

  final String value;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isPlaceholder = value.startsWith('Pilih ') || value == '-';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
              : AmanahColorTokens.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.15)
                : AmanahColorTokens.neutral200,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPlaceholder
                      ? (dark
                          ? AmanahColorTokens.neutral500
                          : AmanahColorTokens.neutral400)
                      : (dark
                          ? AmanahColorTokens.pureWhite
                          : AmanahColorTokens.neutral900),
                  fontSize: 12,
                  fontWeight: isPlaceholder ? FontWeight.w500 : FontWeight.w700,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 15,
                color: AmanahColorTokens.neutral400,
              ),
          ],
        ),
      ),
    );
  }
}

class ScheduleToggleSwitch extends StatelessWidget {
  const ScheduleToggleSwitch({
    required this.active,
    required this.dark,
    this.disabled = false,
    super.key,
  });

  final bool active;
  final bool dark;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 44,
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: disabled
            ? (dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                : AmanahColorTokens.neutral300)
            : active
            ? (dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand)
            : (dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.20)
                : AmanahColorTokens.neutral200),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: disabled
                ? (dark
                    ? AmanahColorTokens.neutral600
                    : AmanahColorTokens.neutral100)
                : AmanahColorTokens.surfaceLight,
            shape: BoxShape.circle,
            boxShadow: disabled
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: AmanahColorTokens.pureBlack.withValues(alpha: 0.20),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

class AnimatedSlotEntry extends StatelessWidget {
  const AnimatedSlotEntry({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: Transform.scale(
              scale: 0.98 + (value * 0.02),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
