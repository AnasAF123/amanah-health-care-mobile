import 'package:flutter/material.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_empty_state.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_modal_scaffold.dart';
import 'package:amanah_healthcare/features/home/presentation/components/amanah_success_drawer.dart';
import 'package:amanah_healthcare/features/home/presentation/theme/amanah_color_tokens.dart';
import 'package:amanah_healthcare/features/presence/presentation/components/amanah_month_picker_dialog.dart';
import '../../domain/entities/export_format.dart';
import '../state/export_controller.dart';

class AmanahExportSheet extends StatefulWidget {
  const AmanahExportSheet({
    super.key,
    required this.exportType,
    required this.sheetTitle,
    this.sheetSubtitle,
    this.parameters,
    this.initialMonth,
  });

  final String exportType;
  final String sheetTitle;
  final String? sheetSubtitle;
  final Map<String, dynamic>? parameters;
  final DateTime? initialMonth;

  static Future<void> show({
    required BuildContext context,
    required String exportType,
    required String sheetTitle,
    String? sheetSubtitle,
    Map<String, dynamic>? parameters,
    DateTime? initialMonth,
  }) {
    return showAmanahBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => AmanahExportSheet(
        exportType: exportType,
        sheetTitle: sheetTitle,
        sheetSubtitle: sheetSubtitle,
        parameters: parameters,
        initialMonth: initialMonth,
      ),
    );
  }

  @override
  State<AmanahExportSheet> createState() => _AmanahExportSheetState();
}

class _AmanahExportSheetState extends State<AmanahExportSheet> {
  late final ExportController _controller;
  late DateTime _selectedMonth;
  bool _isCheckingAvailability = false;
  bool _hasData = true;

  @override
  void initState() {
    super.initState();
    _controller = ExportController();
    _selectedMonth = widget.initialMonth ?? DateTime.now();

    if (widget.exportType == 'attendance') {
      _checkDataAvailability(_selectedMonth);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkDataAvailability(DateTime month) async {
    if (widget.exportType != 'attendance') return;

    setState(() {
      _isCheckingAvailability = true;
    });

    final int lastDay = DateTime(month.year, month.month + 1, 0).day;
    final String mm = month.month.toString().padLeft(2, '0');
    final Map<String, dynamic> checkParams = Map<String, dynamic>.from(
      widget.parameters ?? <String, dynamic>{},
    );
    checkParams['startDate'] = '${month.year}-$mm-01';
    checkParams['endDate'] = '${month.year}-$mm-${lastDay.toString().padLeft(2, '0')}';

    final bool available = await _controller.checkAvailability(
      exportType: widget.exportType,
      parameters: checkParams,
    );

    if (!mounted) return;
    setState(() {
      _hasData = available;
      _isCheckingAvailability = false;
    });
  }

  Future<void> _openMonthPicker(BuildContext context) async {
    final DateTime? picked = await AmanahMonthPickerDialog.show(
      context: context,
      initialMonth: _selectedMonth,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedMonth = picked;
      });
      _checkDataAvailability(picked);
    }
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
        final bool isAttendance = widget.exportType == 'attendance';

        final String subtitle = isAttendance
            ? 'Periode: ${AmanahMonthPickerDialog.formatMonthYear(_selectedMonth)}'
            : (widget.sheetSubtitle ?? 'Pilih format dokumen laporan resmi');

        return AmanahBottomSheetScaffold(
          title: widget.sheetTitle.isNotEmpty ? widget.sheetTitle : 'Format Dokumen',
          subtitle: subtitle,
          hugContent: true,
          trailing: isAttendance ? _buildAttendanceCalendarButton(context, dark) : null,
          body: _controller.isLoading
              ? _buildProgressState(context, dark)
              : (_isCheckingAvailability
                    ? _buildCheckingState(context, dark)
                    : (!_hasData
                          ? _buildEmptyState(context, dark)
                          : _buildFormatSelection(context, dark))),
        );
      },
    );
  }

  Widget _buildAttendanceCalendarButton(BuildContext context, bool dark) {
    final Color activeAccent = dark ? AmanahColorTokens.tabActiveDark : AmanahColorTokens.brand;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _openMonthPicker(context),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: dark ? AmanahColorTokens.neutral800 : AmanahColorTokens.neutral100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dark ? AmanahColorTokens.neutral700 : AmanahColorTokens.neutral200,
          ),
        ),
        child: Icon(Icons.calendar_month_outlined, size: 19, color: activeAccent),
      ),
    );
  }

  Widget _buildCheckingState(BuildContext context, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AmanahColorTokens.brandPrimary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Memeriksa data presensi...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: dark ? AmanahColorTokens.neutral400 : AmanahColorTokens.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AmanahEmptyState.box(
        title: 'Data Tidak Tersedia',
        message:
            'Tidak ada rekaman presensi pada bulan ${AmanahMonthPickerDialog.formatMonthYear(_selectedMonth)}.',
        variant: AmanahEmptyStateVariant.compact,
        boxSize: 76,
        actionText: 'Pilih Bulan Lain',
        actionLeadingIcon: Icons.calendar_month_outlined,
        onAction: () => _openMonthPicker(context),
      ),
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
        final Map<String, dynamic> resolvedParams = Map<String, dynamic>.from(
          widget.parameters ?? <String, dynamic>{},
        );

        if (widget.exportType == 'attendance') {
          final int lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
          final String mm = _selectedMonth.month.toString().padLeft(2, '0');
          resolvedParams['startDate'] = '${_selectedMonth.year}-$mm-01';
          resolvedParams['endDate'] =
              '${_selectedMonth.year}-$mm-${lastDay.toString().padLeft(2, '0')}';
          resolvedParams['periodLabel'] = AmanahMonthPickerDialog.formatMonthYear(_selectedMonth);
        }

        _controller.startExport(
          exportType: widget.exportType,
          format: format,
          parameters: resolvedParams,
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
