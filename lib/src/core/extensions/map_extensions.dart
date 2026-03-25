extension SafeMap on Map<String, dynamic> {
  T? get<T>(String key) => this[key] as T?;
  
  T getOrDefault<T>(String key, T defaultValue) => (this[key] is T) ? (this[key] as T) : defaultValue;
  
  double getDouble(String key, [double defaultValue = 0.0]) {
    final value = this[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
  
  int getInt(String key, [int defaultValue = 0]) {
    final value = this[key];
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
  
  String getString(String key, [String defaultValue = '']) {
    return this[key]?.toString() ?? defaultValue;
  }
  
  bool getBool(String key, [bool defaultValue = false]) {
    final value = this[key];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return defaultValue;
  }

  List<T> getList<T>(String key) {
    final value = this[key];
    if (value is List) return value.cast<T>();
    return <T>[];
  }
}
