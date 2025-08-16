import 'dart:io';
import 'package:path/path.dart' as p;

/// Utility to scan a directory for Dart model files, extract class names and typeId values, and write to a CSV file.
Future<void> generateHiveCsv(String inputDirectory, String outputDirectory,
    {String? csvPath}) async {
  final outDir = Directory(outputDirectory);
  final inDir = Directory(inputDirectory);
  if (!await inDir.exists()) return;

  final csvBuffer = StringBuffer();
  csvBuffer.writeln('className,typeId');

  List<File> dartFiles = [];
  if (await outDir.exists()) {
    dartFiles = outDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => p.extension(f.path) == '.dart')
        .toList();
  }

  if (dartFiles.isNotEmpty) {
    final classRegExp = RegExp(r'class (\w+)');
    final typeIdRegExp = RegExp(r'typeId\s*:\s*(\d+)');
    for (final file in dartFiles) {
      final content = await file.readAsString();
      final classMatch = classRegExp.firstMatch(content);
      final typeIdMatch = typeIdRegExp.firstMatch(content);
      if (classMatch != null && typeIdMatch != null) {
        final className = classMatch.group(1);
        final typeId = typeIdMatch.group(1);
        csvBuffer.writeln('$className,$typeId');
      }
    }
  } else {
    // If no Dart files, use XML metadata files from input directory
    final xmlFiles = inDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => p.extension(f.path) == '.xml');
    final entityTypeRegExp = RegExp(r'<EntityType\s+Name="([^"]+)"');
    for (final file in xmlFiles) {
      final content = await file.readAsString();
      for (final match in entityTypeRegExp.allMatches(content)) {
        final className = match.group(1);
        csvBuffer.writeln('$className,');
      }
    }
  }

  final csvFile = File(csvPath ?? p.join(inputDirectory, 'hive.csv'));
  await csvFile.writeAsString(csvBuffer.toString());
  print('Generated hive.csv at: ${csvFile.path}');
}
