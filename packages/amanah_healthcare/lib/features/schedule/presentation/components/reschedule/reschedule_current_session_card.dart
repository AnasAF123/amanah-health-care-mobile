import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

class RescheduleCurrentSessionCard extends StatelessWidget {
  const RescheduleCurrentSessionCard({
    required this.session,
    required this.dark,
    super.key,
  });

  final DoctorSchedule session;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark
            ? AmanahColorTokens.pureWhite.withValues(alpha: 0.04)
            : AmanahColorTokens.skyLight.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark
              ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
              : AmanahColorTokens.brandLight.withValues(alpha: 0.50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Sesi Sumber',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.neutral400
                        : AmanahColorTokens.neutral500,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.15)
                      : AmanahColorTokens.brandSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${session.bookedPatients.length} Pasien Terdaftar',
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brand,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            session.title,
            style: TextStyle(
              color: dark
                  ? AmanahColorTokens.pureWhite
                  : AmanahColorTokens.neutral950,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: dark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral500,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  session.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.neutral300
                        : AmanahColorTokens.neutral600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.access_time_rounded,
                size: 13,
                color: dark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral500,
              ),
              const SizedBox(width: 4),
              Text(
                session.time,
                style: TextStyle(
                  color: dark
                      ? AmanahColorTokens.neutral300
                      : AmanahColorTokens.neutral600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Icon(
                Icons.meeting_room_outlined,
                size: 13,
                color: dark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral500,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${session.room} • ${session.poli}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.neutral400
                        : AmanahColorTokens.neutral500,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
