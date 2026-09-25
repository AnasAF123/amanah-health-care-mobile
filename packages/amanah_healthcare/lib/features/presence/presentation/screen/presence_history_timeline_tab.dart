import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_drawers.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/presence_timeline_tile.dart';

/// Tab component displaying attendance records timeline and metrics.
class PresenceHistoryTimelineTab extends StatelessWidget {
  const PresenceHistoryTimelineTab({
    required this.records,
    required this.hasActiveFilters,
    required this.statusFilter,
    required this.unitFilter,
    required this.selectedDayFilter,
    required this.isDownloading,
    required this.onOpenFilter,
    required this.onResetFilter,
    required this.onDownloadPdf,
    super.key,
  });

  final List<AttendanceRecord> records;
  final bool hasActiveFilters;
  final AttendanceStatus? statusFilter;
  final String unitFilter;
  final int? selectedDayFilter;
  final bool isDownloading;
  final VoidCallback onOpenFilter;
  final VoidCallback onResetFilter;
  final VoidCallback onDownloadPdf;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor =
        dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.neutral900;
    final Color subtextColor =
        dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    if (records.isEmpty) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: AmanahEmptyState.box(
          title: 'Tidak Ada Data Presensi',
          message:
              'Tidak ditemukan riwayat presensi yang sesuai dengan filter tanggal atau status yang diterapkan.',
          actionText: 'Ubah Filter',
          actionLeadingIcon: Icons.tune_rounded,
          onAction: onOpenFilter,
          secondaryActionText: 'Reset Filter',
          secondaryActionLeadingIcon: Icons.restart_alt_rounded,
          onSecondaryAction: onResetFilter,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row: Timeline Title + Info Button + Filter & Download Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Timeline',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => AmanahPresenceInfoDrawer.show(context),
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: dark
                            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                            : AmanahColorTokens.canvasLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: subtextColor,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  // Filter Action Button
                  InkWell(
                    onTap: onOpenFilter,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: hasActiveFilters
                            ? (dark
                                  ? AmanahColorTokens.tabActiveDark.withValues(
                                      alpha: 0.16,
                                    )
                                  : AmanahColorTokens.brandSurface)
                            : (dark
                                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                                  : AmanahColorTokens.surfaceLight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasActiveFilters
                              ? (dark
                                    ? AmanahColorTokens.tabActiveDark
                                          .withValues(alpha: 0.50)
                                    : AmanahColorTokens.brandAccent)
                              : (dark
                                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                                    : AmanahColorTokens.neutral200),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: hasActiveFilters
                                ? (dark
                                      ? AmanahColorTokens.tabActiveDark
                                      : AmanahColorTokens.brandPrimary)
                                : subtextColor,
                          ),
                          if (hasActiveFilters)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: dark
                                      ? AmanahColorTokens.tabActiveDark
                                      : AmanahColorTokens.brandAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Download PDF Action Button
                  InkWell(
                    onTap: onDownloadPdf,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: dark
                            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                            : AmanahColorTokens.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dark
                              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                              : AmanahColorTokens.neutral200,
                        ),
                      ),
                      child: isDownloading
                          ? const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AmanahColorTokens.brandPrimary,
                                  ),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.download_rounded,
                              size: 16,
                              color: subtextColor,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active Filter Chips Banner (If filters applied)
          if (hasActiveFilters) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                    : AmanahColorTokens.canvasLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
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
                            _buildFilterChip(
                              statusFilter!.name.toUpperCase(),
                              dark,
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (unitFilter != 'all') ...<Widget>[
                            _buildFilterChip(unitFilter, dark),
                            const SizedBox(width: 4),
                          ],
                          if (selectedDayFilter != null) ...<Widget>[
                            _buildFilterChip(
                              'Tgl $selectedDayFilter Ags',
                              dark,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onResetFilter,
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
            ),
            const SizedBox(height: 14),
          ],

          // Distribution Section (Stacked Horizontal Pill Bar + Date Ticks)
          Container(
            width: double.infinity,
            height: 10,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                  : AmanahColorTokens.canvasLight,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.success,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.amberLight,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.danger,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AmanahColorTokens.violet,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Date Ticks
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              PresenceDateTickText('01 Ags'),
              PresenceDateTickText('08 Ags'),
              PresenceDateTickText('15 Ags'),
              PresenceDateTickText('22 Ags'),
              PresenceDateTickText('31 Ags'),
            ],
          ),
          const SizedBox(height: 16),

          // Metrics & Legends Section
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 12,
            runSpacing: 10,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Total jam kerja · Bulan ini',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        '168 hr',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(21 hari)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Wrap(
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  PresenceLegendIndicator(
                    color: AmanahColorTokens.success,
                    label: 'Hadir',
                  ),
                  PresenceLegendIndicator(
                    color: AmanahColorTokens.amberLight,
                    label: 'Telat',
                  ),
                  PresenceLegendIndicator(
                    color: AmanahColorTokens.danger,
                    label: 'Missed',
                  ),
                  PresenceLegendIndicator(
                    color: AmanahColorTokens.violet,
                    label: 'Cuti',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Attendance Records Vertical Timeline List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: records.length,
            itemBuilder: (BuildContext context, int index) {
              final AttendanceRecord item = records[index];
              final bool isLast = index == records.length - 1;
              return PresenceTimelineTile(
                item: item,
                isLast: isLast,
                dark: dark,
                textColor: textColor,
                subtextColor: subtextColor,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool dark) {
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
}
