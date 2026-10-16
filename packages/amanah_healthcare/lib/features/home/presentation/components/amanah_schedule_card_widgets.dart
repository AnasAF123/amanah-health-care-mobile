import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_schedule_card_tokens.dart';

class AmanahDismissButton extends StatelessWidget {
  const AmanahDismissButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      label: 'Tutup jadwal',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: dark
                  ? AmanahScheduleCardTokens.dismissBtnBgDark
                  : AmanahScheduleCardTokens.dismissBtnBgLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: dark
                  ? AmanahScheduleCardTokens.dismissBtnIconColorDark
                  : AmanahScheduleCardTokens.dismissBtnIconColorLight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Atom: Clean Integrated Booking Pill matching Web ScheduleCard.tsx
class AmanahBookingPill extends StatelessWidget {
  const AmanahBookingPill({
    required this.patientCount,
    this.statusText = 'Terdaftar',
    super.key,
  });

  final String patientCount;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: dark
            ? AmanahScheduleCardTokens.bookingPillBgDark
            : AmanahScheduleCardTokens.bookingPillBgLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            patientCount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: dark
                  ? AmanahScheduleCardTokens.bookingPillTextDark
                  : AmanahScheduleCardTokens.bookingPillTextLight,
            ),
          ),
          if (statusText.isNotEmpty) ...<Widget>[
            const SizedBox(width: 3.5),
            Text(
              statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: dark
                    ? AmanahScheduleCardTokens.roomColorDark
                    : AmanahScheduleCardTokens.roomColorLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
