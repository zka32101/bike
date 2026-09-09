import 'package:flutter/foundation.dart';

import '../models/export_models.dart';
import 'export_service.dart';

/// エクスポートサービス実装
/// MemoryExportRepository をラップして提供する
class ExportService {
  final ExportRepository _repository;

  ExportService({ExportRepository? repository})
      : _repository = repository ?? MemoryExportRepository();

  // Job管理
  Future<void> createExportJob(ExportJob job) => _repository.createExportJob(job);
  Future<ExportJob?> getExportJob(String jobId) => _repository.getExportJob(jobId);
  Future<List<ExportJob>> getAllExportJobs() => _repository.getAllExportJobs();
  Future<void> updateExportJob(ExportJob job) => _repository.updateExportJob(job);
  Future<void> deleteExportJob(String jobId) => _repository.deleteExportJob(jobId);

  // Report管理
  Future<void> createReport(Report report) => _repository.createReport(report);
  Future<Report?> getReport(String reportId) => _repository.getReport(reportId);
  Future<List<Report>> getAllReports() => _repository.getAllReports();
  Future<void> updateReport(Report report) => _repository.updateReport(report);

  // ScheduledReport管理
  Future<void> createScheduledReport(ScheduledReport schedule) =>
      _repository.createScheduledReport(schedule);
  Future<ScheduledReport?> getScheduledReport(String scheduleId) =>
      _repository.getScheduledReport(scheduleId);
  Future<List<ScheduledReport>> getAllScheduledReports() =>
      _repository.getAllScheduledReports();
  Future<void> updateScheduledReport(ScheduledReport schedule) =>
      _repository.updateScheduledReport(schedule);

  // Template管理
  Future<void> createTemplate(ReportTemplate template) =>
      _repository.createTemplate(template);
  Future<ReportTemplate?> getTemplate(String templateId) =>
      _repository.getTemplate(templateId);
  Future<List<ReportTemplate>> getAllTemplates() =>
      _repository.getAllTemplates();

  // Statistics管理
  Future<void> saveStatistics(ExportStatistics stats) =>
      _repository.saveStatistics(stats);
  Future<ExportStatistics?> getStatistics(String statsId) =>
      _repository.getStatistics(statsId);
  Future<List<ExportStatistics>> getStatisticsInRange(
    DateTime start,
    DateTime end,
  ) =>
      _repository.getStatisticsInRange(start, end);

  /// データをエクスポート
  Future<ExportResult> exportData(String dataType, String format) async {
    final result = ExportResult(
      id: 'export_${DateTime.now().millisecondsSinceEpoch}',
      exportType: dataType,
      format: format,
      downloadUrl: 'data:text/plain,',
      recordCount: 0,
      fileSizeBytes: 0,
      createdAt: DateTime.now(),
      status: 'pending',
    );
    return result;
  }
}
