import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/data/repositories/attendance_repository_impl.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';
import 'package:amanah_healthcare/features/presence/domain/usecases/get_attendance_history_usecase.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_presence_drawers.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/history/presence_filter_chips_banner.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/history/presence_history_summary_bar.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/history/presence_history_toolbar.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/history/presence_timeline_item.dart';

class AmanahPresenceHistoryScreen extends StatefulWidget {
  const AmanahPresenceHistoryScreen({super.key, this.initialRecords});

  final List<AttendanceRecord>? initialRecords;

  static Route<void> route({List<AttendanceRecord>? records}) {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => AmanahPresenceHistoryScreen(initialRecords: records),
    );
  }

  @override
  State<AmanahPresenceHistoryScreen> createState() => _AmanahPresenceHistoryScreenState();
}

class _AmanahPresenceHistoryScreenState extends State<AmanahPresenceHistoryScreen> {
  late final GetAttendanceHistoryUseCase _getHistoryUseCase;
  List<AttendanceRecord> _records = <AttendanceRecord>[];
  AttendanceHistorySummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  AttendanceStatus? _statusFilter;
  String _unitFilter = 'all';
  int? _selectedDayFilter;
  DateTime? _selectedDateFilter;
  bool _isDownloading = false;

  bool get _hasActiveFilters =>
      _statusFilter != null ||
      _unitFilter != 'all' ||
      _selectedDayFilter != null ||
      _selectedDateFilter != null;

  List<AttendanceRecord> get _filteredRecords {
    return _records
        .where((AttendanceRecord rec) {
          if (_statusFilter != null && rec.status != _statusFilter) {
            return false;
          }
          if (_unitFilter != 'all' &&
              rec.location.isNotEmpty &&
              !rec.location.toLowerCase().contains(_unitFilter.toLowerCase())) {
            return false;
          }
          if (_selectedDateFilter != null) {
            final DateTime? d = rec.attendanceDate ?? rec.checkInAt;
            if (d == null ||
                d.year != _selectedDateFilter!.year ||
                d.month != _selectedDateFilter!.month ||
                d.day != _selectedDateFilter!.day) {
              return false;
            }
          } else if (_selectedDayFilter != null && rec.dayNumber != _selectedDayFilter) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _getHistoryUseCase = GetAttendanceHistoryUseCase(AttendanceRepositoryImpl());

    if (widget.initialRecords != null && widget.initialRecords!.isNotEmpty) {
      _records = widget.initialRecords!;
      _isLoading = false;
    } else {
      _loadHistory();
    }

    AmanahPushService.instance.addMessageListener(_onPushReceived);
  }

  @override
  void dispose() {
    AmanahPushService.instance.removeMessageListener(_onPushReceived);
    super.dispose();
  }

  void _onPushReceived(RemoteMessage message) {
    final Map<String, dynamic> data = message.data;
    if (data['category'] == 'attendance' ||
        data['category'] == 'shift' ||
        data['sourceDomain'] == 'attendance' ||
        message.notification?.title?.toLowerCase().contains('presensi') == true) {
      _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AttendanceHistoryResult res = await _getHistoryUseCase.getResult();
      if (!mounted) return;
      setState(() {
        _records = res.records;
        _summary = res.summary;
        _isLoading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _errorMessage = err.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _statusFilter = null;
      _unitFilter = 'all';
      _selectedDayFilter = null;
      _selectedDateFilter = null;
    });
  }

  Future<void> _openFilterDrawer() async {
    final DateTime? focused = _records.isNotEmpty && _records.first.attendanceDate != null
        ? _records.first.attendanceDate
        : null;
    final Set<int> eventDays = _records.map((r) => r.dayNumber).toSet();

    final Map<String, dynamic>? result = await AmanahPresenceFilterDrawer.show(
      context,
      currentStatus: _statusFilter,
      currentUnit: _unitFilter,
      currentDay: _selectedDayFilter,
      currentDate: _selectedDateFilter,
      focusedDate: focused,
      eventDays: eventDays,
    );

    if (result != null && mounted) {
      setState(() {
        _statusFilter = result['status'] as AttendanceStatus?;
        _unitFilter = (result['unit'] as String?) ?? 'all';
        _selectedDayFilter = result['day'] as int?;
        _selectedDateFilter = result['date'] as DateTime?;
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
              'Laporan riwayat presensi berhasil diunduh (PDF)',
              style: TextStyle(fontSize: 12),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    final Color bgColor = dark ? AmanahColorTokens.canvasDark : AmanahColorTokens.canvasLight;
    final Color textColor = dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900;
    final Color subtextColor = dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Riwayat Presensi',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(child: _buildBody(dark, textColor, subtextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool dark, Color textColor, Color subtextColor) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.error_outline_rounded, size: 44, color: AmanahColorTokens.dangerDark),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadHistory,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AmanahColorTokens.brandPrimary,
                  foregroundColor: AmanahColorTokens.surfaceLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<AttendanceRecord> records = _filteredRecords;

    if (records.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,
        child: _buildEmptyState(dark, textColor, subtextColor),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Timeline Title Row + Filters
            PresenceHistoryToolbar(
              textColor: textColor,
              subtextColor: subtextColor,
              dark: dark,
              hasActiveFilters: _hasActiveFilters,
              isDownloading: _isDownloading,
              onOpenInfo: () => AmanahPresenceInfoDrawer.show(context),
              onOpenFilter: _openFilterDrawer,
              onDownloadPdf: _handleDownloadPdf,
            ),
            const SizedBox(height: 12),

            // Active Filter Chips Banner
            if (_hasActiveFilters) ...<Widget>[
              PresenceFilterChipsBanner(
                statusFilter: _statusFilter,
                unitFilter: _unitFilter,
                selectedDayFilter: _selectedDayFilter,
                selectedDateFilter: _selectedDateFilter,
                onReset: _resetFilters,
                dark: dark,
                subtextColor: subtextColor,
              ),
              const SizedBox(height: 14),
            ],

            // Summary Metrics Bar
            PresenceHistorySummaryBar(
              records: records,
              summary: _summary,
              dark: dark,
              textColor: textColor,
              subtextColor: subtextColor,
            ),
            const SizedBox(height: 20),

            // Timeline Items List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (BuildContext context, int index) {
                final AttendanceRecord item = records[index];
                final bool isLast = index == records.length - 1;
                return PresenceTimelineItem(
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
      ),
    );
  }

  Widget _buildEmptyState(bool dark, Color textColor, Color subtextColor) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: AmanahEmptyState.box(
        title: 'Tidak Ada Data Presensi',
        message:
            'Tidak ditemukan riwayat presensi yang sesuai dengan filter tanggal atau status yang diterapkan.',
        actionText: _hasActiveFilters ? 'Ubah Filter' : 'Perbarui Data',
        actionLeadingIcon: _hasActiveFilters ? Icons.tune_rounded : Icons.refresh_rounded,
        onAction: _hasActiveFilters ? _openFilterDrawer : _loadHistory,
        secondaryActionText: _hasActiveFilters ? 'Reset Filter' : null,
        secondaryActionLeadingIcon: _hasActiveFilters ? Icons.restart_alt_rounded : null,
        onSecondaryAction: _hasActiveFilters ? _resetFilters : null,
      ),
    );
  }
}
