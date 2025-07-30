class TypeMapper {
  static String mapODataTypeToDart(String odataType) {
    switch (odataType) {
      case 'Edm.String':
        return 'String';
      case 'Edm.Int16':
      case 'Edm.Int32':
      case 'Edm.Int64':
        return 'int';
      case 'Edm.Boolean':
        return 'bool';
      case 'Edm.Decimal':
      case 'Edm.Double':
      case 'Edm.Single':
        return 'double';
      case 'Edm.DateTimeOffset':
      case 'Edm.DateTime': // OData V2
        return 'DateTime';
      case 'Edm.Guid':
        return 'String'; // Represent GUIDs as strings in Dart
      case 'Edm.Binary':
        return 'List<int>'; // Represent binary as list of bytes
      // Add more OData types as needed.
      // For complex types and entity types, you'll need to handle namespaces
      default:
        // Assume it's a complex type or entity type within the same schema
        // You might need more sophisticated logic for cross-schema references

        // Handle a case where the type is Collection(Edm.$Type)
        if (odataType.contains('Collection')) {
          final String typ;
          final col = odataType.split('Collection(');
          final col2 = col[1].split(')');
          if (col2[0].contains('Edm')) {
            typ = mapODataTypeToDart(col2[0]).toString();
            return typ;
          } else {
            final col3 = col2[0].split('.');
            if (col3.length == 2) {
              return col3[1];
            } else {
              return 'String';
            }
          }
        }

        return 'String'; // Get the type name without namespace
    }
  }
}
