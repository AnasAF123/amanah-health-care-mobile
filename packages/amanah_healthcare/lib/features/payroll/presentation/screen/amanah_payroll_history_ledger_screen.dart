import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/monthly_payroll_group.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_entry.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_entry_tile.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_export_period_drawer.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_skeleton_view.dart';
import 'package:amanah_healthcare/features/payroll/presentation/state/payroll_controller.dart';
import 'package:amanah_healthcare/features/payroll/presentation/utils/payroll_formatters.dart';

class AmanahPayrollHistoryLedgerScreen extends StatefulWidget {
  const AmanahPayrollHistoryLedgerScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => const AmanahPayrollHistoryLedgerScreen(),
    );
  }

  @override
  State<AmanahPayrollHistoryLedgerScreen> createState() => _AmanahPayrollHistoryLedgerScreenState();
}

class _AmanahPayrollHistoryLedgerScreenState extends State<AmanahPayrollHistoryLedgerScreen> {
  late final PayrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PayrollController();
    _controller.loadHistoryLedger(context: context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openExportDrawer() {
    PayrollExportPeriodDrawer.show(
      context: context,
      periods: _controller.periods,
    );
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
              title: 'History Penggajian',
              onBack: () => Navigator.of(context).pop(),
              trailing: AmanahScreenHeaderIconAction(
                icon: Icons.download_rounded,
                semanticsLabel: 'Unduh Rekap Penggajian',
                onPressed: _openExportDrawer,
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (BuildContext context, _) {
                  if (_controller.isHistoryLoading && _controller.historyGroups.isEmpty) {
                    return const PayrollSkeletonView();
                  }

                  if (_controller.errorMessage != null && _controller.historyGroups.isEmpty) {
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
                              text: 'Coba lagi',
                              onPressed: () => _controller.loadHistoryLedger(context: context),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final List<MonthlyPayrollGroup> groups = _controller.historyGroups;
                  if (groups.isEmpty) {
                    return const Center(
                      child: AmanahEmptyState(
                        title: 'Riwayat Kosong',
                        message: 'Belum ada riwayat buku besar penggajian yang tercatat.',
                        tone: AmanahEmptyStateTone.neutral,
                      ),
                    );
                  }

                  return AmanahPullToRefresh(
                    onRefresh: () => _controller.loadHistoryLedger(context: context),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: groups.length,
                      itemBuilder: (BuildContext context, int index) {
                        final MonthlyPayrollGroup group = groups[index];
                        return _MonthlyGroupLedgerSection(group: group, dark: dark);
                      },
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
}

class _MonthlyGroupLedgerSection extends StatelessWidget {
  const _MonthlyGroupLedgerSection({required this.group, required this.dark});

  final MonthlyPayrollGroup group;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final List<PayrollEntry> entries = group.entries;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Month Header Row (Matching User Wireframe: "oktober 2026    Rp 4.350.000")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  group.monthLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                  ),
                ),
                Text(
                  PayrollFormatters.currency(group.totalNet),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Tidak ada transaksi pada bulan ini',
                style: TextStyle(
                  fontSize: 11.5,
                  color: dark ? AmanahColorTokens.neutral500 : AmanahColorTokens.neutral400,
                ),
              ),
            )
          else
            ...entries.map((PayrollEntry entry) => PayrollEntryTile(entry: entry)),
        ],
      ),
    );
  }
}
