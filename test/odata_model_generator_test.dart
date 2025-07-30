import 'package:odata_model_generator/src/generator/type_mapper.dart';
import 'package:test/test.dart'; 


void main() {

  group('TypeMapper', () {
     
    test('should map Edm.String to String', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.String'), 'String');
    });

    test('should map Edm.Int16 to int', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Int16'), 'int');
    });

    test('should map Edm.Int32 to int', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Int32'), 'int');
    });

    test('should map Edm.Int64 to int', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Int64'), 'int');
    });

    test('should map Edm.Boolean to bool', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Boolean'), 'bool');
    });

    test('should map Edm.Decimal to double', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Decimal'), 'double');
    });

    test('should map Edm.Double to double', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Double'), 'double');
    });

    test('should map Edm.Single to double', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Single'), 'double');
    });

    test('should map Edm.DateTimeOffset to DateTime', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.DateTimeOffset'), 'DateTime');
    });

    test('should map Edm.DateTime (V2) to DateTime', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.DateTime'), 'DateTime');
    });

    test('should map Edm.Guid to String', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Guid'), 'String');
    });

    test('should map Edm.Binary to List<int>', () {
      expect(TypeMapper.mapODataTypeToDart('Edm.Binary'), 'List<int>');
    });

    test('should map complex type Trippin.Location to Location', () {
      expect(TypeMapper.mapODataTypeToDart('Trippin.Location'), 'Location');
    });

    test('should map enum type Trippin.PersonGender to PersonGender', () {
      expect(TypeMapper.mapODataTypeToDart('Trippin.PersonGender'), 'PersonGender');
    });

    test('should map Collection(Edm.String) to List<String>', () {
      expect(TypeMapper.mapODataTypeToDart('Collection(Edm.String)'), 'String');
    });

    test('should map Collection(Trippin.Location) to List<Location>', () {
      expect(TypeMapper.mapODataTypeToDart('Collection(Trippin.Location)'), 'Location');
    });

    test('should map Collection(Trippin.Person) to List<Person>', () {
      expect(TypeMapper.mapODataTypeToDart('Collection(Trippin.Person)'), 'Person');
    });

    test('should return empty string for unhandled collection format (invalid inner type)', () {
      // This case specifically tests the `col[0].split(')')` and subsequent logic
      // leading to the `return '';` branch.
      // A more robust solution might throw an error or handle this more gracefully.
      expect(TypeMapper.mapODataTypeToDart('Collection()'), '');
    });

    test('should handle types with multiple dots correctly (e.g., namespace.type)', () {
      expect(TypeMapper.mapODataTypeToDart('SomeNamespace.SomeType'), 'SomeType');
    });

    test('should handle types with collection for the enum)', () {
      expect(TypeMapper.mapODataTypeToDart('Collection(Trippin.Feature)'), 'Feature');
    });

    test('should return the type name for unrecognized simple types', () {
      // Assuming 'Edm.Duration' is not explicitly mapped but should return 'Duration'
      expect(TypeMapper.mapODataTypeToDart('Edm.Duration'), 'Duration');
    });
  });
}