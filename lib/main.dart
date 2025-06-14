import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'package:provider/provider.dart';
import 'features/command_center/providers/command_center_provider.dart';
import 'features/command_center/views/command_center_view.dart';
import 'features/command_center/data/default_commands.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const CCenterApp());
}

class CCenterApp extends StatelessWidget {
  const CCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommandCenterProvider()),
      ],
      child: MacosApp(
        title: 'CCenter',
        theme: MacosThemeData.light(),
        darkTheme: MacosThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const CCenterHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class CCenterHomePage extends StatefulWidget {
  const CCenterHomePage({super.key});

  @override
  State<CCenterHomePage> createState() => _CCenterHomePageState();
}

class _CCenterHomePageState extends State<CCenterHomePage> {
  final SystemTray _systemTray = SystemTray();

  @override
  void initState() {
    super.initState();
    _initSystemTray();
    _initCommands();
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

  void _initCommands() {
    final provider = Provider.of<CommandCenterProvider>(context, listen: false);
    for (final command in DefaultCommands.getCommands()) {
      provider.registerCommand(command);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: 0,
            onChanged: (i) {},
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.command),
                label: Text('Command Center'),
              ),
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
      child: MacosScaffold(
        toolBar: const ToolBar(title: Text('CCenter'), titleWidth: 150.0),
        children: [
          ContentArea(
            builder: (context, scrollController) {
              return const CommandCenterView();
            },
          ),
        ],
      ),
    );
  }
}
