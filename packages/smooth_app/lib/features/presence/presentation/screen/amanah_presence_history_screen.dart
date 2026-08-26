import 'package:flutter/material.dart';
import 'package:smooth_app/features/presence/data/amanah_presence_store.dart';
import 'package:smooth_app/features/presence/domain/amanah_presence_model.dart';
import 'package:smooth_app/features/presence/presentation/components/amanah_presence_drawers.dart';

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
      _statusFilter != null || _unitFilter != 'all' || _selectedDayFilter != null;

  List<AttendanceRecord> get _filteredRecords {
    return kAttendanceRecords.where((AttendanceRecord rec) {
      if (_statusFilter != null && rec.status != _statusFilter) {
        return false;
      }
      if (_unitFilter != 'all' &&
          !rec.location.toLowerCase().contains(_unitFilter.toLowerCase())) {
        return false;
      }
      if (_selectedDayFilter != null && rec.dayNumber != _selectedDayFilter) {
        return false;
      }
      return true;
    }).toList(growable: false);
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
              style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12),
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
        dark ? const Color(0xFF0A0E1A) : const Color(0xFFF8FAFF);
    final Color textColor =
        dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor =
        dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final List<AttendanceRecord> records = _filteredRecords;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // 1. Master Screen Header
            _buildScreenHeader(dark, textColor, subtextColor),

            // 2. Main Content Viewport
            Expanded(
              child: records.isEmpty
                  ? _buildEmptyState(dark, textColor, subtextColor)
                  : _buildTimelineViewport(records, dark, textColor, subtextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenHeader(bool dark, Color textColor, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: dark
            ? const Color(0xFF0A0E1A).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Back Button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            style: IconButton.styleFrom(
              backgroundColor: dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF8FAFC),
              foregroundColor: textColor,
              shape: const CircleBorder(),
            ),
          ),

          // Title
          Text(
            'Riwayat Presensi',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),

          // Spacer for balance
          const SizedBox(width: 36, height: 36),
        ],
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
                      fontFamily: 'PlusJakartaSans',
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
                            ? Colors.white.withValues(alpha: 0.10)
                            : const Color(0xFFF1F5F9),
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
                                ? const Color(0x3322D3EE)
                                : const Color(0xFFECFEFF))
                            : (dark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasActiveFilters
                              ? const Color(0xFF06B6D4)
                              : (dark
                                  ? Colors.white.withValues(alpha: 0.10)
                                  : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: _hasActiveFilters
                                ? const Color(0xFF0891B2)
                                : subtextColor,
                          ),
                          if (_hasActiveFilters)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF06B6D4),
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
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : const Color(0xFFE2E8F0),
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
                                    Color(0xFF0A44FF),
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
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    'Filter: ',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0891B2),
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
                  ? Colors.white.withValues(alpha: 0.10)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: 15,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
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
                      fontFamily: 'PlusJakartaSans',
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
                          fontFamily: 'PlusJakartaSans',
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
                          fontFamily: 'PlusJakartaSans',
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
                  _LegendIndicator(
                    color: Color(0xFF10B981),
                    label: 'Hadir',
                  ),
                  _LegendIndicator(
                    color: Color(0xFFFBBF24),
                    label: 'Telat',
                  ),
                  _LegendIndicator(
                    color: Color(0xFFF43F5E),
                    label: 'Missed',
                  ),
                  _LegendIndicator(
                    color: Color(0xFF6366F1),
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
              return _buildTimelineItem(item, isLast, dark, textColor, subtextColor);
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
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: dark ? Colors.white : const Color(0xFF0F172A),
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
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFCBD5E1);
    Color iconBgColor =
        dark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC);
    Color iconColor = subtextColor;
    Color titleColor = textColor;
    IconData iconData = Icons.login_rounded;
    Color lineColor = dark
        ? Colors.white.withValues(alpha: 0.15)
        : const Color(0xFFCBD5E1);

    if (item.isLatest) {
      switch (item.status) {
        case AttendanceStatus.hadir:
          iconBorderColor = const Color(0xFF059669);
          iconBgColor = const Color(0xFFECFDF5);
          iconColor = const Color(0xFF059669);
          titleColor = const Color(0xFF059669);
          iconData = Icons.login_rounded;
          lineColor = const Color(0xFF10B981);
        case AttendanceStatus.telat:
          iconBorderColor = const Color(0xFFD97706);
          iconBgColor = const Color(0xFFFFFBEB);
          iconColor = const Color(0xFFD97706);
          titleColor = const Color(0xFFD97706);
          iconData = Icons.schedule_rounded;
          lineColor = const Color(0xFFFBBF24);
        case AttendanceStatus.missed:
          iconBorderColor = const Color(0xFFE11D48);
          iconBgColor = const Color(0xFFFFF1F2);
          iconColor = const Color(0xFFE11D48);
          titleColor = const Color(0xFFE11D48);
          iconData = Icons.close_rounded;
          lineColor = const Color(0xFFF43F5E);
        case AttendanceStatus.cuti:
          iconBorderColor = const Color(0xFF4F46E5);
          iconBgColor = const Color(0xFFEEF2FF);
          iconColor = const Color(0xFF4F46E5);
          titleColor = const Color(0xFF4F46E5);
          iconData = Icons.event_note_rounded;
          lineColor = const Color(0xFF6366F1);
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
                  fontFamily: 'PlusJakartaSans',
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
                  fontFamily: 'PlusJakartaSans',
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
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight:
                        item.isLatest ? FontWeight.w700 : FontWeight.w600,
                    color: titleColor,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.location,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
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
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4F46E5),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Icon(Icons.tune_rounded, size: 28, color: subtextColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada data presensi',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tidak ditemukan riwayat presensi yang sesuai dengan filter yang diterapkan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: subtextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _openFilterDrawer,
                  icon: const Icon(Icons.tune_rounded, size: 14),
                  label: const Text('Ubah Filter'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.15)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.restart_alt_rounded, size: 14),
                  label: const Text('Reset Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        dark ? Colors.white : const Color(0xFF0F172A),
                    foregroundColor:
                        dark ? const Color(0xFF020617) : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF94A3B8),
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
            fontFamily: 'PlusJakartaSans',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
