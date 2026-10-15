import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule/amanah_schedule_views.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_add_edit_schedule_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';

enum AmanahScheduleViewMode { overview, sessions, sessionPatients }

class AmanahScheduleTabScreen extends StatefulWidget {
  const AmanahScheduleTabScreen({
    super.key,
    this.onBack,
    this.initialDate,
    this.initialViewMode,
    this.initialSessionId,
    this.openDetailOnLaunch = false,
  });

  final VoidCallback? onBack;
  final DateTime? initialDate;
  final AmanahScheduleViewMode? initialViewMode;
  final String? initialSessionId;
  final bool openDetailOnLaunch;

  @override
  State<AmanahScheduleTabScreen> createState() =>
      _AmanahScheduleTabScreenState();
}

class _AmanahScheduleTabScreenState extends State<AmanahScheduleTabScreen> {
  final AmanahScheduleStore _store = AmanahScheduleStore.instance;

  DateTime _selectedDate = AmanahScheduleStore.baseToday;
  AmanahScheduleViewMode _viewMode = AmanahScheduleViewMode.overview;
  DoctorSchedule? _selectedSession;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? AmanahScheduleStore.baseToday;
    if (widget.initialViewMode != null) {
      _viewMode = widget.initialViewMode!;
    }
    if (widget.initialSessionId != null) {
      final List<DoctorSchedule> list = _store.getSchedulesForDate(
        _selectedDate,
      );
      int idx = list.indexWhere(
        (DoctorSchedule s) => s.id == widget.initialSessionId,
      );
      if (idx < 0 && list.isNotEmpty) {
        idx = 0;
      }
      if (idx >= 0 && idx < list.length) {
        _selectedSession = list[idx];
        if (widget.openDetailOnLaunch) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final DayScheduleSetting daySetting = _store.getDaySettingForDate(
                _selectedDate,
              );
              _showSessionDetailSheet(context, list[idx], daySetting.isCuti);
            }
          });
        }
      }
    }
    _store.addListener(_onStoreUpdated);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreUpdated);
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSavedDate(DateTime date) {
    if (!mounted) {
      return;
    }
    setState(() {
      _selectedDate = date;
      _selectedSession = null;
      _viewMode = AmanahScheduleViewMode.sessions;
    });
  }

  String _formatDateSubtitle(DateTime date) {
    const List<String> days = <String>[
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const List<String> months = <String>[
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final String dayName = days[(date.weekday - 1).clamp(0, 6)];
    final String monthName = months[(date.month - 1).clamp(0, 11)];
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    final DayScheduleSetting daySetting = _store.getDaySettingForDate(
      _selectedDate,
    );
    final bool isCuti = daySetting.isCuti;
    final List<DoctorSchedule> schedules = _store.getSchedulesForDate(
      _selectedDate,
    );
    final List<({BookedPatient patient, DoctorSchedule schedule})>
    bookedPatients = _store.getAllBookedPatientsForDate(_selectedDate);

    String screenTitle = 'Jadwal Praktik';
    String? screenSubtitle;
    VoidCallback? backAction;

    if (_viewMode == AmanahScheduleViewMode.sessionPatients) {
      screenTitle = 'Daftar Pasien Booking';
      screenSubtitle = _selectedSession?.title;
      backAction = () =>
          setState(() => _viewMode = AmanahScheduleViewMode.sessions);
    } else if (_viewMode == AmanahScheduleViewMode.sessions) {
      screenTitle = 'Jadwal Praktik';
      screenSubtitle = _formatDateSubtitle(_selectedDate);
      backAction = () =>
          setState(() => _viewMode = AmanahScheduleViewMode.overview);
    } else {
      backAction = widget.onBack;
    }

    return Scaffold(
      backgroundColor: dark
          ? AmanahColorTokens.canvasDark
          : AmanahColorTokens.canvasLight,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: screenTitle,
              subtitle: screenSubtitle,
              onBack: backAction,
              trailing: _viewMode != AmanahScheduleViewMode.sessionPatients
                  ? AmanahScreenHeaderIconAction(
                      icon: Icons.add_rounded,
                      semanticsLabel: 'Tambah jadwal praktik',
                      foregroundColor: dark
                          ? AmanahColorTokens.tabActiveDark
                          : AmanahColorTokens.brand,
                      onPressed: () {
                        AmanahAddEditScheduleDrawer.show(
                          context,
                          initialDate: _selectedDate,
                          onSavedDate: _handleSavedDate,
                        );
                      },
                    )
                  : null,
            ),
            Expanded(
              child: AmanahPullToRefresh(
                onRefresh: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 900));
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _buildCurrentView(
                      context: context,
                      dark: dark,
                      daySetting: daySetting,
                      isCuti: isCuti,
                      schedules: schedules,
                      bookedPatients: bookedPatients,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView({
    required BuildContext context,
    required bool dark,
    required DayScheduleSetting daySetting,
    required bool isCuti,
    required List<DoctorSchedule> schedules,
    required List<({BookedPatient patient, DoctorSchedule schedule})>
    bookedPatients,
  }) {
    switch (_viewMode) {
      case AmanahScheduleViewMode.overview:
        return AmanahScheduleOverviewView(
          selectedDate: _selectedDate,
          baseToday: AmanahScheduleStore.baseToday,
          daySetting: daySetting,
          isCuti: isCuti,
          schedules: schedules,
          bookedPatients: bookedPatients,
          dark: dark,
          dateSubtitle: _formatDateSubtitle(_selectedDate),
          onSelectDate: (DateTime d) => setState(() => _selectedDate = d),
          onSelectCalendarDate: (DateTime d) => setState(() {
            _selectedDate = d;
            _viewMode = AmanahScheduleViewMode.sessions;
          }),
          onReopenSchedule: () => _store.setDayCuti(_selectedDate, false),
          onAddSchedule: () {
            AmanahAddEditScheduleDrawer.show(
              context,
              initialDate: _selectedDate,
              onSavedDate: _handleSavedDate,
            );
          },
          onViewSessions: () {
            setState(() => _viewMode = AmanahScheduleViewMode.sessions);
          },
          hasSchedulesForDate: (DateTime d) =>
              _store.getSchedulesForDate(d).isNotEmpty,
          isCutiForDate: (DateTime d) => _store.getDaySettingForDate(d).isCuti,
        );

      case AmanahScheduleViewMode.sessions:
        return AmanahScheduleSessionsView(
          schedules: schedules,
          isCuti: isCuti,
          dark: dark,
          onTapDetail: (DoctorSchedule sch) {
            _showSessionDetailSheet(context, sch, isCuti);
          },
          onTapEdit: (DoctorSchedule sch) {
            AmanahAddEditScheduleDrawer.show(
              context,
              initialDate: _selectedDate,
              scheduleToEdit: sch,
              onSavedDate: _handleSavedDate,
            );
          },
          onTapDelete: (DoctorSchedule sch) {
            _store.deleteSchedule(_selectedDate, sch.id);
          },
          onAddSchedule: () {
            AmanahAddEditScheduleDrawer.show(
              context,
              initialDate: _selectedDate,
              onSavedDate: _handleSavedDate,
            );
          },
        );

      case AmanahScheduleViewMode.sessionPatients:
        return AmanahScheduleSessionPatientsView(
          session: _selectedSession,
          dark: dark,
          onBackToSessions: () {
            setState(() => _viewMode = AmanahScheduleViewMode.sessions);
          },
        );
    }
  }

  void _showSessionDetailSheet(
    BuildContext context,
    DoctorSchedule schedule,
    bool isCuti,
  ) {
    AmanahScheduleDetailDrawer.show(
      context,
      schedule: schedule,
      isDayCuti: isCuti,
      onViewPatients: () {
        setState(() {
          _selectedSession = schedule;
          _viewMode = AmanahScheduleViewMode.sessionPatients;
        });
      },
      onTapEdit: () {
        AmanahAddEditScheduleDrawer.show(
          context,
          initialDate: _selectedDate,
          scheduleToEdit: schedule,
          onSavedDate: _handleSavedDate,
        );
      },
      onTapDelete: () {
        _store.deleteSchedule(_selectedDate, schedule.id);
      },
    );
  }
}
