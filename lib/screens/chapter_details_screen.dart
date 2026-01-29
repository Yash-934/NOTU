import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:notu/models/chapter.dart';
import 'package:notu/utils/database_helper.dart';
import 'package:notu/utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:webview_flutter/webview_flutter.dart';

class ChapterDetailsScreen extends StatefulWidget {
  final Chapter chapter;
  final Function(Chapter) onChapterUpdate;

  const ChapterDetailsScreen({super.key, required this.chapter, required this.onChapterUpdate});

  @override
  State<ChapterDetailsScreen> createState() => _ChapterDetailsScreenState();
}

class _ChapterDetailsScreenState extends State<ChapterDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _contentController;
  final dbHelper = DatabaseHelper();
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.chapter.content);
    if (widget.chapter.contentType == ContentType.html) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000)); // Keep webview transparent to avoid flashes
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load or reload the HTML with the correct theme colors whenever dependencies change
    if (widget.chapter.contentType == ContentType.html && _webViewController != null) {
      _webViewController!.loadHtmlString(_getStyledHtml(widget.chapter.content));
    }
  }

  // Helper to convert a Flutter Color to a CSS-friendly hex string
  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  // Injects CSS to style the HTML content based on the current Flutter theme
  String _getStyledHtml(String content) {
    final theme = Theme.of(context);
    final scaffoldBackgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium?.color;

    // Convert colors to hex strings for CSS
    final String backgroundColorHex = _colorToHex(scaffoldBackgroundColor);
    final String textColorHex = textColor != null
        ? _colorToHex(textColor)
        : (theme.brightness == Brightness.dark ? '#ffffff' : '#000000');
    final String primaryColorHex = _colorToHex(theme.colorScheme.primary);

    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              background-color: $backgroundColorHex; /* Match app background */
              color: $textColorHex; /* Match app text color */
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
              font-size: 16px;
              margin: 0;
              padding: 0;
            }
            a { 
              color: $primaryColorHex; /* Match app primary color for links */
            }
          </style>
        </head>
        <body>
          $content
        </body>
      </html>
    ''';
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChapter() async {
    final updatedChapter = Chapter(
      id: widget.chapter.id,
      bookId: widget.chapter.bookId,
      title: widget.chapter.title,
      content: _contentController.text,
      contentType: widget.chapter.contentType,
    );
    await dbHelper.updateChapter(updatedChapter);
    widget.onChapterUpdate(updatedChapter);

    // After saving, if it's HTML, reload it with the updated content and styles
    if (widget.chapter.contentType == ContentType.html && _webViewController != null) {
      _webViewController!.loadHtmlString(_getStyledHtml(_contentController.text));
    }
    _toggleEditing();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final blockquoteColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];

    return Scaffold(
      backgroundColor: _isEditing ? Theme.of(context).cardColor : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.chapter.title),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveChapter : _toggleEditing,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'pdf') {
                PdfGenerator.generate(widget.chapter.title, _contentController.text);
              } else if (value == 'print') {
                final doc = pw.Document();
                doc.addPage(pw.Page(
                    pageFormat: PdfPageFormat.a4,
                    build: (pw.Context context) {
                      return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(widget.chapter.title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 16),
                            pw.Text(_contentController.text),
                          ]);
                    }));
                await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => doc.save());
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'pdf',
                child: Text('Save as PDF'),
              ),
              const PopupMenuItem<String>(
                value: 'print',
                child: Text('Print'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isEditing
            ? TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your notes here...',
                  border: InputBorder.none,
                ),
              )
            : (widget.chapter.contentType == ContentType.markdown
                ? Markdown(
                    data: _contentController.text,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                      p: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                      h1: Theme.of(context).textTheme.displayLarge!.copyWith(fontSize: 32),
                      h2: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 24),
                      blockquoteDecoration: BoxDecoration(
                        color: blockquoteColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : (_webViewController != null
                    ? WebViewWidget(controller: _webViewController!)
                    : const Center(child: Text('Could not load content.')))),
      ),
    );
  }
}
