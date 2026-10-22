import 'dart:io';
import '../entities/export_format.dart';
import '../entities/export_job.dart';

abstract interface class ExportRepository {
  Future<ExportJob> requestExport({
    required String exportType,
    required ExportFormat format,
    Map<String, dynamic>? parameters,
  });

  Future<bool> checkAvailability({required String exportType, Map<String, dynamic>? parameters});

  Future<ExportJob> getJobStatus(String jobId);

  Future<File> downloadExport({required String downloadUrl, required String fileName});
}
