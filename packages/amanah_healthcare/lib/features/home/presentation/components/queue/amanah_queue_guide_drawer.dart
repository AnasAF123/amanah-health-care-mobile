import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahQueueGuideDrawer extends StatelessWidget {
  const AmanahQueueGuideDrawer({super.key});

  static void show(BuildContext context) {
    showAmanahBottomSheet<void>(
      context: context,
      builder: (_) => const AmanahQueueGuideDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;

    return AmanahBottomSheetScaffold(
      title: 'Panduan alur sistem antrean',
      subtitle: 'Sistem rel antrean 3D interaktif Klinik Amanah',
      fixedHeightFactor: 0.65,
      minHeight: 400,
      footer: AmanahButton.primary(
        text: 'Mengerti',
        isFullWidth: true,
        size: AmanahButtonSize.medium,
        onPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Sistem rel antrean 3D interaktif Klinik Amanah mempermudah dokter & staf dalam memproses dan memanggil pasien:',
            style: TextStyle(
              color: dark
                  ? AmanahColorTokens.neutral400
                  : AmanahColorTokens.neutral500,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          _buildStep(
            '1. Geser Rel 3D',
            'Geser kartu ke kiri/kanan untuk memilih nomor antrean pasien',
            AmanahColorTokens.brandPrimary,
            dark: dark,
          ),
          _buildStep(
            '2. Tarik ke Bawah',
            'Tarik kartu ke slot bawah hingga kotak paramedis terbuka untuk memproses',
            dark ? AmanahColorTokens.brandSoft : AmanahColorTokens.brandLight,
            dark: dark,
          ),
          _buildStep(
            '3. Putar & Cek Kartu',
            'Kartu berputar 3D menampilkan nama pasien, keluhan, dan poli tujuan',
            AmanahColorTokens.success,
            dark: dark,
          ),
          _buildStep(
            '4. Panggil Pasien',
            'Tekan "Panggil Pasien" untuk aktivasi atau simpan ke riwayat antrean',
            AmanahColorTokens.violet,
            dark: dark,
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String title, String desc, Color dotColor, {required bool dark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: dark
                        ? AmanahColorTokens.neutral400
                        : AmanahColorTokens.neutral500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
