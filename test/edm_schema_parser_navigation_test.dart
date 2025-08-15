import 'package:test/test.dart';
import 'package:odata_model_generator/src/parser/edm_schema_parser.dart';

void main() {
  group('EdmSchemaParser Navigation Properties', () {
    test('should detect navigation properties in schema', () {
      const xml = '''
<Schema Namespace="TestModel" xmlns="http://docs.oasis-open.org/odata/ns/edm">
  <EntityType Name="Order">
    <Key><PropertyRef Name="OrderId"/></Key>
    <Property Name="OrderId" Type="Edm.Int32" Nullable="false" />
    <NavigationProperty Name="Customer" Type="TestModel.Customer" />
  </EntityType>
  <EntityType Name="Customer">
    <Key><PropertyRef Name="CustomerId"/></Key>
    <Property Name="CustomerId" Type="Edm.Int32" Nullable="false" />
  </EntityType>
</Schema>
''';
      final parser = EdmSchemaParser();
      final schema = parser.parseMetadata(xml);
      final orderEntity =
          schema.entityTypes.firstWhere((e) => e.name == 'Order');
      expect(orderEntity.navigationProperties, isNotEmpty);
      expect(orderEntity.navigationProperties.first.name, 'Customer');
      expect(orderEntity.navigationProperties.first.isNavigation, isTrue);
      expect(orderEntity.navigationProperties.first.navigationType,
          'TestModel.Customer');
    });
  });
}
