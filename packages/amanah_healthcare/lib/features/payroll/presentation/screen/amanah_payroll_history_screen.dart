import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_pull_to_refresh.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/payroll_period.dart';
import 'package:amanah_healthcare/features/payroll/domain/entities/staff_payroll_summary.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/amanah_payroll_action_drawer.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_breakdown_section.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_hero_salary_card.dart';
import 'package:amanah_healthcare/features/payroll/presentation/components/payroll_skeleton_view.dart';
import 'package:amanah_healthcare/features/payroll/presentation/screen/amanah_payroll_history_ledger_screen.dart';
import 'package:amanah_healthcare/features/payroll/presentation/state/payroll_controller.dart';

class AmanahPayrollHistoryScreen extends StatefulWidget {
  const AmanahPayrollHistoryScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (BuildContext context) => const AmanahPayrollHistoryScreen(),
    );
  }

  @override
  State<AmanahPayrollHistoryScreen> createState() => _AmanahPayrollHistoryScreenState();
}

class _AmanahPayrollHistoryScreenState extends State<AmanahPayrollHistoryScreen> {
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
              title: 'Penggajian',
              onBack: () => Navigator.of(context).pop(),
              rightAction: AmanahScreenHeaderIconAction(
                icon: Icons.more_vert_rounded,
                semanticsLabel: 'Menu tindakan penggajian',
                onPressed: () {
                  AmanahPayrollActionDrawer.show(
                    context,
                    onOpenHistory: () {
                      Navigator.of(context).push(AmanahPayrollHistoryLedgerScreen.route());
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (BuildContext context, _) {
                  if (_controller.isLoading && _controller.summary == null) {
                    return const PayrollSkeletonView();
                  }

                  if (_controller.errorMessage != null && _controller.summary == null) {
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
                              onPressed: _controller.loadInitialData,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final StaffPayrollSummary? summary = _controller.summary;
                  final bool hasNoTransactions =
                      summary == null ||
                      (summary.entries.isEmpty &&
                          summary.netPayroll == 0 &&
                          summary.grossEarnings == 0 &&
                          summary.baseHours == 0);

                  if (hasNoTransactions) {
                    return const Center(
                      child: AmanahEmptyState(
                        title: 'Data belum tersedia',
                        message: 'Belum ada slip gaji yang diproses untuk akun Anda.',
                        tone: AmanahEmptyStateTone.neutral,
                      ),
                    );
                  }

                  final bool isClosedPeriod =
                      _controller.selectedPeriod?.status.toLowerCase() == 'finalized';

                  return AmanahPullToRefresh(
                    onRefresh: _controller.loadInitialData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Optional Closed Period Banner
                          if (isClosedPeriod) ...<Widget>[
                            Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AmanahColorTokens.success.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AmanahColorTokens.success.withValues(alpha: 0.30),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.archive_outlined,
                                    size: 16,
                                    color: AmanahColorTokens.success,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Arsip: ${_controller.selectedPeriod!.periodName}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AmanahColorTokens.success,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      final PayrollPeriod active = _controller.periods.firstWhere(
                                        (PayrollPeriod p) => p.status.toLowerCase() != 'finalized',
                                        orElse: () => _controller.periods.first,
                                      );
                                      _controller.selectPeriod(active, context: context);
                                    },
                                    child: const Text(
                                      'Bulan aktif',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: AmanahColorTokens.success,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // 1. Net Salary Overview Hero Card (Hick's Law Minimalist)
                          PayrollHeroSalaryCard(summary: summary),
                          const SizedBox(height: 20),

                          // 2. Unified Chronological Transaction Ledger
                          PayrollBreakdownSection(summary: summary),
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
}
