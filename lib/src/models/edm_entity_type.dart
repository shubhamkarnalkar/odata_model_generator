import 'edm_property.dart';

class EdmEntityType {
  final String name;
  final List<EdmProperty> properties;
  final List<EdmProperty> navigationProperties;

  EdmEntityType({
    required this.name,
    required this.properties,
    this.navigationProperties = const [],
  });
}
