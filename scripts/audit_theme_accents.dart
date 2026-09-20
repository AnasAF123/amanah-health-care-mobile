import 'dart:io';
import 'dart:convert';

void main(List<String> args) {
  final Stopwatch stopwatch = Stopwatch()..start();

  final bool summaryOnly = args.contains('--summary');
  final bool failOnViolation = args.contains('--fail-on-violation');
  final bool jsonMode = args.contains('--json');

  String targetPath = 'packages/amanah_healthcare/lib';
  String? exportPath;
  String? ruleFilter;
  final List<String> excludedPatterns = <String>[
    'lib/features/home/presentation/theme/amanah_color_tokens.dart',
    'lib/features/home/presentation/theme/amanah_carousel_tokens.dart',
    'lib/features/home/presentation/theme/amanah_schedule_card_tokens.dart',
    'lib/features/home/presentation/theme/amanah_typography_tokens.dart',
    'lib/features/home/presentation/theme/amanah_theme_data.dart',
    'lib/features/home/domain/amanah_visual_role.dart',
    'lib/features/home/presentation/components/amanah_aurora_background.dart',
    'lib/generic_lib/',
  ];

  for (int i = 0; i < args.length; i++) {
    final String arg = args[i];
    if (arg.startsWith('--path=')) {
      targetPath = arg.substring('--path='.length);
    } else if (arg == '--path' && i + 1 < args.length) {
      targetPath = args[++i];
    } else if (arg.startsWith('--export-path=')) {
      exportPath = arg.substring('--export-path='.length);
    } else if (arg == '--export-path' && i + 1 < args.length) {
      exportPath = args[++i];
    } else if (arg.startsWith('--rule=')) {
      ruleFilter = arg.substring('--rule='.length).trim();
    } else if (arg == '--rule' && i + 1 < args.length) {
      ruleFilter = args[++i].trim();
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

  final List<File> filesToScan = <File>[];
  final File singleFile = File(targetPath);
  if (singleFile.existsSync()) {
    filesToScan.add(singleFile);
  } else {
    final Directory targetDir = Directory(targetPath);
    if (!targetDir.existsSync()) {
      stderr.writeln('ERROR: Target path does not exist: $targetPath');
      exit(2);
    }
    for (final FileSystemEntity entity in targetDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        filesToScan.add(entity);
      }
    }
  }

  final List<String> blueAccentTokens = <String>[
    'AmanahColorTokens.brand',
    'AmanahColorTokens.brandAccent',
    'AmanahColorTokens.brandLight',
    'AmanahColorTokens.brandSoft',
    'AmanahColorTokens.brandPrimary',
    'AmanahColorTokens.brandSurface',
    'AmanahColorTokens.brandMuted',
    'AmanahColorTokens.auroraSapphireDark',
    'AmanahColorTokens.auroraBlueDark',
    'AmanahColorTokens.auroraAccentDark',
  ];

  final List<String> cyanAccentTokens = <String>[
    'AmanahColorTokens.cyanAccent',
    'AmanahColorTokens.auroraCyanDark',
    'AmanahColorTokens.auroraCyanLuminousDark',
    'AmanahColorTokens.cyanBright',
    'AmanahColorTokens.cyanLight',
    'AmanahColorTokens.tabActiveDark',
  ];

  final List<String> lightStrokeTokens = <String>[
    'AmanahColorTokens.btnCrispBlueBorder',
    'AmanahColorTokens.scheduleBorderLight',
    'AmanahColorTokens.scheduleDashedLight',
    'AmanahColorTokens.carouselRimStrokeLight',
    'AmanahColorTokens.carouselNavBtnBorderLight',
  ];

  final List<String> darkStrokeTokens = <String>[
    'AmanahColorTokens.btnCrispBlueDarkBorder',
    'AmanahColorTokens.btnCrispSoftDarkBorder',
    'AmanahColorTokens.scheduleBorderDark',
    'AmanahColorTokens.scheduleDashedDark',
    'AmanahColorTokens.carouselRimStrokeDark',
    'AmanahColorTokens.carouselNavBtnBorderDark',
  ];

  final List<String> lightSurfaceTokens = <String>[
    'AmanahColorTokens.canvasLight',
    'AmanahColorTokens.surfaceLight',
    'AmanahColorTokens.surfaceSecondaryLight',
    'AmanahColorTokens.brandSurface',
    'AmanahColorTokens.cardCoverLightBottom',
  ];

  final List<String> darkSurfaceTokens = <String>[
    'AmanahColorTokens.canvasDark',
    'AmanahColorTokens.canvasAltDark',
    'AmanahColorTokens.surfaceDark',
    'AmanahColorTokens.surfaceSecondaryDark',
    'AmanahColorTokens.surfaceElevatedDark',
    'AmanahColorTokens.surfaceHighestDark',
    'AmanahColorTokens.surfaceAccentDark',
    'AmanahColorTokens.navySurface',
    'AmanahColorTokens.dockCavityDark',
    'AmanahColorTokens.dockCavityDeep',
    'AmanahColorTokens.dockSurfaceDarkTop',
    'AmanahColorTokens.dockSurfaceDarkMid',
    'AmanahColorTokens.dockSurfaceDarkBottom',
    'AmanahColorTokens.cardCoverDarkTop',
    'AmanahColorTokens.cardCoverDarkBottom',
  ];

  final List<String> lightShadowTokens = <String>[
    'AmanahColorTokens.btnCrispBlueShadow',
    'AmanahColorTokens.carouselShadowLight',
    'AmanahColorTokens.scheduleShadowLight',
    'AmanahColorTokens.qrButtonShadowLight',
  ];

  final List<String> darkShadowTokens = <String>[
    'AmanahColorTokens.btnCrispBlueDarkShadow',
    'AmanahColorTokens.cardShadowDark',
    'AmanahColorTokens.qrButtonShadowDark',
  ];

  final RegExp darkTernaryRegex = RegExp(
    r'''(?:AmanahThemeTokens\.isDark\([^)]*\)|isDark(?:\([^)]*\))?|\bdark\b)\s*\?\s*([^:\n;]+(?:\n\s*[^:\n;]+)*?)\s*:\s*([^,;\n)]+(?:\n\s*[^,;\n)]+)*)''',
    multiLine: true,
  );

  final RegExp notDarkTernaryRegex = RegExp(
    r'''(?:!AmanahThemeTokens\.isDark\([^)]*\)|!isDark(?:\([^)]*\))?|!\bdark\b)\s*\?\s*([^:\n;]+(?:\n\s*[^:\n;]+)*?)\s*:\s*([^,;\n)]+(?:\n\s*[^,;\n)]+)*)''',
    multiLine: true,
  );

  final RegExp ifDarkRegex = RegExp(
    r'''if\s*\(\s*(?:AmanahThemeTokens\.isDark\([^)]*\)|isDark(?:\([^)]*\))?|\bdark\b)\s*\)\s*\{([^}]+)\}\s*else\s*\{([^}]+)\}''',
    multiLine: true,
  );

  final RegExp ifNotDarkRegex = RegExp(
    r'''if\s*\(\s*(?:!AmanahThemeTokens\.isDark\([^)]*\)|!isDark(?:\([^)]*\))?|!\bdark\b)\s*\)\s*\{([^}]+)\}\s*else\s*\{([^}]+)\}''',
    multiLine: true,
  );

  int totalFilesScanned = 0;
  int totalViolations = 0;
  final Map<String, List<_ThemeFinding>> findingsByFile = <String, List<_ThemeFinding>>{};

  for (final File entity in filesToScan) {

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
    final String content = entity.readAsStringSync();
    final List<_ThemeFinding> fileFindings = <_ThemeFinding>[];

    void inspectBranches({
      required String darkBranch,
      required String lightBranch,
      required int offset,
      required String fullSnippet,
    }) {
      final int line = _lineFromOffset(content, offset);

      for (final String token in blueAccentTokens) {
        if (darkBranch.contains(token)) {
          fileFindings.add(
            _ThemeFinding(
              lineNumber: line,
              rule: 'DARK_MODE_BLUE_ACCENT_VIOLATION',
              description:
                  'Dark theme branch contains blue accent token "$token". Dark mode must use cyan (e.g. AmanahColorTokens.cyanAccent, auroraCyanDark, or AmanahThemeTokens.accent).',
              snippet: fullSnippet,
            ),
          );
          break;
        }
      }

      for (final String token in cyanAccentTokens) {
        if (lightBranch.contains(token)) {
          fileFindings.add(
            _ThemeFinding(
              lineNumber: line,
              rule: 'LIGHT_MODE_CYAN_ACCENT_VIOLATION',
              description:
                  'Light theme branch contains cyan accent token "$token". Light mode must use blue (e.g. AmanahColorTokens.brand or brandAccent).',
              snippet: fullSnippet,
            ),
          );
          break;
        }
      }

      for (final String token in lightStrokeTokens) {
        if (darkBranch.contains(token)) {
          fileFindings.add(
            _ThemeFinding(
              lineNumber: line,
              rule: 'DARK_MODE_STROKE_VIOLATION',
              description:
                  'Dark theme branch contains light stroke token "$token". Dark mode must use dark stroke tokens (e.g. btnCrispBlueDarkBorder, scheduleBorderDark, outline).',
              snippet: fullSnippet,
            ),
          );
          break;
        }
      }

      for (final String token in darkStrokeTokens) {
        if (lightBranch.contains(token)) {
          fileFindings.add(
            _ThemeFinding(
              lineNumber: line,
              rule: 'LIGHT_MODE_STROKE_VIOLATION',
              description:
                  'Light theme branch contains dark stroke token "$token". Light mode must use light stroke tokens (e.g. btnCrispBlueBorder, scheduleBorderLight).',
              snippet: fullSnippet,
            ),
          );
          break;
        }
      }

      for (final String token in lightSurfaceTokens) {
        if (darkBranch.contains(token)) {
          fileFindings.add(
            _ThemeFinding(
              lineNumber: line,
              rule: 'DARK_MODE_SURFACE_VIOLATION',
              description:
                  'Dark theme branch contains light surface token "$token". Dark mode must use dark surface tokens (e.g. surfaceDark, surfaceSecondaryDark, canvasDark).',
              snippet: fullSnippet,
            ),
          );
          break;
        }
      }

      for (final String token in darkSurfaceTokens) {
        if (lightBranch.contains(token)) {
          fileFindings.add(
            _ThemeFinding(
              lineNumber: line,
              rule: 'LIGHT_MODE_SURFACE_VIOLATION',
              description:
                  'Light theme branch contains dark surface token "$token". Light mode must use light surface tokens (e.g. surfaceLight, canvasLight, neutral50).',
              snippet: fullSnippet,
            ),
          );
          break;
        }
      }

      for (final String token in lightShadowTokens) {
        if (darkBranch.contains(token)) {
          fileFindings.add(
            _ThemeFinding(
              lineNumber: line,
              rule: 'DARK_MODE_SHADOW_VIOLATION',
              description:
                  'Dark theme branch contains light shadow token "$token". Dark mode must use dark shadow tokens (e.g. btnCrispBlueDarkShadow, cardShadowDark).',
              snippet: fullSnippet,
            ),
          );
          break;
        }
      }

      for (final String token in darkShadowTokens) {
        if (lightBranch.contains(token)) {
          fileFindings.add(
            _ThemeFinding(
              lineNumber: line,
              rule: 'LIGHT_MODE_SHADOW_VIOLATION',
              description:
                  'Light theme branch contains dark shadow token "$token". Light mode must use light shadow tokens (e.g. btnCrispBlueShadow, carouselShadowLight).',
              snippet: fullSnippet,
            ),
          );
          break;
        }
      }

      if (darkBranch.contains('btnCrispBlueGradient') &&
          !darkBranch.contains('btnCrispBlueDarkGradient')) {
        fileFindings.add(
          _ThemeFinding(
            lineNumber: line,
            rule: 'CTA_BUTTON_CRISP_GRADIENT_VIOLATION',
            description:
                'Dark theme branch uses light crisp gradient "btnCrispBlueGradient". Dark mode buttons must use "btnCrispBlueDarkGradient".',
            snippet: fullSnippet,
          ),
        );
      }

      if (lightBranch.contains('btnCrispBlueDarkGradient')) {
        fileFindings.add(
          _ThemeFinding(
            lineNumber: line,
            rule: 'CTA_BUTTON_CRISP_GRADIENT_VIOLATION',
            description:
                'Light theme branch uses dark crisp gradient "btnCrispBlueDarkGradient". Light mode buttons must use "btnCrispBlueGradient".',
            snippet: fullSnippet,
          ),
        );
      }
    }

    void scanRegex(RegExp regex, bool normalCondition) {
      for (final RegExpMatch match in regex.allMatches(content)) {
        final String branchA = match.group(1)?.trim() ?? '';
        final String branchB = match.group(2)?.trim() ?? '';
        final String darkBranch = normalCondition ? branchA : branchB;
        final String lightBranch = normalCondition ? branchB : branchA;
        final String snippet = match.group(0)!.trim().replaceAll(RegExp(r'\s+'), ' ');

        inspectBranches(
          darkBranch: darkBranch,
          lightBranch: lightBranch,
          offset: match.start,
          fullSnippet: snippet.length > 120 ? '${snippet.substring(0, 120)}...' : snippet,
        );
      }
    }

    scanRegex(darkTernaryRegex, true);
    scanRegex(notDarkTernaryRegex, false);
    scanRegex(ifDarkRegex, true);
    scanRegex(ifNotDarkRegex, false);

    final RegExp directCrispBorderRegex = RegExp(
      r'''(?<!\?)\s*(?:AmanahColorTokens\.btnCrispBlueBorder|AmanahColorTokens\.btnCrispBlueDarkBorder)''',
    );
    for (final RegExpMatch m in directCrispBorderRegex.allMatches(content)) {
      final int start = m.start;
      final int line = _lineFromOffset(content, start);
      final int lookbackStart = start > 120 ? start - 120 : 0;
      final String lookback = content.substring(lookbackStart, start);
      if (!lookback.contains('?') && !lookback.contains('if')) {
        fileFindings.add(
          _ThemeFinding(
            lineNumber: line,
            rule: 'UNADAPTED_STROKE_TOKEN_VIOLATION',
            description:
                'Button border token used directly without theme adaptation. Must adapt between btnCrispBlueBorder (light) and btnCrispBlueDarkBorder (dark).',
            snippet: content.substring(start, (start + 60).clamp(0, content.length)).replaceAll('\n', ' ').trim(),
          ),
        );
      }
    }

    final List<_ThemeFinding> filteredFindings = ruleFilter == null
        ? fileFindings
        : fileFindings.where((f) => f.rule.toLowerCase() == ruleFilter!.toLowerCase()).toList();

    if (filteredFindings.isNotEmpty) {
      findingsByFile[entity.path] = filteredFindings;
      totalViolations += filteredFindings.length;
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
      'findings': findingsByFile.map(
        (key, value) => MapEntry(
          key.replaceAll(r'\', '/'),
          value.map((e) => e.toJson()).toList(),
        ),
      ),
    };

    final String timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-');
    final String autoFileName = 'theme_accent_audit_report_$timestamp.json';

    File jsonFile;
    if (exportPath != null) {
      if (exportPath.endsWith('.json')) {
        jsonFile = File(exportPath);
        final Directory parentDir = jsonFile.parent;
        if (!parentDir.existsSync()) {
          parentDir.createSync(recursive: true);
        }
      } else {
        final Directory exportDir = Directory(exportPath);
        if (!exportDir.existsSync()) {
          exportDir.createSync(recursive: true);
        }
        String cleanDir = exportPath.replaceAll(r'\', '/');
        if (!cleanDir.endsWith('/')) {
          cleanDir += '/';
        }
        jsonFile = File('$cleanDir$autoFileName');
      }
    } else {
      jsonFile = File(autoFileName);
    }

    jsonFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(reportData),
    );
    stdout.writeln('DUMP_PATH=${jsonFile.absolute.path}');
  }

  final Map<String, int> countByRule = <String, int>{};
  final Map<String, int> countByFile = <String, int>{};

  findingsByFile.forEach((String filePath, List<_ThemeFinding> findings) {
    final String cleanPath = filePath.replaceAll(r'\', '/');
    countByFile[cleanPath] = findings.length;
    for (final _ThemeFinding f in findings) {
      countByRule[f.rule] = (countByRule[f.rule] ?? 0) + 1;
    }
  });

  if (!summaryOnly && findingsByFile.isNotEmpty) {
    findingsByFile.forEach((String filePath, List<_ThemeFinding> findings) {
      final String relativePath = filePath.replaceAll(r'\', '/');
      stdout.writeln('\n--- $relativePath (${findings.length} violations) ---');
      for (final _ThemeFinding f in findings) {
        stdout.writeln(
          '  line ${f.lineNumber}: [${f.rule}] ${f.description}',
        );
        stdout.writeln('    snippet: ${f.snippet}');
      }
    });
  }

  stdout.writeln('\n======================================================');
  stdout.writeln('VIOLATIONS BY RULE:');
  final List<MapEntry<String, int>> sortedRules = countByRule.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final MapEntry<String, int> entry in sortedRules) {
    stdout.writeln('  ${entry.key.padRight(40)} : ${entry.value}');
  }

  stdout.writeln('\nTOP FILES WITH VIOLATIONS:');
  final List<MapEntry<String, int>> sortedFiles = countByFile.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final MapEntry<String, int> entry in sortedFiles.take(15)) {
    stdout.writeln('  ${entry.key.padRight(75)} : ${entry.value}');
  }

  stdout.writeln('======================================================');
  stdout.writeln(
    'TOTAL SCANNED: $totalFilesScanned files | TOTAL VIOLATIONS: $totalViolations | SCAN TIME: ${stopwatch.elapsedMilliseconds}ms',
  );

  if (totalViolations > 0 && failOnViolation) {
    exit(1);
  }
  exit(0);
}

int _lineFromOffset(String content, int offset) {
  return content.substring(0, offset).split('\n').length;
}

class _ThemeFinding {
  const _ThemeFinding({
    required this.lineNumber,
    required this.rule,
    required this.description,
    required this.snippet,
  });

  final int lineNumber;
  final String rule;
  final String description;
  final String snippet;

  Map<String, dynamic> toJson() => {
    'lineNumber': lineNumber,
    'rule': rule,
    'description': description,
    'snippet': snippet,
  };
}
