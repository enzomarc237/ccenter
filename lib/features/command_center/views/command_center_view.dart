import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import '../models/command.dart';

class CommandCenterView extends StatefulWidget {
  const CommandCenterView({super.key});

  @override
  State<CommandCenterView> createState() => _CommandCenterViewState();
}

class _CommandCenterViewState extends State<CommandCenterView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Command> _filteredCommands = [];
  int _selectedIndex = 0;

  final List<Command> _commands = [
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
    // Add more commands here
  ];

  @override
  void initState() {
    super.initState();
    _filteredCommands = _commands;
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommands = _commands.where((command) {
        return command.title.toLowerCase().contains(query) ||
            command.description.toLowerCase().contains(query);
      }).toList();
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      backgroundColor: MacosColors.windowBackgroundColor,
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  MacosTextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    placeholder: 'Search commands...',
                    prefix: const MacosIcon(CupertinoIcons.search),
                    onSubmitted: (value) {
                      if (_filteredCommands.isNotEmpty) {
                        _filteredCommands[_selectedIndex].onExecute();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredCommands.length,
                      itemBuilder: (context, index) {
                        final command = _filteredCommands[index];
                        final isSelected = index == _selectedIndex;
                        
                        return Container(
                          color: isSelected ? MacosColors.controlAccentColor.withOpacity(0.2) : Colors.transparent,
                          child: ListTile(
                            title: Text(
                              command.title,
                              style: MacosTheme.of(context).typography.headline,
                            ),
                            subtitle: Text(
                              command.description,
                              style: MacosTheme.of(context).typography.subheadline,
                            ),
                            onTap: command.onExecute,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
