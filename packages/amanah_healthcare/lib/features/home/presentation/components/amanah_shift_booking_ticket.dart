import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

/// Reusable, ticket-booking styled shift time card.
/// Displays Start Time (prominent on left), Session & Date (centered with connecting dot-arrow),
/// and End Time (prominent on right).
class AmanahShiftBookingTicket extends StatelessWidget {
  const AmanahShiftBookingTicket({
    required this.startTime,
    required this.endTime,
    required this.sessionLabel,
    required this.dateLabel,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    super.key,
  });

  final String startTime;
  final String endTime;
  final String sessionLabel;
  final String dateLabel;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bool dark = AmanahThemeTokens.isDark(context);
    final String resolvedEnd =
        endTime.contains(RegExp(r'[A-Za-z]')) ? endTime : '$endTime WIB';

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (dark
                ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.04)
                : AmanahColorTokens.neutral100.withValues(alpha: 0.60)),
        borderRadius: BorderRadius.circular(AmanahRadius.md),
        border: Border.all(
          color: borderColor ??
              (dark
                  ? AmanahColorTokens.surfaceLight.withValues(alpha: 0.08)
                  : AmanahColorTokens.neutral200),
        ),
      ),
      child: Row(
        children: <Widget>[
          // 1. Start Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                startTime,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  color: AmanahThemeTokens.textPrimary(context),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Mulai',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AmanahThemeTokens.textTertiary(context),
                ),
              ),
            ],
          ),

          // 2. Middle Route Connector
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    sessionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AmanahThemeTokens.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AmanahThemeTokens.outline(context),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AmanahThemeTokens.outline(context),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: AmanahThemeTokens.textTertiary(context),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: AmanahThemeTokens.outline(context),
                        ),
                      ),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AmanahThemeTokens.outline(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: AmanahThemeTokens.textTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. End Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                resolvedEnd,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                  color: AmanahThemeTokens.textPrimary(context),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Selesai',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AmanahThemeTokens.textTertiary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
