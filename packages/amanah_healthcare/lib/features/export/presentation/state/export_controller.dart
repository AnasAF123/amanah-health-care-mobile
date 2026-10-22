import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:amanah_healthcare/core/notifications/amanah_push_service.dart';
import '../../domain/entities/export_format.dart';
import '../../domain/entities/export_job.dart';
import '../../domain/repositories/export_repository.dart';
import '../../data/repositories/export_repository_impl.dart';

class ExportController extends ChangeNotifier {
  ExportController({ExportRepository? repository})
    : _repository = repository ?? ExportRepositoryImpl();

  final ExportRepository _repository;

  bool _isLoading = false;
  bool _isDownloading = false;
  ExportJob? _job;
  File? _downloadedFile;
  String? _errorMessage;
  int _progressPercent = 0;
  String _currentPhase = 'Mengantre';

  bool get isLoading => _isLoading;
  bool get isDownloading => _isDownloading;
  bool get isDone => _downloadedFile != null;
  ExportJob? get job => _job;
  File? get downloadedFile => _downloadedFile;
  String? get errorMessage => _errorMessage;
  int get progressPercent => _progressPercent;
  String get currentPhase => _currentPhase;

  Future<bool> checkAvailability({
    required String exportType,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      return await _repository.checkAvailability(exportType: exportType, parameters: parameters);
    } catch (e) {
      debugPrint('[ExportController] Error checking availability: $e');
      return true;
    }
  }

  Future<void> startExport({
    required String exportType,
    required ExportFormat format,
    Map<String, dynamic>? parameters,
  }) async {
    _isLoading = true;
    _isDownloading = false;
    _downloadedFile = null;
    _errorMessage = null;
    _progressPercent = 5;
    _currentPhase = 'Mendaftarkan antrean ekspor...';
    notifyListeners();

    try {
      final ExportJob initialJob = await _repository.requestExport(
        exportType: exportType,
        format: format,
        parameters: parameters,
      );

      _job = initialJob;
      _progressPercent = 15;
      _currentPhase = 'Memproses data di server...';
      notifyListeners();

      // Start polling status
      await _pollStatus(initialJob.jobId, format);
    } catch (err) {
      _isLoading = false;
      _isDownloading = false;
      _errorMessage = err.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> _pollStatus(String jobId, ExportFormat format) async {
    int attempts = 0;
    const int maxAttempts = 30;

    while (attempts < maxAttempts) {
      await Future<void>.delayed(Duration(milliseconds: attempts < 3 ? 1000 : 2000));
      attempts++;

      try {
        final ExportJob statusJob = await _repository.getJobStatus(jobId);
        _job = statusJob;
        _progressPercent = statusJob.percent > 0 ? statusJob.percent : 40;
        _currentPhase = _mapPhaseText(statusJob.phase);
        notifyListeners();

        if (statusJob.isCompleted) {
          _progressPercent = 90;
          _currentPhase = 'Mengunduh berkas laporan...';
          _isDownloading = true;
          notifyListeners();

          final String fileName =
              '${statusJob.exportType}_${DateTime.now().millisecondsSinceEpoch}.${format.extensionName}';

          if (statusJob.downloadUrl != null) {
            final File file = await _repository.downloadExport(
              downloadUrl: statusJob.downloadUrl!,
              fileName: fileName,
            );
            _downloadedFile = file;

            // Trigger instant status bar notification (tap to open)
            unawaited(
              AmanahPushService.instance.showDownloadCompleteNotification(
                title: 'Laporan Berhasil Diunduh',
                body: 'Ketuk untuk langsung membuka berkas $fileName',
                filePath: file.path,
              ),
            );
          }

          _progressPercent = 100;
          _currentPhase = 'Selesai';
          _isLoading = false;
          _isDownloading = false;
          notifyListeners();
          return;
        }

        if (statusJob.isFailed) {
          throw Exception(statusJob.errorMessage ?? 'Proses ekspor gagal di server');
        }
      } catch (err) {
        _isLoading = false;
        _isDownloading = false;
        _errorMessage = err.toString().replaceAll('Exception: ', '');
        notifyListeners();
        return;
      }
    }

    _isLoading = false;
    _errorMessage = 'Batas waktu tunggu ekspor terlampaui. Silakan coba lagi.';
    notifyListeners();
  }

  String _mapPhaseText(String phase) {
    switch (phase.toUpperCase()) {
      case 'QUEUED':
        return 'Mengantre di antrean server...';
      case 'WRITING':
        return 'Menyusun berkas dokumen data...';
      case 'FINALIZING':
        return 'Menyelesaikan enkripsi dan penyimpanan...';
      case 'DONE':
        return 'Berkas siap diunduh!';
      default:
        return 'Memproses data ($phase)...';
    }
  }

  Future<void> shareFile() async {
    if (_downloadedFile == null) return;
    try {
      await SharePlus.instance.share(
        ShareParams(title: 'Bagikan Laporan', files: <XFile>[XFile(_downloadedFile!.path)]),
      );
    } catch (e) {
      debugPrint('Error sharing export file: $e');
    }
  }

  Future<void> openFile() async {
    if (_downloadedFile == null) return;
    try {
      final OpenResult result = await OpenFilex.open(_downloadedFile!.path);
      if (result.type != ResultType.done) {
        debugPrint('[ExportController] OpenFilex result: ${result.message}');
      }
    } catch (e) {
      debugPrint('[ExportController] Error opening export file: $e');
    }
  }
}
