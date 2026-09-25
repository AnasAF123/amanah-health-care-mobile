import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_session_builder.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_slot_collision_helper.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/reschedule/reschedule_current_session_card.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/reschedule/reschedule_options_section.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/reschedule/reschedule_target_date_section.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/reschedule/reschedule_target_selectors.dart';

/// Modal bottom sheet drawer for rescheduling a doctor's practice session.
/// Fully integrated with the backend Reschedule V2 API engine.
class AmanahRescheduleSessionDrawer extends StatefulWidget {
  const AmanahRescheduleSessionDrawer({
    required this.session,
    this.onRescheduled,
    super.key,
  });

  final DoctorSchedule session;
  final ValueChanged<DateTime>? onRescheduled;

  static void show(
    BuildContext context, {
    required DoctorSchedule session,
    ValueChanged<DateTime>? onRescheduled,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahRescheduleSessionDrawer(
        session: session,
        onRescheduled: onRescheduled,
      ),
    );
  }

  @override
  State<AmanahRescheduleSessionDrawer> createState() =>
      _AmanahRescheduleSessionDrawerState();
}

class _AmanahRescheduleSessionDrawerState
    extends State<AmanahRescheduleSessionDrawer> {
  final AmanahScheduleStore _store = AmanahScheduleStore.instance;

  late DateTime _targetDate;
  late DateTime _calendarMonth;
  bool _isCalendarOpen = false;

  String? _selectedStartTime;
  String? _projectedEndTime;
  ClinicRoomReference? _selectedRoom;
  List<ClinicRoomReference> _availableRooms = const <ClinicRoomReference>[];

  final TextEditingController _notesController = TextEditingController();
  bool _rescheduleActiveAppointments = true;

  bool _isCheckingEligibility = false;
  bool _isSubmitting = false;
  String? _conflictMessage;

  @override
  void initState() {
    super.initState();
    final DateTime now = AmanahScheduleStore.baseToday;
    final DateTime sessionDate =
        DateTime.tryParse(widget.session.scheduleDate ?? widget.session.date) ??
            now;
    _targetDate = sessionDate.isBefore(now)
        ? now
        : sessionDate.add(const Duration(days: 1));
    _calendarMonth = DateTime(_targetDate.year, _targetDate.month);

    _selectedStartTime = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeTargetData();
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initializeTargetData() async {
    await _loadRoomsForTargetDate();
    if (_selectedStartTime != null && _selectedRoom != null) {
      await _performEligibilityCheck();
    }
  }

  Future<void> _loadRoomsForTargetDate() async {
    final List<ClinicRoomReference> rooms =
        await _store.loadRooms(date: _targetDate);
    await _store.loadOccupancyOverview(date: _targetDate);
    if (!mounted) return;
    setState(() {
      _availableRooms = rooms;
    });
  }

  Future<void> _performEligibilityCheck() async {
    if (!mounted) return;
    if (_selectedStartTime == null || _selectedRoom == null) {
      setState(() {
        _isCheckingEligibility = false;
        _conflictMessage = null;
        _projectedEndTime = null;
      });
      return;
    }
    setState(() {
      _isCheckingEligibility = true;
      _conflictMessage = null;
    });

    final String targetDateStr = AmanahScheduleStore.formatDateKey(_targetDate);
    final String doctorId = widget.session.doctorId.isNotEmpty
        ? widget.session.doctorId
        : widget.session.id;

    try {
      final RescheduleEligibilityData? data =
          await _store.checkRescheduleEligibility(
        doctorId: doctorId,
        sessionId: widget.session.sessionId,
        targetDate: targetDateStr,
        targetStartTime: _selectedStartTime,
        targetRoomId: _selectedRoom?.id ?? widget.session.roomId,
      );

      if (!mounted) return;
      setState(() {
        _isCheckingEligibility = false;
        if (data != null) {
          final RescheduleTargetValidation? targetVal = data.targetValidation;
          if (targetVal != null) {
            _projectedEndTime = targetVal.projectedEndTime;
            if (!targetVal.isTargetEligible) {
              _conflictMessage = targetVal.conflictMessage;
            }
          }
          if (!data.isEligible && data.ineligibilityReason != null) {
            _conflictMessage = data.ineligibilityReason;
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCheckingEligibility = false;
      });
    }
  }

  Future<void> _executeReschedule() async {
    if (_isSubmitting) return;

    if (_selectedStartTime == null || _selectedRoom == null) {
      showRescheduleErrorDialog(
        context,
        'Silakan tentukan jam mulai dan ruang praktik target terlebih dahulu.',
        title: 'Pilihan Belum Lengkap',
      );
      return;
    }

    if (_conflictMessage != null && _conflictMessage!.isNotEmpty) {
      showRescheduleErrorDialog(
        context,
        _conflictMessage!,
        title: 'Konflik Penjadwalan',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final String targetDateStr = AmanahScheduleStore.formatDateKey(_targetDate);
    final String doctorId = widget.session.doctorId.isNotEmpty
        ? widget.session.doctorId
        : widget.session.id;

    final DateTime? parsedSource = DateTime.tryParse(
      widget.session.scheduleDate ?? widget.session.date,
    );

    try {
      await _store.rescheduleSession(
        doctorId: doctorId,
        sessionId: widget.session.sessionId,
        targetDate: targetDateStr,
        targetStartTime: _selectedStartTime!,
        targetRoomId: _selectedRoom!.id,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        rescheduleActiveAppointments: _rescheduleActiveAppointments,
        sourceDate: parsedSource,
      );

      if (mounted) {
        widget.onRescheduled?.call(_targetDate);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sesi berhasil di-reschedule ke ${formatIndonesianDate(_targetDate)}',
            ),
            backgroundColor: AmanahColorTokens.success,
          ),
        );
      }
    } on AmanahScheduleConflictException catch (e) {
      if (mounted) {
        showRescheduleErrorDialog(context, e.message, title: 'Konflik Penjadwalan');
      }
    } catch (e) {
      if (mounted) {
        showRescheduleErrorDialog(context, e.toString(), title: 'Gagal Reschedule');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final bool isEligible = _conflictMessage == null &&
        _selectedStartTime != null &&
        _selectedRoom != null;

    final rescheduleCollisions =
        ScheduleSlotCollisionHelper.computeRescheduleDisabledTimes(
      allTimeOptions: RescheduleStartTimePicker.buildTimeOptions(),
      currentSessionId: widget.session.sessionId,
      targetDateSchedules: _store.getSchedulesForDate(_targetDate),
      targetOccupancy: _store.occupancyOverview,
      targetDate: _targetDate,
    );

    return AmanahBottomSheetScaffold(
      title: 'Reschedule Sesi Praktik',
      subtitle: 'Pindahkan sesi dan jadwal konsultasi ke tanggal/jam lain',
      fixedHeightFactor: 0.90,
      minHeight: 560,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahActionRow(
        secondary: AmanahButton.ghost(
          text: 'Batal',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
        primary: AmanahButton.primary(
          text: 'Konfirmasi Reschedule',
          leadingIcon: Icons.schedule_send_rounded,
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          isLoading: _isSubmitting,
          isDisabled: !isEligible || _isCheckingEligibility,
          onPressed: _executeReschedule,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RescheduleCurrentSessionCard(
            session: widget.session,
            dark: dark,
          ),
          const SizedBox(height: 16),
          if (_conflictMessage != null && _conflictMessage!.isNotEmpty) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AmanahColorTokens.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AmanahColorTokens.warning.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AmanahColorTokens.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _conflictMessage!,
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.pureWhite
                            : AmanahColorTokens.neutral900,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          RescheduleTargetDateSection(
            targetDate: _targetDate,
            calendarMonth: _calendarMonth,
            isCalendarOpen: _isCalendarOpen,
            dark: dark,
            onToggleCalendar: () =>
                setState(() => _isCalendarOpen = !_isCalendarOpen),
            onMonthChanged: (DateTime newMonth) {
              setState(() => _calendarMonth = newMonth);
            },
            onDateSelected: (DateTime selected) {
              setState(() {
                _targetDate = selected;
                _isCalendarOpen = false;
              });
              _loadRoomsForTargetDate();
              _performEligibilityCheck();
            },
            formatDateDisplay: formatIndonesianDate,
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Jam Mulai',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral200
                            : AmanahColorTokens.neutral700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RescheduleStartTimePicker(
                      selectedStartTime: _selectedStartTime,
                      disabledTimes: rescheduleCollisions.disabledTimes,
                      optionSubtitles: rescheduleCollisions.subtitles,
                      occupiedDetails: rescheduleCollisions.occupiedDetails,
                      onTimeSelected: (String t) {
                        setState(() => _selectedStartTime = t);
                        _performEligibilityCheck();
                      },
                      dark: dark,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Jam Selesai (Proyeksi)',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: dark
                            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.03)
                            : AmanahColorTokens.neutral100,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: dark
                              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                              : AmanahColorTokens.neutral200,
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: AmanahColorTokens.neutral400,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _projectedEndTime != null
                                  ? '$_projectedEndTime WIB'
                                  : (widget.session.endTime != null
                                      ? '${widget.session.endTime} WIB'
                                      : '-'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: dark
                                    ? AmanahColorTokens.pureWhite
                                    : AmanahColorTokens.neutral900,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ruang Praktik Target',
            style: TextStyle(
              color: dark
                  ? AmanahColorTokens.neutral200
                  : AmanahColorTokens.neutral700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          RescheduleRoomPicker(
            availableRooms: _availableRooms,
            selectedRoom: _selectedRoom,
            onRoomSelected: (ClinicRoomReference r) {
              setState(() => _selectedRoom = r);
              _performEligibilityCheck();
            },
            dark: dark,
          ),
          const SizedBox(height: 16),
          RescheduleOptionsSection(
            bookedPatientCount: widget.session.bookedPatients.length,
            rescheduleActiveAppointments: _rescheduleActiveAppointments,
            notesController: _notesController,
            dark: dark,
            onSwitchChanged: (bool val) {
              setState(() => _rescheduleActiveAppointments = val);
            },
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}
