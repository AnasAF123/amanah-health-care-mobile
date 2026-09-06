import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/data/amanah_presence_store.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_drawers.dart';

class AmanahPresenceHistoryScreen extends StatefulWidget {
  const AmanahPresenceHistoryScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => const AmanahPresenceHistoryScreen(),
    );
  }

  @override
  State<AmanahPresenceHistoryScreen> createState() =>
      _AmanahPresenceHistoryScreenState();
}

class _AmanahPresenceHistoryScreenState
    extends State<AmanahPresenceHistoryScreen> {
  AttendanceStatus? _statusFilter;
  String _unitFilter = 'all';
  int? _selectedDayFilter;
  bool _isDownloading = false;

  bool get _hasActiveFilters =>
      _statusFilter != null ||
      _unitFilter != 'all' ||
      _selectedDayFilter != null;

  List<AttendanceRecord> get _filteredRecords {
    return kAttendanceRecords
        .where((AttendanceRecord rec) {
          if (_statusFilter != null && rec.status != _statusFilter) {
            return false;
          }
          if (_unitFilter != 'all' &&
              !rec.location.toLowerCase().contains(_unitFilter.toLowerCase())) {
            return false;
          }
          if (_selectedDayFilter != null &&
              rec.dayNumber != _selectedDayFilter) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  void _resetFilters() {
    setState(() {
      _statusFilter = null;
      _unitFilter = 'all';
      _selectedDayFilter = null;
    });
  }

  Future<void> _openFilterDrawer() async {
    final Map<String, dynamic>? result = await AmanahPresenceFilterDrawer.show(
      context,
      currentStatus: _statusFilter,
      currentUnit: _unitFilter,
      currentDay: _selectedDayFilter,
    );

    if (result != null && mounted) {
      setState(() {
        _statusFilter = result['status'] as AttendanceStatus?;
        _unitFilter = (result['unit'] as String?) ?? 'all';
        _selectedDayFilter = result['day'] as int?;
      });
    }
  }

  void _handleDownloadPdf() {
    if (_isDownloading) {
      return;
    }
    setState(() => _isDownloading = true);
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Laporan presensi berhasil diunduh (PDF)',
              style: TextStyle(fontSize: 12),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor =
        dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.canvasLight;
    final Color textColor =
        dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900;
    final Color subtextColor =
        dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    final List<AttendanceRecord> records = _filteredRecords;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // 1. Master Screen Header
            AmanahScreenHeader(
              title: 'Riwayat Presensi',
              onBack: () => Navigator.of(context).pop(),
            ),

            // 2. Main Content Viewport
            Expanded(
              child: records.isEmpty
                  ? _buildEmptyState(dark, textColor, subtextColor)
                  : _buildTimelineViewport(
                      records,
                      dark,
                      textColor,
                      subtextColor,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineViewport(
    List<AttendanceRecord> records,
    bool dark,
    Color textColor,
    Color subtextColor,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
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
                    onTap: _openFilterDrawer,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _hasActiveFilters
                            ? (dark
                                  ? AmanahColorTokens.tabActiveDark.withValues(
                                      alpha: 0.16,
                                    )
                                  : AmanahColorTokens.brandSurface)
                            : (dark
                                  ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                                  : AmanahColorTokens.surfaceLight),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasActiveFilters
                              ? (dark
                                    ? AmanahColorTokens.tabActiveDark
                                          .withValues(alpha: 0.50)
                                    : AmanahColorTokens.brandAccent)
                              : (dark
                                    ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                                    : AmanahColorTokens.neutral200),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: _hasActiveFilters
                                ? (dark
                                      ? AmanahColorTokens.tabActiveDark
                                      : AmanahColorTokens.brandPrimary)
                                : subtextColor,
                          ),
                          if (_hasActiveFilters)
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
                    onTap: _handleDownloadPdf,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: dark
                            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                            : AmanahColorTokens.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dark
                              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                              : AmanahColorTokens.neutral200,
                        ),
                      ),
                      child: _isDownloading
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
          if (_hasActiveFilters) ...<Widget>[
            Container(
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
                          if (_statusFilter != null) ...<Widget>[
                            _buildFilterChip(
                              _statusFilter!.name.toUpperCase(),
                              dark,
                            ),
                            const SizedBox(width: 4),
                          ],
                          if (_unitFilter != 'all') ...<Widget>[
                            _buildFilterChip(_unitFilter, dark),
                            const SizedBox(width: 4),
                          ],
                          if (_selectedDayFilter != null) ...<Widget>[
                            _buildFilterChip(
                              'Tgl $_selectedDayFilter Ags',
                              dark,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _resetFilters,
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
                  ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
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

          // Date Ticks: 01 Ags, 08 Ags, 15 Ags, 22 Ags, 31 Ags
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _DateTickText('01 Ags'),
              _DateTickText('08 Ags'),
              _DateTickText('15 Ags'),
              _DateTickText('22 Ags'),
              _DateTickText('31 Ags'),
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
                  _LegendIndicator(color: AmanahColorTokens.success, label: 'Hadir'),
                  _LegendIndicator(color: AmanahColorTokens.amberLight, label: 'Telat'),
                  _LegendIndicator(color: AmanahColorTokens.danger, label: 'Missed'),
                  _LegendIndicator(color: AmanahColorTokens.violet, label: 'Cuti'),
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
              return _buildTimelineItem(
                item,
                isLast,
                dark,
                textColor,
                subtextColor,
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

  Widget _buildTimelineItem(
    AttendanceRecord item,
    bool isLast,
    bool dark,
    Color textColor,
    Color subtextColor,
  ) {
    Color iconBorderColor = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
        : AmanahColorTokens.neutral300;
    Color iconBgColor = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
        : AmanahColorTokens.canvasLight;
    Color iconColor = subtextColor;
    Color titleColor = textColor;
    IconData iconData = Icons.login_rounded;
    Color lineColor = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.15)
        : AmanahColorTokens.neutral300;

    if (item.isLatest) {
      switch (item.status) {
        case AttendanceStatus.hadir:
          iconBorderColor = AmanahColorTokens.successDark;
          iconBgColor = AmanahColorTokens.successSurface;
          iconColor = AmanahColorTokens.successDark;
          titleColor = AmanahColorTokens.successDark;
          iconData = Icons.login_rounded;
          lineColor = AmanahColorTokens.success;
        case AttendanceStatus.telat:
          iconBorderColor = AmanahColorTokens.warningDark;
          iconBgColor = AmanahColorTokens.warningSurface;
          iconColor = AmanahColorTokens.warningDark;
          titleColor = AmanahColorTokens.warningDark;
          iconData = Icons.schedule_rounded;
          lineColor = AmanahColorTokens.amberLight;
        case AttendanceStatus.missed:
          iconBorderColor = AmanahColorTokens.dangerDark;
          iconBgColor = AmanahColorTokens.dangerSurface;
          iconColor = AmanahColorTokens.dangerDark;
          titleColor = AmanahColorTokens.dangerDark;
          iconData = Icons.close_rounded;
          lineColor = AmanahColorTokens.danger;
        case AttendanceStatus.cuti:
          iconBorderColor = AmanahColorTokens.violetDark;
          iconBgColor = AmanahColorTokens.violetSurface;
          iconColor = AmanahColorTokens.violetDark;
          titleColor = AmanahColorTokens.violetDark;
          iconData = Icons.event_note_rounded;
          lineColor = AmanahColorTokens.violet;
      }
    } else {
      switch (item.status) {
        case AttendanceStatus.hadir:
          iconData = Icons.login_rounded;
        case AttendanceStatus.telat:
          iconData = Icons.schedule_rounded;
        case AttendanceStatus.missed:
          iconData = Icons.close_rounded;
        case AttendanceStatus.cuti:
          iconData = Icons.event_note_rounded;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Left timeline node & connecting line
        Column(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                border: Border.all(color: iconBorderColor, width: 2),
              ),
              child: Icon(iconData, size: 14, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: item.isLatest ? 2 : 1.5,
                height: 48,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: lineColor,
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Date Column (85px)
        SizedBox(
          width: 85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 4),
              Text(
                item.date,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.time,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),

        // Right details Column (Text aligned right)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  item.title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: item.isLatest
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: titleColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.location,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: subtextColor,
                    height: 1.2,
                  ),
                ),
                if (item.status == AttendanceStatus.cuti) ...<Widget>[
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () => AmanahPresenceLeaveReasonDrawer.show(
                      context,
                      record: item,
                    ),
                    child: const Text(
                      'Lihat Alasan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AmanahColorTokens.violetDark,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool dark, Color textColor, Color subtextColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: AmanahEmptyState.box(
        title: 'Tidak Ada Data Presensi',
        message:
            'Tidak ditemukan riwayat presensi yang sesuai dengan filter tanggal atau status yang diterapkan.',
        actionText: 'Ubah Filter',
        actionLeadingIcon: Icons.tune_rounded,
        onAction: _openFilterDrawer,
        secondaryActionText: 'Reset Filter',
        secondaryActionLeadingIcon: Icons.restart_alt_rounded,
        onSecondaryAction: _resetFilters,
      ),
    );
  }
}

class _DateTickText extends StatelessWidget {
  const _DateTickText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AmanahColorTokens.neutral400,
      ),
    );
  }
}

class _LegendIndicator extends StatelessWidget {
  const _LegendIndicator({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AmanahColorTokens.neutral500,
          ),
        ),
      ],
    );
  }
}
