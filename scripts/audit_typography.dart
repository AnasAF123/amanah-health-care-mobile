import 'dart:io';
import 'dart:convert';

void main(List<String> args) {
  final Stopwatch stopwatch = Stopwatch()..start();
  
  final bool summaryOnly = args.contains('--summary');
  final bool failOnViolation = args.contains('--fail-on-violation');
  final bool jsonMode = args.contains('--json');
  
  String targetPath = 'packages/amanah_healthcare/lib';
  String? exportPath;
  final List<String> excludedPatterns = <String>[];

  for (final String arg in args) {
    if (arg.startsWith('--path=')) {
      targetPath = arg.substring('--path='.length);
    } else if (arg.startsWith('--export-path=')) {
      exportPath = arg.substring('--export-path='.length);
    } else if (arg.startsWith('--exclude=')) {
      final String rawExcludes = arg.substring('--exclude='.length);
      excludedPatterns.addAll(
        rawExcludes
            .split(',')
            .map((e) => e.trim().replaceAll(r'\', '/'))
            .where((e) => e.isNotEmpty),
      );
    }
  }

  final Directory targetDir = Directory(targetPath);
  if (!targetDir.existsSync()) {
    stderr.writeln('ERROR: Target directory does not exist: ${targetDir.absolute.path}');
    exit(2);
  }

  final RegExp typographyRegex = RegExp(
    r'''fontFamily\s*:\s*['"][^'"]+['"]''',
  );

  int totalFilesScanned = 0;
  int totalViolations = 0;
  final Map<String, List<_Finding>> findingsByFile = <String, List<_Finding>>{};

  for (final FileSystemEntity entity in targetDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final String normalizedPath = entity.path.replaceAll(r'\', '/');
    bool isExcluded = false;
    
    for (final String pattern in excludedPatterns) {
      if (normalizedPath.contains(pattern)) {
        isExcluded = true;
        break;
      }
    }

    if (isExcluded) {
      continue;
    }

    totalFilesScanned++;
    final List<String> lines = entity.readAsLinesSync();
    final List<_Finding> fileFindings = <_Finding>[];

    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      for (final RegExpMatch match in typographyRegex.allMatches(line)) {
        final String matchText = match.group(0)!;
        
        fileFindings.add(
          _Finding(
            lineNumber: i + 1,
            matchedValue: matchText,
            lineContent: line.trim(),
          ),
        );
      }
    }

    if (fileFindings.isNotEmpty) {
      findingsByFile[entity.path] = fileFindings;
      totalViolations += fileFindings.length;
    }
  }

  stopwatch.stop();

  if (jsonMode) {
    final Map<String, dynamic> reportData = {
      'timestamp': DateTime.now().toIso8601String(),
      'targetPath': targetPath,
      'totalFilesScanned': totalFilesScanned,
      'totalViolations': totalViolations,
      'scanDurationMs': stopwatch.elapsedMilliseconds,
      'findings': findingsByFile.map((key, value) => MapEntry(
            key.replaceAll(r'\', '/'), 
            value.map((e) => e.toJson()).toList(),
          )),
    };

    final String timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final String autoFileName = 'typography_audit_report_$timestamp.json';
    
    File jsonFile;
    if (exportPath != null) {
      final Directory exportDir = Directory(exportPath);
      if (!exportDir.existsSync()) {
        exportDir.createSync(recursive: true);
      }
      
      String cleanDir = exportPath.replaceAll(r'\', '/');
      if (!cleanDir.endsWith('/')) {
        cleanDir += '/';
      }
      jsonFile = File('$cleanDir$autoFileName');
    } else {
      jsonFile = File(autoFileName);
    }

    jsonFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(reportData));
    stdout.writeln('DUMP_PATH=${jsonFile.absolute.path}');
  }

  if (!summaryOnly && findingsByFile.isNotEmpty) {
    findingsByFile.forEach((String filePath, List<_Finding> findings) {
      final String relativePath = filePath.replaceAll(r'\', '/');
      for (final _Finding f in findings) {
        stdout.writeln('$relativePath:${f.lineNumber}: ${f.matchedValue}');
      }
    });
  }

  stdout.writeln('Scanned: $totalFilesScanned files. Violations: $totalViolations. Duration: ${stopwatch.elapsedMilliseconds}ms.');

  if (totalViolations > 0 && failOnViolation) {
    exit(1);
  }
  exit(0);
}

class _Finding {
  const _Finding({
    required this.lineNumber,
    required this.matchedValue,
    required this.lineContent,
  });

  final int lineNumber;
  final String matchedValue;
  final String lineContent;

  Map<String, dynamic> toJson() => {
        'lineNumber': lineNumber,
        'matchedValue': matchedValue,
        'lineContent': lineContent,
      };
}