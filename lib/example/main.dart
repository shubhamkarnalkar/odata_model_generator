import 'dart:convert';
// You'll import your generated models here after running the generator
// For example:
// import 'package:example_app/src/models/generated/myservice/product.dart';
// import 'package:example_app/src/models/generated/myservice/customer.dart';

void main() {
  print('To use generated models, first run:');
  print('  dart run odata_model_generator --input odata_metadata --output lib/src/models/generated');
  print('Then, run:');
  print('  dart run build_runner build');
  print('\nAfter that, you can uncomment and use your generated models here.');

  // Example of how you would use it (uncomment and replace with actual generated models)
  /*
  final productJson = '''
  {
    "Id": 123,
    "Name": "Laptop",
    "Price": 1200.50,
    "IsAvailable": true
  }
  ''';

  try {
    // Assuming Product is generated under lib/src/models/generated/yourschema/product.dart
    // import 'package:example_app/src/models/generated/yourschema/product.dart';
    // final product = Product.fromJson(jsonDecode(productJson));
    // print('Product Name: ${product.name}');
    // print('Product Price: ${product.price}');
    //
    // final productToJson = product.toJson();
    // print('Product to JSON: ${jsonEncode(productToJson)}');
  } catch (e) {
    print('Error parsing product: $e');
  }
  */
}