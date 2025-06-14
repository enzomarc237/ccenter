import 'package:flutter/material.dart';
import '../models/command.dart';

class CommandCenterProvider extends ChangeNotifier {
  final List<Command> _commands = [];
  List<Command> _filteredCommands = [];
  int _selectedIndex = 0;

  List<Command> get filteredCommands => _filteredCommands;
  int get selectedIndex => _selectedIndex;

  void registerCommand(Command command) {
    _commands.add(command);
    _filteredCommands = List.from(_commands);
    notifyListeners();
  }

  void search(String query) {
    query = query.toLowerCase();
    _filteredCommands = _commands.where((command) {
      return command.title.toLowerCase().contains(query) ||
          command.description.toLowerCase().contains(query);
    }).toList();
    _selectedIndex = 0;
    notifyListeners();
  }

  void selectNext() {
    if (_filteredCommands.isEmpty) return;
    _selectedIndex = (_selectedIndex + 1) % _filteredCommands.length;
    notifyListeners();
  }

  void selectPrevious() {
    if (_filteredCommands.isEmpty) return;
    _selectedIndex = (_selectedIndex - 1 + _filteredCommands.length) % _filteredCommands.length;
    notifyListeners();
  }

  void executeSelected() {
    if (_filteredCommands.isNotEmpty) {
      _filteredCommands[_selectedIndex].onExecute();
    }
  }
}
