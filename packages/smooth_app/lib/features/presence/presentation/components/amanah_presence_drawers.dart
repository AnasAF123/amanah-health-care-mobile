import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:smooth_app/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:smooth_app/features/presence/data/amanah_presence_store.dart';
import 'package:smooth_app/features/presence/domain/amanah_presence_model.dart';

/// 1. Filter Master Drawer for Attendance History
class AmanahPresenceFilterDrawer extends StatefulWidget {
  const AmanahPresenceFilterDrawer({
    required this.initialStatus,
    required this.initialUnit,
    required this.initialDay,
    super.key,
  });

  final AttendanceStatus? initialStatus;
  final String initialUnit;
  final int? initialDay;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required AttendanceStatus? currentStatus,
    required String currentUnit,
    required int? currentDay,
  }) {
    return showAmanahBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext ctx) => AmanahPresenceFilterDrawer(
        initialStatus: currentStatus,
        initialUnit: currentUnit,
        initialDay: currentDay,
      ),
    );
  }

  @override
  State<AmanahPresenceFilterDrawer> createState() =>
      _AmanahPresenceFilterDrawerState();
}

class _AmanahPresenceFilterDrawerState
    extends State<AmanahPresenceFilterDrawer> {
  late AttendanceStatus? _draftStatus;
  late String _draftUnit;
  late int? _draftDay;

  @override
  void initState() {
    super.initState();
    _draftStatus = widget.initialStatus;
    _draftUnit = widget.initialUnit;
    _draftDay = widget.initialDay;
  }

  void _reset() {
    setState(() {
      _draftStatus = null;
      _draftUnit = 'all';
      _draftDay = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(<String, dynamic>{
      'status': _draftStatus,
      'unit': _draftUnit,
      'day': _draftDay,
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double bottomNavPadding = MediaQuery.viewPaddingOf(context).bottom;

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFFFFFFF);
    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return SizedBox(
      height: screenHeight * 0.85,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.80 : 0.25),
              blurRadius: 45,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Column(
            children: <Widget>[
              // Drag Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.20)
                          : AmanahColorTokens.neutral300,
                      borderRadius: BorderRadius.circular(AmanahRadius.pill),
                    ),
                  ),
                ),
              ),

              // Master Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Filter Presensi',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sesuaikan status, unit, atau tanggal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        AmanahButton.text(
                          text: 'Reset',
                          onPressed: _reset,
                          size: AmanahButtonSize.small,
                          customForegroundColor: subtextColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Detail Content Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 1. Status Filter Pills
                      Text(
                        'Status Presensi',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: kStatusOptions
                            .map((
                              AttendanceFilterOption<AttendanceStatus?> opt,
                            ) {
                              final bool isSelected = _draftStatus == opt.value;
                              return InkWell(
                                onTap: () =>
                                    setState(() => _draftStatus = opt.value),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AmanahColorTokens.brand
                                        : (dark
                                              ? Colors.white.withValues(
                                                  alpha: 0.05,
                                                )
                                              : const Color(0xFFF8FAFC)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AmanahColorTokens.brand
                                          : (dark
                                                ? Colors.white.withValues(
                                                    alpha: 0.10,
                                                  )
                                                : const Color(0xFFE2E8F0)),
                                    ),
                                    boxShadow: isSelected
                                        ? <BoxShadow>[
                                            BoxShadow(
                                              color: AmanahColorTokens.brand
                                                  .withValues(alpha: 0.28),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    opt.label,
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : (dark
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFF334155)),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 20),

                      // 2. Unit Penugasan Filter Pills
                      Text(
                        'Unit Penugasan',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: subtextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: kUnitOptions
                            .map((AttendanceFilterOption<String> opt) {
                              final bool isSelected = _draftUnit == opt.value;
                              return InkWell(
                                onTap: () =>
                                    setState(() => _draftUnit = opt.value),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AmanahColorTokens.brand
                                        : (dark
                                              ? Colors.white.withValues(
                                                  alpha: 0.05,
                                                )
                                              : const Color(0xFFF8FAFC)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AmanahColorTokens.brand
                                          : (dark
                                                ? Colors.white.withValues(
                                                    alpha: 0.10,
                                                  )
                                                : const Color(0xFFE2E8F0)),
                                    ),
                                    boxShadow: isSelected
                                        ? <BoxShadow>[
                                            BoxShadow(
                                              color: AmanahColorTokens.brand
                                                  .withValues(alpha: 0.28),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    opt.label,
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : (dark
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFF334155)),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 20),

                      // 3. Calendar Grid (Agustus 2026)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Pilih Tanggal',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: subtextColor,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Agustus 2026',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_left_rounded,
                                size: 16,
                                color: subtextColor.withValues(alpha: 0.40),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: subtextColor.withValues(alpha: 0.40),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Calendar Grid Box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.05)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.10)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            // Days Header: Sen Sel Rab Kam Jum Sab Min
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                _CalendarHeaderDay('Sen'),
                                _CalendarHeaderDay('Sel'),
                                _CalendarHeaderDay('Rab'),
                                _CalendarHeaderDay('Kam'),
                                _CalendarHeaderDay('Jum'),
                                _CalendarHeaderDay('Sab'),
                                _CalendarHeaderDay('Min'),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Day Cells Grid (Offset 5 for Saturday Aug 1, 2026)
                            _buildAugustCalendarGrid(dark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  28.0 + bottomNavPadding,
                ),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: AmanahButton.primary(
                  text: 'Terapkan Filter',
                  size: AmanahButtonSize.medium,
                  isFullWidth: true,
                  onPressed: _apply,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAugustCalendarGrid(bool dark) {
    const int leadingOffset = 5;
    const int totalDays = 31;
    const List<int> eventDays = <int>[25, 24, 23, 22, 20, 19, 18];

    final List<Widget> cells = <Widget>[];

    // Leading empty cells
    for (int i = 0; i < leadingOffset; i++) {
      cells.add(const SizedBox(width: 28, height: 28));
    }

    // Day cells 1 to 31
    for (int day = 1; day <= totalDays; day++) {
      final bool isSelected = _draftDay == day;
      final bool hasEvent = eventDays.contains(day);

      cells.add(
        InkWell(
          onTap: () {
            setState(() {
              _draftDay = _draftDay == day ? null : day;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isSelected
                  ? AmanahColorTokens.brand
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: AmanahColorTokens.brand.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (dark
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFF334155)),
                  ),
                ),
                if (hasEvent && !isSelected)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Wrap in rows of 7
    final List<Widget> rowWidgets = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final int end = (i + 7 < cells.length) ? i + 7 : cells.length;
      final List<Widget> chunk = cells.sublist(i, end);
      while (chunk.length < 7) {
        chunk.add(const SizedBox(width: 28, height: 28));
      }
      rowWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: chunk,
          ),
        ),
      );
    }

    return Column(children: rowWidgets);
  }
}

class _CalendarHeaderDay extends StatelessWidget {
  const _CalendarHeaderDay(this.day);

  final String day;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

/// 2. Leave Reason Master Drawer ("Alasan Cuti Dokter")
class AmanahPresenceLeaveReasonDrawer extends StatelessWidget {
  const AmanahPresenceLeaveReasonDrawer({required this.record, super.key});

  final AttendanceRecord record;

  static void show(BuildContext context, {required AttendanceRecord record}) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) =>
          AmanahPresenceLeaveReasonDrawer(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFFFFFFF);
    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final double screenHeight = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: screenHeight * 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.80 : 0.25),
              blurRadius: 45,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Column(
            children: <Widget>[
              // Drag Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.20)
                          : AmanahColorTokens.neutral300,
                      borderRadius: BorderRadius.circular(AmanahRadius.pill),
                    ),
                  ),
                ),
              ),

              // Master Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Alasan Cuti Dokter',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${record.date} • ${record.time}',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AmanahComponentSize.iconButton),
                  ],
                ),
              ),

              // Detail Content Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Keterangan Alasan',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: subtextColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0x336366F1)
                                  : const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6366F1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Disetujui',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        record.reason ??
                            'Izin cuti resmi terjadwal yang telah disetujui manajemen RS Amanah.',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFFFFFFF);
    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final double screenHeight = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: screenHeight * 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.80 : 0.25),
              blurRadius: 45,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: Column(
            children: <Widget>[
              // Drag Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.20)
                          : AmanahColorTokens.neutral300,
                      borderRadius: BorderRadius.circular(AmanahRadius.pill),
                    ),
                  ),
                ),
              ),

              // Master Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Keterangan Timeline Presensi',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AmanahComponentSize.iconButton),
                  ],
                ),
              ),

              // Detail Content Body
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Data timeline presensi diakumulasikan secara otomatis setiap bulan berdasarkan shift dan jadwal yang terdaftar di sistem RS Amanah:',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: subtextColor,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _InfoStatusRow(
                        dotColor: Color(0xFF10B981),
                        title: 'Hadir',
                        description: 'Tepat waktu sesuai shift',
                      ),
                      const _InfoStatusRow(
                        dotColor: Color(0xFFFBBF24),
                        title: 'Telat',
                        description: 'Melewati toleransi shift',
                      ),
                      const _InfoStatusRow(
                        dotColor: Color(0xFFF43F5E),
                        title: 'Missed',
                        description: 'Tidak tercatat check-in',
                      ),
                      const _InfoStatusRow(
                        dotColor: Color(0xFF6366F1),
                        title: 'Cuti',
                        description: 'Izin atau cuti resmi HRD',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
                      ? Colors.white.withValues(alpha: 0.05)
                      : const Color(0xFFF1F5F9),
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
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white : const Color(0xFF0F172A),
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
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
