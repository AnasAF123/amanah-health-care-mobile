import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:smooth_app/features/permission/domain/amanah_permission_model.dart';
import 'package:smooth_app/features/permission/presentation/theme/amanah_permission_tokens.dart';

/// Master Permission Card Component (Stitched Stacked Ticket Motif)
/// Replicating lines 695-796 in LeavePermissionTabScreen.tsx (.web) 1:1
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

    final Color statusBg = AmanahPermissionTokens.getStatusBg(
      item.status,
      dark: dark,
    );
    final Color statusText = AmanahPermissionTokens.getStatusText(
      item.status,
      dark: dark,
    );

    final Color cardWrapperBg = dark
        ? AmanahPermissionTokens.cardWrapperDark
        : AmanahPermissionTokens.cardWrapperLight;
    final Color cardBorder = dark
        ? AmanahPermissionTokens.cardBorderDark
        : AmanahPermissionTokens.cardBorderLight;

    final Color innerStitchBg = dark
        ? AmanahPermissionTokens.innerStitchBgDark
        : AmanahPermissionTokens.innerStitchBgLight;
    final Color dashedStrokeColor = dark
        ? AmanahPermissionTokens.dashedStrokeDark
        : AmanahPermissionTokens.dashedStrokeLight;

    final Color textTitle = dark
        ? AmanahPermissionTokens.textTitleDark
        : AmanahPermissionTokens.textTitleLight;
    final Color textMuted = dark
        ? AmanahPermissionTokens.textMutedDark
        : AmanahPermissionTokens.textMutedLight;

    return Semantics(
      button: true,
      label: 'Perizinan ${item.type.label}, Status ${item.status.label}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.40 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 1. Top Stacking Layer Status Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  child: Center(
                    child: Text(
                      item.status.label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                        color: statusText,
                      ),
                    ),
                  ),
                ),

                // 2. Main Stacked White/Dark Card Wrapper
                Container(
                  margin: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                  decoration: BoxDecoration(
                    color: cardWrapperBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: cardBorder, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CustomPaint(
                      painter: _DashedRoundedRectPainter(
                        strokeColor: dashedStrokeColor,
                        strokeWidth: 1.5,
                        radius: 20,
                        dashWidth: 5.0,
                        dashSpace: 3.5,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: innerStitchBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Title (Full Width, No Pills)
                            Text(
                              item.type.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                                color: textTitle,
                              ),
                            ),
                            const SizedBox(height: 3),

                            // Reason (Truncated with Ellipsis)
                            Text(
                              item.reason,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: textMuted,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Dates Row (Mulai & Selesai)
                            Row(
                              children: <Widget>[
                                // Mulai
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: textMuted,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              item.formattedStartDate,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.2,
                                                color: textTitle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20, top: 2),
                                        child: Text(
                                          'Mulai',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Selesai
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: textMuted,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              item.formattedEndDate,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.2,
                                                color: textTitle,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20, top: 2),
                                        child: Text(
                                          'Selesai',
                                          style: TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: textMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw crisp dashed rounded borders
class _DashedRoundedRectPainter extends CustomPainter {
  const _DashedRoundedRectPainter({
    required this.strokeColor,
    required this.strokeWidth,
    required this.radius,
    this.dashWidth = 5.0,
    this.dashSpace = 3.5,
  });

  final Color strokeColor;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = distance + dashWidth;
        dashPath.addPath(
          metric.extractPath(
            distance,
            next > metric.length ? metric.length : next,
          ),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) =>
      strokeColor != oldDelegate.strokeColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius;
}
