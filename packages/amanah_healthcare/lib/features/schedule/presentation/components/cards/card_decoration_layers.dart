import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

AmanahTone scheduleBadgeTone(
  AmanahBadgeVariant variant, [
  BuildContext? context,
]) {
  switch (variant) {
    case AmanahBadgeVariant.success:
      return AmanahThemeTokens.status(
        AmanahStatusTone.success,
        context: context,
      );
    case AmanahBadgeVariant.primary:
    case AmanahBadgeVariant.live:
      return AmanahThemeTokens.status(AmanahStatusTone.brand, context: context);
    case AmanahBadgeVariant.warning:
      return AmanahThemeTokens.status(
        AmanahStatusTone.warning,
        context: context,
      );
    case AmanahBadgeVariant.trend:
      return AmanahThemeTokens.status(
        AmanahStatusTone.violet,
        context: context,
      );
  }
}

class ProfileReadabilityMaskLayer extends StatelessWidget {
  const ProfileReadabilityMaskLayer({
    required this.dark,
    required this.height,
    super.key,
  });

  final bool dark;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: height,
      child: IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const <double>[0.0, 0.22, 0.42, 1.0],
              colors: <Color>[
                Colors.transparent,
                AmanahColorTokens.pureBlack.withValues(alpha: 0.45),
                AmanahColorTokens.pureBlack,
                AmanahColorTokens.pureBlack,
              ],
            ).createShader(bounds);
          },
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const <double>[0.0, 0.44, 1.0],
                    colors: dark
                        ? <Color>[
                            AmanahColorTokens.darkNavy.withValues(alpha: 0.0),
                            AmanahColorTokens.darkNavy.withValues(alpha: 0.72),
                            AmanahColorTokens.darkNavy.withValues(alpha: 0.97),
                          ]
                        : <Color>[
                            AmanahColorTokens.pureWhite.withValues(alpha: 0.0),
                            AmanahColorTokens.pureWhite.withValues(alpha: 0.86),
                            AmanahColorTokens.pureWhite.withValues(alpha: 0.98),
                          ],
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AmbientCardGradientLayer extends StatelessWidget {
  const AmbientCardGradientLayer({required this.dark, super.key});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const <double>[0.0, 0.35, 0.65, 1.0],
              colors: dark
                  ? <Color>[
                      AmanahColorTokens.darkNavy.withValues(alpha: 0.0),
                      AmanahColorTokens.darkNavy.withValues(alpha: 0.0),
                      AmanahColorTokens.darkNavy.withValues(alpha: 0.60),
                      AmanahColorTokens.darkNavy.withValues(alpha: 0.96),
                    ]
                  : <Color>[
                      AmanahColorTokens.pureWhite.withValues(alpha: 0.0),
                      AmanahColorTokens.pureWhite.withValues(alpha: 0.0),
                      AmanahColorTokens.pureWhite.withValues(alpha: 0.60),
                      AmanahColorTokens.pureWhite.withValues(alpha: 0.97),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatientSpecRow extends StatelessWidget {
  const PatientSpecRow({
    required this.label,
    required this.value,
    required this.dark,
    super.key,
  });

  final String label;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                : AmanahColorTokens.neutral100,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.neutral900,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PatientCardSlotSpecsRow extends StatelessWidget {
  const PatientCardSlotSpecsRow({
    required this.poli,
    required this.room,
    required this.startTime,
    required this.endTime,
    super.key,
  });

  final String poli;
  final String room;
  final String startTime;
  final String endTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        // Slot 1: Poli & Room
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                poli,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AmanahThemeTokens.textPrimary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                room,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AmanahThemeTokens.textTertiary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Separator Line 1
        Container(
          width: 1,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: AmanahThemeTokens.divider(context),
        ),

        // Slot 2: Jam Mulai
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    startTime,
                    style: TextStyle(
                      color: AmanahThemeTokens.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'Mulai',
                style: TextStyle(
                  color: AmanahThemeTokens.textTertiary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Separator Line 2
        Container(
          width: 1,
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          color: AmanahThemeTokens.divider(context),
        ),

        // Slot 3: Jam Selesai
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: AmanahThemeTokens.textPrimary(context),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    endTime,
                    style: TextStyle(
                      color: AmanahThemeTokens.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'Selesai',
                style: TextStyle(
                  color: AmanahThemeTokens.textTertiary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

