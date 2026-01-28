
import 'package:flutter/material.dart';
import 'package:myapp/models/book.dart';
import 'package:myapp/screens/chapter_details_screen.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: ListView.builder(
        itemCount: book.chapters.length,
        itemBuilder: (context, index) {
          final chapter = book.chapters[index];
          return ListTile(
            title: Text(chapter.title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterDetailsScreen(chapter: chapter),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
