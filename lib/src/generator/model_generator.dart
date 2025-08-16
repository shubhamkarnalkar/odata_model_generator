import 'package:odata_model_generator/src/models/edm_enum.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import '../models/edm_schema.dart';
import '../models/edm_property.dart';
import 'type_mapper.dart';
import 'dart:io';

/// Generates Dart model classes from OData metadata.
///
/// - Supports `json_serializable` for JSON (de)serialization.
/// - Optionally adds Hive annotations if the class is present in `hive.csv`.
/// - If a class is present in `hive.csv` but missing a typeId, assigns the next available typeId and prints a warning.
class ModelGenerator {
  /// Output directory for generated Dart files.
  final String outputDirectory;

  /// Output directory for generated Dart files.
  final String inputDirectory;

  /// If true, enables Hive annotation logic (requires `hive.csv`).
  final bool useHive;

  final List<String> hiveAdapterClasses = [];

  /// Creates a [ModelGenerator].
  ///
  /// [outputDirectory]: Where generated Dart files will be written.
  /// [useHive]: If true, enables Hive annotation logic (requires `hive.csv`).
  ModelGenerator(this.outputDirectory, this.inputDirectory,
      {this.useHive = false});

  /// Generates Dart model classes and enums for the given [schema].
  ///
  /// - Reads `hive.csv` (if [useHive] is true) to determine which classes get Hive annotations.
  /// - If a class is present in `hive.csv` but missing a typeId, assigns the next available typeId and prints a warning.
  /// - If a class is not present in `hive.csv`, no Hive annotation is added.
  Future<void> generate(EdmSchema schema) async {
    final schemaName = schema.namespace.split('.').last.snakeCase;
    final schemaOutputDirectory = p.join(outputDirectory, schemaName);
    await Directory(schemaOutputDirectory).create(recursive: true);

    final generatedFiles = <String>[];

    // --- Read hive.csv once and build a map ---
    Map<String, String> hiveTypeIdMap = {};
    if (useHive) {
      final csvFile = File(p.join(inputDirectory, 'hive.csv'));
      if (await csvFile.exists()) {
        final lines = await csvFile.readAsLines();
        for (final line in lines.skip(1)) {
          final parts = line.split(',');
          if (parts.length >= 2 && parts[0].trim().isNotEmpty) {
            hiveTypeIdMap[parts[0].trim()] = parts[1].trim();
          }
        }
      }

      // Scan all Dart files in lib/models for existing typeIds
      final typeIdRegExp = RegExp(r'@HiveType\(typeId: (\d+)\)');
      final modelsDir = Directory('lib/models');
      int maxTypeId = -1;
      if (modelsDir.existsSync()) {
        for (final file in modelsDir.listSync(recursive: true)) {
          if (file is File && file.path.endsWith('.dart')) {
            final content = await file.readAsString();
            for (final match in typeIdRegExp.allMatches(content)) {
              final id = int.tryParse(match.group(1) ?? '');
              if (id != null && id > maxTypeId) maxTypeId = id;
            }
          }
        }
      }
      // For any class missing a typeId, assign next available and warn
      // Only assign typeId if the className is present in the CSV (even if typeId is missing)
      for (final entityType in schema.entityTypes) {
        if (hiveTypeIdMap.containsKey(entityType.name) &&
            hiveTypeIdMap[entityType.name]!.isEmpty) {
          final nextId = maxTypeId + 1;
          print(
              'WARNING: No Hive typeId for ${entityType.name}. Assigning typeId: $nextId');
          hiveTypeIdMap[entityType.name] = nextId.toString();
          maxTypeId = nextId;
        }
      }
      for (final complexType in schema.complexTypes) {
        if (hiveTypeIdMap.containsKey(complexType.name) &&
            hiveTypeIdMap[complexType.name]!.isEmpty) {
          final nextId = maxTypeId + 1;
          print(
              'WARNING: No Hive typeId for ${complexType.name}. Assigning typeId: $nextId');
          hiveTypeIdMap[complexType.name] = nextId.toString();
          maxTypeId = nextId;
        }
      }
    }

    // create an enum class
    if (schema.enums.length > 0) {
      await _generateEnum(
          directory: schemaOutputDirectory, enums: schema.enums);
      generatedFiles.add('enum.dart');
    }

    for (final entityType in schema.entityTypes) {
      await _generateClass(
        schemaOutputDirectory,
        entityType.name,
        entityType.properties,
        schema.enums,
        entityType.navigationProperties,
        hiveTypeId: hiveTypeIdMap[entityType.name],
      );
      generatedFiles.add('${ReCase(entityType.name).snakeCase}.dart');
    }

    for (final complexType in schema.complexTypes) {
      await _generateClass(
        schemaOutputDirectory,
        complexType.name,
        complexType.properties,
        schema.enums,
        complexType.navigationProperties,
        hiveTypeId: hiveTypeIdMap[complexType.name],
      );
      generatedFiles.add('${ReCase(complexType.name).snakeCase}.dart');
    }

    // Generate <namespace>.dart exporting all generated files, with a library directive
    final libraryBuffer = StringBuffer();
    libraryBuffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    libraryBuffer.writeln('// Exports all models for namespace: $schemaName');
    libraryBuffer.writeln('library $schemaName;');
    libraryBuffer.writeln();
    for (final file in generatedFiles) {
      libraryBuffer.writeln("export '$file';");
    }
    final libraryFilePath = p.join(schemaOutputDirectory, '$schemaName.dart');
    await File(libraryFilePath).writeAsString(libraryBuffer.toString());
    print('Generated library: $libraryFilePath');
  }

  /// Generates Dart enum classes for the given [enums] in [directory].
  Future<void> _generateEnum(
      {required String directory, required List<EdmEnum> enums}) async {
    final filePath = p.join(directory, 'enum.dart');
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// ignore_for_file: constant_identifier_names');

    for (final en in enums) {
      buffer.writeln('enum ${en.type}{');

      for (final enm in en.values) {
        String seperator = '';
        if (en.values.last != enm) {
          seperator = ',';
        } else {
          seperator = ';';
        }
        buffer
            .writeln(' ${enm.name}("${enm.name}", "${enm.value}")${seperator}');
      }
      buffer.writeln('');
      buffer.writeln(' const ${en.type}(this.name, this.value);');
      buffer.writeln(' final String name;');
      buffer.writeln(' final String value;');
      buffer.writeln('}');
    }

    await File(filePath).writeAsString(buffer.toString());
    print('Generated enum classes in : $filePath');
  }

  /// Generates a Dart class for [className] with [properties] and [navigationProperties].
  ///
  /// - Adds Hive annotation if [hiveTypeId] is non-null and non-empty.
  /// - Adds `json_serializable` annotation for all classes.
  Future<void> _generateClass(
      String directory,
      String className,
      List<EdmProperty> properties,
      List<EdmEnum> enums,
      List<EdmProperty> navigationProperties,
      {String? hiveTypeId}) async {
    final ReCase rcClassName = ReCase(className);
    final fileName = '${rcClassName.snakeCase}.dart';
    final filePath = p.join(directory, fileName);
    const enumDart = "import 'enum.dart';";

    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    if (hiveTypeId != null) {
      buffer.writeln("import 'package:hive/hive.dart';");
    }
    // imports for different entity models which are related

    // Regular properties imports
    for (final prop
        in properties.where((element) => !element.type.contains('Edm'))) {
      final dartType2 = TypeMapper.mapODataTypeToDart(prop.type);
      final imp = "import '${dartType2.snakeCase}.dart';";
      if (!buffer.toString().contains(imp) &&
          !prop.type.contains('Edm') &&
          dartType2 != 'String' &&
          !enums.any((element) => element.type.contains(dartType2))) {
        buffer.writeln(imp);
      } else {
        !buffer.toString().contains(enumDart) &&
                enums.any((element) => element.type.contains(dartType2))
            ? buffer.writeln(enumDart)
            : null;
      }
    }

    // Navigation properties imports
    for (final navProp in navigationProperties) {
      final navType = navProp.navigationType ?? navProp.type;
      if (!navType.contains('Edm')) {
        String typeName = navType;
        if (navType.startsWith('Collection(') && navType.endsWith(')')) {
          typeName = navType.substring(11, navType.length - 1);
        }
        final navTypeClass = typeName.split('.').last;
        final navFile = '${ReCase(navTypeClass).snakeCase}.dart';
        final imp = "import '$navFile';";
        if (!buffer.toString().contains(imp)) {
          buffer.writeln(imp);
        }
      }
    }

    buffer.writeln(
        "part '${rcClassName.snakeCase}.g.dart';"); // For json_serializable
    buffer.writeln();

    if (hiveTypeId != null) {
      buffer.writeln('@HiveType(typeId: $hiveTypeId)');
    }
    buffer.writeln('@JsonSerializable()');
    if (hiveTypeId != null) {
      buffer.writeln('class ${rcClassName.pascalCase} extends HiveObject {');

      hiveAdapterClasses.add(
          'Hive.registerAdapter(${rcClassName.pascalCase.toString()}Adapter());');
    } else {
      buffer.writeln('class ${rcClassName.pascalCase} {');
    }

    // Constructor
    buffer.writeln('  ${rcClassName.pascalCase}({');
    for (final prop in properties) {
      prop.nullable
          ? buffer.writeln('    this.${prop.name.camelCase}?,')
          : buffer.writeln('    this.${prop.name.camelCase},');
    }
    for (final navProp in navigationProperties) {
      buffer.writeln('    this.${navProp.name.camelCase},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    // copyWith method
    buffer.writeln('  ${rcClassName.pascalCase} copyWith({');
    for (final prop in properties) {
      final dartType = TypeMapper.mapODataTypeToDart(prop.type);
      buffer.writeln('    $dartType? ${prop.name.camelCase},');
    }
    for (final navProp in navigationProperties) {
      final navType = navProp.navigationType ?? navProp.type;
      String typeName = navType;
      bool isCollection = false;
      if (navType.startsWith('Collection(') && navType.endsWith(')')) {
        typeName = navType.substring(11, navType.length - 1);
        isCollection = true;
      }
      final navTypeClass = ReCase(typeName.split('.').last).pascalCase;
      final dartType = isCollection ? 'List<$navTypeClass>' : navTypeClass;
      buffer.writeln('    $dartType? ${navProp.name.camelCase},');
    }
    buffer.writeln('  }) {');
    buffer.writeln('    return ${rcClassName.pascalCase}(');
    for (final prop in properties) {
      buffer.writeln(
          '      ${prop.name.camelCase}: ${prop.name.camelCase} ?? this.${prop.name.camelCase},');
    }
    for (final navProp in navigationProperties) {
      buffer.writeln(
          '      ${navProp.name.camelCase}: ${navProp.name.camelCase} ?? this.${navProp.name.camelCase},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln();

    // Properties
    for (final prop in properties) {
      final dartType = TypeMapper.mapODataTypeToDart(prop.type);
      buffer.writeln('  @JsonKey(name: "${prop.name}")');
      if (prop.type.contains('Collection') && !dartType.contains('List')) {
        buffer.writeln('  final $dartType? ${prop.name.camelCase};');
      } else {
        buffer.writeln('  final $dartType? ${prop.name.camelCase};');
      }
      buffer.writeln();
    }
    // Navigation Properties
    for (final navProp in navigationProperties) {
      final navType = navProp.navigationType ?? navProp.type;
      String typeName = navType;
      bool isCollection = false;
      if (navType.startsWith('Collection(') && navType.endsWith(')')) {
        typeName = navType.substring(11, navType.length - 1);
        isCollection = true;
      }
      final navTypeClass = ReCase(typeName.split('.').last).pascalCase;
      final dartType = isCollection ? 'List<$navTypeClass>' : navTypeClass;
      buffer.writeln('  // Navigation property');
      buffer.writeln('  final $dartType? ${navProp.name.camelCase};');
      buffer.writeln();
    }

    // From JSON factory
    buffer.writeln(
        '  factory ${rcClassName.pascalCase}.fromJson(Map<String, dynamic> json) => _\$${rcClassName.pascalCase}FromJson(json);');
    buffer.writeln();

    // To JSON method
    buffer.writeln(
        '  Map<String, dynamic> toJson() => _\$${rcClassName.pascalCase}ToJson(this);');

    buffer.writeln('}');

    await File(filePath).writeAsString(buffer.toString());
    print('Generated model: $filePath');
  }
}
