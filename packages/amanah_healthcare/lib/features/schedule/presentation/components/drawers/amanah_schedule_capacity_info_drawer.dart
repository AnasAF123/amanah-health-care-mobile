import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/schedule/domain/amanah_schedule_model.dart';

/// Modal bottom sheet drawer explaining the daily practice capacity and slot calculation.
///
/// Designed with clear, professional medical clinic terminology for doctors.
class AmanahScheduleCapacityInfoDrawer extends StatelessWidget {
  const AmanahScheduleCapacityInfoDrawer({
    required this.bookedCount,
    required this.totalSlots,
    this.schedules = const <DoctorSchedule>[],
    super.key,
  });

  final int bookedCount;
  final int totalSlots;
  final List<DoctorSchedule> schedules;

  static void show(
    BuildContext context, {
    required int bookedCount,
    required int totalSlots,
    List<DoctorSchedule> schedules = const <DoctorSchedule>[],
  }) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahScheduleCapacityInfoDrawer(
        bookedCount: bookedCount,
        totalSlots: totalSlots,
        schedules: schedules,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color textColor =
        dark ? AmanahColorTokens.pureWhite : AmanahColorTokens.neutral900;
    final Color subtextColor =
        dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    final int remainingSlots = (totalSlots - bookedCount).clamp(0, totalSlots);
    final int activeSessionCount = schedules.length;

    return AmanahBottomSheetScaffold(
      title: 'Informasi Kuota Layanan',
      subtitle: 'Rincian kapasitas praktik dan pasien hari ini',
      fixedHeightFactor: 0.68,
      minHeight: 420,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      footer: AmanahButton.primary(
        text: 'Mengerti',
        size: AmanahButtonSize.medium,
        isFullWidth: true,
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Indikator "$bookedCount / $totalSlots Slot" menunjukkan alokasi daya tampung konsultasi pasien pada hari ini:',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: subtextColor,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),

            _CapacityDetailRow(
              dotColor: dark
                  ? AmanahColorTokens.tabActiveDark
                  : AmanahColorTokens.brand,
              title: 'Pasien Terdaftar ($bookedCount)',
              description: '$bookedCount Pasien',
              explanation:
                  'Jumlah pasien yang telah melakukan reservasi konsultasi dokter.',
              highlightDescription: true,
            ),

            _CapacityDetailRow(
              dotColor: AmanahColorTokens.success,
              title: 'Total Kuota Layanan ($totalSlots)',
              description: '$totalSlots Slot Tersedia',
              explanation: activeSessionCount > 0
                  ? 'Akumulasi kuota dari $activeSessionCount sesi praktik yang dibuat hari ini.'
                  : 'Batas kuota harian praktik yang ditetapkan sistem klinik.',
            ),

            _CapacityDetailRow(
              dotColor: AmanahColorTokens.amberLight,
              title: 'Sisa Kuota Tersedia',
              description: '$remainingSlots Slot',
              explanation:
                  'Kapasitas antrean yang masih dapat menerima reservasi pasien baru.',
            ),

            if (schedules.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                'Rincian Kuota per Sesi Praktik:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              ...schedules.map((DoctorSchedule s) {
                final int sessionBooked = s.bookedPatients.length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: subtextColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              s.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '(${s.time.split(' WIB').first})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subtextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$sessionBooked / ${s.capacity} Slot',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? AmanahColorTokens.tabActiveDark
                              : AmanahColorTokens.brand,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: dark
                    ? AmanahColorTokens.pureWhite.withValues(alpha: 0.05)
                    : AmanahColorTokens.brandLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: dark
                      ? AmanahColorTokens.tabActiveDark.withValues(alpha: 0.20)
                      : AmanahColorTokens.brand.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: dark
                        ? AmanahColorTokens.tabActiveDark
                        : AmanahColorTokens.brand,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kapasitas dihitung otomatis dari total kuota sesi praktik Anda. Jika Anda menambah sesi baru atau menyesuaikan jam praktik, kuota total akan bertambah secara otomatis.',
                      style: TextStyle(
                        color: dark
                            ? AmanahColorTokens.pureWhite
                            : AmanahColorTokens.brandAccent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AmanahSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _CapacityDetailRow extends StatelessWidget {
  const _CapacityDetailRow({
    required this.dotColor,
    required this.title,
    required this.description,
    required this.explanation,
    this.highlightDescription = false,
  });

  final Color dotColor;
  final String title;
  final String description;
  final String explanation;
  final bool highlightDescription;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dark
                ? AmanahColorTokens.pureWhite.withValues(alpha: 0.06)
                : AmanahColorTokens.neutral100,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: dark
                              ? AmanahColorTokens.pureWhite
                              : AmanahColorTokens.neutral900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: highlightDescription ? FontWeight.w800 : FontWeight.w700,
                  color: highlightDescription
                      ? (dark
                          ? AmanahColorTokens.tabActiveDark
                          : AmanahColorTokens.brand)
                      : (dark
                          ? AmanahColorTokens.neutral300
                          : AmanahColorTokens.neutral700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              explanation,
              style: TextStyle(
                fontSize: 11,
                color: dark
                    ? AmanahColorTokens.neutral400
                    : AmanahColorTokens.neutral500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
