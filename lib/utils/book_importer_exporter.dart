import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:notu/models/book.dart';
import 'package:notu/utils/database_helper.dart';

class BookImporterExporter {
  final dbHelper = DatabaseHelper();

  Future<bool> importBook() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final jsonString = utf8.decode(result.files.single.bytes!);
        final book = Book.fromJson(jsonString);
        await dbHelper.insertBook(book);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> exportBook(Book book) async {
    try {
      return book.toJson();
    } catch (e) {
      return null;
    }
  }
}
