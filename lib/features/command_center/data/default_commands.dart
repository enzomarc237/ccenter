import '../models/command.dart';

class DefaultCommands {
  static List<Command> getCommands() {
    return [
      Command(
        id: 'capture_screen',
        title: 'Capture Screen',
        description: 'Capture current screen or selection',
        category: 'capture',
        onExecute: () {
          // TODO: Implement screen capture
        },
      ),
      Command(
        id: 'capture_text',
        title: 'Capture Text',
        description: 'Extract text from screen selection',
        category: 'capture',
        onExecute: () {
          // TODO: Implement text capture
        },
      ),
      Command(
        id: 'settings',
        title: 'Open Settings',
        description: 'Configure CCenter settings',
        category: 'app',
        onExecute: () {
          // TODO: Implement settings navigation
        },
      ),
      Command(
        id: 'quit',
        title: 'Quit CCenter',
        description: 'Close the application',
        category: 'app',
        onExecute: () {
          // TODO: Implement quit
        },
      ),
    ];
  }
}
