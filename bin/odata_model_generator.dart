import 'package:args/args.dart';
import 'package:odata_model_generator/odata_model_generator.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('input',
        abbr: 'i',
        help: 'Path to the folder containing OData metadata XML files.',
        defaultsTo: 'odata_metadata')
    ..addOption('output',
        abbr: 'o',
        help: 'Path to the directory where generated Dart models will be saved.',
        defaultsTo: 'lib/src/models/generated');

  ArgResults argResults = parser.parse(arguments);

  final inputPath = argResults['input'] as String;
  final outputPath = argResults['output'] as String;

  print('Input metadata folder: $inputPath');
  print('Output models folder: $outputPath');

  final generator = ODataModelGenerator(
    metadataFolderPath: inputPath,
    outputFolderPath: outputPath,
  );

  try {
    await generator.generateModels();
  } catch (e) {
    stderr.writeln('Error during model generation: $e');
    exit(1);
  }
}