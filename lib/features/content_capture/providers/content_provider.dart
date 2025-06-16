import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/content_item.dart';

class ContentProvider extends ChangeNotifier {
  late Database _db;
  List<ContentItem> _items = [];
  List<ContentItem> get items => _items;

  ContentProvider() {
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'content.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE content(id TEXT PRIMARY KEY, content TEXT, source TEXT, capturedAt TEXT, summary TEXT, tags TEXT, isFavorite INTEGER)',
        );
      },
      version: 1,
    );
    await _loadItems();
  }

  Future<void> _loadItems() async {
    final List<Map<String, dynamic>> maps = await _db.query('content');
    _items = maps.map((item) {
      item['tags'] = jsonDecode(item['tags'] as String);
      item['isFavorite'] = item['isFavorite'] == 1;
      return ContentItem.fromJson(item);
    }).toList();
    notifyListeners();
  }

  Future<void> addItem(ContentItem item) async {
    await _db.insert('content', {
      ...item.toJson(),
      'tags': jsonEncode(item.tags),
      'isFavorite': item.isFavorite ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await _loadItems();
  }

  Future<void> updateItem(ContentItem item) async {
    await _db.update(
      'content',
      {
        ...item.toJson(),
        'tags': jsonEncode(item.tags),
        'isFavorite': item.isFavorite ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
    await _loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _db.delete('content', where: 'id = ?', whereArgs: [id]);
    await _loadItems();
  }

  Future<void> toggleFavorite(String id) async {
    final item = _items.firstWhere((item) => item.id == id);
    await updateItem(item.copyWith(isFavorite: !item.isFavorite));
  }

  Future<void> addTag(String id, String tag) async {
    final item = _items.firstWhere((item) => item.id == id);
    if (!item.tags.contains(tag)) {
      await updateItem(item.copyWith(tags: [...item.tags, tag]));
    }
  }

  Future<void> removeTag(String id, String tag) async {
    final item = _items.firstWhere((item) => item.id == id);
    await updateItem(
      item.copyWith(tags: item.tags.where((t) => t != tag).toList()),
    );
  }

  Future<void> generateSummary(String id) async {
    final item = _items.firstWhere((item) => item.id == id);
    try {
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: 'YOUR_API_KEY', // TODO: Get from settings
      );

      final prompt = 'Summarize this text in 2-3 sentences: ${item.content}';
      final response = await model.generateContent([Content.text(prompt)]);
      final summary = response.text;

      if (summary != null) {
        await updateItem(item.copyWith(summary: summary));
      }
    } catch (e) {
      debugPrint('Error generating summary: $e');
    }
  }

  List<ContentItem> search(String query) {
    query = query.toLowerCase();
    return _items.where((item) {
      return item.content.toLowerCase().contains(query) ||
          item.source.toLowerCase().contains(query) ||
          item.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          (item.summary?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<String> getAllTags() {
    final Set<String> tags = {};
    for (var item in _items) {
      tags.addAll(item.tags);
    }
    return tags.toList()..sort();
  }
}
