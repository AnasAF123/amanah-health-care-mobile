import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_schedule_ticket_painters.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_status_badge.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_schedule_card_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class AmanahScheduleEmptyCard extends StatelessWidget {
  const AmanahScheduleEmptyCard({this.onCreateSchedule, super.key});

  final VoidCallback? onCreateSchedule;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final String bgAsset = dark
        ? AmanahScheduleCardTokens.bgImageDark
        : AmanahScheduleCardTokens.bgImageLight;

    return Semantics(
      label: 'Belum ada jadwal praktik hari ini',
      child: Container(
        height: AmanahScheduleCardTokens.cardHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: dark
              ? AmanahScheduleCardTokens.cardShadowDark
              : AmanahScheduleCardTokens.cardShadowLight,
        ),
        child: ClipPath(
          clipper: const AmanahTicketClipper(),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(painter: AmanahCardBasePainter(dark: dark)),
              ),
              Positioned.fill(
                child: Image.asset(
                  bgAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stack) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: dark
                              ? const <Color>[
                                  AmanahColorTokens.surfaceSecondaryDark,
                                  AmanahColorTokens.canvasDark,
                                ]
                              : const <Color>[
                                  AmanahColorTokens.brandSurface,
                                  AmanahColorTokens.canvasLight,
                                ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: dark
                        ? AmanahScheduleCardTokens.liquidGlassGradientDark
                        : AmanahScheduleCardTokens.liquidGlassGradientLight,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: dark
                        ? AmanahScheduleCardTokens.glassSpecularSheenDark
                        : AmanahScheduleCardTokens.glassSpecularSheenLight,
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: AmanahPerforatedLinePainter(dark: dark),
                ),
              ),
              Padding(
                padding: AmanahScheduleCardTokens.padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Jadwal Hari Ini',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                              height: 1.15,
                              color: dark
                                  ? AmanahScheduleCardTokens.titleColorDark
                                  : AmanahScheduleCardTokens.titleColorLight,
                            ),
                          ),
                        ),
                        const AmanahStatusBadge(
                          variant: AmanahBadgeVariant.primary,
                          text: 'Kosong',
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Hari ini masih nyantai',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                            height: 1.1,
                            color: dark
                                ? AmanahScheduleCardTokens.timeColorDark
                                : AmanahScheduleCardTokens.timeColorLight,
                          ),
                        ),
                        const SizedBox(height: AmanahSpacing.xs),
                        Text(
                          'Belum ada sesi praktik untuk hari ini.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                            height: 1.35,
                            color: dark
                                ? AmanahScheduleCardTokens.roomColorDark
                                : AmanahScheduleCardTokens.roomColorLight,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AmanahButton.text(
                        text: 'Pengaturan jadwal',
                        trailingIcon: Icons.arrow_forward_rounded,
                        customForegroundColor: dark
                            ? AmanahColorTokens.cyanAccent
                            : AmanahColorTokens.brand,
                        onPressed: onCreateSchedule,
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
  }
}
