import 'dart:io';
import 'package:path/path.dart' as p;
import 'src/parser/edm_schema_parser.dart';
import 'src/generator/model_generator.dart';

class ODataModelGenerator {
  final String metadataFolderPath;
  final String outputFolderPath;
  final bool hive;
  final bool isar;

  ODataModelGenerator({
    required this.metadataFolderPath,
    required this.outputFolderPath,
    this.hive = false,
    this.isar = false,
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
    final generator = ModelGenerator(outputFolderPath, metadataFolderPath,
        useHive: hive, isar: isar);

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

    if (generator.hiveAdapterClasses.isNotEmpty) {
      print('\nIMPORTANT!! Don\'t forget to register Hive adapters:');
      for (final className in generator.hiveAdapterClasses) {
        print('$className');
      }
    }

    if (generator.isarClasses.isNotEmpty) {
      print('\nIMPORTANT!! Don\'t forget to add schemas for Isar:');
      for (final className in generator.isarClasses) {
        print('$className');
      }
    }
  }
}
