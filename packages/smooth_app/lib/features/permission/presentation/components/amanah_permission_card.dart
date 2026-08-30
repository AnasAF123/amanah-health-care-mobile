import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_clay_icon.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';

class AmanahPermissionCard extends StatelessWidget {
  const AmanahPermissionCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final AmanahPermissionRecord item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color cardBg =
        dark ? const Color(0xFF111624) : const Color(0xFFFFFFFF);
    final Color borderColor =
        dark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9);
    final Color textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final Color subtextColor =
        dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color dividerColor = dark
        ? Colors.white.withValues(alpha: 0.05)
        : const Color(0xFFF1F5F9);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: dark ? 0.40 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 1. Card Header: Type with ClayIcon + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        AmanahClayIcon(
                          icon: Icons.calendar_today_rounded,
                          size: 28,
                          colorPrimary: item.type.colorPrimary,
                          colorLight: item.type.colorLight,
                          colorDark: item.type.colorDark,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.type.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PermissionStatusBadge(status: item.status, dark: dark),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Card Body: Date Range & Duration Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.formattedDateRange,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: textColor,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Durasi izin praktik',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.white.withValues(alpha: 0.10)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.durationDays} Hari',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Card Footer: Applicant User Info & Chevron
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: dividerColor)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.20)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                item.userAvatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Container(
                                    color: const Color(0xFF0A44FF)
                                        .withValues(alpha: 0.30),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  item.userRole,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 10,
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
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: subtextColor.withValues(alpha: 0.70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionStatusBadge extends StatelessWidget {
  const _PermissionStatusBadge({
    required this.status,
    required this.dark,
  });

  final AmanahPermissionStatus status;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final Widget icon;

    switch (status) {
      case AmanahPermissionStatus.menunggu:
        bgColor = dark
            ? const Color(0xFF451A03).withValues(alpha: 0.60)
            : const Color(0xFFFFFBEB);
        borderColor = dark
            ? const Color(0xFFF59E0B).withValues(alpha: 0.30)
            : const Color(0xFFFDE68A);
        textColor = dark ? const Color(0xFFFBBF24) : const Color(0xFF92400E);
        icon = Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFFF59E0B),
            shape: BoxShape.circle,
          ),
        );

      case AmanahPermissionStatus.disetujui:
        bgColor = dark
            ? const Color(0xFF064E3B).withValues(alpha: 0.60)
            : const Color(0xFFECFDF5);
        borderColor = dark
            ? const Color(0xFF10B981).withValues(alpha: 0.30)
            : const Color(0xFFA7F3D0);
        textColor = dark ? const Color(0xFF34D399) : const Color(0xFF065F46);
        icon = Icon(
          Icons.check_rounded,
          size: 12,
          color: textColor,
        );

      case AmanahPermissionStatus.ditolak:
        bgColor = dark
            ? const Color(0xFF4C0519).withValues(alpha: 0.60)
            : const Color(0xFFFFF1F2);
        borderColor = dark
            ? const Color(0xFFF43F5E).withValues(alpha: 0.30)
            : const Color(0xFFFECDD3);
        textColor = dark ? const Color(0xFFFB7185) : const Color(0xFF9F1239);
        icon = Icon(
          Icons.close_rounded,
          size: 12,
          color: textColor,
        );

      case AmanahPermissionStatus.dibatalkan:
        bgColor = dark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF1F5F9);
        borderColor = dark
            ? Colors.white.withValues(alpha: 0.10)
            : const Color(0xFFE2E8F0);
        textColor = dark ? const Color(0xFFA1A1AA) : const Color(0xFF475569);
        icon = const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (status != AmanahPermissionStatus.dibatalkan) ...<Widget>[
            icon,
            const SizedBox(width: 4),
          ],
          Text(
            status.label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
