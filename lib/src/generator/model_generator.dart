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

    // create an enum class
    if (schema.enums.length > 0) {
      _generateEnum(directory: schemaOutputDirectory, enums: schema.enums);
    }

    for (final entityType in schema.entityTypes) {
      await _generateClass(schemaOutputDirectory, entityType.name,
          entityType.properties, schema.enums);
    }

    for (final complexType in schema.complexTypes) {
      await _generateClass(schemaOutputDirectory, complexType.name,
          complexType.properties, schema.enums);
    }
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

  Future<void> _generateClass(String directory, String className,
      List<EdmProperty> properties, List<EdmEnum> enums) async {
    final ReCase rcClassName = ReCase(className);
    final fileName = '${rcClassName.snakeCase}.dart';
    final filePath = p.join(directory, fileName);
    const enumDart = "import 'enum.dart';";

    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    // imports for different entity models which are related

    for (final prop in properties.where(
      (element) => !element.type.contains('Edm'),
    )) {
      final dartType2 = TypeMapper.mapODataTypeToDart(prop.type);
      final imp = "import '${dartType2.snakeCase}.dart';";
      if (!buffer.toString().contains(imp) &&
          !prop.type.contains('Edm') &&
          dartType2 != 'String' &&
          !enums.any(
            (element) => element.type.contains(dartType2),
          )) {
        buffer.writeln(imp);
      } else {
        !buffer.toString().contains(enumDart) &&
                enums.any(
                  (element) => element.type.contains(dartType2),
                )
            ? buffer.writeln(enumDart)
            : null;
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
      // final dartType = TypeMapper.mapODataTypeToDart(prop.type);
      prop.nullable
          ? buffer.writeln('    this.${prop.name.camelCase}?,')
          : buffer.writeln('    this.${prop.name.camelCase},');
    }
    buffer.writeln('  });');
    buffer.writeln();

    // Properties
    for (final prop in properties) {
      final dartType = TypeMapper.mapODataTypeToDart(prop.type);
      // final nullable = prop.nullable ? '?' : '';
      buffer.writeln(
          '  @JsonKey(name: \'${prop.name}\')'); // Map OData property name to Dart
      // buffer.writeln('  final $dartType$nullable ${prop.name.camelCase};');
      if (prop.type.contains('Collection') && !dartType.contains('List')) {
        buffer.writeln('  final $dartType? ${prop.name.camelCase};');
      } else {
        buffer.writeln('  final $dartType? ${prop.name.camelCase};');
      }

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
