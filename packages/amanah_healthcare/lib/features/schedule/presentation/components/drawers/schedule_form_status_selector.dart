import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/schedule_shift_constants.dart';

class ScheduleFormStatusSelector extends StatelessWidget {
  const ScheduleFormStatusSelector({
    required this.status,
    required this.options,
    required this.dark,
    required this.onChanged,
    super.key,
  });

  final String status;
  final List<String> options;
  final bool dark;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Status Praktik',
          style: TextStyle(
            color: dark
                ? AmanahColorTokens.neutral200
                : AmanahColorTokens.neutral700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                : AmanahColorTokens.surfaceSecondaryLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                  : AmanahColorTokens.neutral200,
            ),
          ),
          child: Row(
            children: options.map((String label) {
              final bool active = status == label;
              Color activeBg = AmanahColorTokens.success;
              Color dotColor = AmanahColorTokens.emeraldLight;
              if (label == ScheduleFormConstants.statusTutup ||
                  label == ScheduleFormConstants.statusCuti) {
                activeBg = AmanahColorTokens.danger;
                dotColor = AmanahColorTokens.roseLight;
              }
              final Color selectedBg =
                  dark ? AmanahColorTokens.tabActiveDark : activeBg;
              final Color selectedText = dark
                  ? AmanahColorTokens.canvasDark
                  : AmanahColorTokens.surfaceLight;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? selectedBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: active
                          ? <BoxShadow>[
                              BoxShadow(
                                color: selectedBg.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: active ? selectedText : dotColor,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(width: 6, height: 6),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            color: active
                                ? selectedText
                                : (dark
                                    ? AmanahColorTokens.neutral400
                                    : AmanahColorTokens.neutral600),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
