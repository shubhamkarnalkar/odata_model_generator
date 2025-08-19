import 'package:odata_model_generator/src/models/edm_enum.dart';
import 'package:xml/xml.dart';
import '../models/edm_schema.dart';
import '../models/edm_entity_type.dart';
import '../models/edm_complex_type.dart';
import '../models/edm_property.dart';

/// Parses OData CSDL XML metadata into Dart model schema objects.
///
/// Converts XML into [EdmSchema], [EdmEntityType], [EdmComplexType], and [EdmEnum] objects.
class EdmSchemaParser {
  /// Parses the given OData XML metadata string and returns an [EdmSchema].
  EdmSchema parseMetadata(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final schemaElement = document.findAllElements('Schema').first;

    final namespace = schemaElement.getAttribute('Namespace')!;

    final entityTypes = <EdmEntityType>[];
    for (final entityTypeElement
        in schemaElement.findAllElements('EntityType')) {
      final name = entityTypeElement.getAttribute('Name')!;
      final properties = <EdmProperty>[];
      // Find key property names
      final keyNames = <String>{};
      final keyElement = entityTypeElement.findElements('Key').firstOrNull;
      if (keyElement != null) {
        for (final propRef in keyElement.findElements('PropertyRef')) {
          final keyName = propRef.getAttribute('Name');
          if (keyName != null) keyNames.add(keyName);
        }
      }
      for (final propertyElement
          in entityTypeElement.findAllElements('Property')) {
        final prop = _parseProperty(propertyElement);
        final isKey = keyNames.contains(prop.name);
        properties.add(EdmProperty(
          name: prop.name,
          type: prop.type,
          nullable: prop.nullable,
          maxLength: prop.maxLength,
          isNavigation: prop.isNavigation,
          navigationType: prop.navigationType,
          isKey: isKey,
        ));
      }
      final navigationProperties = <EdmProperty>[];
      for (final navPropElement
          in entityTypeElement.findAllElements('NavigationProperty')) {
        navigationProperties.add(_parseNavigationProperty(navPropElement));
      }
      entityTypes.add(EdmEntityType(
          name: name,
          properties: properties,
          navigationProperties: navigationProperties));
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
      final navigationProperties = <EdmProperty>[];
      for (final navPropElement
          in complexTypeElement.findAllElements('NavigationProperty')) {
        navigationProperties.add(_parseNavigationProperty(navPropElement));
      }
      complexTypes.add(EdmComplexType(
          name: name,
          properties: properties,
          navigationProperties: navigationProperties));
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
      isNavigation: false,
    );
  }

  EdmProperty _parseNavigationProperty(XmlElement navPropElement) {
    final name = navPropElement.getAttribute('Name')!;
    final type = navPropElement.getAttribute('Type')!;
    // Navigation properties are always references to other entities
    return EdmProperty(
      name: name,
      type: type,
      isNavigation: true,
      navigationType: type,
    );
  }
}
