import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_cards_and_drawers.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_components.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_form_and_calendar_dialog.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    await Future.wait(<Future<dynamic>>[
      _store.loadSchedulesForDate(_selectedDate, forceRefresh: forceRefresh),
      _store.loadDaySettings(_selectedDate),
      _store.loadCalendarSummary(
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}',
      ),
    ]);
  }

  void _showConflictDialog(BuildContext context, String message) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        final bool dark = Theme.of(ctx).brightness == Brightness.dark;
        return AmanahBottomSheetScaffold(
          title: 'Konflik Penjadwalan',
          subtitle: 'Validasi Sistem Praktik Dokter',
          maxHeightFactor: 0.45,
          footer: AmanahButton.primary(
            text: 'Mengerti',
            isFullWidth: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AmanahColorTokens.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AmanahColorTokens.warning.withValues(alpha: 0.40),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AmanahColorTokens.warning,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.neutral900,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
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
    _loadData();
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

  Widget? _buildHeaderMoreMenu(
    BuildContext context,
    bool dark,
    DayScheduleSetting daySetting,
  ) {
    if (_viewMode == AmanahScheduleViewMode.sessionPatients) {
      return null;
    }

    final bool isDayClosed =
        daySetting.isClosed || daySetting.status == 'Tutup';

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: dark
              ? AmanahColorTokens.surfaceDark
              : AmanahColorTokens.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.12)
                  : AmanahColorTokens.neutral200,
            ),
          ),
          elevation: 6,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Menu Opsi Jadwal',
        icon: Icon(
          Icons.more_vert_rounded,
          color: dark
              ? AmanahColorTokens.pureWhite
              : AmanahColorTokens.neutral800,
          size: 22,
        ),
        padding: EdgeInsets.zero,
        splashRadius: 20,
        onSelected: (String value) async {
          if (value == 'add') {
            AmanahAddEditScheduleDrawer.show(
              context,
              initialDate: _selectedDate,
              onSavedDate: _handleSavedDate,
            );
          } else if (value == 'toggle_day') {
            final String nextStatus = isDayClosed ? 'Buka' : 'Tutup';
            await _store.updateDayStatus(
              date: _selectedDate,
              status: nextStatus,
              notes: isDayClosed ? 'Buka kembali' : 'Jadwal ditutup oleh dokter',
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'add',
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 18,
                  color: dark
                      ? AmanahColorTokens.pureWhite
                      : AmanahColorTokens.neutral800,
                ),
                const SizedBox(width: 10),
                Text(
                  'Tambah Jadwal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: dark
                        ? AmanahColorTokens.pureWhite
                        : AmanahColorTokens.neutral800,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem<String>(
            value: 'toggle_day',
            child: Row(
              children: <Widget>[
                Icon(
                  isDayClosed
                      ? Icons.check_circle_outline_rounded
                      : Icons.do_not_disturb_on_outlined,
                  size: 18,
                  color: isDayClosed
                      ? AmanahColorTokens.success
                      : AmanahColorTokens.danger,
                ),
                const SizedBox(width: 10),
                Text(
                  isDayClosed ? 'Buka Jadwal Hari Ini' : 'Tutup Jadwal Hari Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDayClosed
                        ? AmanahColorTokens.success
                        : AmanahColorTokens.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            // Top Overlay Screen Header
            AmanahScreenHeader(
              title: screenTitle,
              subtitle: screenSubtitle,
              onBack: backAction,
              trailing: _buildHeaderMoreMenu(context, dark, daySetting),
            ),

            // Main Scrollable Viewport
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
        return _buildOverviewView(
          context: context,
          dark: dark,
          daySetting: daySetting,
          isCuti: isCuti,
          schedules: schedules,
          bookedPatients: bookedPatients,
          capacityPercentage: capacityPercentage,
        );

      case AmanahScheduleViewMode.sessions:
        return _buildSessionsView(
          context: context,
          dark: dark,
          daySetting: daySetting,
          isCuti: isCuti,
          schedules: schedules,
        );

      case AmanahScheduleViewMode.sessionPatients:
        return _buildSessionPatientsView(context: context, dark: dark);
    }
  }

  /// VIEW 1: Overview & Showcase Pasien Booking
  Widget _buildOverviewView({
    required BuildContext context,
    required bool dark,
    required DayScheduleSetting daySetting,
    required bool isCuti,
    required List<DoctorSchedule> schedules,
    required List<({BookedPatient patient, DoctorSchedule schedule})>
    bookedPatients,
    required int capacityPercentage,
  }) {
    return Column(
      key: const ValueKey<String>('view-overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Top Row: Radial Capacity Gauge & Lihat Schedule Trigger
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: AmanahRadialCapacityGauge(
                capacityPercentage: capacityPercentage,
                bookedCount: bookedPatients.length,
                targetQuota: daySetting.targetQuota,
                isCuti: isCuti,
              ),
            ),
            const SizedBox(width: 8),
            AmanahButton.text(
              text: 'Lihat jadwal',
              trailingIcon: Icons.chevron_right_rounded,
              size: AmanahButtonSize.small,
              customForegroundColor: dark
                  ? AmanahColorTokens.tabActiveDark
                  : AmanahColorTokens.brand,
              onPressed: () {
                AmanahDocScheduleCalendarDrawer.show(
                  context,
                  selectedDate: _selectedDate,
                  baseToday: AmanahScheduleStore.baseToday,
                  onSelectDate: (DateTime d) {
                    setState(() {
                      _selectedDate = d;
                      _viewMode = AmanahScheduleViewMode.sessions;
                    });
                    _loadData();
                  },
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Date Carousel Strip
        AmanahDateCarouselStrip(
          selectedDate: _selectedDate,
          baseToday: AmanahScheduleStore.baseToday,
          onSelectDate: (DateTime d) {
            setState(() => _selectedDate = d);
            _loadData();
          },
          hasSchedulesForDate: (DateTime d) =>
              _store.getSchedulesForDate(d).isNotEmpty,
          isCutiForDate: (DateTime d) => _store.getDaySettingForDate(d).isCuti,
        ),
        const SizedBox(height: 12),


        // Section Title: Date & Patient Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                _formatDateSubtitle(_selectedDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.neutral400
                      : AmanahColorTokens.neutral500,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${bookedPatients.length} Pasien Booking',
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral500,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Showcase Pasien Booking Cards
        if (bookedPatients.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookedPatients.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              final ({BookedPatient patient, DoctorSchedule schedule}) item =
                  bookedPatients[index];
              return AmanahBookedPatientCard(
                patient: item.patient,
                schedule: item.schedule,
                imageIndex: index,
                onTapDetail: () {
                  AmanahPatientDetailModal.show(
                    context,
                    item.patient,
                    item.schedule,
                  );
                },
              );
            },
          )
        else
          AmanahEmptyState.box(
            title: 'Belum Ada Pasien Booking',
            message: isCuti
                ? 'Dokter sedang cuti pada tanggal ini.'
                : 'Belum ada pasien yang mendaftar pada sesi praktik di tanggal ini.',
            actionText: 'Tambah Jadwal',
            actionLeadingIcon: Icons.add_rounded,
            onAction: () {
              AmanahAddEditScheduleDrawer.show(
                context,
                initialDate: _selectedDate,
                onSavedDate: _handleSavedDate,
              );
            },
            secondaryActionText: 'Lihat Sesi Dokter',
            secondaryActionLeadingIcon: Icons.calendar_month_outlined,
            onSecondaryAction: () {
              setState(() => _viewMode = AmanahScheduleViewMode.sessions);
            },
          ),
      ],
    );
  }

  /// VIEW 2: Dedicated Doctor Practice Sessions Page
  Widget _buildSessionsView({
    required BuildContext context,
    required bool dark,
    required DayScheduleSetting daySetting,
    required bool isCuti,
    required List<DoctorSchedule> schedules,
  }) {
    final bool isDayClosed =
        daySetting.isClosed || daySetting.status == 'Tutup';

    return Column(
      key: const ValueKey<String>('view-sessions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Header Count & Status Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                'Daftar Sesi Praktik Dokter',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.neutral400
                      : AmanahColorTokens.neutral500,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isDayClosed
                  ? 'Jadwal Ditutup'
                  : '${schedules.length} Sesi Aktif',
              style: TextStyle(
                color: isDayClosed
                    ? AmanahColorTokens.danger
                    : (dark
                        ? AmanahColorTokens.neutral400
                        : AmanahColorTokens.neutral500),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (schedules.isNotEmpty)
          Opacity(
            opacity: isDayClosed ? 0.45 : 1.0,
            child: IgnorePointer(
              ignoring: isDayClosed,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: schedules.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 14),
                itemBuilder: (BuildContext context, int index) {
                  final DoctorSchedule sch = schedules[index];
                  return AmanahDoctorSessionCard(
                    schedule: sch,
                    imageIndex: index,
                    onTapDetail: () {
                      _showSessionDetailSheet(context, sch, isCuti);
                    },
                    onTapEdit: () {
                      AmanahAddEditScheduleDrawer.show(
                        context,
                        initialDate: _selectedDate,
                        scheduleToEdit: sch,
                        onSavedDate: _handleSavedDate,
                      );
                    },
                    onTapDelete: () async {
                      try {
                        await _store.removeSchedule(_selectedDate, sch.id);
                      } on AmanahScheduleConflictException catch (e) {
                        if (context.mounted) {
                          _showConflictDialog(context, e.message);
                        }
                      }
                    },
                  );
                },
              ),
            ),
          )
        else
          AmanahEmptyState.box(
            title: isDayClosed
                ? 'Jadwal Hari Ini Ditutup'
                : 'Belum Ada Sesi Praktik',
            message: isDayClosed
                ? 'Dokter tidak membuka praktik pada tanggal ini.'
                : 'Belum ada sesi praktik dokter yang ditambahkan pada tanggal ini.',
            actionText: 'Tambah Jadwal Dokter',
            actionLeadingIcon: Icons.add_rounded,
            onAction: () {
              AmanahAddEditScheduleDrawer.show(
                context,
                initialDate: _selectedDate,
                onSavedDate: _handleSavedDate,
              );
            },
          ),
      ],
    );
  }

  /// VIEW 3: Dedicated Full-Screen Session Booked Patients
  Widget _buildSessionPatientsView({
    required BuildContext context,
    required bool dark,
  }) {
    final DoctorSchedule? sch = _selectedSession;
    final List<BookedPatient> patients =
        sch?.bookedPatients ?? const <BookedPatient>[];

    return Column(
      key: const ValueKey<String>('view-session-patients'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Session Header Overview
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${sch?.title} • ${sch?.poli}',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.pureWhite
                            : AmanahColorTokens.neutral900,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sch?.room} • ${sch?.time}',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (dark
                              ? AmanahColorTokens.cyanAccent
                              : AmanahColorTokens.brand)
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${patients.length} Pasien',
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.cyanAccent
                        : AmanahColorTokens.brand,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (patients.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: patients.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 14),
            itemBuilder: (BuildContext context, int index) {
              final BookedPatient patient = patients[index];
              return AmanahBookedPatientCard(
                patient: patient,
                schedule: sch!,
                imageIndex: index,
                onTapDetail: () {
                  AmanahPatientDetailModal.show(context, patient, sch);
                },
              );
            },
          )
        else
          AmanahEmptyState.box(
            title: 'Belum Ada Pasien Booking',
            message: 'Belum ada pasien yang mendaftar pada sesi praktik ini.',
            actionText: 'Kembali ke Sesi Praktik',
            actionLeadingIcon: Icons.arrow_back_rounded,
            onAction: () {
              setState(() => _viewMode = AmanahScheduleViewMode.sessions);
            },
          ),
      ],
    );
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
      onTapDelete: () async {
        try {
          await _store.removeSchedule(_selectedDate, schedule.id);
        } on AmanahScheduleConflictException catch (e) {
          if (context.mounted) {
            _showConflictDialog(context, e.message);
          }
        }
      },
    );
  }
}
