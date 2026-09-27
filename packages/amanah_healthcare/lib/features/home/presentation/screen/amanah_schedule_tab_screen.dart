import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule_tab_views/schedule_overview_view.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule_tab_views/schedule_session_patients_view.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule_tab_views/schedule_sessions_view.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule_tab_views/schedule_tab_header_menu.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_reschedule_session_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_conflict_dialog.dart';

enum AmanahScheduleViewMode { overview, sessions, sessionPatients }

class AmanahScheduleTabScreen extends StatefulWidget {
  const AmanahScheduleTabScreen({
    super.key,
    this.user,
    this.doctorId,
    this.onBack,
    this.initialDate,
    this.initialViewMode,
    this.initialSessionId,
    this.openDetailOnLaunch = false,
  });

  final AmanahAuthUser? user;
  final String? doctorId;
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
    } else {
      _viewMode = AmanahScheduleViewMode.overview;
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
    final String? resolvedDoctorId = widget.doctorId ??
        widget.user?.staff?.practitionerId ??
        widget.user?.staff?.id ??
        widget.user?.id;
    if (resolvedDoctorId != null && resolvedDoctorId.isNotEmpty) {
      _store.setActiveDoctorId(resolvedDoctorId);
    }
    _store.addListener(_onStoreUpdated);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    final String? resolvedDoctorId = widget.doctorId ??
        widget.user?.staff?.practitionerId ??
        widget.user?.staff?.id ??
        widget.user?.id;
    await _store.syncAll(
      _selectedDate,
      doctorId: resolvedDoctorId,
      forceRefresh: forceRefresh,
    );
    if (!mounted) return;
    final List<DoctorSchedule> schs = _store.getSchedulesForDate(_selectedDate);
    final String? roomId = schs.isNotEmpty ? schs.first.roomId : null;
    if (roomId != null) {
      await _store.loadOccupancyOverview(
        date: _selectedDate,
        roomId: roomId,
      );
    }
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
    _loadData(forceRefresh: true);
  }

  Future<void> _toggleDayStatus(DayScheduleSetting daySetting) async {
    final List<DoctorSchedule> daySchedules =
        _store.getSchedulesForDate(_selectedDate);
    final bool allSchedulesClosed = daySchedules.isNotEmpty &&
        daySchedules.every((DoctorSchedule s) =>
            !s.isAvailable ||
            s.badge == ScheduleFormConstants.statusTutup ||
            s.badge == ScheduleFormConstants.statusCuti);
    final bool isDayClosed = daySetting.isDayClosed || allSchedulesClosed;
    final String nextStatus = isDayClosed
        ? ScheduleCanonicalStatus.open
        : ScheduleCanonicalStatus.closed;
    try {
      await _store.updateDayStatus(
        date: _selectedDate,
        status: nextStatus,
        notes: isDayClosed ? 'Buka kembali' : 'Jadwal ditutup oleh dokter',
      );
      await _store.syncAll(_selectedDate, forceRefresh: true);
    } on AmanahScheduleConflictException catch (e) {
      if (mounted) {
        showScheduleConflictDialog(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        showScheduleConflictDialog(context, e.toString());
      }
    }
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

  Widget? _buildHeaderTrailing(
    BuildContext context,
    bool dark,
    DayScheduleSetting daySetting,
  ) {
    if (_viewMode == AmanahScheduleViewMode.sessionPatients) {
      return null;
    }
    return ScheduleTabHeaderMenu(
      dark: dark,
      daySetting: daySetting,
      onAddSchedule: () {
        AmanahAddEditScheduleDrawer.show(
          context,
          initialDate: _selectedDate,
          onSavedDate: _handleSavedDate,
        );
      },
      onToggleDayStatus: () => _toggleDayStatus(daySetting),
    );
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
    final int capacityPercentage = _store.getCapacityPercentage(_selectedDate);

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
              trailing: _buildHeaderTrailing(context, dark, daySetting),
            ),
            Expanded(
              child: AmanahPullToRefresh(
                onRefresh: () async {
                  await _loadData(forceRefresh: true);
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
                      capacityPercentage: capacityPercentage,
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
    required int capacityPercentage,
  }) {
    switch (_viewMode) {
      case AmanahScheduleViewMode.overview:
        return AmanahScheduleOverviewView(
          selectedDate: _selectedDate,
          daySetting: daySetting,
          isCuti: isCuti,
          schedules: schedules,
          bookedPatients: bookedPatients,
          capacityPercentage: capacityPercentage,
          dark: dark,
          onSelectDate: (DateTime d) {
            setState(() {
              _selectedDate = d;
              _viewMode = AmanahScheduleViewMode.sessions;
            });
            _loadData(forceRefresh: true);
          },
          onOpenSessionsView: () {
            setState(() => _viewMode = AmanahScheduleViewMode.sessions);
          },
          onOpenAddSchedule: () {
            AmanahAddEditScheduleDrawer.show(
              context,
              initialDate: _selectedDate,
              onSavedDate: _handleSavedDate,
            );
          },
          formatDateSubtitle: _formatDateSubtitle,
        );

      case AmanahScheduleViewMode.sessions:
        final List<DoctorSchedule> intervalSchedules =
            _store.getIntervalSchedulesForDate(_selectedDate);
        return AmanahScheduleSessionsView(
          selectedDate: _selectedDate,
          daySetting: daySetting,
          isCuti: isCuti,
          schedules: intervalSchedules.isNotEmpty ? intervalSchedules : schedules,
          occupancyOverview: _store.occupancyOverview,
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
          onTapDelete: (DoctorSchedule sch) async {
            try {
              await _store.removeSchedule(_selectedDate, sch.id);
            } on AmanahScheduleConflictException catch (e) {
              if (context.mounted) {
                showScheduleConflictDialog(context, e.message);
              }
            }
          },
          onOpenAddSchedule: () {
            AmanahAddEditScheduleDrawer.show(
              context,
              initialDate: _selectedDate,
              onSavedDate: _handleSavedDate,
            );
          },
          onToggleDayStatus: () => _toggleDayStatus(daySetting),
        );

      case AmanahScheduleViewMode.sessionPatients:
        return AmanahScheduleSessionPatientsView(
          selectedSession: _selectedSession,
          dark: dark,
          sessionPatients: _store.activeSessionPatients?.patients,
          isLoading: _store.isSessionPatientsLoading,
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
        if (schedule.sessionId.isNotEmpty) {
          _store.fetchSessionPatients(schedule.sessionId);
        }
      },
      onTapReschedule: () {
        AmanahRescheduleSessionDrawer.show(
          context,
          session: schedule,
          onRescheduled: (DateTime targetDate) {
            _handleSavedDate(targetDate);
          },
        );
      },
      onTapEdit: () {
        AmanahAddEditScheduleDrawer.show(
          context,
          initialDate: _selectedDate,
          scheduleToEdit: schedule,
          onSavedDate: _handleSavedDate,
        );
      },
      onTapDelete: () async {
        try {
          await _store.removeSchedule(_selectedDate, schedule.id);
        } on AmanahScheduleConflictException catch (e) {
          if (context.mounted) {
            showScheduleConflictDialog(context, e.message);
          }
        }
      },
    );
  }
}
