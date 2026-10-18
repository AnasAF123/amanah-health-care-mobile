import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';

class PresenceFilterChipsBanner extends StatelessWidget {
  const PresenceFilterChipsBanner({
    required this.statusFilter,
    required this.unitFilter,
    required this.selectedDayFilter,
    required this.onReset,
    required this.dark,
    required this.subtextColor,
    super.key,
  });

  final AttendanceStatus? statusFilter;
  final String unitFilter;
  final int? selectedDayFilter;
  final VoidCallback onReset;
  final bool dark;
  final Color subtextColor;

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.16)
            : AmanahColorTokens.neutral200,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: dark
              ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.34)
              : AmanahColorTokens.neutral200,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: dark
              ? AmanahColorTokens.tabActiveDark
              : AmanahColorTokens.neutral900,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
            : AmanahColorTokens.canvasLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
              : AmanahColorTokens.neutral200,
        ),
      ),
      child: Row(
        children: <Widget>[
          Text(
            'Filter: ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: subtextColor,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: <Widget>[
                  if (statusFilter != null) ...<Widget>[
                    _buildFilterChip(statusFilter!.name.toUpperCase()),
                    const SizedBox(width: 4),
                  ],
                  if (unitFilter != 'all') ...<Widget>[
                    _buildFilterChip(unitFilter),
                    const SizedBox(width: 4),
                  ],
                  if (selectedDayFilter != null) ...<Widget>[
                    _buildFilterChip('Tgl $selectedDayFilter'),
                  ],
                ],
              ),
            ),
          ),
          InkWell(
            onTap: onReset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Reset',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: dark
                      ? AmanahColorTokens.tabActiveDark
                      : AmanahColorTokens.brandAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
