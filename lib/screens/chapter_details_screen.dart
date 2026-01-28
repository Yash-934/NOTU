
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:myapp/models/chapter.dart';

class ChapterDetailsScreen extends StatelessWidget {
  final Chapter chapter;

  const ChapterDetailsScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.title),
      ),
      body: Markdown(
        data: chapter.content,
      ),
    );
  }
}
