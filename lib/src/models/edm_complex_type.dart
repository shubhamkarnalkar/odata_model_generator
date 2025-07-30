import 'edm_property.dart';

class EdmComplexType {
  final String name;
  final List<EdmProperty> properties;

  EdmComplexType({
    required this.name,
    required this.properties,
  });
}