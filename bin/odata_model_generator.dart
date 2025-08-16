import 'package:args/args.dart';
import 'package:odata_model_generator/odata_model_generator.dart';
import 'package:odata_model_generator/src/generator/hive_csv_util.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('input',
        abbr: 'i',
        help: 'Path to the folder containing OData metadata XML files.',
        defaultsTo: 'odata_metadata')
    ..addOption('output',
        abbr: 'o',
        help:
            'Path to the directory where generated Dart models will be saved.',
        defaultsTo: 'lib/src/models/generated')
    ..addFlag('csv',
        abbr: 'c',
        help:
            'Generate a summary CSV of important data based on input and output folders.',
        defaultsTo: false)
    ..addFlag('generate',
        abbr: 'g',
        help: 'Generate Dart model classes from metadata.',
        defaultsTo: false);

  ArgResults argResults = parser.parse(arguments);

  final inputPath = argResults['input'] as String;
  final outputPath = argResults['output'] as String;
  final summaryCsv = argResults['csv'] as bool;
  final generateClasses = argResults['generate'] as bool;

  // Require exactly one of -c or -g
  if ((summaryCsv && generateClasses) || (!summaryCsv && !generateClasses)) {
    stderr.writeln(
        'You must specify exactly one of -c (CSV) or -g (generate classes).');
    exit(2);
  }

  print('Input metadata folder: $inputPath');
  print('Output models folder: $outputPath');
  if (summaryCsv) {
    try {
      await generateHiveCsv(inputPath, outputPath);
      print('Summary CSV (hive.csv) generated in $inputPath');
    } catch (e) {
      stderr.writeln('Error during summary CSV generation: $e');
      exit(1);
    }
    return;
  }

  if (generateClasses) {
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
}
