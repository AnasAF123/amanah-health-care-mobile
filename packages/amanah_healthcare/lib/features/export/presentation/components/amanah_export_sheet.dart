import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_success_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import '../../domain/entities/export_format.dart';
import '../state/export_controller.dart';

class AmanahExportSheet extends StatefulWidget {
  const AmanahExportSheet({
    super.key,
    required this.exportType,
    required this.sheetTitle,
    this.sheetSubtitle,
    this.parameters,
  });

  final String exportType;
  final String sheetTitle;
  final String? sheetSubtitle;
  final Map<String, dynamic>? parameters;

  static Future<void> show({
    required BuildContext context,
    required String exportType,
    required String sheetTitle,
    String? sheetSubtitle,
    Map<String, dynamic>? parameters,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahExportSheet(
        exportType: exportType,
        sheetTitle: sheetTitle,
        sheetSubtitle: sheetSubtitle,
        parameters: parameters,
      ),
    );
  }

  @override
  State<AmanahExportSheet> createState() => _AmanahExportSheetState();
}

class _AmanahExportSheetState extends State<AmanahExportSheet> {
  late final ExportController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExportController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext ctx, _) {
        if (_controller.isDone && _controller.downloadedFile != null) {
          final file = _controller.downloadedFile!;
          final int fileSizeKb = file.lengthSync() ~/ 1024;
          final String fileName = file.path.split(RegExp(r'[/\\]')).last;

          return AmanahSuccessDrawer(
            variant: AmanahDrawerVariant.success,
            title: 'Laporan Berhasil Diunduh!',
            subtitle: 'Berkas laporan telah tersimpan di perangkat Anda.',
            infoTitle: 'Ukuran Berkas',
            infoSubtitle: '$fileSizeKb KB — $fileName',
            infoIcon: Icons.description_rounded,
            primaryButtonText: 'Buka',
            primaryIcon: Icons.file_open_rounded,
            secondaryButtonText: 'Bagikan',
            secondaryIcon: Icons.share_rounded,
            sideBySideActions: true,
            showCloseButton: true,
            onClose: () => Navigator.of(context).pop(),
            onPrimaryAction: () => _controller.openFile(),
            onSecondaryAction: () => _controller.shareFile(),
          );
        }

        if (_controller.errorMessage != null && !_controller.isLoading) {
          return AmanahSuccessDrawer(
            variant: AmanahDrawerVariant.error,
            title: 'Gagal Mengunduh Laporan',
            subtitle: _controller.errorMessage!,
            primaryButtonText: 'Tutup',
            showCloseButton: true,
            onClose: () => Navigator.of(context).pop(),
            onPrimaryAction: () => Navigator.of(context).pop(),
          );
        }

        final bool dark = Theme.of(context).brightness == Brightness.dark;

        return AmanahBottomSheetScaffold(
          title: widget.sheetTitle.isNotEmpty ? widget.sheetTitle : 'Format Dokumen',
          subtitle: widget.sheetSubtitle ?? 'Pilih format dokumen laporan resmi',
          hugContent: true,
          body: _controller.isLoading
              ? _buildProgressState(context, dark)
              : _buildFormatSelection(context, dark),
        );
      },
    );
  }

  Widget _buildFormatSelection(BuildContext context, bool dark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ...ExportFormat.values.map((ExportFormat format) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildFormatCard(format, dark),
          );
        }),
      ],
    );
  }

  Widget _buildFormatCard(ExportFormat format, bool dark) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _controller.startExport(
          exportType: widget.exportType,
          format: format,
          parameters: widget.parameters,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark
              ? AmanahColorTokens.neutral800.withValues(alpha: 0.35)
              : AmanahColorTokens.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark ? AmanahThemeTokens.outline(context) : AmanahColorTokens.neutral200,
            width: 1.0,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: format.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(format.icon, color: format.accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    format.label,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    format.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: dark ? AmanahColorTokens.neutral500 : AmanahColorTokens.neutral400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressState(BuildContext context, bool dark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: 12),
        Center(
          child: SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  value: _controller.progressPercent > 0
                      ? _controller.progressPercent / 100.0
                      : null,
                  strokeWidth: 3.5,
                  valueColor: const AlwaysStoppedAnimation<Color>(AmanahColorTokens.brandPrimary),
                  backgroundColor: dark
                      ? AmanahColorTokens.neutral800
                      : AmanahColorTokens.neutral200,
                ),
                Text(
                  '${_controller.progressPercent}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AmanahColorTokens.brandPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          _controller.currentPhase,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: dark ? AmanahColorTokens.surfaceLight : AmanahColorTokens.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Proses berjalan di background. Anda dapat menunggu di sini.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral500,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
