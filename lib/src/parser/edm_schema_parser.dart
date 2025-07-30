import 'package:odata_model_generator/src/models/edm_enum.dart';
import 'package:xml/xml.dart';
import '../models/edm_schema.dart';
import '../models/edm_entity_type.dart';
import '../models/edm_complex_type.dart';
import '../models/edm_property.dart';

class EdmSchemaParser {
  EdmSchema parseMetadata(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final schemaElement = document.findAllElements('Schema').first;

    final namespace = schemaElement.getAttribute('Namespace')!;

    final entityTypes = <EdmEntityType>[];
    for (final entityTypeElement
        in schemaElement.findAllElements('EntityType')) {
      final name = entityTypeElement.getAttribute('Name')!;
      final properties = <EdmProperty>[];
      for (final propertyElement
          in entityTypeElement.findAllElements('Property')) {
        properties.add(_parseProperty(propertyElement));
      }
      entityTypes.add(EdmEntityType(name: name, properties: properties));
    }

    final complexTypes = <EdmComplexType>[];
    for (final complexTypeElement
        in schemaElement.findAllElements('ComplexType')) {
      final name = complexTypeElement.getAttribute('Name')!;
      final properties = <EdmProperty>[];
      for (final propertyElement
          in complexTypeElement.findAllElements('Property')) {
        properties.add(_parseProperty(propertyElement));
      }
      complexTypes.add(EdmComplexType(name: name, properties: properties));
    }

    final enums = <EdmEnum>[];
    for (final EnumElement in schemaElement.findAllElements('EnumType')) {
      final name = EnumElement.getAttribute('Name')!;
      final enumVals = <EnumValue>[];
      for (final ens in EnumElement.findAllElements('Member')) {
        final EnumValue env = EnumValue(
            name: ens.getAttribute('Name')!, value: ens.getAttribute('Value'));
        enumVals.add(env);
      }
      // TODO: value add
      enums.add(EdmEnum(type: name, values: enumVals));
    }

    return EdmSchema(
        namespace: namespace,
        entityTypes: entityTypes,
        complexTypes: complexTypes,
        enums: enums);
  }

  EdmProperty _parseProperty(XmlElement propertyElement) {
    final name = propertyElement.getAttribute('Name')!;
    final type = propertyElement.getAttribute('Type')!;
    final nullable = propertyElement.getAttribute('Nullable') == 'true';
    final maxLength = propertyElement.getAttribute('MaxLength');
    // Add more attributes as needed (e.g., Precision, Scale, Srid for geography)
    return EdmProperty(
      name: name,
      type: type,
      nullable: nullable,
      maxLength: maxLength != null ? int.tryParse(maxLength) : null,
    );
  }
}
