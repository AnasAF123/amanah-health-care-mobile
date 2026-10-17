import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/schedule/amanah_schedule_views.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/entities/session_patient.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/organisms/doctor_schedule_roster_sheet.dart';
import 'package:amanah_healthcare/features/schedule/presentation/organisms/schedule_calendar_detail_sheet.dart';
import 'package:amanah_healthcare/features/schedule/presentation/state/schedule_overview_controller.dart';

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
  late final ScheduleOverviewController _controller;
  AmanahScheduleViewMode _viewMode = AmanahScheduleViewMode.overview;
  DoctorSchedule? _selectedSession;

  @override
  void initState() {
    super.initState();
    _controller = ScheduleOverviewController(
      initialDate: widget.initialDate ?? DateTime.now(),
    );
    if (widget.initialViewMode != null) {
      _viewMode = widget.initialViewMode!;
    }
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, _) {
        final DateTime selectedDate = _controller.selectedDate;
        final bool isCuti = _controller.isCutiOnSelectedDate;
        final DayScheduleSetting daySetting = DayScheduleSetting(isCuti: isCuti);

        final List<({BookedPatient patient, DoctorSchedule schedule})>
            bookedPatients = _controller.bookedPatients.map((SessionPatient sp) {
          final BookedPatient bp = sp.toBookedPatient();
          final DoctorSchedule mockSchedule = DoctorSchedule(
            id: sp.appointmentId,
            title: sp.sessionTitle,
            date: _formatDateSubtitle(selectedDate),
            time: sp.estimatedStartAt ?? 'Sesi Praktik',
            poli: sp.poliklinikName,
            room: sp.room.isNotEmpty ? sp.room : null,
            badge: sp.statusBadge,
            badgeVariant: sp.badgeVariant,
          );
          return (patient: bp, schedule: mockSchedule);
        }).toList();

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
          screenSubtitle = _formatDateSubtitle(selectedDate);
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
                          icon: Icons.tune_rounded,
                          semanticsLabel: 'Pengaturan jadwal shift praktik',
                          foregroundColor: dark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brand,
                          onPressed: () {
                            DoctorScheduleRosterSheet.show(context);
                          },
                        )
                      : null,
                ),
                Expanded(
                  child: AmanahPullToRefresh(
                    onRefresh: _controller.refresh,
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
                          bookedPatients: bookedPatients,
                          selectedDate: selectedDate,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentView({
    required BuildContext context,
    required bool dark,
    required DayScheduleSetting daySetting,
    required bool isCuti,
    required List<({BookedPatient patient, DoctorSchedule schedule})>
        bookedPatients,
    required DateTime selectedDate,
  }) {
    switch (_viewMode) {
      case AmanahScheduleViewMode.overview:
        return AmanahScheduleOverviewView(
          selectedDate: selectedDate,
          baseToday: DateTime.now(),
          daySetting: daySetting,
          isCuti: isCuti,
          schedules: const <DoctorSchedule>[],
          bookedPatients: bookedPatients,
          dark: dark,
          dateSubtitle: _formatDateSubtitle(selectedDate),
          onSelectDate: _controller.selectDate,
          onSelectCalendarDate: (DateTime d) {
            _controller.selectDate(d);
            ScheduleCalendarDetailSheet.show(context, selectedDate: d);
          },
          onReopenSchedule: () => _controller.reopenSchedule(context, selectedDate),
          onOpenSettings: () {
            DoctorScheduleRosterSheet.show(context);
          },
          onViewSessions: () {
            ScheduleCalendarDetailSheet.show(context, selectedDate: selectedDate);
          },
          hasSchedulesForDate: _controller.hasSchedulesForDate,
          isCutiForDate: _controller.isCutiForDate,
        );

      case AmanahScheduleViewMode.sessions:
        return AmanahScheduleSessionsView(
          schedules: const <DoctorSchedule>[],
          isCuti: isCuti,
          dark: dark,
          onTapDetail: (DoctorSchedule sch) {
            AmanahScheduleDetailDrawer.show(
              context,
              schedule: sch,
              isDayCuti: isCuti,
              onViewPatients: () {
                setState(() {
                  _selectedSession = sch;
                  _viewMode = AmanahScheduleViewMode.sessionPatients;
                });
              },
              onTapEdit: () {
                DoctorScheduleRosterSheet.show(context);
              },
              onTapDelete: () {},
            );
          },
          onTapEdit: (_) {},
          onTapDelete: (_) {},
          onOpenSettings: () {
            DoctorScheduleRosterSheet.show(context);
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
}
