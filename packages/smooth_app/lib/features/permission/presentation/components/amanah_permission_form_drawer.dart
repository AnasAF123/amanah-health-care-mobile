import 'package:flutter/material.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';

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
    return showModalBottomSheet<AmanahPermissionFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.60),
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
  late AmanahPermissionType _selectedType;
  late DateTime _startDate;
  late DateTime _endDate;
  late final TextEditingController _reasonController;
  late final TextEditingController _substituteDoctorController;

  String? _startDateError;
  String? _endDateError;
  String? _reasonError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final AmanahPermissionRecord? record = widget.editingRecord;
    if (record != null) {
      _selectedType = record.type;
      _startDate = DateTime.tryParse(record.startDate) ??
          DateTime.now().add(const Duration(days: 3));
      _endDate = DateTime.tryParse(record.endDate) ??
          DateTime.now().add(const Duration(days: 5));
      _reasonController = TextEditingController(text: record.reason);
      _substituteDoctorController =
          TextEditingController(text: record.substituteDoctor ?? '');
    } else {
      _selectedType = AmanahPermissionType.cutiTahunan;
      _startDate = DateTime.now().add(const Duration(days: 3));
      _endDate = DateTime.now().add(const Duration(days: 5));
      _reasonController = TextEditingController();
      _substituteDoctorController =
          TextEditingController(text: 'dr. Budi Santoso, Sp.A');
    }
  }

  @override
  void dispose() {
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

  int get _calculatedDays {
    final int diff = _endDate.difference(_startDate).inDays + 1;
    return diff > 0 ? diff : 1;
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _startDateError = null;
      _endDateError = null;
      _reasonError = null;

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
        Navigator.of(context).pop(
          AmanahPermissionFormData(
            type: _selectedType,
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
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final Color bgColor =
        dark ? const Color(0xFF0A0E1A) : const Color(0xFFFFFFFF);
    final Color borderColor =
        dark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor =
        dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color fieldBg =
        dark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final Color fieldBorder =
        dark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE2E8F0);
    final Color sectionBg =
        dark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC);
    final Color sectionBorder =
        dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9);

    final bool isEditing = widget.editingRecord != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.92,
          minHeight: 520,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.80 : 0.30),
              blurRadius: 45,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            // Interactive Drag Handle
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 4),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.25)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),

            // Header
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    isEditing ? 'Edit perizinan' : 'Pengajuan izin baru',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: dark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF1F5F9),
                      foregroundColor: subtextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Applicant Header Badge
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: sectionBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sectionBorder),
                      ),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.20)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                widget.doctorAvatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Container(
                                    color: const Color(0xFF0A44FF)
                                        .withValues(alpha: 0.30),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.person,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        widget.doctorName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'PlusJakartaSans',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 14,
                                      color: Color(0xFF10B981),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.doctorRole,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: subtextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Field 1: Jenis Perizinan
                    Row(
                      children: <Widget>[
                        Text(
                          'Jenis Perizinan',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 2-column grid for permission types
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AmanahPermissionType.values
                          .map((AmanahPermissionType type) {
                        final bool isSelected = _selectedType == type;
                        final double itemWidth =
                            (MediaQuery.sizeOf(context).width - 48 - 8) / 2;

                        return SizedBox(
                          width: itemWidth,
                          child: InkWell(
                            onTap: () => setState(() => _selectedType = type),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (dark
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFEFF6FF))
                                    : (dark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : const Color(0xFFF8FAFC)),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0A44FF)
                                      : fieldBorder,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: type.colorPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      type.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? (dark
                                                ? Colors.white
                                                : const Color(0xFF1E40AF))
                                            : textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // 3. Field 2: Rentang Tanggal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              'Rentang Tanggal',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              '*',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$_calculatedDays Hari Kerja',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: dark
                                ? const Color(0xFF22D3EE)
                                : const Color(0xFF0A44FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: _pickStartDate,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: fieldBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _startDateError != null
                                      ? const Color(0xFFEF4444)
                                      : fieldBorder,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: subtextColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Mulai',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: subtextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AmanahPermissionRecord.formatDateIndo(
                                              _formatDate(_startDate)),
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 11.5,
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
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: _pickEndDate,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: fieldBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _endDateError != null
                                      ? const Color(0xFFEF4444)
                                      : fieldBorder,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: subtextColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Selesai',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: subtextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          AmanahPermissionRecord.formatDateIndo(
                                              _formatDate(_endDate)),
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 11.5,
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
                          ),
                        ),
                      ],
                    ),
                    if (_endDateError != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        _endDateError!,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // 4. Field 3: Pesan / Alasan Perizinan
                    Row(
                      children: <Widget>[
                        Text(
                          'Pesan / Alasan Perizinan',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          '*',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _reasonController,
                      maxLines: 3,
                      minLines: 2,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        height: 1.45,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan keterangan keperluan izin...',
                        hintStyle: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: subtextColor.withValues(alpha: 0.60),
                        ),
                        filled: true,
                        fillColor: fieldBg,
                        contentPadding: const EdgeInsets.all(14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _reasonError != null
                                ? const Color(0xFFEF4444)
                                : fieldBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF0A44FF),
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
                          fontSize: 10,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),

                    // 5. Field 4: Dokter Pengganti (Opsional)
                    Text(
                      'Dokter Pengganti (Opsional)',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _substituteDoctorController,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nama dokter pengganti...',
                        hintStyle: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          color: subtextColor.withValues(alpha: 0.60),
                        ),
                        prefixIcon: Icon(
                          Icons.medical_services_outlined,
                          size: 16,
                          color: subtextColor,
                        ),
                        filled: true,
                        fillColor: fieldBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF0A44FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 6. Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A44FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEditing
                              ? 'Simpan Perubahan'
                              : 'Kirim Pengajuan Izin',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
