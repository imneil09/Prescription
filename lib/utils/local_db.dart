import 'package:shared_preferences/shared_preferences.dart';

class LocalDb {
  static late SharedPreferences _prefs;

  // Initialize the database
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get a list of suggestions for a specific field
  static List<String> getSuggestions(String key) {
    return _prefs.getStringList(key) ?? [];
  }

  // Save a new word if it doesn't already exist
  static Future<void> saveSuggestion(String key, String value) async {
    if (value.trim().isEmpty) return;

    List<String> currentList = getSuggestions(key);
    String formattedValue = value.trim();

    // Only add if it's not already in the list to avoid duplicates
    if (!currentList.contains(formattedValue)) {
      currentList.add(formattedValue);
      await _prefs.setStringList(key, currentList);
    }
  }
}