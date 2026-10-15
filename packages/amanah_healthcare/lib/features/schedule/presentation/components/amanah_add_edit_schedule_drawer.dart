import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/data/amanah_schedule_store.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

/// Doctor Schedule Add & Edit Drawer (Slot-free, clean domain model)
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
  late String _status;
  late String _sessionType;
  late final TextEditingController _titleController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;
  late final TextEditingController _poliController;
  late final TextEditingController _roomController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    final DoctorSchedule? sch = widget.scheduleToEdit;
    _status = sch?.badge ?? 'Buka';
    _sessionType = sch?.sessionType ?? 'Pagi';
    _titleController = TextEditingController(text: sch?.title ?? 'Sesi Pagi');
    _startTimeController = TextEditingController(text: sch?.startTime ?? '08:00');
    _endTimeController = TextEditingController(text: sch?.endTime ?? '12:00');
    _poliController = TextEditingController(text: sch?.poli ?? 'Poli Umum');
    _roomController = TextEditingController(text: sch?.room ?? 'Ruang 101');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _poliController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const List<String> days = <String>[
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    const List<String> months = <String>[
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final String dayName = days[(d.weekday - 1).clamp(0, 6)];
    final String monthName = months[(d.month - 1).clamp(0, 11)];
    return '$dayName, ${d.day} $monthName ${d.year}';
  }

  void _saveSchedule() {
    final AmanahScheduleStore store = AmanahScheduleStore.instance;
    final String dateStr = _formatDate(_selectedDate);
    final String startTime = _startTimeController.text.trim();
    final String endTime = _endTimeController.text.trim();
    final String timeStr = '$startTime - $endTime WIB';

    final AmanahBadgeVariant badgeVariant = _status == 'Cuti'
        ? AmanahBadgeVariant.warning
        : (_status == 'Menunggu'
            ? AmanahBadgeVariant.primary
            : AmanahBadgeVariant.success);

    if (widget.scheduleToEdit != null) {
      final DoctorSchedule updated = widget.scheduleToEdit!.copyWith(
        title: _titleController.text.trim(),
        date: dateStr,
        time: timeStr,
        startTime: startTime,
        endTime: endTime,
        sessionType: _sessionType,
        poli: _poliController.text.trim(),
        room: _roomController.text.trim(),
        badge: _status,
        badgeVariant: badgeVariant,
      );
      store.updateSchedule(_selectedDate, updated);
      if (_status == 'Cuti') {
        store.setDayCuti(_selectedDate, true);
      }
    } else {
      final DoctorSchedule newSch = DoctorSchedule(
        id: 'ses-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        date: dateStr,
        time: timeStr,
        startTime: startTime,
        endTime: endTime,
        sessionType: _sessionType,
        poli: _poliController.text.trim(),
        room: _roomController.text.trim(),
        badge: _status,
        badgeVariant: badgeVariant,
        bookedPatients: const <BookedPatient>[],
      );
      store.addSchedule(_selectedDate, newSch);
    }

    widget.onSavedDate?.call(_selectedDate);
    Navigator.of(context).pop();
  }

  void _deleteSchedule() {
    if (widget.scheduleToEdit != null) {
      AmanahScheduleStore.instance.deleteSchedule(
        _selectedDate,
        widget.scheduleToEdit!.id,
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final bool isEditing = widget.scheduleToEdit != null;

    final Color labelColor = dark
        ? AmanahColorTokens.neutral300
        : AmanahColorTokens.neutral700;

    return AmanahBottomSheetScaffold(
      title: isEditing ? 'Edit Jadwal' : 'Tambah Jadwal',
      maxHeightFactor: 0.88,
      minHeight: 480,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahActionRow(
        axis: isEditing
            ? AmanahActionRowAxis.vertical
            : AmanahActionRowAxis.horizontal,
        primary: AmanahButton.primary(
          text: isEditing ? 'Simpan Perubahan' : 'Tambah Jadwal',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          onPressed: _saveSchedule,
        ),
        secondary: isEditing
            ? AmanahButton.ghost(
                text: 'Hapus',
                size: AmanahButtonSize.medium,
                isFullWidth: true,
                customForegroundColor: AmanahColorTokens.dangerDark,
                onPressed: _deleteSchedule,
              )
            : null,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Status Praktik Selector
            Text(
              'Status Praktik',
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <String>['Buka', 'Menunggu', 'Cuti'].map((String label) {
                final bool active = _status == label;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => _status = label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: active
                              ? (dark
                                  ? AmanahColorTokens.tabActiveDark
                                  : AmanahColorTokens.brand)
                              : (dark
                                  ? AmanahColorTokens.surfaceLight
                                      .withValues(alpha: 0.05)
                                  : AmanahColorTokens.neutral100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: active
                                ? (dark
                                    ? AmanahColorTokens.tabActiveDark
                                    : AmanahColorTokens.brand)
                                : (dark
                                    ? AmanahColorTokens.surfaceLight
                                        .withValues(alpha: 0.10)
                                    : AmanahColorTokens.neutral200),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: active
                                  ? (dark
                                      ? AmanahColorTokens.canvasDark
                                      : AmanahColorTokens.surfaceLight)
                                  : (dark
                                      ? AmanahColorTokens.neutral300
                                      : AmanahColorTokens.neutral700),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Tanggal Praktik
            Text(
              'Tanggal Praktik',
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                      : AmanahColorTokens.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: dark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.12)
                        : AmanahColorTokens.neutral200,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: AmanahColorTokens.neutral400,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formatDate(_selectedDate),
                        style: TextStyle(
                          color: dark
                              ? AmanahColorTokens.surfaceLight
                              : AmanahColorTokens.neutral900,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AmanahColorTokens.neutral400,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sesi / Title
            Text(
              'Judul Sesi Praktik',
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Contoh: Sesi Pagi',
                filled: true,
                fillColor: dark
                    ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                    : AmanahColorTokens.surfaceLight,
                border: _inputBorder(dark),
              ),
            ),
            const SizedBox(height: 16),

            // Jam Mulai & Jam Selesai
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Jam Mulai',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _startTimeController,
                        decoration: InputDecoration(
                          hintText: '08:00',
                          filled: true,
                          fillColor: dark
                              ? AmanahColorTokens.surfaceLight
                                  .withValues(alpha: 0.05)
                              : AmanahColorTokens.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: dark
                                  ? AmanahColorTokens.surfaceLight
                                      .withValues(alpha: 0.12)
                                  : AmanahColorTokens.neutral200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Jam Selesai',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _endTimeController,
                        decoration: InputDecoration(
                          hintText: '12:00',
                          filled: true,
                          fillColor: dark
                              ? AmanahColorTokens.surfaceLight
                                  .withValues(alpha: 0.05)
                              : AmanahColorTokens.surfaceLight,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: dark
                                  ? AmanahColorTokens.surfaceLight
                                      .withValues(alpha: 0.12)
                                  : AmanahColorTokens.neutral200,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Poliklinik & Ruang
            Text(
              'Poliklinik',
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _poliController,
              decoration: InputDecoration(
                hintText: 'Contoh: Poli Spesialis Anak',
                filled: true,
                fillColor: dark
                    ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                    : AmanahColorTokens.surfaceLight,
                border: _inputBorder(dark),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Ruang Praktik',
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                hintText: 'Contoh: Ruang 201',
                filled: true,
                fillColor: dark
                    ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                    : AmanahColorTokens.surfaceLight,
                border: _inputBorder(dark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(bool dark) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: dark
            ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.12)
            : AmanahColorTokens.neutral200,
      ),
    );
  }
}
