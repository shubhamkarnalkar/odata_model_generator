class EdmEnum {
  final String type;
  final List<EnumValue> values;
  EdmEnum({required this.type, required this.values});
}

class EnumValue{
  final String name;
  final String? value;

  EnumValue({required this.name, required this.value});
}
