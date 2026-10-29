import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/replacement_facets.dart';

/// Horizontal facet filter chips for replacement opportunities.
/// Allows filtering opportunities by staff who are on leave.
class AmanahReplacementStaffFacetChips extends StatelessWidget {
  const AmanahReplacementStaffFacetChips({
    required this.staffFacets,
    required this.totalOpenCount,
    required this.selectedStaffProfileId,
    required this.onStaffSelected,
    super.key,
  });

  final List<ReplacementStaffFacet> staffFacets;
  final int totalOpenCount;
  final String? selectedStaffProfileId;
  final ValueChanged<ReplacementStaffFacet?> onStaffSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final bool isAllSelected = selectedStaffProfileId == null;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: staffFacets.length + 1,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            // First Chip: 'Semua'
            return _buildChip(
              context: context,
              label: 'Semua',
              count: totalOpenCount,
              isSelected: isAllSelected,
              onTap: () => onStaffSelected(null),
              dark: dark,
            );
          }

          final ReplacementStaffFacet staff = staffFacets[index - 1];
          final bool isSelected = staff.staffProfileId == selectedStaffProfileId;

          return _buildChip(
            context: context,
            label: staff.fullName,
            count: staff.opportunityCount,
            isSelected: isSelected,
            onTap: () => onStaffSelected(staff),
            dark: dark,
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool dark,
  }) {
    final Color activeBg = dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand;
    final Color inactiveBg = dark ? AmanahColorTokens.surfaceDark : AmanahColorTokens.surfaceLight;
    final Color activeText = Colors.white;
    final Color inactiveText = AmanahThemeTokens.textPrimary(context);
    final Color borderColor = isSelected
        ? activeBg
        : (dark ? AmanahColorTokens.neutral700 : AmanahColorTokens.neutral200);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? activeText : inactiveText,
                ),
              ),
              if (count > 0) ...<Widget>[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : (dark ? AmanahColorTokens.neutral700 : AmanahColorTokens.neutral100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AmanahThemeTokens.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
