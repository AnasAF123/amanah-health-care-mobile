import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/domain/amanah_presence_model.dart';

/// Leave Reason Master Drawer ("Alasan Cuti Dokter")
class AmanahPresenceLeaveReasonDrawer extends StatelessWidget {
  const AmanahPresenceLeaveReasonDrawer({required this.record, super.key});

  final AttendanceRecord record;

  static void show(BuildContext context, {required AttendanceRecord record}) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahPresenceLeaveReasonDrawer(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color textColor = dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900;
    final Color subtextColor = dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500;

    return AmanahBottomSheetScaffold(
      title: 'Alasan Cuti Dokter',
      subtitle: '${record.date} - ${record.time}',
      fixedHeightFactor: 0.45,
      minHeight: 300,
      bodyPadding: const EdgeInsets.fromLTRB(
        AmanahSpacing.xxl,
        AmanahSpacing.lg,
        AmanahSpacing.xxl,
        AmanahSpacing.xxl,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Keterangan Alasan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: subtextColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: dark
                      ? AmanahColorTokens.violet.withValues(alpha: 0.20)
                      : AmanahColorTokens.violetSurface,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AmanahColorTokens.violet,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Disetujui',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AmanahColorTokens.violetDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            record.reason ?? 'Izin cuti resmi terjadwal yang telah disetujui manajemen RS Amanah.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AmanahSpacing.xxl),
        ],
      ),
    );
  }
}
