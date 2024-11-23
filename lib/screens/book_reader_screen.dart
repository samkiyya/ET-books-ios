import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookReaderScreen extends StatefulWidget {
  final String pdfUrl; // URL of the PDF book
  final String bookTitle;

  const BookReaderScreen({
    super.key,
    required this.pdfUrl,
    required this.bookTitle,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  String? _localFilePath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;
  late PDFViewController _pdfViewController;
  late SharedPreferences _prefs;
  double _fontSize = 16.0; // Retained for compatibility
  String _theme = 'light'; // 'light', 'dark', 'sepia'

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _downloadAndSavePdf();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = _prefs.getDouble('fontSize') ?? 16.0;
      _theme = _prefs.getString('theme') ?? 'light';
    });
  }

  void _savePreferences() {
    _prefs.setDouble('fontSize', _fontSize);
    _prefs.setString('theme', _theme);
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${widget.bookTitle.replaceAll(" ", "_")}.pdf';

      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _localFilePath = filePath;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }

  Color _getBackgroundColor() {
    switch (_theme) {
      case 'dark':
        return Colors.black;
      case 'sepia':
        return const Color(0xFFF5DEB3); // Sepia tone
      default:
        return Colors.white;
    }
  }

  Color _getTextColor() {
    return _theme == 'dark' ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.bookTitle),
          actions: [
            if (!_isLoading)
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    if (value == 'Light Theme') {
                      _theme = 'light';
                    } else if (value == 'Dark Theme') {
                      _theme = 'dark';
                    } else if (value == 'Sepia Theme') {
                      _theme = 'sepia';
                    }
                    _savePreferences();
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'Light Theme', child: Text('Light Theme')),
                  const PopupMenuItem(
                      value: 'Dark Theme', child: Text('Dark Theme')),
                  const PopupMenuItem(
                      value: 'Sepia Theme', child: Text('Sepia Theme')),
                ],
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _localFilePath == null
                ? const Center(child: Text('Failed to load PDF'))
                : Container(
                    color: _getBackgroundColor(),
                    child: PDFView(
                      filePath: _localFilePath,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: true,
                      pageFling: true,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages!;
                        });
                      },
                      onViewCreated: (PDFViewController controller) {
                        _pdfViewController = controller;
                      },
                      onPageChanged: (currentPage, totalPages) {
                        setState(() {
                          _currentPage = currentPage!;
                        });
                      },
                    ),
                  ),
        bottomNavigationBar: !_isLoading
            ? BottomAppBar(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page ${_currentPage + 1} of $_totalPages',
                        style: TextStyle(color: _getTextColor()),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon:
                                Icon(Icons.arrow_back, color: _getTextColor()),
                            onPressed: () async {
                              final previousPage =
                                  (_currentPage - 1).clamp(0, _totalPages - 1);
                              await _pdfViewController.setPage(previousPage);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward,
                                color: _getTextColor()),
                            onPressed: () async {
                              final nextPage =
                                  (_currentPage + 1).clamp(0, _totalPages - 1);
                              await _pdfViewController.setPage(nextPage);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
