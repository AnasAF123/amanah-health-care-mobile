import 'package:flutter/material.dart';

enum ExportFormat {
  pdf,
  xlsx,
  csv;

  String get label {
    switch (this) {
      case ExportFormat.pdf:
        return 'Dokumen PDF (.pdf)';
      case ExportFormat.xlsx:
        return 'Spreadsheet Excel (.xlsx)';
      case ExportFormat.csv:
        return 'Berkas Tabel CSV (.csv)';
    }
  }

  String get shortLabel {
    switch (this) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.xlsx:
        return 'Excel';
      case ExportFormat.csv:
        return 'CSV';
    }
  }

  String get description {
    switch (this) {
      case ExportFormat.pdf:
        return 'Format dokumen cetak resmi berkop klinik';
      case ExportFormat.xlsx:
        return 'Format tabel Microsoft Excel bersel terstruktur';
      case ExportFormat.csv:
        return 'Format berkas data teks koma ringan';
    }
  }

  String get extensionName {
    switch (this) {
      case ExportFormat.pdf:
        return 'pdf';
      case ExportFormat.xlsx:
        return 'xlsx';
      case ExportFormat.csv:
        return 'csv';
    }
  }

  IconData get icon {
    switch (this) {
      case ExportFormat.pdf:
        return Icons.picture_as_pdf_rounded;
      case ExportFormat.xlsx:
        return Icons.table_chart_rounded;
      case ExportFormat.csv:
        return Icons.description_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case ExportFormat.pdf:
        return const Color(0xFFDC2626); // Red
      case ExportFormat.xlsx:
        return const Color(0xFF16A34A); // Green
      case ExportFormat.csv:
        return const Color(0xFF2563EB); // Blue
    }
  }
}
