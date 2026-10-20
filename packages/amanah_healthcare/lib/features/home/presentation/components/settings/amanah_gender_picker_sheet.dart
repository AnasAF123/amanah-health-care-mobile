import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/constants/gender_constants.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Clean bottom sheet to pick gender using canonical GenderConstants.
class AmanahGenderPickerSheet extends StatelessWidget {
  const AmanahGenderPickerSheet({
    required this.selectedGender,
    super.key,
  });

  final String? selectedGender;

  static Future<String?> show({
    required BuildContext context,
    String? selectedGender,
  }) {
    return showAmanahBottomSheet<String>(
      context: context,
      isDismissible: true,
      builder: (BuildContext ctx) => AmanahGenderPickerSheet(
        selectedGender: selectedGender,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> options = <Map<String, String>>[
      <String, String>{
        'value': GenderConstants.male,
        'label': GenderConstants.maleLabel,
      },
      <String, String>{
        'value': GenderConstants.female,
        'label': GenderConstants.femaleLabel,
      },
    ];

    final Color dividerColor = AmanahThemeTokens.outline(context);
    final Color selectedBg = AmanahColorTokens.brand.withValues(alpha: 0.08);

    return AmanahBottomSheetScaffold(
      title: 'Pilih Jenis Kelamin',
      hugContent: true,
      disableInternalScroll: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < options.length; i++) ...<Widget>[
            Builder(
              builder: (BuildContext ctx) {
                final Map<String, String> opt = options[i];
                final String val = opt['value']!;
                final String label = opt['label']!;
                final bool isSelected = selectedGender?.toLowerCase() == val;

                return Material(
                  color: isSelected ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(val),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            val == GenderConstants.male
                                ? Icons.male_rounded
                                : Icons.female_rounded,
                            size: 20,
                            color: isSelected
                                ? AmanahColorTokens.brand
                                : AmanahThemeTokens.textSecondary(context),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AmanahColorTokens.brand
                                    : AmanahThemeTokens.textPrimary(context),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: AmanahColorTokens.brand,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (i < options.length - 1)
              Divider(height: 1, thickness: 1, color: dividerColor),
          ],
        ],
      ),
    );
  }
}
