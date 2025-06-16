import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/content_item.dart';
import '../providers/content_provider.dart';

class ContentCaptureView extends StatefulWidget {
  const ContentCaptureView({super.key});

  @override
  State<ContentCaptureView> createState() => _ContentCaptureViewState();
}

class _ContentCaptureViewState extends State<ContentCaptureView> {
  final _searchController = TextEditingController();
  String _selectedTag = '';
  List<ContentItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = Provider.of<ContentProvider>(context, listen: false);
    setState(() {
      _filteredItems = provider.search(_searchController.text);
    });
  }

  void _showAddContentDialog() {
    final contentController = TextEditingController();
    final sourceController = TextEditingController();
    final tagController = TextEditingController();

    showMacosSheet(
      context: context,
      builder: (context) {
        return MacosSheet(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Content',
                  style: MacosTypography.of(context).title1,
                ),
                const SizedBox(height: 20),
                MacosTextField(
                  controller: contentController,
                  placeholder: 'Content',
                  maxLines: 5,
                ),
                const SizedBox(height: 12),
                MacosTextField(
                  controller: sourceController,
                  placeholder: 'Source',
                ),
                const SizedBox(height: 12),
                MacosTextField(
                  controller: tagController,
                  placeholder: 'Tags (comma separated)',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PushButton(
                      controlSize: ControlSize.regular,
                      secondary: true,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    PushButton(
                      controlSize: ControlSize.regular,
                      onPressed: () {
                        final provider = Provider.of<ContentProvider>(
                          context,
                          listen: false,
                        );
                        final content = contentController.text.trim();
                        final source = sourceController.text.trim();
                        final tags = tagController.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                        if (content.isNotEmpty) {
                          final item = ContentItem(
                            id: const Uuid().v4(),
                            content: content,
                            source: source,
                            capturedAt: DateTime.now(),
                            tags: tags,
                          );
                          provider.addItem(item);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Content'),
        titleWidth: 150.0,
        actions: [
          ToolBarIconButton(
            label: 'Add Content',
            icon: const MacosIcon(CupertinoIcons.add),
            onPressed: _showAddContentDialog,
            showLabel: false,
          ),
        ],
      ),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Consumer<ContentProvider>(
              builder: (context, provider, child) {
                final items = _searchController.text.isEmpty
                    ? provider.items
                    : _filteredItems;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: MacosTextField(
                              controller: _searchController,
                              placeholder: 'Search content...',
                            ),
                          ),
                          const SizedBox(width: 16),
                          MacosPopupButton<String>(
                            value: _selectedTag,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedTag = value);
                              }
                            },
                            items: [
                              const MacosPopupMenuItem(
                                value: '',
                                child: Text('All Tags'),
                              ),
                              ...provider.getAllTags().map(
                                (tag) => MacosPopupMenuItem(
                                  value: tag,
                                  child: Text(tag),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (_selectedTag.isNotEmpty &&
                              !item.tags.contains(_selectedTag)) {
                            return const SizedBox.shrink();
                          }
                          return ContentItemTile(item: item);
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

class ContentItemTile extends StatelessWidget {
  final ContentItem item;

  const ContentItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return MacosListTile(
      title: Text(item.content, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Source: ${item.source}',
            style: MacosTypography.of(context).caption2,
          ),
          if (item.summary != null) ...[
            const SizedBox(height: 4),
            Text(
              'Summary: ${item.summary}',
              style: MacosTypography.of(context).caption2,
            ),
          ],
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: item.tags.map((tag) {
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: PushButton(
                  controlSize: ControlSize.small,
                  secondary: true,
                  onPressed: () {
                    Provider.of<ContentProvider>(
                      context,
                      listen: false,
                    ).removeTag(item.id, tag);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag),
                      const SizedBox(width: 4),
                      const Icon(CupertinoIcons.xmark, size: 12),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      onClick: () {
        // TODO: Show detail view
      },
    );
  }
}
