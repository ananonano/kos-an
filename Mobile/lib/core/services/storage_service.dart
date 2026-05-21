import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Local Storage Service
/// Mengelola penyimpanan data lokal menggunakan SharedPreferences
class StorageService {
  static SharedPreferences? _prefs;
  
  // Initialize Storage
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Save String
  static Future<bool> saveString(String key, String value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setString(key, value);
  }
  
  // Get String
  static String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  // Save Int
  static Future<bool> saveInt(String key, int value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setInt(key, value);
  }
  
  // Get Int
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }
  
  // Save Bool
  static Future<bool> saveBool(String key, bool value) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.setBool(key, value);
  }
  
  // Get Bool
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }
  
  // Save Object (as JSON)
  static Future<bool> saveObject(String key, Map<String, dynamic> value) async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonString = json.encode(value);
    return await _prefs!.setString(key, jsonString);
  }
  
  // Get Object (from JSON)
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }
  
  // Remove Key
  static Future<bool> remove(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.remove(key);
  }
  
  // Clear All
  static Future<bool> clear() async {
    _prefs ??= await SharedPreferences.getInstance();
    return await _prefs!.clear();
  }
  
  // Check if Key Exists
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
}
