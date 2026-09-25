import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/data/amanah_presence_store.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_drawers.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/presence_history_patient_tab.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/presence_history_timeline_tab.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

/// Master History Screen supporting segmented tabs:
/// Tab 0: Presensi (Attendance Timeline)
/// Tab 1: Pasien (Completed Patient History)
class AmanahPresenceHistoryScreen extends StatefulWidget {
  const AmanahPresenceHistoryScreen({
    this.records,
    this.patients,
    this.initialTab = 0,
    super.key,
  });

  final List<AttendanceRecord>? records;
  final List<({BookedPatient patient, DoctorSchedule schedule})>? patients;
  final int initialTab;

  static Route<void> route({
    List<AttendanceRecord>? records,
    List<({BookedPatient patient, DoctorSchedule schedule})>? patients,
    int initialTab = 0,
  }) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => AmanahPresenceHistoryScreen(
        records: records,
        patients: patients,
        initialTab: initialTab,
      ),
    );
  }

  @override
  State<AmanahPresenceHistoryScreen> createState() =>
      _AmanahPresenceHistoryScreenState();
}

class _AmanahPresenceHistoryScreenState
    extends State<AmanahPresenceHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  AttendanceStatus? _statusFilter;
  String _unitFilter = 'all';
  int? _selectedDayFilter;
  bool _isDownloading = false;

  bool get _hasActiveFilters =>
      _statusFilter != null ||
      _unitFilter != 'all' ||
      _selectedDayFilter != null;

  List<AttendanceRecord> get _sourceRecords =>
      widget.records ?? kAttendanceRecords;

  List<AttendanceRecord> get _filteredRecords {
    return _sourceRecords
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

            // 2. Segmented Pill Tab Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.pureWhite.withValues(alpha: 0.06)
                      : AmanahColorTokens.neutral200.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    gradient: dark
                        ? AmanahColorTokens.btnCrispBlueDarkGradient
                        : AmanahColorTokens.btnCrispBlueGradient,
                    boxShadow: <BoxShadow>[
                      if (dark)
                        AmanahColorTokens.btnCrispBlueDarkShadow
                      else
                        AmanahColorTokens.btnCrispBlueShadow,
                    ],
                  ),
                  labelColor: AmanahColorTokens.surfaceLight,
                  unselectedLabelColor: dark
                      ? AmanahColorTokens.neutral400
                      : AmanahColorTokens.neutral600,
                  labelStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const <Widget>[
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.access_time_rounded, size: 15),
                          SizedBox(width: 6),
                          Text('Presensi'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.people_alt_rounded, size: 15),
                          SizedBox(width: 6),
                          Text('Pasien'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // Tab 0: Presensi Timeline
                  PresenceHistoryTimelineTab(
                    records: _filteredRecords,
                    hasActiveFilters: _hasActiveFilters,
                    statusFilter: _statusFilter,
                    unitFilter: _unitFilter,
                    selectedDayFilter: _selectedDayFilter,
                    isDownloading: _isDownloading,
                    onOpenFilter: _openFilterDrawer,
                    onResetFilter: _resetFilters,
                    onDownloadPdf: _handleDownloadPdf,
                  ),

                  // Tab 1: Pasien History
                  PresenceHistoryPatientTab(
                    patients: widget.patients,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
