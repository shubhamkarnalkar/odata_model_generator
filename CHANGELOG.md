
# Changelog

## 1.1.0 - 2025-08-16

* CLI BREAKING CHANGE: Now supports mutually exclusive `-c` (CSV only) and `-g` (generate models only) flags.
* Hive support: Generates Hive-compatible model classes and a `hive.csv` file automatically if present.
* Removed old `-h`/`--hive` and `--hive-csv` flags. CLI is now simpler and more robust.
* Updated documentation and usage instructions for new CLI behavior.
* Added Hive support: generate Hive-compatible model classes and CSV utility.
* Added CSV utility: generates a `hive.csv` file listing all generated classes and their `typeId` values in the output directory.
* Updated CLI: new options for advanced model and CSV generation (now replaced by -c/-g in 1.2.0).

## 1.0.0 - 2025-07-30

* Initial release of `odata_model_generator`.
* Generates Dart models from OData CSDL XML metadata.
* Integrates with `json_annotation` for serialization.