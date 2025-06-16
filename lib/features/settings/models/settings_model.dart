class AppSettings {
  final String geminiApiKey;
  final bool darkMode;
  final String hotkeyCommand;
  final bool startAtLogin;
  final bool minimizeToTray;

  AppSettings({
    this.geminiApiKey = '',
    this.darkMode = false,
    this.hotkeyCommand = 'meta+l',
    this.startAtLogin = true,
    this.minimizeToTray = true,
  });

  AppSettings copyWith({
    String? geminiApiKey,
    bool? darkMode,
    String? hotkeyCommand,
    bool? startAtLogin,
    bool? minimizeToTray,
  }) {
    return AppSettings(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      darkMode: darkMode ?? this.darkMode,
      hotkeyCommand: hotkeyCommand ?? this.hotkeyCommand,
      startAtLogin: startAtLogin ?? this.startAtLogin,
      minimizeToTray: minimizeToTray ?? this.minimizeToTray,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'geminiApiKey': geminiApiKey,
      'darkMode': darkMode,
      'hotkeyCommand': hotkeyCommand,
      'startAtLogin': startAtLogin,
      'minimizeToTray': minimizeToTray,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      geminiApiKey: json['geminiApiKey'] as String? ?? '',
      darkMode: json['darkMode'] as bool? ?? false,
      hotkeyCommand: json['hotkeyCommand'] as String? ?? 'meta+l',
      startAtLogin: json['startAtLogin'] as bool? ?? true,
      minimizeToTray: json['minimizeToTray'] as bool? ?? true,
    );
  }
}
