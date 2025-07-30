class EdmProperty {
  final String name;
  final String type; // Edm.String, Edm.Int32, Namespace.ComplexType etc.
  final bool nullable;
  final int? maxLength;
  // Add other OData property attributes as needed

  EdmProperty({
    required this.name,
    required this.type,
    this.nullable = true,
    this.maxLength,
  });
}