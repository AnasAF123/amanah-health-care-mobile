import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/domain/failures/permission_failure.dart';
import 'package:amanah_healthcare/generic_lib/design_constants.dart';

/// Modal bottom sheet presented when staff leave submission violates clinic policies.
///
/// Clean, minimal, human-readable exception modal with no decorative buzzwords.
class AmanahLeavePolicyExceptionModal extends StatelessWidget {
  const AmanahLeavePolicyExceptionModal({
    required this.failure,
    super.key,
  });

  final PermissionPolicyFailure failure;

  static Future<void> show({
    required BuildContext context,
    required PermissionPolicyFailure failure,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => AmanahLeavePolicyExceptionModal(failure: failure),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Map<String, dynamic>? details = failure.details;

    return AmanahBottomSheetScaffold(
      title: failure.title,
      hugContent: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.warning.withValues(alpha: 0.12)
                  : AmanahColorTokens.warningLight.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AmanahColorTokens.warning.withValues(alpha: dark ? 0.35 : 0.45),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.info_outline_rounded,
                  color: AmanahColorTokens.warning,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    failure.message,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: dark
                          ? AmanahThemeTokens.textPrimary(context)
                          : AmanahColorTokens.neutral800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Structured Policy Facts Card (if structured details are present)
          if (details != null && details.isNotEmpty) ...<Widget>[
            const SizedBox(height: MEDIUM_SPACE),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahThemeTokens.surfaceSecondary(context)
                    : AmanahColorTokens.neutral50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AmanahThemeTokens.outline(context),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildFactRows(context, details),
              ),
            ),
          ],
        ],
      ),
      footer: SizedBox(
        width: double.infinity,
        child: AmanahButton(
          text: 'Saya Mengerti',
          variant: AmanahButtonVariant.primary,
          size: AmanahButtonSize.medium,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  List<Widget> _buildFactRows(BuildContext context, Map<String, dynamic> details) {
    final List<Widget> rows = <Widget>[];

    void addFact(String label, String value) {
      if (rows.isNotEmpty) {
        rows.add(
          Divider(
            height: 14,
            thickness: 0.5,
            color: AmanahThemeTokens.outline(context),
          ),
        );
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AmanahThemeTokens.textSecondary(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AmanahThemeTokens.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (details.containsKey('limit') && details.containsKey('used')) {
      final String unit = details['unit']?.toString() ?? 'kali';
      addFact('Batas Kuota', '${details['limit']} $unit/bulan');
      addFact('Terpakai', '${details['used']} $unit');
    }

    if (details.containsKey('noticeDaysRequired')) {
      addFact('Ketentuan', 'Minimal H-${details['noticeDaysRequired']} hari');
      if (details.containsKey('minAllowedDate')) {
        addFact('Paling Cepat', details['minAllowedDate'].toString());
      }
    }

    if (details.containsKey('conflictingRange')) {
      addFact('Jadwal Bentrok', details['conflictingRange'].toString());
    }

    if (details.containsKey('activePeriodRange')) {
      addFact('Periode Izin Aktif', details['activePeriodRange'].toString());
    }

    return rows;
  }
}
