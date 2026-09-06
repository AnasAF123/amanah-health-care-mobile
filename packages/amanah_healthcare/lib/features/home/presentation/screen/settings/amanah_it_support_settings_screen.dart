import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/authentication/domain/amanah_auth_user.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_button.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_screen_header.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_settings_components.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_it_chat_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_it_faq_detail_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/screen/settings/amanah_it_my_reports_screen.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';

class AmanahItSupportSettingsScreen extends StatefulWidget {
  const AmanahItSupportSettingsScreen({this.user, this.onBack, super.key});

  final AmanahAuthUser? user;
  final VoidCallback? onBack;

  @override
  State<AmanahItSupportSettingsScreen> createState() =>
      _AmanahItSupportSettingsScreenState();
}

class _AmanahItSupportSettingsScreenState
    extends State<AmanahItSupportSettingsScreen> {
  static const List<AmanahFaqItem> _faqList = <AmanahFaqItem>[
    AmanahFaqItem(
      id: 'faq-1',
      category: 'Presensi & scanner',
      title: 'Kamera scanner presensi tidak merespons atau blank hitam',
      solution: <String>[
        'Pastikan izin akses kamera pada aplikasi sudah diberikan (Allow Camera).',
        'Tutup paksa aplikasi dan buka kembali untuk me-refresh driver kamera.',
        'Jika kamera masih blank, gunakan fitur input PIN presensi manual sebagai alternatif cepat.',
        'Hubungi tim IT jika kendala berulang pada tablet atau perangkat poli.',
      ],
    ),
    AmanahFaqItem(
      id: 'faq-2',
      category: 'Lokasi & GPS',
      title: 'Muncul pesan error "Di luar radius presensi poliklinik"',
      solution: <String>[
        'Pastikan fitur GPS/Location pada ponsel dalam status aktif dengan akurasi tinggi (High Accuracy).',
        'Pastikan Anda berada dalam radius maksimal 50 meter dari gedung poliklinik RS Amanah Sehat.',
        'Hubungi tim IT untuk kalibrasi ulang koordinat access point jika Anda berada di dalam ruangan beton.',
      ],
    ),
    AmanahFaqItem(
      id: 'faq-3',
      category: 'SIMRS & jadwal',
      title: 'Jadwal praktik atau kuota pasien belum tersinkronisasi',
      solution: <String>[
        'Buka menu Data & penyimpanan lalu lakukan sinkronisasi data SIMRS secara manual.',
        'Pastikan koneksi jaringan Wi-Fi RS terhubung ke SSID Medis resmi.',
        'Periksa apakah ada perubahan shift yang belum disetujui pihak manajemen pelayanan medis.',
      ],
    ),
    AmanahFaqItem(
      id: 'faq-4',
      category: 'Akun & keamanan',
      title: 'Cara ubah kata sandi akun jika ingin memperbarui',
      solution: <String>[
        'Buka halaman pengaturan lalu pilih menu Keamanan akun & PIN.',
        'Pilih opsi Ubah kata sandi akun.',
        'Masukkan kata sandi baru (minimal 8 karakter) lalu tekan Simpan.',
      ],
    ),
  ];

  final List<AmanahReportItem> _reports = <AmanahReportItem>[
    const AmanahReportItem(
      id: 'rep-1',
      ticketNumber: 'TK-2026-0819',
      title: 'Scanner QR poliklinik anak lambat membaca kode',
      date: 'Kemarin, 14:20 WIB',
      status: 'proses',
      technicianNote:
          'Teknisi sedang melakukan pengecekan lensa scanner dan firmware bridge SIMRS.',
    ),
  ];

  void _openChat() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => AmanahItChatScreen(
          user: widget.user,
          onBack: () => Navigator.of(ctx).pop(),
          onTicketCreated: (String title, String date) {
            setState(() {
              _reports.insert(
                0,
                AmanahReportItem(
                  id: 'rep-${DateTime.now().millisecondsSinceEpoch}',
                  ticketNumber:
                      'TK-2026-${1000 + (DateTime.now().millisecond % 9000)}',
                  title: title,
                  date: date,
                  status: 'proses',
                  technicianNote:
                      'Laporan baru dibuat via live chat IT. Teknisi sedang memverifikasi kendala.',
                ),
              );
            });
          },
        ),
      ),
    );
  }

  void _openReports() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => AmanahItMyReportsScreen(
          reports: _reports,
          onBack: () => Navigator.of(ctx).pop(),
          onOpenChat: () {
            Navigator.of(ctx).pop();
            _openChat();
          },
        ),
      ),
    );
  }

  void _openFaq(AmanahFaqItem faq) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => AmanahItFaqDetailScreen(
          faq: faq,
          onBack: () => Navigator.of(ctx).pop(),
          onOpenChat: () {
            Navigator.of(ctx).pop();
            _openChat();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor = AmanahThemeTokens.canvas(context);
    final Color cardBg = AmanahThemeTokens.surface(context);
    final Color borderColor = AmanahThemeTokens.outline(context);
    final Color textColor = AmanahThemeTokens.textPrimary(context);
    final Color subtextColor = AmanahThemeTokens.textSecondary(context);

    final int activeReportsCount = _reports
        .where((AmanahReportItem r) => r.status == 'proses')
        .length;

    final AmanahTone reportBadgeTone = AmanahThemeTokens.status(
      activeReportsCount > 0
          ? AmanahStatusTone.warning
          : AmanahStatusTone.neutral,
      isDark: dark,
    );
    final Color reportBadgeBg = reportBadgeTone.surface;
    final Color reportBadgeBorder = reportBadgeTone.border;
    final Color reportBadgeText = reportBadgeTone.onSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Bantuan teknisi IT',
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  130 + MediaQuery.paddingOf(context).bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Laporan saya quick navigation card
                    InkWell(
                      onTap: _openReports,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AmanahColorTokens.pureBlack.withValues(
                                alpha: dark ? 0.35 : 0.03,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Laporan saya',
                                    style: TextStyle(
                                      color: textColor,
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Pantau status penanganan tiket kendala teknis',
                                    style: TextStyle(
                                      color: subtextColor,
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: reportBadgeBg,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: reportBadgeBorder),
                              ),
                              child: Text(
                                activeReportsCount > 0
                                    ? '$activeReportsCount proses'
                                    : '0 laporan',
                                style: TextStyle(
                                  color: reportBadgeText,
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: subtextColor.withValues(alpha: 0.50),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Pertanyaan sering diajukan
                    AmanahSettingSection(
                      title: 'Pertanyaan sering diajukan',
                      children: <Widget>[
                        for (final AmanahFaqItem faq in _faqList)
                          AmanahSettingNavRow(
                            category: faq.category,
                            title: faq.title,
                            onClick: () => _openFaq(faq),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Chat callout card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dark
                            ? AmanahColorTokens.surfaceLight.withValues(
                                alpha: 0.05,
                              )
                            : AmanahColorTokens.brandSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: dark
                              ? AmanahColorTokens.surfaceLight.withValues(
                                  alpha: 0.10,
                                )
                              : AmanahColorTokens.brandMuted,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Butuh bantuan teknisi langsung?',
                            style: TextStyle(
                              color: dark
                                  ? AmanahColorTokens.surfaceLight
                                  : AmanahColorTokens.navy,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hubungi petugas IT melalui percakapan langsung untuk penanganan kendala cepat.',
                            style: TextStyle(
                              color: dark
                                  ? AmanahColorTokens.neutral400
                                  : AmanahColorTokens.neutral600,
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 11.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AmanahButton.primary(
                            text: 'Chat dengan tim IT',
                            isFullWidth: true,
                            size: AmanahButtonSize.medium,
                            onPressed: _openChat,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
