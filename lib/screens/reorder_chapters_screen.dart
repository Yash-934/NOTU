import 'package:flutter/material.dart';
import 'package:notu/models/chapter.dart';
import 'package:notu/utils/database_helper.dart';

class ReorderChaptersScreen extends StatefulWidget {
  final List<Chapter> chapters;

  const ReorderChaptersScreen({super.key, required this.chapters});

  @override
  State<ReorderChaptersScreen> createState() => _ReorderChaptersScreenState();
}

class _ReorderChaptersScreenState extends State<ReorderChaptersScreen> {
  late List<Chapter> _chapters;
  final dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _chapters = List.of(widget.chapters);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Chapter item = _chapters.removeAt(oldIndex);
      _chapters.insert(newIndex, item);
    });
  }

  void _saveOrder() async {
    await dbHelper.updateChapterOrder(_chapters);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter order saved!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder Chapters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOrder,
          ),
        ],
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        onReorder: _onReorder,
        children: _chapters.map((chapter) {
          return ListTile(
            key: Key('${chapter.id}'),
            title: Text(chapter.title),
            leading: const Icon(Icons.drag_handle),
          );
        }).toList(),
      ),
    );
  }
}
