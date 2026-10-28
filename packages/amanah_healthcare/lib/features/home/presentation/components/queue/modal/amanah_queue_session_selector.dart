import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/queue/domain/entities/queue_session_info.dart';

/// Modal bottom sheet allowing practitioner to switch clinical duty sessions.
class AmanahQueueSessionSelector {
  const AmanahQueueSessionSelector._();

  static void show(
    BuildContext context, {
    required List<QueueSessionInfo> sessions,
    required QueueSessionInfo? activeSession,
    required ValueChanged<QueueSessionInfo> onSelectSession,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark
          ? AmanahColorTokens.surfaceDark
          : AmanahColorTokens.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Pilih Sesi Praktik Dokter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AmanahColorTokens.surfaceLight
                            : AmanahColorTokens.darkNavy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Tidak ada jadwal sesi dinas lain hari ini',
                        style: TextStyle(
                          color: isDark
                              ? AmanahColorTokens.neutral400
                              : AmanahColorTokens.neutral600,
                        ),
                      ),
                    ),
                  )
                else
                  ...sessions.map((QueueSessionInfo session) {
                    final bool isCurrent =
                        activeSession?.sessionId == session.sessionId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? (isDark
                                ? AmanahColorTokens.brandNavyDark
                                : AmanahColorTokens.brandSurface)
                            : (isDark
                                ? AmanahColorTokens.surfaceSecondaryDark
                                : AmanahColorTokens.neutral50),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? AmanahColorTokens.brandPrimary
                              : (isDark
                                  ? AmanahColorTokens.neutral700
                                  : AmanahColorTokens.neutral200),
                          width: isCurrent ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCurrent
                              ? AmanahColorTokens.brandPrimary
                              : (isDark
                                  ? AmanahColorTokens.surfaceDark
                                  : AmanahColorTokens.neutral200),
                          child: Icon(
                            Icons.medical_services_rounded,
                            size: 18,
                            color: isCurrent
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral600,
                          ),
                        ),
                        title: Text(
                          session.sessionLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AmanahColorTokens.surfaceLight
                                : AmanahColorTokens.neutral900,
                          ),
                        ),
                        subtitle: Text(
                          '${session.timeRange} • ${session.roomName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AmanahColorTokens.neutral400
                                : AmanahColorTokens.neutral600,
                          ),
                        ),
                        trailing: isCurrent
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AmanahColorTokens.brandPrimary,
                              )
                            : null,
                        onTap: () {
                          Navigator.of(ctx).pop();
                          onSelectSession(session);
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}
