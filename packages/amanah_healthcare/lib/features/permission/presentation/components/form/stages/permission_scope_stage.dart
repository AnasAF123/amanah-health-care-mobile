import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/permission/domain/entities/eligible_session.dart';
import 'package:amanah_healthcare/features/permission/presentation/theme/amanah_permission_tokens.dart';

/// Stage 3: Select permission scope (1 Hari Penuh vs Sesi Tertentu with roster sessions).
class PermissionScopeStage extends StatelessWidget {
  final String scope;
  final List<EligibleSession> eligibleSessions;
  final List<EligibleSession> selectedSessions;
  final bool isLoadingSessions;
  final ValueChanged<String> onScopeSelected;
  final ValueChanged<EligibleSession> onSessionToggled;
  final VoidCallback onContinue;

  const PermissionScopeStage({
    super.key,
    required this.scope,
    required this.eligibleSessions,
    required this.selectedSessions,
    required this.isLoadingSessions,
    required this.onScopeSelected,
    required this.onSessionToggled,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor =
        dark ? AmanahPermissionTokens.textTitleDark : AmanahPermissionTokens.textTitleLight;
    final Color subtextColor =
        dark ? AmanahPermissionTokens.textMutedDark : AmanahPermissionTokens.textMutedLight;
    final Color borderColor = dark
        ? AmanahPermissionTokens.cardBorderDark
        : AmanahPermissionTokens.cardBorderLight;

    final bool isFullDay = scope == 'full_day';
    final bool isSession = scope == 'session';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tentukan apakah izin berlaku sepanjang hari atau pada sesi dinas spesifik.',
          style: TextStyle(
            fontSize: 13,
            color: subtextColor,
          ),
        ),
        const SizedBox(height: 16),

        // 2-Column Card Grid
        Row(
          children: <Widget>[
            // Card 1: 1 Hari Penuh (Auto-advance)
            Expanded(
              child: _buildScopeOptionCard(
                context: context,
                title: '1 Hari Penuh',
                subtitle: 'Seluruh shift roster',
                icon: Icons.wb_sunny_rounded,
                isSelected: isFullDay,
                onTap: () => onScopeSelected('full_day'),
                dark: dark,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Sesi Tertentu
            Expanded(
              child: _buildScopeOptionCard(
                context: context,
                title: 'Sesi Tertentu',
                subtitle: 'Pilih shift dinas',
                icon: Icons.schedule_rounded,
                isSelected: isSession,
                onTap: () => onScopeSelected('session'),
                dark: dark,
                borderColor: borderColor,
              ),
            ),
          ],
        ),

        // If 'Sesi Tertentu' is active, show the roster sessions
        if (isSession) ...<Widget>[
          const SizedBox(height: 20),
          Text(
            'Pilih Sesi Roster yang Dimaksud *',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoadingSessions) ...<Widget>[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ] else if (eligibleSessions.isEmpty) ...<Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.surfaceDark
                    : AmanahColorTokens.neutral50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.event_busy_rounded,
                    size: 32,
                    color: subtextColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ditemukan jadwal shift aktif pada tanggal yang dipilih.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...<Widget>[
            ...eligibleSessions.map((EligibleSession session) {
              final bool isSelected = selectedSessions
                  .any((EligibleSession s) => s.sessionId == session.sessionId);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => onSessionToggled(session),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AmanahColorTokens.brand.withValues(
                              alpha: dark ? 0.15 : 0.08,
                            )
                          : (dark
                              ? AmanahColorTokens.surfaceDark
                              : AmanahColorTokens.surfaceLight),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AmanahColorTokens.brand
                            : borderColor,
                        width: isSelected ? 1.6 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          isSelected
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 20,
                          color: isSelected
                              ? AmanahColorTokens.brand
                              : subtextColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                session.sessionLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                '${session.startsAt} - ${session.endsAt}',
                                style: TextStyle(
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
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: selectedSessions.isNotEmpty ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AmanahColorTokens.brand,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Lanjutkan ke Alasan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildScopeOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool dark,
    required Color borderColor,
  }) {
    final Color textColor =
        dark ? AmanahPermissionTokens.textTitleDark : AmanahPermissionTokens.textTitleLight;
    final Color subtextColor =
        dark ? AmanahPermissionTokens.textMutedDark : AmanahPermissionTokens.textMutedLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AmanahColorTokens.brand.withValues(alpha: dark ? 0.15 : 0.08)
              : (dark
                  ? AmanahColorTokens.surfaceDark
                  : AmanahColorTokens.surfaceLight),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AmanahColorTokens.brand : borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AmanahColorTokens.brand.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AmanahColorTokens.brand
                    : (dark
                        ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
                        : AmanahColorTokens.neutral50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: subtextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
