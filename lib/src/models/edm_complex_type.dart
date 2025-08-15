import 'edm_property.dart';

class EdmComplexType {
  final String name;
  final List<EdmProperty> properties;
  final List<EdmProperty> navigationProperties;

  EdmComplexType({
    required this.name,
    required this.properties,
    this.navigationProperties = const [],
  });
}
