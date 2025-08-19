/// Represents a property of an OData entity or complex type.
///
/// Includes type, nullability, navigation info, and other OData attributes.
class EdmProperty {
  final String name;
  final String type; // Edm.String, Edm.Int32, Namespace.ComplexType etc.
  final bool nullable;
  final int? maxLength;
  final bool isNavigation;
  final String? navigationType; // Target entity type for navigation properties
  final bool isKey;
  // Add other OData property attributes as needed

  EdmProperty({
    required this.name,
    required this.type,
    this.nullable = true,
    this.maxLength,
    this.isNavigation = false,
    this.navigationType,
    this.isKey = false,
  });
}
