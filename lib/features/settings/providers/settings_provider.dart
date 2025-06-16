import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _settingsKey = 'app_settings';

  AppSettings _settings = AppSettings();
  AppSettings get settings => _settings;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsJson = await _storage.read(key: _settingsKey);
      if (settingsJson != null) {
        _settings = AppSettings.fromJson(jsonDecode(settingsJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    try {
      await _storage.write(
        key: _settingsKey,
        value: jsonEncode(newSettings.toJson()),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> updateGeminiApiKey(String apiKey) async {
    await updateSettings(_settings.copyWith(geminiApiKey: apiKey));
  }

  Future<void> updateDarkMode(bool darkMode) async {
    await updateSettings(_settings.copyWith(darkMode: darkMode));
  }

  Future<void> updateHotkeyCommand(String hotkeyCommand) async {
    await updateSettings(_settings.copyWith(hotkeyCommand: hotkeyCommand));
  }

  Future<void> updateStartAtLogin(bool startAtLogin) async {
    await updateSettings(_settings.copyWith(startAtLogin: startAtLogin));
  }

  Future<void> updateMinimizeToTray(bool minimizeToTray) async {
    await updateSettings(_settings.copyWith(minimizeToTray: minimizeToTray));
  }
}
