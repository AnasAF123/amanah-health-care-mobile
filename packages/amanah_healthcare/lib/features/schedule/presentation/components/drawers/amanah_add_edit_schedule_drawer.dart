import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';
import 'package:amanah_healthcare/features/schedule/domain/slot_occupied_info.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/amanah_schedule_duration_info_drawer.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_body_content.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_saver.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/drawers/schedule_form_session_builder.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/amanah_schedule_selection_sheet.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_conflict_dialog.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_form_models.dart';
import 'package:amanah_healthcare/features/schedule/presentation/components/form/schedule_shift_boundary_helper.dart';

class AmanahAddEditScheduleDrawer extends StatefulWidget {
  const AmanahAddEditScheduleDrawer({
    required this.initialDate,
    this.scheduleToEdit,
    this.onSavedDate,
    super.key,
  });

  final DateTime initialDate;
  final DoctorSchedule? scheduleToEdit;
  final ValueChanged<DateTime>? onSavedDate;

  static void show(
    BuildContext context, {
    required DateTime initialDate,
    DoctorSchedule? scheduleToEdit,
    ValueChanged<DateTime>? onSavedDate,
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahAddEditScheduleDrawer(
        initialDate: initialDate,
        scheduleToEdit: scheduleToEdit,
        onSavedDate: onSavedDate,
      ),
    );
  }

  @override
  State<AmanahAddEditScheduleDrawer> createState() =>
      _AmanahAddEditScheduleDrawerState();
}

class _AmanahAddEditScheduleDrawerState
    extends State<AmanahAddEditScheduleDrawer> {
  late DateTime _selectedDate;
  late DateTime _calendarMonth;
  bool _isCalendarOpen = false;
  String _status = ScheduleFormConstants.statusBuka;
  List<ScheduleFormSession> _sessions = const <ScheduleFormSession>[];
  List<ClinicPoliklinikReference> _polis = const <ClinicPoliklinikReference>[];
  List<ClinicRoomReference> _rooms = const <ClinicRoomReference>[];
  List<String> _dynamicPoliOptions = const <String>[];
  List<String> _dynamicRoomOptions = const <String>[];
  List<String> _occupiedRoomOptions = const <String>[];
  bool _isSubmitting = false;

  static const List<ClinicRoomReference> canonicalDefaultRooms = <ClinicRoomReference>[
    ClinicRoomReference(id: 'b77d141b-2fa5-4481-9f47-a5a040faf57a', code: 'room_umum_1', name: 'Ruang Poli Umum 1'),
    ClinicRoomReference(id: 'ce282b3b-cb35-484b-bf5a-4b26ae747dc8', code: 'room_umum_2', name: 'Ruang Poli Umum 2'),
    ClinicRoomReference(id: '590be133-107b-476e-bab3-a3ccd2d875dd', code: 'room_kia_1', name: 'Ruang KIA 1'),
    ClinicRoomReference(id: '4c19daa5-0e45-460b-a7c9-d51d33fcd5bc', code: 'room_kia_2', name: 'Ruang KIA 2'),
  ];

  static const List<ClinicPoliklinikReference> canonicalDefaultPolikliniks = <ClinicPoliklinikReference>[
    ClinicPoliklinikReference(id: '53fa8088-46c8-4611-9dea-99a54f4a45ab', code: 'poli_umum', name: 'Poli Umum'),
    ClinicPoliklinikReference(id: 'c7df1666-5bb1-4c89-b0f7-9d62a6b96c75', code: 'poli_kia', name: 'Poli KIA'),
    ClinicPoliklinikReference(id: 'c4fdf447-ff4a-4298-81a9-24fdd55839c5', code: 'front_desk', name: 'Front Desk'),
    ClinicPoliklinikReference(id: 'dfb1dd2c-9635-441d-86c2-d117a4ee123d', code: 'it_support', name: 'IT Support'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _calendarMonth = DateTime(_selectedDate.year, _selectedDate.month);
    final DoctorSchedule? sch = widget.scheduleToEdit;
    _status = (sch?.badge == ScheduleFormConstants.statusTutup ||
            sch?.badge == ScheduleFormConstants.statusCuti)
        ? ScheduleFormConstants.statusTutup
        : ScheduleFormConstants.statusBuka;
    _sessions = buildInitialScheduleSessions(editingSchedule: sch);

    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    if (store.formBootstrap != null && store.formBootstrap!.rooms.isNotEmpty) {
      _applyReferenceData(
        polis: store.formBootstrap!.polikliniks,
        rooms: store.formBootstrap!.rooms,
      );
    } else if (store.rooms.isNotEmpty) {
      _applyReferenceData(
        polis: canonicalDefaultPolikliniks,
        rooms: store.rooms,
      );
    } else {
      _applyReferenceData(
        polis: canonicalDefaultPolikliniks,
        rooms: canonicalDefaultRooms,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadReferenceData();
    });
  }

  ScheduleContext? _getContextForSession(String sessionId) {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    final String targetShift = sessionShiftFromId(sessionId);
    return store.scheduleContexts
        .where((ScheduleContext c) =>
            c.sessionShift == targetShift ||
            c.contextId == sessionId ||
            c.contextId == targetShift)
        .firstOrNull;
  }

  int _getEffectiveDurationForSession(String sessionId) {
    final ScheduleContext? ctx = _getContextForSession(sessionId);
    if (ctx != null && ctx.effectiveConsultationDurationMinutes > 0) {
      return ctx.effectiveConsultationDurationMinutes;
    }
    return 30;
  }

  Future<void> _loadOccupancyData([String? preferredRoomName]) async {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    final String? roomName = (preferredRoomName != null &&
            preferredRoomName != ScheduleFormConstants.selectRoom)
        ? preferredRoomName
        : _sessions
            .expand((ScheduleFormSession s) => s.slots)
            .where((ScheduleFormSlot sl) =>
                sl.room.isNotEmpty &&
                sl.room != ScheduleFormConstants.selectRoom)
            .firstOrNull
            ?.room;

    final String? roomId = roomName != null
        ? _rooms
            .where((ClinicRoomReference r) => r.name == roomName)
            .firstOrNull
            ?.id
        : null;

    await store.loadOccupancyOverview(date: _selectedDate, roomId: roomId);
    if (mounted) setState(() {});
  }

  void _applyReferenceData({
    required List<ClinicPoliklinikReference> polis,
    required List<ClinicRoomReference> rooms,
  }) {
    _polis = polis;
    _rooms = rooms;
    _dynamicPoliOptions =
        polis.map((ClinicPoliklinikReference p) => p.name).toList();
    _dynamicRoomOptions =
        rooms.map((ClinicRoomReference r) => r.name).toList();
    _occupiedRoomOptions = rooms
        .where((ClinicRoomReference r) => r.isOccupied)
        .map((ClinicRoomReference r) => r.name)
        .toList();
  }

  Future<void> _loadReferenceData() async {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    try {
      final ScheduleFormBootstrapData? bootstrap = await store.loadFormBootstrap(
        date: _selectedDate,
        scheduleId: widget.scheduleToEdit?.id,
      );

      if (bootstrap != null && mounted) {
        setState(() {
          _applyReferenceData(
            polis: bootstrap.polikliniks,
            rooms: bootstrap.rooms,
          );
          if (widget.scheduleToEdit == null && _sessions.every((s) => !s.active)) {
            _sessions = buildInitialScheduleSessions(
              editingSchedule: widget.scheduleToEdit,
              bootstrap: bootstrap,
            );
          }
        });
        await _loadOccupancyData(bootstrap.doctor.defaultRoomName);
        return;
      }
    } catch (_) {}

    await _loadOccupancyData();
  }

  Future<void> _handleSave() async {
    setState(() => _isSubmitting = true);
    await ScheduleFormSaver.save(
      context: context,
      selectedDate: _selectedDate,
      status: _status,
      sessions: _sessions,
      rooms: _rooms,
      polis: _polis,
      scheduleToEdit: widget.scheduleToEdit,
      onSavedDate: widget.onSavedDate,
    );
    if (mounted) setState(() => _isSubmitting = false);
  }

  Future<void> _handleDelete() async {
    await ScheduleFormSaver.delete(
      context: context,
      selectedDate: _selectedDate,
      scheduleToEdit: widget.scheduleToEdit,
      onSavedDate: widget.onSavedDate,
    );
  }

  ScheduleFormSlot _defaultSlot(String sessionId) {
    final ScheduleDoctorReference? doc =
        AmanahScheduleStore.instance.formBootstrap?.doctor;
    return defaultSlotForSession(
      sessionId,
      defaultRoom: doc?.defaultRoomName,
      defaultPoli: doc?.defaultPoliklinikName,
    );
  }

  bool _isSessionUnavailable(String sessionId) {
    final ScheduleContext? ctx = _getContextForSession(sessionId);
    final String targetShift = sessionShiftFromId(sessionId);
    final ScheduleShiftOccupancy? shiftOcc = AmanahScheduleStore
        .instance.occupancyOverview?.shifts
        .where((ScheduleShiftOccupancy s) =>
            s.shift == targetShift ||
            s.shift == sessionId ||
            s.shift.toLowerCase() == targetShift.toLowerCase() ||
            s.shift.toLowerCase() == sessionId.toLowerCase())
        .firstOrNull;

    final bool isEditingThisSession = widget.scheduleToEdit != null &&
        (_sessions
                .firstWhere((ScheduleFormSession s) => s.id == sessionId,
                    orElse: () => _sessions.first)
                .slots
                .any((ScheduleFormSlot sl) => sl.id == widget.scheduleToEdit!.id) ||
            sessionId == sessionIdFromType(widget.scheduleToEdit!.sessionType));

    return isSessionShiftUnavailable(
      sessionId: sessionId,
      selectedDate: _selectedDate,
      occupancy: shiftOcc,
      context: ctx,
      isEditingThisSession: isEditingThisSession,
    );
  }

  void _toggleSession(String sessionId, [bool? forcedState]) {
    if (_isSessionUnavailable(sessionId)) return;
    setState(() {
      _sessions = _sessions.map((ScheduleFormSession session) {
        if (session.id != sessionId) return session;
        final bool nextActive = forcedState ?? !session.active;
        final List<ScheduleFormSlot> slots = nextActive && session.slots.isEmpty
            ? <ScheduleFormSlot>[_defaultSlot(session.id)]
            : session.slots;
        return session.copyWith(active: nextActive, slots: slots);
      }).toList();
    });
  }

  void _addTimeSlot(String sessionId) {
    if (_isSessionUnavailable(sessionId)) return;
    final ScheduleFormSession session = _sessions.firstWhere(
      (ScheduleFormSession s) => s.id == sessionId,
      orElse: () => _sessions.first,
    );

    final int duration = _getEffectiveDurationForSession(sessionId);
    final ScheduleContext? ctx = _getContextForSession(sessionId);
    final SessionShiftBoundary bounds = getSessionShiftBoundary(sessionId, ctx);

    final ({String title, String message})? error = checkCanAddSlotError(
      session: session,
      duration: duration,
      bounds: bounds,
    );
    if (error != null) {
      showScheduleConflictDialog(context, error.message, title: error.title);
      return;
    }

    setState(() {
      _sessions = _sessions.map((ScheduleFormSession s) {
        if (s.id != sessionId) return s;
        return s.copyWith(
          slots: <ScheduleFormSlot>[...s.slots, _defaultSlot(sessionId)],
        );
      }).toList();
    });
  }

  void _removeTimeSlot(String sessionId, int slotIndex) {
    setState(() {
      _sessions = removeSessionSlot(_sessions, sessionId, slotIndex);
    });
  }

  void _updateSlot({
    required String sessionId,
    required int slotIndex,
    String? from,
    String? to,
    String? room,
    String? poli,
  }) {
    final int duration = _getEffectiveDurationForSession(sessionId);
    final ScheduleContext? ctx = _getContextForSession(sessionId);

    setState(() {
      _sessions = updateSessionSlot(
        sessions: _sessions,
        sessionId: sessionId,
        slotIndex: slotIndex,
        from: from,
        to: to,
        room: room,
        poli: poli,
        durationMinutes: duration,
        context: ctx,
      );
    });

    if (room != null && room != ScheduleFormConstants.selectRoom) {
      _loadOccupancyData(room);
    }
  }

  Future<void> _openSelectionSheet({
    required String title,
    required String subtitle,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onChanged,
    List<String> disabledOptions = const <String>[],
    Map<String, String> optionSubtitles = const <String, String>{},
    Map<String, SlotOccupiedInfo> occupiedDetails = const <String, SlotOccupiedInfo>{},
    String? sessionId,
    bool isTimePicker = false,
  }) async {
    if (isTimePicker) {
      final String? currentRoom = _sessions
          .where((ScheduleFormSession s) => sessionId == null || s.id == sessionId)
          .expand((ScheduleFormSession s) => s.slots)
          .where((ScheduleFormSlot sl) =>
              sl.room.isNotEmpty && sl.room != ScheduleFormConstants.selectRoom)
          .firstOrNull
          ?.room;
      final String? targetRoomId = currentRoom != null
          ? _rooms.where((ClinicRoomReference r) => r.name == currentRoom).firstOrNull?.id
          : null;
      if (AmanahScheduleStore.instance.occupancyOverview == null ||
          AmanahScheduleStore.instance.occupancyOverview?.roomId != targetRoomId) {
        await _loadOccupancyData(currentRoom);
        if (!mounted) return;
      }
    }

    List<String> effectiveOptions = options;
    List<String> effectiveDisabled = disabledOptions;

    if (!isTimePicker) {
      final String lowerTitle = title.toLowerCase();
      if (lowerTitle.contains('ruang')) {
        effectiveOptions =
            _dynamicRoomOptions.isNotEmpty ? _dynamicRoomOptions : options;
        effectiveDisabled = _occupiedRoomOptions.isNotEmpty
            ? _occupiedRoomOptions
            : disabledOptions;
      } else if (lowerTitle.contains('poli') ||
          lowerTitle.contains('spesialisasi')) {
        effectiveOptions =
            _dynamicPoliOptions.isNotEmpty ? _dynamicPoliOptions : options;
        effectiveDisabled = const <String>[];
      }
    }

    final String? selected = await showAmanahBottomSheet<String>(
      context: context,
      builder: (BuildContext context) => AmanahScheduleSelectionSheet(
        title: title,
        subtitle: subtitle,
        currentValue: currentValue,
        options: effectiveOptions,
        disabledOptions: effectiveDisabled,
        optionSubtitles: optionSubtitles,
        occupiedDetails: occupiedDetails,
        sessionId: sessionId,
        isTimePicker: isTimePicker,
      ),
    );
    if (selected != null && mounted) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final bool isEditing = widget.scheduleToEdit != null;

    return AmanahBottomSheetScaffold(
      title: isEditing ? 'Edit Jadwal' : 'Tambah Jadwal',
      trailing: Tooltip(
        message: 'Informasi Ketentuan Praktik',
        triggerMode: TooltipTriggerMode.tap,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => AmanahScheduleDurationInfoDrawer.show(
            context,
            durationMinutes: _getEffectiveDurationForSession(
              _sessions.where((ScheduleFormSession s) => s.active).firstOrNull?.id ?? 'pagi',
            ),
          ),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: (dark ? Colors.white : AmanahColorTokens.brand).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline_rounded,
              size: 16, color: dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand),
          ),
        ),
      ),
      fixedHeightFactor: 0.90,
      minHeight: 520,
      bodyPadding: const EdgeInsets.symmetric(
        horizontal: AmanahSpacing.xxl,
        vertical: AmanahSpacing.lg,
      ),
      footer: AmanahActionRow(
        axis: isEditing ? AmanahActionRowAxis.vertical : AmanahActionRowAxis.horizontal,
        primary: AmanahButton.primary(
          text: isEditing ? 'Simpan Perubahan' : 'Tambah Jadwal',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          isLoading: _isSubmitting,
          onPressed: _handleSave,
        ),
        secondary: isEditing ? AmanahButton.ghost(
          text: 'Hapus',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          customForegroundColor: AmanahColorTokens.dangerDark,
          onPressed: _handleDelete,
        ) : null,
      ),
      body: ScheduleFormBodyContent(
        selectedDate: _selectedDate,
        calendarMonth: _calendarMonth,
        isCalendarOpen: _isCalendarOpen,
        status: _status,
        sessions: _sessions,
        isEditing: isEditing,
        dark: dark,
        onStatusChanged: (String newStatus) => setState(() => _status = newStatus),
        onToggleCalendar: () => setState(() => _isCalendarOpen = !_isCalendarOpen),
        onMonthChanged: (DateTime m) => setState(() => _calendarMonth = m),
        onSelectDate: (DateTime date) {
          setState(() {
            _selectedDate = date;
            _calendarMonth = DateTime(date.year, date.month);
            _isCalendarOpen = false;
          });
          _loadReferenceData();
        },
        onToggleSession: _toggleSession,
        onSlotChanged: _updateSlot,
        onAddSlot: _addTimeSlot,
        onRemoveSlot: _removeTimeSlot,
        onOpenSelection: _openSelectionSheet,
        poliOptions: _dynamicPoliOptions,
        roomOptions: _dynamicRoomOptions,
        occupiedRoomOptions: _occupiedRoomOptions,
        scheduleToEdit: widget.scheduleToEdit,
      ),
    );
  }
}
