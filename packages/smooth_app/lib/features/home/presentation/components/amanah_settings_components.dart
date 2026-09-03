import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';

/// Section container with clean Android-style header and rounded divider card.
class AmanahSettingSection extends StatelessWidget {
  const AmanahSettingSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color cardBg = AmanahThemeTokens.elevatedSurface(context);
    final Color borderColor = AmanahThemeTokens.outline(context);
    final Color dividerColor = AmanahThemeTokens.outline(context);
    final Color titleColor = AmanahThemeTokens.textTertiary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontFamily: 'PlusJakartaSans',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.35 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < children.length; i++) ...<Widget>[
                  children[i],
                  if (i < children.length - 1)
                    Divider(height: 1, thickness: 1, color: dividerColor),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Standard label and value display row.
class AmanahSettingInfoRow extends StatelessWidget {
  const AmanahSettingInfoRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    super.key,
  });

  final String label;
  final String value;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = AmanahThemeTokens.textTertiary(context);
    final Color valueColor = isHighlighted
        ? AmanahThemeTokens.status(AmanahStatusTone.success).onSurface
        : AmanahThemeTokens.textPrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive editable row for settings with trailing chevron.
class AmanahSettingEditableRow extends StatelessWidget {
  const AmanahSettingEditableRow({
    required this.label,
    required this.value,
    required this.onEdit,
    this.helperText,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = AmanahThemeTokens.textTertiary(context);
    final Color valueColor = AmanahThemeTokens.textPrimary(context);
    final Color helperColor = AmanahThemeTokens.textTertiary(context);
    final Color chevronColor = AmanahThemeTokens.textTertiary(
      context,
    ).withValues(alpha: 0.50);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        color: labelColor,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: valueColor,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                    if (helperText != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        helperText!,
                        style: TextStyle(
                          color: helperColor,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 18, color: chevronColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigable setting row that opens a sub-screen with trailing chevron.
class AmanahSettingNavRow extends StatelessWidget {
  const AmanahSettingNavRow({
    required this.title,
    required this.onClick,
    this.category,
    this.subtitle,
    super.key,
  });

  final String title;
  final VoidCallback onClick;
  final String? category;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = AmanahThemeTokens.textPrimary(context);
    final Color categoryColor = AmanahThemeTokens.textTertiary(context);
    final Color subtitleColor = AmanahThemeTokens.textTertiary(context);
    final Color chevronColor = AmanahThemeTokens.textTertiary(
      context,
    ).withValues(alpha: 0.50);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (category != null) ...<Widget>[
                      Text(
                        category!,
                        style: TextStyle(
                          color: categoryColor,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        height: 1.3,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: subtitleColor,
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 18, color: chevronColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label and right-aligned value row.
class AmanahSettingHorizontalRow extends StatelessWidget {
  const AmanahSettingHorizontalRow({
    required this.label,
    required this.value,
    this.isBold = false,
    super.key,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = AmanahThemeTokens.textTertiary(context);
    final Color valueColor = AmanahThemeTokens.textPrimary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Native Android-style toggle switch row.
class AmanahSettingToggleRow extends StatelessWidget {
  const AmanahSettingToggleRow({
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.onToggle,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color titleColor = AmanahThemeTokens.textPrimary(context);
    final Color subtitleColor = AmanahThemeTokens.textTertiary(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AmanahToggleSwitch(active: checked, onToggle: onToggle, dark: dark),
        ],
      ),
    );
  }
}

/// Universal iOS/Android toggle switch with crisp brand color & clean grey inactive fill.
class AmanahToggleSwitch extends StatelessWidget {
  const AmanahToggleSwitch({
    required this.active,
    required this.onToggle,
    this.dark,
    super.key,
  });

  final bool active;
  final VoidCallback onToggle;
  final bool? dark;

  @override
  Widget build(BuildContext context) {
    final bool isDark = dark ?? Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF0D66E9)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.20)
                    : const Color(0xFFE5E5EA)),
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
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Setting action button row (e.g. Clear Cache, Export PDF).
class AmanahSettingActionRow extends StatelessWidget {
  const AmanahSettingActionRow({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
    this.disabled = false,
    this.isSuccess = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;
  final bool disabled;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color titleColor = AmanahThemeTokens.textPrimary(context);
    final Color subtitleColor = AmanahThemeTokens.textTertiary(context);

    Color btnBg;
    Color btnBorder;
    Color btnText;

    if (isSuccess) {
      btnBg = dark
          ? const Color(0xFF064E3B).withValues(alpha: 0.40)
          : const Color(0xFFECFDF5);
      btnBorder = dark
          ? const Color(0xFF10B981).withValues(alpha: 0.30)
          : const Color(0xFFA7F3D0);
      btnText = dark ? const Color(0xFF34D399) : const Color(0xFF047857);
    } else if (dark) {
      btnBg = Colors.white.withValues(alpha: 0.05);
      btnBorder = Colors.white.withValues(alpha: 0.10);
      btnText = const Color(0xFFE2E8F0);
    } else {
      btnBg = const Color(0xFFF8FAFC);
      btnBorder = const Color(0xFFE2E8F0);
      btnText = const Color(0xFF334155);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: disabled ? null : onAction,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: btnBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: btnBorder),
              ),
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: btnText,
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Native Android-style dialog for editing a single setting value.
class AmanahSettingEditDialog extends StatefulWidget {
  const AmanahSettingEditDialog({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.onSave,
    this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    super.key,
  });

  final String title;
  final String label;
  final String initialValue;
  final ValueChanged<String> onSave;
  final String? placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String label,
    required String initialValue,
    required ValueChanged<String> onSave,
    String? placeholder,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahSettingEditDialog(
        title: title,
        label: label,
        initialValue: initialValue,
        onSave: onSave,
        placeholder: placeholder,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  @override
  State<AmanahSettingEditDialog> createState() =>
      _AmanahSettingEditDialogState();
}

class _AmanahSettingEditDialogState extends State<AmanahSettingEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color dialogBg = dark ? const Color(0xFF111624) : Colors.white;
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color inputBg = dark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF8FAFC);
    final Color inputBorder = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: dialogBg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(
                color: textColor,
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                color: subtextColor,
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              autofocus: true,
              style: TextStyle(
                color: textColor,
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  color: subtextColor.withValues(alpha: 0.60),
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                ),
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0D66E9),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                AmanahButton.text(
                  text: 'Batal',
                  size: AmanahButtonSize.small,
                  customForegroundColor: subtextColor,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                AmanahButton.primary(
                  text: 'Simpan',
                  size: AmanahButtonSize.small,
                  onPressed: () {
                    widget.onSave(_controller.text);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
