import 'package:odata_model_generator/src/models/edm_enum.dart';

import 'edm_entity_type.dart';
import 'edm_complex_type.dart';

/// Represents an OData schema, including entity types, complex types, and enums.
class EdmSchema {
  final String namespace;
  final List<EdmEntityType> entityTypes;
  final List<EdmComplexType> complexTypes;
  final List<EdmEnum> enums;

  EdmSchema(
      {required this.namespace,
      required this.entityTypes,
      required this.complexTypes,
      required this.enums});
}
