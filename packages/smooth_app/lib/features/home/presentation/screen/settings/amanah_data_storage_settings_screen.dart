import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_screen_header.dart';
import 'package:smooth_app/features/home/presentation/components/amanah_settings_components.dart';

class AmanahDataStorageSettingsScreen extends StatefulWidget {
  const AmanahDataStorageSettingsScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  State<AmanahDataStorageSettingsScreen> createState() =>
      _AmanahDataStorageSettingsScreenState();
}

class _AmanahDataStorageSettingsScreenState
    extends State<AmanahDataStorageSettingsScreen> {
  bool _autoSyncEnabled = true;
  bool _wifiOnlySync = false;
  bool _cacheCleaned = false;
  String _exportState = 'idle'; // 'idle' | 'exporting' | 'done'

  void _handleClearCache() {
    setState(() => _cacheCleaned = true);
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _cacheCleaned = false);
      }
    });
  }

  void _handleExportData() {
    setState(() => _exportState = 'exporting');
    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _exportState = 'done');
        Timer(const Duration(milliseconds: 2500), () {
          if (mounted) {
            setState(() => _exportState = 'idle');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool dark = theme.brightness == Brightness.dark;

    final Color bgColor = dark
        ? const Color(0xFF0A0E1A)
        : const Color(0xFFF8FAFF);

    String exportLabel = 'Ekspor PDF';
    if (_exportState == 'exporting') {
      exportLabel = 'Memproses...';
    } else if (_exportState == 'done') {
      exportLabel = 'Tersimpan';
    }

    String exportSubtitle = 'Simpan berkas laporan dalam format PDF';
    if (_exportState == 'done') {
      exportSubtitle = 'Unduhan selesai disimpan di folder Download';
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AmanahScreenHeader(
              title: 'Data & penyimpanan',
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
                    // 1. Ruang penyimpanan
                    AmanahSettingSection(
                      title: 'Ruang penyimpanan',
                      children: <Widget>[
                        AmanahSettingHorizontalRow(
                          label: 'Total data portal',
                          value: _cacheCleaned ? '74 MB' : '142 MB',
                          isBold: true,
                        ),
                        AmanahSettingHorizontalRow(
                          label: 'Cache berkas sementara',
                          value: _cacheCleaned ? '0 MB' : '68 MB',
                        ),
                        const AmanahSettingHorizontalRow(
                          label: 'Dokumen unduhan',
                          value: '54 MB',
                        ),
                        const AmanahSettingHorizontalRow(
                          label: 'Database lokal',
                          value: '20 MB',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. Sinkronisasi data
                    AmanahSettingSection(
                      title: 'Sinkronisasi data',
                      children: <Widget>[
                        AmanahSettingToggleRow(
                          title: 'Sinkronisasi otomatis',
                          subtitle: 'Perbarui jadwal dan status berkala',
                          checked: _autoSyncEnabled,
                          onToggle: () {
                            setState(
                              () => _autoSyncEnabled = !_autoSyncEnabled,
                            );
                          },
                        ),
                        AmanahSettingToggleRow(
                          title: 'Hanya melalui Wi-Fi',
                          subtitle: 'Hemat pemakaian kuota data seluler',
                          checked: _wifiOnlySync,
                          onToggle: () {
                            setState(() => _wifiOnlySync = !_wifiOnlySync);
                          },
                        ),
                        const AmanahSettingInfoRow(
                          label: 'Sinkronisasi terakhir',
                          value: 'Hari ini, 07:15 WIB',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Tindakan penyimpanan
                    AmanahSettingSection(
                      title: 'Tindakan penyimpanan',
                      children: <Widget>[
                        AmanahSettingActionRow(
                          title: 'Bersihkan cache sementara',
                          subtitle: _cacheCleaned
                              ? 'Cache berhasil dibersihkan (0 MB)'
                              : 'Hapus data sementara tanpa menghapus akun',
                          actionLabel: _cacheCleaned ? 'Selesai' : 'Bersihkan',
                          onAction: _handleClearCache,
                          disabled: _cacheCleaned,
                          isSuccess: _cacheCleaned,
                        ),
                        AmanahSettingActionRow(
                          title: 'Ekspor rekap presensi',
                          subtitle: exportSubtitle,
                          actionLabel: exportLabel,
                          onAction: _handleExportData,
                          disabled: _exportState != 'idle',
                          isSuccess: _exportState == 'done',
                        ),
                      ],
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
