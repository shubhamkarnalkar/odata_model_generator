import 'dart:io';
import 'package:path/path.dart' as p;
import 'src/parser/edm_schema_parser.dart';
import 'src/generator/model_generator.dart';
import 'src/generator/hive_csv_util.dart';

class ODataModelGenerator {
  final String metadataFolderPath;
  final String outputFolderPath;
  final bool hive;

  ODataModelGenerator({
    required this.metadataFolderPath,
    required this.outputFolderPath,
    this.hive = false,
  });

  Future<void> generateModels() async {
    final metadataDir = Directory(metadataFolderPath);
    if (!await metadataDir.exists()) {
      throw Exception('Metadata folder not found: $metadataFolderPath');
    }

    final metadataFiles = metadataDir
        .listSync()
        .whereType<File>()
        .where((file) => p.extension(file.path) == '.xml');

    if (metadataFiles.isEmpty) {
      print('No OData metadata XML files found in $metadataFolderPath');
      return;
    }

    final parser = EdmSchemaParser();
    final generator = ModelGenerator(outputFolderPath, useHive: hive);

    for (final file in metadataFiles) {
      print('Processing metadata file: ${file.path}');
      final xmlContent = await file.readAsString();
      try {
        final schema = parser.parseMetadata(xmlContent);
        await generator.generate(schema);
      } catch (e) {
        print('Error processing ${file.path}: $e');
      }
    }

    print(
        '\nModel generation complete. Run `dart run build_runner build` in your project to generate .g.dart files.');
  }
}
