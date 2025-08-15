import 'package:odata_model_generator/src/models/edm_enum.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart'; // Consider adding this for name formatting
import '../models/edm_schema.dart';
import '../models/edm_property.dart';
import 'type_mapper.dart';
import 'dart:io';

class ModelGenerator {
  final String outputDirectory;

  ModelGenerator(this.outputDirectory);

  Future<void> generate(EdmSchema schema) async {
    final schemaName = schema.namespace.split('.').last.snakeCase;
    final schemaOutputDirectory = p.join(outputDirectory, schemaName);
    await Directory(schemaOutputDirectory).create(recursive: true);

    final generatedFiles = <String>[];

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
      );
      generatedFiles.add('${ReCase(entityType.name).snakeCase}.dart');
    }

    for (final complexType in schema.complexTypes) {
      await _generateClass(
        schemaOutputDirectory,
        complexType.name,
        complexType.properties,
        schema.enums,
        complexType.navigationProperties ?? const [],
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

  Future<void> _generateClass(
    String directory,
    String className,
    List<EdmProperty> properties,
    List<EdmEnum> enums,
    List<EdmProperty> navigationProperties,
  ) async {
    final ReCase rcClassName = ReCase(className);
    final fileName = '${rcClassName.snakeCase}.dart';
    final filePath = p.join(directory, fileName);
    const enumDart = "import 'enum.dart';";

    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
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

    buffer.writeln('@JsonSerializable()');
    buffer.writeln('class ${rcClassName.pascalCase} {');

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
