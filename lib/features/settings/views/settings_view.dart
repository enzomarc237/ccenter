import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = MacosTypography.of(context);

    return MacosScaffold(
      toolBar: const ToolBar(title: Text('Settings'), titleWidth: 150.0),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                final settings = settingsProvider.settings;
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    MacosListTile(
                      title: Text('General', style: typography.title2),
                    ),
                    const SizedBox(height: 8),
                    PushButton(
                      controlSize: ControlSize.regular,
                      secondary: true,
                      child: Text('Start at login'),
                      onPressed: () {
                        settingsProvider.updateStartAtLogin(
                          !settings.startAtLogin,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    PushButton(
                      controlSize: ControlSize.regular,
                      secondary: true,
                      child: Text('Minimize to system tray'),
                      onPressed: () {
                        settingsProvider.updateMinimizeToTray(
                          !settings.minimizeToTray,
                        );
                      },
                    ),
                    MacosListTile(
                      title: Text('Appearance', style: typography.title2),
                    ),
                    const SizedBox(height: 8),
                    PushButton(
                      controlSize: ControlSize.regular,
                      secondary: true,
                      child: Text('Dark Mode'),
                      onPressed: () {
                        settingsProvider.updateDarkMode(!settings.darkMode);
                      },
                    ),
                    MacosListTile(
                      title: Text('API Settings', style: typography.title2),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: MacosTextField(
                        placeholder: 'Enter Gemini API Key',
                        controller: TextEditingController(
                          text: settings.geminiApiKey,
                        ),
                        onSubmitted: (value) {
                          settingsProvider.updateGeminiApiKey(value);
                        },
                      ),
                    ),
                    MacosListTile(
                      title: Text(
                        'Keyboard Shortcuts',
                        style: typography.title2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: MacosTextField(
                        placeholder: 'Command + L',
                        controller: TextEditingController(
                          text: settings.hotkeyCommand,
                        ),
                        onSubmitted: (value) {
                          settingsProvider.updateHotkeyCommand(value);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
