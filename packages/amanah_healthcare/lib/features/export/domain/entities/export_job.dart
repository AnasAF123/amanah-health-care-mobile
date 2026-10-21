import 'export_format.dart';

class ExportJob {
  const ExportJob({
    required this.jobId,
    required this.status,
    required this.exportType,
    required this.format,
    required this.totalRows,
    required this.processedRows,
    required this.percent,
    required this.phase,
    this.downloadUrl,
    this.errorMessage,
    this.createdAt,
    this.finishedAt,
  });

  final String jobId;
  final String status;
  final String exportType;
  final ExportFormat format;
  final int totalRows;
  final int processedRows;
  final int percent;
  final String phase;
  final String? downloadUrl;
  final String? errorMessage;
  final String? createdAt;
  final String? finishedAt;

  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get isRunning => status.toLowerCase() == 'running';
  bool get isQueued => status.toLowerCase() == 'queued';

  factory ExportJob.fromJson(Map<String, dynamic> json) {
    ExportFormat parsedFormat = ExportFormat.pdf;
    final String fmtStr = (json['format'] as String? ?? 'pdf').toLowerCase();
    if (fmtStr == 'xlsx' || fmtStr == 'excel') {
      parsedFormat = ExportFormat.xlsx;
    } else if (fmtStr == 'csv') {
      parsedFormat = ExportFormat.csv;
    }

    return ExportJob(
      jobId: json['jobId'] as String? ?? '',
      status: json['status'] as String? ?? 'queued',
      exportType: json['exportType'] as String? ?? '',
      format: parsedFormat,
      totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
      processedRows: (json['processedRows'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      phase: json['phase'] as String? ?? 'QUEUED',
      downloadUrl: json['downloadUrl'] as String?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: json['createdAt'] as String?,
      finishedAt: json['finishedAt'] as String?,
    );
  }
}
