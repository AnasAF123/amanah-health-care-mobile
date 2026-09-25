import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class RescheduleOptionsSection extends StatelessWidget {
  const RescheduleOptionsSection({
    required this.bookedPatientCount,
    required this.rescheduleActiveAppointments,
    required this.notesController,
    required this.dark,
    required this.onSwitchChanged,
    super.key,
  });

  final int bookedPatientCount;
  final bool rescheduleActiveAppointments;
  final TextEditingController notesController;
  final bool dark;
  final ValueChanged<bool> onSwitchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Switch for transferring active booked patients
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.04)
                : AmanahColorTokens.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark
                  ? AmanahColorTokens.pureWhite.withValues(alpha: 0.08)
                  : AmanahColorTokens.neutral200,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AmanahColorTokens.brand.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.people_alt_rounded,
                  size: 16,
                  color: AmanahColorTokens.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Alihkan Antrean Pasien Otomatis',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.pureWhite
                            : AmanahColorTokens.neutral900,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pindahkan $bookedPatientCount pasien terdaftar ke sesi baru secara berurutan',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.neutral400
                            : AmanahColorTokens.neutral500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rescheduleActiveAppointments,
                activeThumbColor: dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand,
                onChanged: onSwitchChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Notes Field
        Text(
          'Catatan Reschedule (Opsional)',
          style: TextStyle(
            color: dark
                ? AmanahColorTokens.neutral200
                : AmanahColorTokens.neutral700,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: notesController,
          maxLines: 2,
          style: TextStyle(
            color: dark
                ? AmanahColorTokens.pureWhite
                : AmanahColorTokens.neutral900,
            fontSize: 12.5,
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: Dokter berhalangan hadir karena rapat klinis',
            hintStyle: TextStyle(
              color: dark
                ? AmanahColorTokens.neutral500
                : AmanahColorTokens.neutral400,
              fontSize: 12,
            ),
            filled: true,
            fillColor: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                : AmanahColorTokens.surfaceSecondaryLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                    : AmanahColorTokens.neutral200,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.10)
                    : AmanahColorTokens.neutral200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: dark
                    ? AmanahColorTokens.tabActiveDark
                    : AmanahColorTokens.brand,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
