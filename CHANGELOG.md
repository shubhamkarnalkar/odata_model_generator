
* Added Hive support: generate Hive-compatible model classes with the `-h`/`--hive` CLI flag.
* Added CSV utility: generates a `hive.csv` file listing all generated classes and their `typeId` values in the output directory (or custom location via `--hive-csv`).
* Updated CLI: new options `-h`/`--hive` and `--hive-csv` for advanced model and CSV generation.
# Changelog

## 1.0.0 - 2025-07-30

* Initial release of `odata_model_generator`.
* Generates Dart models from OData CSDL XML metadata.
* Integrates with `json_annotation` for serialization.
## 1.2.0 - 2025-08-16

* CLI BREAKING CHANGE: Now supports mutually exclusive `-c` (CSV only) and `-g` (generate models only) flags.
* Removed old `-h`/`--hive` and `--hive-csv` flags. Hive support is now automatic if `hive.csv` is present.
* Updated documentation and usage instructions for new CLI behavior.

# Changelog

## 1.1.0 - 2025-08-15

* Added Hive support: generate Hive-compatible model classes with the `-h`/`--hive` CLI flag.
* Added CSV utility: generates a `hive.csv` file listing all generated classes and their `typeId` values in the output directory (or custom location via `--hive-csv`).
* Updated CLI: new options `-h`/`--hive` and `--hive-csv` for advanced model and CSV generation.