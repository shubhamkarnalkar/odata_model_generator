import 'edm_property.dart';

class EdmEntityType {
  final String name;
  final List<EdmProperty> properties;

  EdmEntityType({
    required this.name,
    required this.properties,
  });
}