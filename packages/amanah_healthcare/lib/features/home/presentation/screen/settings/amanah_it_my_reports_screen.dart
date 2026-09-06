import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_typography_tokens.dart';

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

    final Color bgColor = AmanahThemeTokens.canvas(context);
    final Color cardBg = AmanahThemeTokens.surface(context);
    final Color borderColor = AmanahThemeTokens.outline(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(title: 'Laporan saya', onBack: onBack),
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
                    if (reports.isEmpty) ...<Widget>[
                      AmanahEmptyState.card(
                        icon: Icons.assignment_outlined,
                        title: 'Belum Ada Laporan Kendala',
                        message:
                            'Belum ada riwayat laporan kendala teknis yang Anda ajukan.',
                        actionText: 'Laporkan kendala baru via chat IT',
                        actionLeadingIcon: Icons.chat_bubble_outline_rounded,
                        onAction: onOpenChat,
                      ),
                    ] else ...<Widget>[
                      for (final AmanahReportItem report
                          in reports) ...<Widget>[
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
                      AmanahButton.primary(
                        text: 'Laporkan kendala baru via chat IT',
                        isFullWidth: true,
                        size: AmanahButtonSize.medium,
                        onPressed: onOpenChat,
                      ),
                    ],
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

    final AmanahTone badgeTone = AmanahThemeTokens.status(
      isProcessing ? AmanahStatusTone.warning : AmanahStatusTone.success,
      isDark: dark,
    );
    final Color badgeBg = badgeTone.surface;
    final Color badgeBorder = badgeTone.border;
    final Color badgeText = badgeTone.onSurface;
    final String badgeLabel =
        isProcessing ? 'Sedang ditangani' : 'Selesai ditangani';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AmanahColorTokens.pureBlack.withValues(
              alpha: dark ? 0.35 : 0.03,
            ),
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
                  fontFamily: AmanahTypographyTokens.monospaceFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    color: badgeText,
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
                  ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                  : AmanahColorTokens.neutral50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: dark
                    ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.05)
                    : AmanahColorTokens.neutral100,
              ),
            ),
            child: Text(
              report.technicianNote,
              style: TextStyle(
                color: dark
                    ? AmanahColorTokens.neutral300
                    : AmanahColorTokens.neutral600,
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
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
