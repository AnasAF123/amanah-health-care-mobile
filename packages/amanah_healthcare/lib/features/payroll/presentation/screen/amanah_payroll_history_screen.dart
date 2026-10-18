import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/domain/amanah_home_data.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/presentation/state/payroll_controller.dart';

class AmanahPayrollHistoryScreen extends StatefulWidget {
  const AmanahPayrollHistoryScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => const AmanahPayrollHistoryScreen(),
    );
  }

  @override
  State<AmanahPayrollHistoryScreen> createState() =>
      _AmanahPayrollHistoryScreenState();
}

class _AmanahPayrollHistoryScreenState
    extends State<AmanahPayrollHistoryScreen> {
  late final PayrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PayrollController();
    _controller.loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final bool isNegative = amount < 0;
    final int absVal = amount.abs().round();
    final String str = absVal.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return '${isNegative ? "- " : ""}Rp $buffer';
  }

  Future<void> _showPeriodPicker(BuildContext context) async {
    final List<PayrollPeriod> periods = _controller.periods;
    if (periods.isEmpty) return;

    final PayrollPeriod? selected = await showModalBottomSheet<PayrollPeriod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        final bool dark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: dark
                ? AmanahColorTokens.canvasDark
                : AmanahColorTokens.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 24 + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: dark
                        ? AmanahColorTokens.neutral700
                        : AmanahColorTokens.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pilih Periode Penggajian',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: dark
                      ? AmanahColorTokens.surfaceLight
                      : AmanahColorTokens.neutral900,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: periods.length,
                  separatorBuilder: (BuildContext _, int _) => const SizedBox(height: 8),
                  itemBuilder: (BuildContext _, int index) {
                    final PayrollPeriod period = periods[index];
                    final bool isCurrent =
                        _controller.selectedPeriod?.id == period.id;

                    return InkWell(
                      onTap: () => Navigator.of(ctx).pop(period),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AmanahColorTokens.sky.withValues(alpha: 0.12)
                              : (dark
                                  ? AmanahColorTokens.neutral800.withValues(alpha: 0.4)
                                  : AmanahColorTokens.neutral100),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrent
                                ? AmanahColorTokens.sky
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    period.periodName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isCurrent
                                          ? AmanahColorTokens.sky
                                          : (dark
                                              ? AmanahColorTokens.surfaceLight
                                              : AmanahColorTokens.neutral900),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${period.periodStart} s/d ${period.periodEnd}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: dark
                                          ? AmanahColorTokens.neutral400
                                          : AmanahColorTokens.neutral600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrent)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AmanahColorTokens.sky,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      _controller.selectPeriod(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = AmanahThemeTokens.canvas(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Laporan Slip Gaji',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (BuildContext context, _) {
                  if (_controller.isLoading && _controller.summary == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (_controller.errorMessage != null &&
                      _controller.summary == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AmanahColorTokens.danger,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _controller.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: dark
                                    ? AmanahColorTokens.neutral400
                                    : AmanahColorTokens.neutral600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AmanahButton.primary(
                              text: 'Coba Lagi',
                              onPressed: _controller.loadInitialData,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final StaffPayrollSummary? summary = _controller.summary;
                  if (summary == null) {
                    return const Center(
                      child: AmanahEmptyState(
                        title: 'Data Belum Tersedia',
                        message:
                            'Belum ada slip gaji yang diproses untuk akun Anda.',
                        tone: AmanahEmptyStateTone.neutral,
                      ),
                    );
                  }

                  return AmanahPullToRefresh(
                    onRefresh: _controller.loadInitialData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // 1. Period Selector Card
                          _buildPeriodSelectorCard(context, dark),
                          const SizedBox(height: 16),

                          // 2. Net Salary Overview Hero Card
                          _buildHeroSalaryCard(summary, dark),
                          const SizedBox(height: 20),

                          // 3. Breakdown Header
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 10),
                            child: Text(
                              'Rincian Komponen Penggajian',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: dark
                                    ? AmanahColorTokens.surfaceLight
                                    : AmanahColorTokens.neutral900,
                              ),
                            ),
                          ),

                          // 4. Entries list
                          if (summary.entries.isEmpty)
                            const AmanahEmptyState(
                              title: 'Tidak Ada Item Rincian',
                              message:
                                  'Tidak ditemukan item komponen pada slip gaji periode ini.',
                              tone: AmanahEmptyStateTone.neutral,
                            )
                          else
                            ...summary.entries.map(
                              (PayrollEntry entry) =>
                                  _buildEntryCard(entry, dark),
                            ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelectorCard(BuildContext context, bool dark) {
    final PayrollPeriod? period = _controller.selectedPeriod;

    return Container(
      decoration: BoxDecoration(
        color: dark
            ? AmanahThemeTokens.surface(context)
            : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark
              ? AmanahThemeTokens.outline(context)
              : AmanahColorTokens.neutral200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPeriodPicker(context),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AmanahColorTokens.sky.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: AmanahColorTokens.sky,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        period?.periodName ?? 'Periode Berjalan',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? AmanahColorTokens.surfaceLight
                              : AmanahColorTokens.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        period != null
                            ? '${period.periodStart} s/d ${period.periodEnd}'
                            : 'Memuat data periode...',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: dark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (period != null)
                  AmanahStatusBadge(
                    text: period.status.toUpperCase(),
                    variant: _resolveStatusVariant(period.status),
                    fontSize: 10,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                  ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: dark
                      ? AmanahColorTokens.neutral400
                      : AmanahColorTokens.neutral600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSalaryCard(StaffPayrollSummary summary, bool dark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? <Color>[
                  const Color(0xFF1E293B),
                  const Color(0xFF0F172A),
                ]
              : <Color>[
                  AmanahColorTokens.neutral900,
                  const Color(0xFF1E293B),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AmanahColorTokens.pureBlack.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Total Gaji Bersih (THP)',
                style: TextStyle(
                  color: AmanahColorTokens.neutral400,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  summary.staffType.toUpperCase(),
                  style: const TextStyle(
                    color: AmanahColorTokens.surfaceLight,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(summary.netPayroll),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: AmanahColorTokens.surfaceLight,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildMetricCol(
                  label: 'Jam Pokok',
                  value: '${summary.baseHours.toStringAsFixed(1)} jam',
                  subValue: _formatCurrency(summary.baseEarnings),
                  color: AmanahColorTokens.surfaceLight,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.12),
              ),
              Expanded(
                child: _buildMetricCol(
                  label: 'Potongan Izin',
                  value: '-${_formatCurrency(summary.leaveDeductions)}',
                  color: const Color(0xFFF87171),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AmanahColorTokens.surfaceLight.withValues(alpha: 0.12),
              ),
              Expanded(
                child: _buildMetricCol(
                  label: 'Insentif/Ganti',
                  value: '+${_formatCurrency(summary.replacementAdditions)}',
                  color: const Color(0xFF4ADE80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCol({
    required String label,
    required String value,
    String? subValue,
    required Color color,
  }) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AmanahColorTokens.neutral400,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        if (subValue != null)
          Text(
            subValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
      ],
    );
  }

  Widget _buildEntryCard(PayrollEntry entry, bool dark) {
    final IconData icon = _resolveEntryIcon(entry.entryType);
    final Color toneColor = _resolveEntryColor(entry.entryType);
    final String typeLabel = _resolveEntryTypeLabel(entry.entryType);
    final bool isPositive = entry.amount >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark
            ? AmanahThemeTokens.surface(context)
            : AmanahColorTokens.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? AmanahThemeTokens.outline(context)
              : AmanahColorTokens.neutral200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: toneColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: toneColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? AmanahColorTokens.surfaceLight
                              : AmanahColorTokens.neutral900,
                        ),
                      ),
                    ),
                    Text(
                      '${isPositive ? "+" : ""}${_formatCurrency(entry.amount)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: toneColor,
                      ),
                    ),
                  ],
                ),
                if (entry.description != null &&
                    entry.description!.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    entry.description!,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: dark
                          ? AmanahColorTokens.neutral400
                          : AmanahColorTokens.neutral600,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '${entry.quantityHours.toStringAsFixed(1)} jam @ ${_formatCurrency(entry.hourlyRate)}/jam',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: dark
                        ? AmanahColorTokens.neutral500
                        : AmanahColorTokens.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AmanahBadgeVariant _resolveStatusVariant(String status) {
    switch (status.toUpperCase()) {
      case 'PAID':
      case 'APPROVED':
        return AmanahBadgeVariant.success;
      case 'CALCULATED':
        return AmanahBadgeVariant.primary;
      case 'DRAFT':
      default:
        return AmanahBadgeVariant.warning;
    }
  }

  IconData _resolveEntryIcon(String type) {
    switch (type) {
      case 'base_scheduled':
        return Icons.event_available_rounded;
      case 'leave_deduction':
        return Icons.event_busy_rounded;
      case 'replacement_addition':
        return Icons.volunteer_activism_rounded;
      case 'overtime_addition':
        return Icons.more_time_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color _resolveEntryColor(String type) {
    switch (type) {
      case 'base_scheduled':
        return AmanahColorTokens.sky;
      case 'leave_deduction':
        return AmanahColorTokens.danger;
      case 'replacement_addition':
        return AmanahColorTokens.success;
      case 'overtime_addition':
        return AmanahColorTokens.brand;
      default:
        return AmanahColorTokens.neutral600;
    }
  }

  String _resolveEntryTypeLabel(String type) {
    switch (type) {
      case 'base_scheduled':
        return 'Jam Pelayanan Pokok';
      case 'leave_deduction':
        return 'Potongan Izin Tidak Hadir';
      case 'replacement_addition':
        return 'Insentif Pengganti Jadwal';
      case 'overtime_addition':
        return 'Tambahan Lembur';
      default:
        return 'Komponen Lainnya';
    }
  }
}
