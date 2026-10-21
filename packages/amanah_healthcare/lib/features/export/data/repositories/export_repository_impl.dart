import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/export_format.dart';
import '../../domain/entities/export_job.dart';
import '../../domain/repositories/export_repository.dart';
import '../datasources/export_remote_data_source.dart';

class ExportRepositoryImpl implements ExportRepository {
  ExportRepositoryImpl({ExportRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ExportRemoteDataSourceImpl();

  final ExportRemoteDataSource _remoteDataSource;

  @override
  Future<ExportJob> requestExport({
    required String exportType,
    required ExportFormat format,
    Map<String, dynamic>? parameters,
  }) {
    return _remoteDataSource.requestExport(
      exportType: exportType,
      format: format.extensionName,
      parameters: parameters,
    );
  }

  @override
  Future<ExportJob> getJobStatus(String jobId) {
    return _remoteDataSource.getJobStatus(jobId);
  }

  @override
  Future<File> downloadExport({
    required String downloadUrl,
    required String fileName,
  }) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String savePath = '${directory.path}/$fileName';
    return _remoteDataSource.downloadFile(
      downloadUrl: downloadUrl,
      savePath: savePath,
    );
  }
}
