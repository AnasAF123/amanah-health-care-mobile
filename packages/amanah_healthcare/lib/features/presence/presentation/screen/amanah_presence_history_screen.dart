import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/data/amanah_presence_store.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_drawers.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/presence_history_patient_tab.dart';
import 'package:amanah_healthcare/features/presence/presentation/screen/presence_history_timeline_tab.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

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
    extends State<AmanahPresenceHistoryScreen> {
  late int _activeTabIndex;
  AttendanceStatus? _statusFilter;
  String _unitFilter = 'all';
  int? _selectedDayFilter;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _activeTabIndex = widget.initialTab;
  }

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
            AmanahScreenHeader(
              title: 'Riwayat Presensi',
              onBack: () => Navigator.of(context).pop(),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.surfaceElevatedDark
                    : AmanahColorTokens.neutral100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 0
                              ? (dark
                                  ? AmanahColorTokens.surfaceSecondaryDark
                                  : AmanahColorTokens.pureWhite)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTabIndex == 0
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Presensi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _activeTabIndex == 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: _activeTabIndex == 0
                                  ? (dark
                                      ? AmanahColorTokens.pureWhite
                                      : AmanahColorTokens.neutral900)
                                  : AmanahColorTokens.neutral400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _activeTabIndex == 1
                              ? (dark
                                  ? AmanahColorTokens.surfaceSecondaryDark
                                  : AmanahColorTokens.pureWhite)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _activeTabIndex == 1
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Pasien',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _activeTabIndex == 1
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: _activeTabIndex == 1
                                  ? (dark
                                      ? AmanahColorTokens.pureWhite
                                      : AmanahColorTokens.neutral900)
                                  : AmanahColorTokens.neutral400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _activeTabIndex == 0
                  ? PresenceHistoryTimelineTab(
                      records: _filteredRecords,
                      hasActiveFilters: _hasActiveFilters,
                      statusFilter: _statusFilter,
                      unitFilter: _unitFilter,
                      selectedDayFilter: _selectedDayFilter,
                      isDownloading: _isDownloading,
                      onOpenFilter: _openFilterDrawer,
                      onResetFilter: _resetFilters,
                      onDownloadPdf: _handleDownloadPdf,
                    )
                  : PresenceHistoryPatientTab(
                      patients: widget.patients,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
