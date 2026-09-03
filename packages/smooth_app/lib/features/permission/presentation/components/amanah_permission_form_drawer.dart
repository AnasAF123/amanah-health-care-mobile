import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';
import 'package:smooth_app/features/permission/presentation/theme/amanah_permission_tokens.dart';

class AmanahPermissionFormData {
  const AmanahPermissionFormData({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.substituteDoctor,
  });

  final AmanahPermissionType type;
  final String startDate;
  final String endDate;
  final String reason;
  final String? substituteDoctor;
}

/// Permission Form Drawer (Create & Edit matching Web prototype lines 1062-1230)
class AmanahPermissionFormDrawer extends StatefulWidget {
  const AmanahPermissionFormDrawer({
    required this.doctorName,
    required this.doctorRole,
    required this.doctorAvatarUrl,
    this.editingRecord,
    super.key,
  });

  final String doctorName;
  final String doctorRole;
  final String doctorAvatarUrl;
  final AmanahPermissionRecord? editingRecord;

  static Future<AmanahPermissionFormData?> show({
    required BuildContext context,
    required String doctorName,
    required String doctorRole,
    required String doctorAvatarUrl,
    AmanahPermissionRecord? editingRecord,
  }) {
    return showAmanahBottomSheet<AmanahPermissionFormData>(
      context: context,
      builder: (BuildContext ctx) => AmanahPermissionFormDrawer(
        doctorName: doctorName,
        doctorRole: doctorRole,
        doctorAvatarUrl: doctorAvatarUrl,
        editingRecord: editingRecord,
      ),
    );
  }

  @override
  State<AmanahPermissionFormDrawer> createState() =>
      _AmanahPermissionFormDrawerState();
}

class _AmanahPermissionFormDrawerState
    extends State<AmanahPermissionFormDrawer> {
  late final TextEditingController _typeController;
  late final TextEditingController _reasonController;
  late final TextEditingController _substituteDoctorController;

  late DateTime _startDate;
  late DateTime _endDate;

  String? _typeError;
  String? _endDateError;
  String? _reasonError;
  bool _isSubmitting = false;

  final List<String> _typeSuggestions = <String>[
    'Cuti Tahunan',
    'Seminar / Simposium',
    'Urusan Keluarga',
    'Tugas Luar RS',
    'Izin Sakit',
  ];

  @override
  void initState() {
    super.initState();
    final AmanahPermissionRecord? record = widget.editingRecord;
    if (record != null) {
      _typeController = TextEditingController(text: record.type.label);
      _startDate =
          DateTime.tryParse(record.startDate) ??
          DateTime.now().add(const Duration(days: 3));
      _endDate =
          DateTime.tryParse(record.endDate) ??
          DateTime.now().add(const Duration(days: 5));
      _reasonController = TextEditingController(text: record.reason);
      _substituteDoctorController = TextEditingController(
        text: record.substituteDoctor ?? '',
      );
    } else {
      _typeController = TextEditingController(text: 'Cuti Tahunan');
      _startDate = DateTime.now().add(const Duration(days: 3));
      _endDate = DateTime.now().add(const Duration(days: 5));
      _reasonController = TextEditingController();
      _substituteDoctorController = TextEditingController(
        text: 'dr. Budi Santoso, Sp.A',
      );
    }
  }

  @override
  void dispose() {
    _typeController.dispose();
    _reasonController.dispose();
    _substituteDoctorController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final String y = dt.year.toString().padLeft(4, '0');
    final String m = dt.month.toString().padLeft(2, '0');
    final String d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatDateIndo(DateTime dt) {
    const List<String> monthNames = <String>[
      '',
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
    return '${dt.day} ${monthNames[dt.month]} ${dt.year}';
  }

  int get _calculatedDays {
    final int diff = _endDate.difference(_startDate).inDays + 1;
    return diff > 0 ? diff : 1;
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _typeError = null;
      _endDateError = null;
      _reasonError = null;

      if (_typeController.text.trim().isEmpty) {
        _typeError = 'Subjek perizinan wajib diisi';
        valid = false;
      }

      if (_endDate.isBefore(_startDate)) {
        _endDateError = 'Tanggal selesai tidak boleh sebelum tanggal mulai';
        valid = false;
      }

      final String reason = _reasonController.text.trim();
      if (reason.isEmpty) {
        _reasonError = 'Pesan / alasan perizinan wajib diisi';
        valid = false;
      } else if (reason.length < 8) {
        _reasonError = 'Tuliskan alasan minimal 8 karakter';
        valid = false;
      }
    });

    return valid;
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Mulai Izin',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Selesai Izin',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _handleSubmit() {
    if (!_validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final AmanahPermissionType matchedType =
            AmanahPermissionType.fromString(_typeController.text.trim());

        Navigator.of(context).pop(
          AmanahPermissionFormData(
            type: matchedType,
            startDate: _formatDate(_startDate),
            endDate: _formatDate(_endDate),
            reason: _reasonController.text.trim(),
            substituteDoctor: _substituteDoctorController.text.trim().isNotEmpty
                ? _substituteDoctorController.text.trim()
                : null,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE2E8F0);
    final Color textColor = dark
        ? AmanahPermissionTokens.textTitleDark
        : AmanahPermissionTokens.textTitleLight;
    final Color subtextColor = dark
        ? AmanahPermissionTokens.textMutedDark
        : AmanahPermissionTokens.textMutedLight;
    final Color inputBg = dark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFFFFFFF);

    final bool isEditing = widget.editingRecord != null;

    return AmanahBottomSheetScaffold(
      title: isEditing ? 'Edit perizinan' : 'Pengajuan izin baru',
      fixedHeightFactor: 0.92,
      minHeight: 520,
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
          customForegroundColor: subtextColor,
          onPressed: () => Navigator.of(context).pop(),
        ),
        primary: AmanahButton.primary(
          text: isEditing ? 'Simpan Perubahan' : 'Kirim Pengajuan Izin',
          isLoading: _isSubmitting,
          isFullWidth: true,
          size: AmanahButtonSize.medium,
          onPressed: _handleSubmit,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Field 1: Subjek Perizinan
          Text(
            'Subjek Perizinan *',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _typeController,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: 'Contoh: Urusan Keluarga, Seminar / Simposium, Cuti...',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: subtextColor,
              ),
              filled: true,
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _typeError != null
                      ? const Color(0xFFFB2C36)
                      : borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AmanahColorTokens.brand,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (_typeError != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              _typeError!,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                color: Color(0xFFFB2C36),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // Quick Suggestion Chips
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _typeSuggestions.map((String s) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _typeController.text = s;
                    _typeError = null;
                  });
                },
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: dark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: subtextColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // Field 2: Rentang Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Rentang Tanggal *',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_calculatedDays Hari Kerja',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Start Date Selector Button
          _buildDatePickerTile(
            label: 'Mulai Izin',
            dateString: _formatDateIndo(_startDate),
            onTap: _pickStartDate,
            dark: dark,
            borderColor: borderColor,
            textColor: textColor,
          ),
          const SizedBox(height: 8),

          // End Date Selector Button
          _buildDatePickerTile(
            label: 'Selesai Izin',
            dateString: _formatDateIndo(_endDate),
            onTap: _pickEndDate,
            dark: dark,
            borderColor: _endDateError != null
                ? const Color(0xFFFB2C36)
                : borderColor,
            textColor: textColor,
          ),
          if (_endDateError != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              _endDateError!,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                color: Color(0xFFFB2C36),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 18),

          // Field 3: Pesan / Alasan Perizinan
          Text(
            'Pesan / Alasan Perizinan *',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: 'Tuliskan keterangan keperluan izin...',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: subtextColor,
              ),
              filled: true,
              fillColor: inputBg,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _reasonError != null
                      ? const Color(0xFFFB2C36)
                      : borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AmanahColorTokens.brand,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (_reasonError != null) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              _reasonError!,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                color: Color(0xFFFB2C36),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 18),

          // Field 4: Dokter Pengganti (Opsional)
          Row(
            children: <Widget>[
              Text(
                'Dokter Pengganti',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(Opsional)',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: subtextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _substituteDoctorController,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: 'Nama dokter pengganti...',
              hintStyle: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: subtextColor,
              ),
              filled: true,
              fillColor: inputBg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AmanahColorTokens.brand,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildDatePickerTile({
    required String label,
    required String dateString,
    required VoidCallback onTap,
    required bool dark,
    required Color borderColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: dark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: dark
                          ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: dark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF0D66E9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: dark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          dateString,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: dark ? const Color(0xFF94A3B8) : const Color(0xFF90A1B9),
            ),
          ],
        ),
      ),
    );
  }
}
