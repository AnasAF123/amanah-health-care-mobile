import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/data/amanah_presence_store.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';

/// 1. Filter Master Drawer for Attendance History
class AmanahPresenceFilterDrawer extends StatefulWidget {
  const AmanahPresenceFilterDrawer({
    required this.initialStatus,
    required this.initialUnit,
    required this.initialDay,
    this.initialDate,
    this.unitOptions = const <AttendanceFilterOption<String>>[],
    this.focusedDate,
    this.eventDays = const <int>{},
    super.key,
  });

  final AttendanceStatus? initialStatus;
  final String initialUnit;
  final int? initialDay;
  final DateTime? initialDate;
  final List<AttendanceFilterOption<String>> unitOptions;
  final DateTime? focusedDate;
  final Set<int> eventDays;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required AttendanceStatus? currentStatus,
    required String currentUnit,
    required int? currentDay,
    DateTime? currentDate,
    List<AttendanceFilterOption<String>> unitOptions = const <AttendanceFilterOption<String>>[],
    DateTime? focusedDate,
    Set<int> eventDays = const <int>{},
  }) {
    return showAmanahBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext ctx) => AmanahPresenceFilterDrawer(
        initialStatus: currentStatus,
        initialUnit: currentUnit,
        initialDay: currentDay,
        initialDate: currentDate,
        unitOptions: unitOptions,
        focusedDate: focusedDate,
        eventDays: eventDays,
      ),
    );
  }

  @override
  State<AmanahPresenceFilterDrawer> createState() => _AmanahPresenceFilterDrawerState();
}

class _AmanahPresenceFilterDrawerState extends State<AmanahPresenceFilterDrawer> {
  late AttendanceStatus? _draftStatus;
  late String _draftUnit;
  late int? _draftDay;
  late DateTime? _draftDate;

  @override
  void initState() {
    super.initState();
    _draftStatus = widget.initialStatus;
    _draftUnit = widget.initialUnit;
    _draftDay = widget.initialDay;
    _draftDate = widget.initialDate;
  }

  void _reset() {
    setState(() {
      _draftStatus = null;
      _draftUnit = 'all';
      _draftDay = null;
      _draftDate = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(<String, dynamic>{
      'status': _draftStatus,
      'unit': _draftUnit,
      'day': _draftDay,
      'date': _draftDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color subtextColor = dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;
    final Color selectedAccent = dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand;
    final Color selectedForeground = dark
        ? AmanahColorTokens.canvasDark
        : AmanahColorTokens.surfaceLight;

    return AmanahBottomSheetScaffold(
      title: 'Filter Presensi',
      subtitle: 'Sesuaikan status, unit, atau tanggal',
      hugContent: true,
      trailing: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          final DateTime now = DateTime.now();
          final DateTime initial = _draftDate ?? widget.focusedDate ?? now;
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: now.subtract(const Duration(days: 365)),
            lastDate: now.add(const Duration(days: 365)),
            builder: (BuildContext ctx, Widget? child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: selectedAccent,
                    brightness: dark ? Brightness.dark : Brightness.light,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null && mounted) {
            setState(() {
              _draftDate = picked;
              _draftDay = picked.day;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _draftDate != null || _draftDay != null
                ? selectedAccent.withValues(alpha: 0.15)
                : (dark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _draftDate != null || _draftDay != null
                  ? selectedAccent.withValues(alpha: 0.4)
                  : (dark ? AmanahColorTokens.neutral700 : AmanahColorTokens.neutral200),
            ),
          ),
          child: Icon(
            Icons.calendar_month_outlined,
            size: 19,
            color: _draftDate != null || _draftDay != null
                ? selectedAccent
                : (dark ? AmanahColorTokens.neutral300 : AmanahColorTokens.neutral700),
          ),
        ),
      ),
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahActionRow(
        secondary: AmanahButton.ghost(
          text: 'Reset',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          customForegroundColor: subtextColor,
          onPressed: _reset,
        ),
        primary: AmanahButton.primary(
          text: 'Terapkan Filter',
          size: AmanahButtonSize.medium,
          isFullWidth: true,
          onPressed: _apply,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Active Date Filter Chip if selected
          if (_draftDate != null || _draftDay != null) ...<Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Tanggal Filter:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subtextColor),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: selectedAccent.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _draftDate != null
                            ? '${_draftDate!.day} ${_monthNameShort(_draftDate!.month)} ${_draftDate!.year}'
                            : 'Tanggal $_draftDay',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: selectedAccent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() {
                          _draftDate = null;
                          _draftDay = null;
                        }),
                        child: Icon(Icons.close_rounded, size: 14, color: selectedAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // 1. Status Filter Horizontal Scrollable Row
          Text(
            'Status Presensi',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subtextColor),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: kStatusOptions
                  .map((AttendanceFilterOption<AttendanceStatus?> opt) {
                    final bool isSelected = _draftStatus == opt.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _draftStatus = opt.value),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? selectedAccent
                                : (dark
                                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                                      : AmanahColorTokens.canvasLight),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? selectedAccent
                                  : (dark
                                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                                        : AmanahColorTokens.neutral200),
                            ),
                          ),
                          child: Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? selectedForeground
                                  : (dark
                                        ? AmanahColorTokens.neutral300
                                        : AmanahColorTokens.neutral700),
                            ),
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Unit Penugasan Horizontal Scrollable Row
          if (widget.unitOptions.isNotEmpty) ...<Widget>[
            Text(
              'Unit Penugasan',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subtextColor),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: widget.unitOptions
                    .map((AttendanceFilterOption<String> opt) {
                      final bool isSelected = _draftUnit == opt.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _draftUnit = opt.value),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedAccent
                                  : (dark
                                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                                        : AmanahColorTokens.canvasLight),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? selectedAccent
                                    : (dark
                                          ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.10)
                                          : AmanahColorTokens.neutral200),
                              ),
                            ),
                            child: Text(
                              opt.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected
                                    ? selectedForeground
                                    : (dark
                                          ? AmanahColorTokens.neutral300
                                          : AmanahColorTokens.neutral700),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  static String _monthNameShort(int month) {
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }
}

/// 2. Leave Reason Master Drawer ("Alasan Cuti Dokter")
class AmanahPresenceLeaveReasonDrawer extends StatelessWidget {
  const AmanahPresenceLeaveReasonDrawer({required this.record, super.key});

  final AttendanceRecord record;

  static void show(BuildContext context, {required AttendanceRecord record}) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahPresenceLeaveReasonDrawer(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color textColor = dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900;
    final Color subtextColor = dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    return AmanahBottomSheetScaffold(
      title: 'Alasan Cuti Dokter',
      subtitle: '${record.date} - ${record.time}',
      fixedHeightFactor: 0.45,
      minHeight: 300,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Keterangan Alasan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subtextColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.violet.withValues(alpha: 0.20)
                      : AmanahColorTokens.violetSurface,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AmanahColorTokens.violet,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Disetujui',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AmanahColorTokens.violetDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.reason ?? 'Izin cuti resmi terjadwal yang telah disetujui manajemen RS Amanah.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}

/// 3. Info Master Drawer ("Keterangan Timeline Presensi")
class AmanahPresenceInfoDrawer extends StatelessWidget {
  const AmanahPresenceInfoDrawer({super.key});

  static void show(BuildContext context) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => const AmanahPresenceInfoDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color subtextColor = dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    return AmanahBottomSheetScaffold(
      title: 'Keterangan Timeline Presensi',
      fixedHeightFactor: 0.55,
      minHeight: 340,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Data timeline presensi diakumulasikan secara otomatis setiap bulan berdasarkan shift dan jadwal yang terdaftar di sistem RS Amanah:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: subtextColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          const _InfoStatusRow(
            dotColor: AmanahColorTokens.success,
            title: 'Hadir',
            description: 'Tepat waktu sesuai shift',
          ),
          const _InfoStatusRow(
            dotColor: AmanahColorTokens.amberLight,
            title: 'Telat',
            description: 'Melewati toleransi shift',
          ),
          const _InfoStatusRow(
            dotColor: AmanahColorTokens.danger,
            title: 'Missed',
            description: 'Tidak tercatat check-in',
          ),
          const _InfoStatusRow(
            dotColor: AmanahColorTokens.violet,
            title: 'Cuti',
            description: 'Izin atau cuti resmi HRD',
            isLast: true,
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}

class _InfoStatusRow extends StatelessWidget {
  const _InfoStatusRow({
    required this.dotColor,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final Color dotColor;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: dark
                      ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                      : AmanahColorTokens.neutral100,
                ),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              description,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
