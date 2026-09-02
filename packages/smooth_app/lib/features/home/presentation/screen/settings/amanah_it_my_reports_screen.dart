import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';

class AmanahReportItem {
  const AmanahReportItem({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.date,
    required this.status, // 'proses' | 'selesai'
    required this.technicianNote,
  });

  final String id;
  final String ticketNumber;
  final String title;
  final String date;
  final String status;
  final String technicianNote;
}

class AmanahItMyReportsScreen extends StatelessWidget {
  const AmanahItMyReportsScreen({
    required this.reports,
    this.onBack,
    this.onOpenChat,
    super.key,
  });

  final List<AmanahReportItem> reports;
  final VoidCallback? onBack;
  final VoidCallback? onOpenChat;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFF8FAFF);
    final Color cardBg = dark ? const Color(0xFF111624) : Colors.white;
    final Color borderColor = dark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Laporan saya',
              onBack: onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  130 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  children: <Widget>[
                    if (reports.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'Belum ada riwayat laporan kendala teknis.',
                            style: TextStyle(
                              color: subtextColor,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final AmanahReportItem report in reports) ...<Widget>[
                        _ReportCard(
                          report: report,
                          dark: dark,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        const SizedBox(height: 12),
                      ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onOpenChat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D66E9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Laporkan kendala baru via chat IT',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.dark,
    required this.cardBg,
    required this.borderColor,
    required this.textColor,
    required this.subtextColor,
  });

  final AmanahReportItem report;
  final bool dark;
  final Color cardBg;
  final Color borderColor;
  final Color textColor;
  final Color subtextColor;

  @override
  Widget build(BuildContext context) {
    final bool isProcessing = report.status == 'proses';

    Color badgeBg;
    Color badgeBorder;
    Color badgeText;
    String badgeLabel;

    if (isProcessing) {
      badgeBg = dark
          ? const Color(0xFF78350F).withValues(alpha: 0.40)
          : const Color(0xFFFFFBEB);
      badgeBorder = dark
          ? const Color(0xFFF59E0B).withValues(alpha: 0.30)
          : const Color(0xFFFDE68A);
      badgeText = dark ? const Color(0xFFFCD34D) : const Color(0xFFB45309);
      badgeLabel = 'Sedang ditangani';
    } else {
      badgeBg = dark
          ? const Color(0xFF064E3B).withValues(alpha: 0.40)
          : const Color(0xFFECFDF5);
      badgeBorder = dark
          ? const Color(0xFF10B981).withValues(alpha: 0.30)
          : const Color(0xFFA7F3D0);
      badgeText = dark ? const Color(0xFF34D399) : const Color(0xFF047857);
      badgeLabel = 'Selesai ditangani';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.35 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                report.ticketNumber,
                style: TextStyle(
                  color: subtextColor,
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeText,
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.title,
            style: TextStyle(
              color: textColor,
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : const Color(0xFFF1F5F9),
              ),
            ),
            child: Text(
              report.technicianNote,
              style: TextStyle(
                color: dark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Diajukan pada: ${report.date}',
            style: TextStyle(
              color: subtextColor,
              fontFamily: 'PlusJakartaSans',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
