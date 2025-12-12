/// Parses an integer from dynamic input (int or String).
/// Returns [defaultValue] if parsing fails or input is null.
int parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  
  // Tambahan: Handle jika inputnya 1.0 (double)
  if (value is num) return value.toInt(); 
  
  if (value is String) {
    // tryParse bisa handle "1", tapi tidak bisa handle "1.0"
    // Jadi di parse ke num dulu baru toInt()
    return num.tryParse(value)?.toInt() ?? defaultValue;
  }
  return defaultValue;
}
/// Parses a nullable integer from dynamic input.
/// Returns null if input is null or parsing fails.
int? parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
