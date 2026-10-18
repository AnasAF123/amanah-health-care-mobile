import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/data/repositories/permission_repository_impl.dart';
import 'package:amanah_healthcare/features/permission/domain/amanah_permission_model.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/domain/repositories/permission_repository.dart';
import 'package:amanah_healthcare/features/permission/presentation/theme/amanah_permission_tokens.dart';

class AmanahPermissionFormData {
  const AmanahPermissionFormData({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.scope = 'full_day',
    this.sessionIds,
  });

  final AmanahPermissionType type;
  final String startDate;
  final String endDate;
  final String reason;
  final String scope;
  final List<String>? sessionIds;
}

class AmanahPermissionFormDrawer extends StatefulWidget {
  const AmanahPermissionFormDrawer({
    required this.doctorName,
    required this.doctorRole,
    required this.doctorAvatarUrl,
    this.editingRecord,
    this.repository,
    super.key,
  });

  final String doctorName;
  final String doctorRole;
  final String doctorAvatarUrl;
  final AmanahPermissionRecord? editingRecord;
  final PermissionRepository? repository;

  static Future<AmanahPermissionFormData?> show({
    required BuildContext context,
    required String doctorName,
    required String doctorRole,
    required String doctorAvatarUrl,
    AmanahPermissionRecord? editingRecord,
    PermissionRepository? repository,
  }) {
    return showAmanahBottomSheet<AmanahPermissionFormData>(
      context: context,
      builder: (BuildContext ctx) => AmanahPermissionFormDrawer(
        doctorName: doctorName,
        doctorRole: doctorRole,
        doctorAvatarUrl: doctorAvatarUrl,
        editingRecord: editingRecord,
        repository: repository,
      ),
    );
  }

  @override
  State<AmanahPermissionFormDrawer> createState() =>
      _AmanahPermissionFormDrawerState();
}

class _AmanahPermissionFormDrawerState
    extends State<AmanahPermissionFormDrawer> {
  late final PermissionRepository _repository;
  late final TextEditingController _reasonController;

  AmanahPermissionType _selectedType = AmanahPermissionType.cutiTahunan;
  late DateTime _startDate;
  late DateTime _endDate;
  String _scope = 'full_day'; // 'full_day' or 'session'

  List<EligibleSession> _eligibleSessions = <EligibleSession>[];
  final Set<String> _selectedSessionIds = <String>{};
  bool _isLoadingSessions = false;

  String? _endDateError;
  String? _reasonError;
  String? _sessionError;
  bool _isSubmitting = false;

  final List<AmanahPermissionType> _types = <AmanahPermissionType>[
    AmanahPermissionType.cutiTahunan,
    AmanahPermissionType.izinSakit,
    AmanahPermissionType.seminarSimposium,
    AmanahPermissionType.urusanKeluarga,
    AmanahPermissionType.tugasLuarRS,
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? PermissionRepositoryImpl();
    final AmanahPermissionRecord? record = widget.editingRecord;
    if (record != null) {
      _selectedType = record.type;
      _startDate =
          DateTime.tryParse(record.startDate) ??
          DateTime.now().add(const Duration(days: 3));
      _endDate =
          DateTime.tryParse(record.endDate) ??
          DateTime.now().add(const Duration(days: 5));
      _reasonController = TextEditingController(text: record.reason);
    } else {
      _startDate = DateTime.now().add(const Duration(days: 3));
      _endDate = DateTime.now().add(const Duration(days: 3));
      _reasonController = TextEditingController();
    }

    _loadEligibleSessions();
  }

  @override
  void dispose() {
    _reasonController.dispose();
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

  Future<void> _loadEligibleSessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      final List<EligibleSession> sessions =
          await _repository.getEligibleSessions(_formatDate(_startDate));
      if (mounted) {
        setState(() {
          _eligibleSessions = sessions;
          _selectedSessionIds.clear();
          if (sessions.isNotEmpty) {
            _selectedSessionIds.add(sessions.first.sessionId);
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _eligibleSessions = <EligibleSession>[]);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingSessions = false);
      }
    }
  }

  bool _validate() {
    bool valid = true;
    setState(() {
      _endDateError = null;
      _reasonError = null;
      _sessionError = null;

      if (_endDate.isBefore(_startDate)) {
        _endDateError = 'Tanggal selesai tidak boleh sebelum tanggal mulai';
        valid = false;
      }

      if (_scope == 'session' && _selectedSessionIds.isEmpty) {
        _sessionError = 'Pilih minimal satu sesi yang ingin diajukan izin';
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
      _loadEligibleSessions();
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
      setState(() => _endDate = picked);
    }
  }

  void _handleSubmit() {
    if (!_validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        Navigator.of(context).pop(
          AmanahPermissionFormData(
            type: _selectedType,
            startDate: _formatDate(_startDate),
            endDate: _formatDate(_endDate),
            reason: _reasonController.text.trim(),
            scope: _scope,
            sessionIds: _scope == 'session'
                ? _selectedSessionIds.toList()
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
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
        : AmanahColorTokens.neutral200;
    final Color textColor = dark
        ? AmanahPermissionTokens.textTitleDark
        : AmanahPermissionTokens.textTitleLight;
    final Color subtextColor = dark
        ? AmanahPermissionTokens.textMutedDark
        : AmanahPermissionTokens.textMutedLight;
    final Color inputBg = dark
        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
        : AmanahColorTokens.surfaceLight;

    final bool isEditing = widget.editingRecord != null;

    return AmanahBottomSheetScaffold(
      title: isEditing ? 'Edit perizinan' : 'Pengajuan izin staf',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Jenis / Subjek Perizinan
            Text(
              'Jenis Perizinan *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((AmanahPermissionType t) {
                final bool isSelected = _selectedType == t;
                return ChoiceChip(
                  label: Text(t.label),
                  selected: isSelected,
                  onSelected: (bool sel) {
                    if (sel) setState(() => _selectedType = t);
                  },
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : textColor,
                  ),
                  selectedColor: AmanahColorTokens.brand,
                  backgroundColor: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                      : AmanahColorTokens.canvasLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(
                      color: isSelected ? AmanahColorTokens.brand : borderColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // 2. Rentang Tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Tanggal Izin *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  '$_calculatedDays Hari',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AmanahColorTokens.brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildDatePickerTile(
              label: 'Mulai',
              dateString: _formatDateIndo(_startDate),
              onTap: _pickStartDate,
              dark: dark,
              borderColor: borderColor,
              textColor: textColor,
            ),
            const SizedBox(height: 8),
            _buildDatePickerTile(
              label: 'Selesai',
              dateString: _formatDateIndo(_endDate),
              onTap: _pickEndDate,
              dark: dark,
              borderColor: _endDateError != null
                  ? AmanahColorTokens.danger
                  : borderColor,
              textColor: textColor,
            ),
            if (_endDateError != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                _endDateError!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AmanahColorTokens.danger,
                ),
              ),
            ],
            const SizedBox(height: 18),

            // 3. Lingkup Izin (1 Hari Penuh vs Sesi Tertentu)
            Text(
              'Lingkup Perizinan *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _scope = 'full_day'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _scope == 'full_day'
                          ? AmanahColorTokens.brand.withValues(alpha: 0.12)
                          : inputBg,
                      side: BorderSide(
                        color: _scope == 'full_day'
                            ? AmanahColorTokens.brand
                            : borderColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      '1 Hari Penuh',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _scope == 'full_day'
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _scope == 'full_day'
                            ? AmanahColorTokens.brand
                            : textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _scope = 'session'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _scope == 'session'
                          ? AmanahColorTokens.brand.withValues(alpha: 0.12)
                          : inputBg,
                      side: BorderSide(
                        color: _scope == 'session'
                            ? AmanahColorTokens.brand
                            : borderColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Sesi Tertentu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: _scope == 'session'
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _scope == 'session'
                            ? AmanahColorTokens.brand
                            : textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Sesi Roster Selector if scope == 'session'
            if (_scope == 'session') ...<Widget>[
              const SizedBox(height: 12),
              if (_isLoadingSessions)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (_eligibleSessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AmanahColorTokens.brandSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AmanahColorTokens.brand.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Tidak ditemukan sesi dinas terjadwal pada tanggal ini. Izin akan diproses sebagai izin umum.',
                    style: TextStyle(fontSize: 11, color: AmanahColorTokens.brand),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _eligibleSessions.map((EligibleSession s) {
                    final bool isSelected =
                        _selectedSessionIds.contains(s.sessionId);
                    return FilterChip(
                      label: Text(
                        '${s.sessionCode.toUpperCase()} (${s.startsAt.substring(0, 5)} - ${s.endsAt.substring(0, 5)})',
                      ),
                      selected: isSelected,
                      onSelected: (bool sel) {
                        setState(() {
                          if (sel) {
                            _selectedSessionIds.add(s.sessionId);
                          } else {
                            _selectedSessionIds.remove(s.sessionId);
                          }
                        });
                      },
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : textColor,
                      ),
                      selectedColor: AmanahColorTokens.brand,
                      backgroundColor: inputBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AmanahColorTokens.brand
                              : borderColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              if (_sessionError != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  _sessionError!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AmanahColorTokens.danger,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 18),

            // 4. Pesan / Alasan
            Text(
              'Alasan Pengajuan *',
              style: TextStyle(
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
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'Tuliskan keterangan lengkap keperluan izin Anda...',
                hintStyle: TextStyle(fontSize: 12, color: subtextColor),
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
                        ? AmanahColorTokens.danger
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
                  fontSize: 11,
                  color: AmanahColorTokens.danger,
                ),
              ),
            ],
            const SizedBox(height: AmanahSpacing.xxl),
          ],
        ),
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
              ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
              : AmanahColorTokens.canvasLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: dark
                        ? AmanahColorTokens.brand.withValues(alpha: 0.15)
                        : AmanahColorTokens.brandSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: dark
                        ? AmanahColorTokens.brandSoft
                        : AmanahColorTokens.brand,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                      ),
                    ),
                    Text(
                      dateString,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: AmanahColorTokens.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}
