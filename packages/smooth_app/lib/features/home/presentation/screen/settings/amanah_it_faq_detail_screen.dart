import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_button.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';

class AmanahFaqItem {
  const AmanahFaqItem({
    required this.id,
    required this.title,
    required this.category,
    required this.solution,
  });

  final String id;
  final String title;
  final String category;
  final List<String> solution;
}

class AmanahItFaqDetailScreen extends StatelessWidget {
  const AmanahItFaqDetailScreen({
    required this.faq,
    this.onBack,
    this.onOpenChat,
    super.key,
  });

  final AmanahFaqItem faq;
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
    final Color categoryColor = subtextColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(title: 'Pusat bantuan', onBack: onBack),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Question Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(
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
                          Text(
                            faq.category,
                            style: TextStyle(
                              color: categoryColor,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            faq.title,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Solution Steps Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(
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
                          Text(
                            'Langkah penyelesaian',
                            style: TextStyle(
                              color: subtextColor,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          for (
                            int i = 0;
                            i < faq.solution.length;
                            i++
                          ) ...<Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 22,
                                  height: 22,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                    color: dark
                                        ? Colors.white.withValues(alpha: 0.10)
                                        : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        color: dark
                                            ? const Color(0xFFE2E8F0)
                                            : const Color(0xFF334155),
                                        fontFamily: 'PlusJakartaSans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    faq.solution[i],
                                    style: TextStyle(
                                      color: dark
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF334155),
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (i < faq.solution.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Fallback Action Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dark
                            ? Colors.white.withValues(alpha: 0.04)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Kendala belum terselesaikan?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: subtextColor,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          AmanahButton.primary(
                            text: 'Chat dengan tim IT',
                            isFullWidth: true,
                            size: AmanahButtonSize.medium,
                            onPressed: onOpenChat,
                          ),
                        ],
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
