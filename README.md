
<div align="center">

# 🚀 odata_model_generator


<a href="https://pub.dev/packages/odata_model_generator"><img src="https://img.shields.io/pub/v/odata_model_generator.svg?style=flat-square" alt="Pub Version"></a>
<a href="https://github.com/shubhamkarnalkar/odata_model_generator"><img src="https://img.shields.io/badge/GitHub-181717?logo=github&logoColor=white&style=flat-square" alt="GitHub"></a>
<a href="https://ko-fi.com/shubhamkarnalkar"><img src="https://img.shields.io/badge/Ko--fi-F16061?logo=kofi&logoColor=white&style=flat-square" alt="Ko-fi"></a>

</div>

[](https://www.google.com/search?q=https://pub.dev/packages/odata_model_generator)
[](https://www.google.com/search?q=LICENSE)
[](https://www.google.com/search?q=https://github.com/shubhamkarnalkar/odata_model_generator/actions)


> **A modern Dart code generator for OData CSDL XML metadata.**
> 
> - 🏗️ Generates Dart classes for OData Entity Types, Enums, and Complex Types
> - 🐝 Optional Hive support for local storage
> - 🔄 JSON serialization with `json_annotation`
> - 🛠️ CLI for easy automation

## ✨ Features

✔️ **Model Generation:** Dart classes for OData Entity Types, Complex Types, and Enums  
✔️ **Hive Support:** Optionally generate Hive-compatible models and a `hive.csv` for local storage  
✔️ **JSON Serialization:** Models use `@JsonSerializable()` for easy `fromJson`/`toJson`  
✔️ **Type Mapping:** Maps OData EDM types to Dart types  
✔️ **CLI:** Simple terminal commands for automation  
✔️ **Multi-file Support:** Handles multiple OData metadata XML files in one go

## 🛠️ Usage

The CLI supports two mutually exclusive modes:

- `-c` or `--csv`: Generate a `hive.csv` file listing all generated classes and their typeId values (no model generation).
- `-g` or `--generate`: Generate Dart model classes from OData metadata (no CSV generation).

**You must specify exactly one of `-c` or `-g`.**

### Directory Options

- `--input` (or `-i`): Path to the folder containing OData metadata XML files.  
  **Default:** `odata_metadata`
- `--output` (or `-o`): Path to the directory where generated Dart models will be saved.  
  **Default:** `lib/src/models/generated`

### Hive Support

- When generating models with Hive support, the generator checks for `hive.csv` in the input directory.
- Hive annotations are only added if the class is present in `hive.csv`.
- If a class is present in `hive.csv` but missing a typeId, the generator assigns the next available typeId and prints a warning.

### Example Commands

Generate only the CSV:
```bash
dart run odata_model_generator -c --input odata_metadata --output lib/src/models/generated
```

Generate only Dart models:
```bash
dart run odata_model_generator -g --input odata_metadata --output lib/src/models/generated
```

### After Model Generation

After generating models, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```
to generate the necessary `.g.dart` files for JSON serialization.

If Hive adapters are generated, the tool will print a reminder to register them in your project.

> ⚡️ **IMPORTANT:**
> 
> If you use Hive, **always generate the `hive.csv` file first** with `-c` before generating Hive-annotated Dart classes with `-g`. This keeps all Hive typeIds and class mappings up to date. If you skip this, Hive annotations and typeIds may be missing or incorrect in your generated models.
  - Ensure every generated class gets a unique `typeId` and you are notified of the assignment.
- If a class is not present in `hive.csv`, no Hive annotation or import will be added for that class.

### 1\.  📦 Installation

Add `odata_model_generator` as a dev dependency using your preferred CLI:

For Flutter projects:
```bash
flutter pub add --dev odata_model_generator
```

For pure Dart projects:
```bash
dart pub add --dev odata_model_generator
```

Or manually add to your `pubspec.yaml` under `dev_dependencies`:
```yaml
dev_dependencies:
  odata_model_generator: ^latest_version # Check pub.dev for the latest version
```

Then run `flutter pub get` or `dart pub get` as appropriate.

### 2\. Prepare Your OData Metadata Files
Download and store in your project with extension .xml

**Example `MyServiceMetadata.xml` content:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">
    <edmx:DataServices>
        <Schema Namespace="MyService" xmlns="http://docs.oasis-open.org/odata/ns/edm">
            <EntityType Name="Product">
                <Key>
                    <PropertyRef Name="Id"/>
                </Key>
                <Property Name="Id" Type="Edm.Int32" Nullable="false"/>
                <Property Name="Name" Type="Edm.String" MaxLength="255"/>
                <Property Name="Price" Type="Edm.Decimal" Scale="2" Precision="10"/>
                <Property Name="IsAvailable" Type="Edm.Boolean"/>
            </EntityType>
            <ComplexType Name="Address">
                <Property Name="Street" Type="Edm.String"/>
                <Property Name="City" Type="Edm.String"/>
                <Property Name="ZipCode" Type="Edm.String"/>
            </ComplexType>
            <EntityType Name="Customer">
                <Key>
                    <PropertyRef Name="CustomerId"/>
                </Key>
                <Property Name="CustomerId" Type="Edm.Guid" Nullable="false"/>
                <Property Name="FirstName" Type="Edm.String" MaxLength="100"/>
                <Property Name="LastName" Type="Edm.String" MaxLength="100"/>
                <Property Name="Email" Type="Edm.String"/>
                <Property Name="ShippingAddress" Type="MyService.Address"/>
            </EntityType>
        </Schema>
    </edmx:DataServices>
</edmx:Edmx>
```

### 3\. Generate Dart Models

Run the `odata_model_generator` command-line tool from your project's root directory:

```bash
dart run odata_model_generator --input odata_metadata --output lib/src/models/odata
```

**Command Options:**
  * `-i`, `--input`: Path to the folder containing your OData metadata XML files.
      * **Default:** `odata_metadata`
  * `-o`, `--output`: Path to the directory where the generated Dart models will be saved.
      * **Default:** `lib/src/models/generated`

This command will parse your XML files and create Dart `.dart` files for each EntityType and ComplexType. The generated files will be organized into subdirectories based on the OData schema namespace (e.g., `lib/src/models/generated/myservice/`).

**Example Output Structure:**

```
my_app/
├── lib/
│   └── src/
│       └── models/
│           └── generated/
│               └── myservice/ # Matches the 'MyService' namespace from XML
|                   ├── enum.dart # All enums in the namespace will be here
│                   ├── product.dart
│                   ├── customer.dart
│                   ├── address.dart
│                   └── ...
├── odata_metadata/
├── pubspec.yaml
└── ...
```

### 4\. Run `build_runner`

The generated models include `part 'your_model.g.dart';` declarations and `JsonSerializable` annotations. To complete the serialization/deserialization logic, you **must** run `build_runner`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs # For Flutter
# OR
dart pub run build_runner build --delete-conflicting-outputs   # For pure Dart
```

This command will create the `*.g.dart` files alongside your generated models (e.g., `product.g.dart`, `customer.g.dart`), which contain the `fromJson` and `toJson` factory/methods.

### 5\. Use the Generated Models

You can now import and use your strongly-typed OData models in your Dart application:

```dart
// lib/main.dart (or any other Dart file)
import 'dart:convert';
import 'package:my_app/src/models/generated/myservice/product.dart';
import 'package:my_app/src/models/generated/myservice/customer.dart';
import 'package:my_app/src/models/generated/myservice/address.dart';

void main() {
  // Example: Deserializing a Product from JSON
  const String productJson = '''
  {
    "Id": 101,
    "Name": "Wireless Mouse",
    "Price": 35.99,
    "IsAvailable": true
  }
  ''';

  try {
    final Product product = Product.fromJson(jsonDecode(productJson));
    print('Product Name: ${product.name}');         // Output: Wireless Mouse
    print('Product Price: \$${product.price}');      // Output: $35.99
    print('Product Available: ${product.isAvailable}'); // Output: true

    // Example: Serializing a Product to JSON
    final Map<String, dynamic> productMap = product.toJson();
    print('Product as JSON: ${jsonEncode(productMap)}');
    // Output: {"Id":101,"Name":"Wireless Mouse","Price":35.99,"IsAvailable":true}


    // Example with ComplexType
    const String customerJson = '''
    {
      "CustomerId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "FirstName": "Jane",
      "LastName": "Doe",
      "Email": "jane.doe@example.com",
      "ShippingAddress": {
        "Street": "123 Main St",
        "City": "Anytown",
        "ZipCode": "12345"
      }
    }
    ''';
    final Customer customer = Customer.fromJson(jsonDecode(customerJson));
    print('Customer Name: ${customer.firstName} ${customer.lastName}');
    print('Customer Email: ${customer.email}');
    print('Shipping City: ${customer.shippingAddress?.city}'); // Use null-safe access
    
  } catch (e) {
    print('Error processing data: $e');
  }
}
```

## 🤝 Contributing

Contributions are welcome\! If you find a bug or want to add a feature, please feel free to open an issue or submit a pull request on GitHub.

1.  Fork the repository.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

## 🙏 Acknowledgements

  * [Dart](https://dart.dev/)
  * [Flutter](https://flutter.dev/)
  * [`package:xml`](https://www.google.com/search?q=%5Bhttps://pub.dev/packages/xml%5D\(https://pub.dev/packages/xml\)) for XML parsing.
  * [`package:json_annotation`](https://www.google.com/search?q=%5Bhttps://pub.dev/packages/json_annotation%5D\(https://pub.dev/packages/json_annotation\)) and [`package:build_runner`](https://www.google.com/search?q=%5Bhttps://pub.dev/packages/build_runner%5D\(https://pub.dev/packages/build_runner\)) for robust JSON serialization.
  * [`package:recase`](https://www.google.com/search?q=%5Bhttps://pub.dev/packages/recase%5D\(https://pub.dev/packages/recase\)) for convenient string casing.


## ❤️ Support This Project

Developing and maintaining open-source packages like `odata_model_generator` requires significant time and effort. If this package helps you or your organization, please consider supporting its continued development. Your support helps ensure ongoing maintenance, bug fixes, and the addition of new features.

You can support this project via:

* [**GitHub Sponsors**](https://github.com/shubhamkarnalkar/odata_model_generator?sponsor=1) - A great way to provide recurring support.


<div align="center">
  <a href="https://ko-fi.com/shubhamkarnalkar" target="_blank">
    <img src="https://cdn.ko-fi.com/cdn/kofi3.png?v=3" height="36" alt="Buy Me a Coffee at ko-fi.com"/>
  </a>
  <br/>
  <b>Thank you for your support!</b>
</div>