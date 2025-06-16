import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:system_tray/system_tray.dart';

import 'features/content_capture/providers/content_provider.dart';
import 'features/content_capture/views/content_capture_view.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/views/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window utils
  await WindowManipulator.initialize();

  // Initialize window manager
  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  // Configure window properties
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  // Configure window effects
  await WindowManipulator.setWindowBackgroundColorToClear();
  await WindowManipulator.setMaterial(NSVisualEffectViewMaterial.hudWindow);

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Register global hotkey (Cmd+L)
  await hotKeyManager.register(
    HotKey(KeyCode.keyL, modifiers: [KeyModifier.meta]),
    keyDownHandler: (hotKey) async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
      ],
      child: const CCenterApp(),
    ),
  );
}

class CCenterApp extends StatelessWidget {
  const CCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'CCenter',
      debugShowCheckedModeBanner: false,
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const CCenterHomePage(),
    );
  }
}

class CCenterHomePage extends StatefulWidget {
  const CCenterHomePage({super.key});

  @override
  State<CCenterHomePage> createState() => _CCenterHomePageState();
}

class _CCenterHomePageState extends State<CCenterHomePage> {
  int _selectedViewIndex = 0;

  final SystemTray _systemTray = SystemTray();

  @override
  void initState() {
    super.initState();
    _initSystemTray();
  }

  Future<void> _initSystemTray() async {
    String iconPath = 'assets/icons/tray_icon_template.png';

    await _systemTray.initSystemTray(title: "CCenter", iconPath: iconPath);

    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Show CCenter',
        onClicked: (menuItem) async {
          await windowManager.show();
          await windowManager.focus();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit',
        onClicked: (menuItem) async {
          await hotKeyManager.unregisterAll();
          await _systemTray.destroy();
          await windowManager.destroy();
        },
      ),
    ]);

    await _systemTray.setContextMenu(menu);
  }

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: _selectedViewIndex,
            onChanged: (index) {
              setState(() => _selectedViewIndex = index);
            },
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.doc_text),
                label: Text('Content'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.settings),
                label: Text('Settings'),
              ),
            ],
          );
        },
      ),
      child: IndexedStack(
        index: _selectedViewIndex,
        children: const [ContentCaptureView(), SettingsView()],
      ),
    );
  }
}
