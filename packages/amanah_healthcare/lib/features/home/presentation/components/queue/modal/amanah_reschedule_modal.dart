import 'package:flutter/material.dart';
import 'package:amanah_healthcare/core/presentation/components/amanah_skeleton.dart';
import 'package:amanah_healthcare/core/time/time.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/modal/dynamic_session_tile.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/modal/patient_reschedule_header_card.dart';
import 'package:amanah_healthcare/features/home/presentation/components/queue/modal/reschedule_date_picker_field.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/reschedule_options_entity.dart';
import 'package:amanah_healthcare/features/queue/presentation/state/amanah_queue_store.dart';

/// Modal Bottom Sheet for rescheduling a clinical queue appointment dynamically.
/// Completely conforms to the session-based paradigm (SSOT from backend).
class AmanahRescheduleModal extends StatefulWidget {
  const AmanahRescheduleModal({
    required this.appointmentId,
    required this.patientName,
    required this.queueNumber,
    required this.onConfirm,
    this.currentDate,
    super.key,
  });

  final String appointmentId;
  final String patientName;
  final String queueNumber;
  final String? currentDate;
  final Future<void> Function({
    required String targetDate,
    required String session,
    String? targetSessionId,
    String? reason,
  }) onConfirm;

  static Future<void> show(
    BuildContext context, {
    required String appointmentId,
    required String patientName,
    required String queueNumber,
    String? currentDate,
    required Future<void> Function({
      required String targetDate,
      required String session,
      String? targetSessionId,
      String? reason,
    }) onConfirm,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (_) => AmanahRescheduleModal(
        appointmentId: appointmentId,
        patientName: patientName,
        queueNumber: queueNumber,
        currentDate: currentDate,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<AmanahRescheduleModal> createState() => _AmanahRescheduleModalState();
}

class _AmanahRescheduleModalState extends State<AmanahRescheduleModal> {
  bool _isLoading = true;
  String? _errorMessage;
  RescheduleOptionsEntity? _options;

  late DateTime _selectedDate;
  RescheduleShiftOption? _selectedShift;
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _loadOptions();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final RescheduleOptionsEntity? result = await AmanahQueueStore.instance
          .getRescheduleOptions(widget.appointmentId);
      if (!mounted) return;

      if (result == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat jadwal alternatif dari server';
        });
        return;
      }

      RescheduleDateOption? initialDateOption;
      if (result.availableDates.isNotEmpty) {
        initialDateOption = result.availableDates.firstWhere(
          (RescheduleDateOption d) => d.shifts.isNotEmpty,
          orElse: () => result.availableDates.first,
        );
      }

      DateTime initialDate = _selectedDate;
      if (initialDateOption != null && initialDateOption.date.isNotEmpty) {
        final DateTime? parsed = DateTime.tryParse(initialDateOption.date);
        if (parsed != null) {
          initialDate = parsed;
        }
      }

      RescheduleShiftOption? initialShift;
      if (initialDateOption != null && initialDateOption.shifts.isNotEmpty) {
        initialShift = initialDateOption.shifts.firstWhere(
          (RescheduleShiftOption s) => s.isAvailable,
          orElse: () => initialDateOption!.shifts.first,
        );
      }

      setState(() {
        _options = result;
        _selectedDate = initialDate;
        _selectedShift = initialShift;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _formatDate(DateTime dt) =>
      formatLocalizedDate(dt, style: 'human_full');

  String _toIsoDate(DateTime dt) => formatIsoDateString(dt);

  List<RescheduleShiftOption> _getShiftsForSelectedDate() {
    if (_options == null) return <RescheduleShiftOption>[];
    final String dateStr = _toIsoDate(_selectedDate);
    for (final RescheduleDateOption d in _options!.availableDates) {
      if (d.date == dateStr) {
        return d.shifts;
      }
    }
    return <RescheduleShiftOption>[];
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (BuildContext ctx, Widget? child) {
        final bool dark = AmanahThemeTokens.isDark(ctx);
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AmanahColorTokens.brandPrimary,
              brightness: dark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        final List<RescheduleShiftOption> currentShifts =
            _getShiftsForSelectedDate();
        if (currentShifts.isNotEmpty) {
          _selectedShift = currentShifts.firstWhere(
            (RescheduleShiftOption s) => s.isAvailable,
            orElse: () => currentShifts.first,
          );
        } else {
          _selectedShift = null;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (_selectedShift == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih sesi praktik yang tersedia.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String targetDateStr = _toIsoDate(_selectedDate);
    final String? reason = _reasonController.text.trim().isNotEmpty
        ? _reasonController.text.trim()
        : null;

    try {
      await widget.onConfirm(
        targetDate: targetDateStr,
        session: _selectedShift!.sessionCode,
        targetSessionId: _selectedShift!.sessionId,
        reason: reason,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);
    final Color cardBg = dark
        ? AmanahColorTokens.surfaceSecondaryDark
        : AmanahColorTokens.neutral50;
    final Color borderColor = dark
        ? AmanahColorTokens.neutral700
        : AmanahColorTokens.neutral200;

    final String formattedDate = _formatDate(_selectedDate);
    final List<RescheduleShiftOption> availableShifts =
        _getShiftsForSelectedDate();

    final String doctorAndServiceText = _options != null
        ? '${_options!.doctorName} • ${_options!.serviceName}'
        : (widget.currentDate != null
            ? 'Jadwal saat ini: ${widget.currentDate}'
            : 'Antrean Hari Ini');

    return AmanahBottomSheetScaffold(
      title: 'Jadwalkan Ulang',
      subtitle: '${widget.patientName} (${widget.queueNumber})',
      footer: AmanahButton.primary(
        text: 'Simpan Perubahan Jadwal',
        isLoading: _isSubmitting,
        leadingIcon: Icons.calendar_month_rounded,
        onPressed: (_isSubmitting ||
                _isLoading ||
                _selectedShift == null ||
                !_selectedShift!.isAvailable)
            ? null
            : _handleSubmit,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Patient & Doctor Info Header Card
            PatientRescheduleHeaderCard(
              queueNumber: widget.queueNumber,
              patientName: widget.patientName,
              doctorAndServiceText: doctorAndServiceText,
            ),
            const SizedBox(height: 20),

            // 2. Target Date Picker
            Text(
              'Tanggal Janji Temu Baru',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            RescheduleDatePickerField(
              formattedDate: formattedDate,
              onTap: _pickDate,
            ),
            const SizedBox(height: 20),

            // 3. Dynamic Sesi / Shift Selector from Backend
            Text(
              'Pilih Sesi / Shift Praktik',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),

            if (_isLoading)
              const Column(
                children: <Widget>[
                  AmanahSkeleton.card(height: 54),
                  SizedBox(height: 8),
                  AmanahSkeleton.card(height: 54),
                ],
              )
            else if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.red, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: _loadOptions,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            else if (availableShifts.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.event_busy_rounded,
                        color: subtextColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tidak ada jadwal sesi praktik dokter pada tanggal ini. Silakan tentukan tanggal lain.',
                        style: TextStyle(fontSize: 12, color: subtextColor),
                      ),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.35,
                ),
                itemCount: availableShifts.length,
                itemBuilder: (BuildContext context, int index) {
                  final RescheduleShiftOption shift = availableShifts[index];
                  final bool isSelected =
                      _selectedShift?.sessionId == shift.sessionId;
                  return DynamicSessionTile(
                    shift: shift,
                    isSelected: isSelected,
                    onTap: shift.isAvailable
                        ? () => setState(() => _selectedShift = shift)
                        : null,
                  );
                },
              ),
            const SizedBox(height: 20),

            // 4. Reason Text Field
            Text(
              'Alasan Perubahan Jadwal (Opsional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 3,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                hintText:
                    'Contoh: Pasien berhalangan hadir, permintaan dokter jaga, dsb.',
                hintStyle: TextStyle(color: subtextColor, fontSize: 13),
                filled: true,
                fillColor: cardBg,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AmanahColorTokens.brandPrimary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
