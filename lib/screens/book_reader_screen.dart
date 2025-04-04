import 'package:bookreader/screens/book_reader_screens/docx_reader_screen.dart';
import 'package:bookreader/screens/book_reader_screens/epub_reader_screen.dart';
import 'package:bookreader/screens/book_reader_screens/epub_reader_screen2.dart';
import 'package:bookreader/screens/book_reader_screens/pdf_reader_screen.dart';
import 'package:bookreader/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class BookReaderScreen extends StatefulWidget {
  final int bookId;
  final String filePath;
  final String bookTitle;

  const BookReaderScreen({
    super.key,
    required this.filePath,
    required this.bookTitle,
    required this.bookId,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  String? _localFilePath;
  bool _isLoading = true;
  String? _selectedEpubReader;

  @override
  void initState() {
    super.initState();
    print('initState: Starting file download/load');
    _downloadOrLoadFile();
  }

  Future<void> _downloadOrLoadFile() async {
    print('downloadOrLoadFile: Checking file path: ${widget.filePath}');
    if (widget.filePath.startsWith('http://') ||
        widget.filePath.startsWith('https://')) {
      await _downloadAndSaveFile();
    } else {
      _loadLocalFile(widget.filePath);
    }
  }

  Future<void> _downloadAndSaveFile() async {
    try {
      final tempDir = await getTemporaryDirectory();
      String fileExtension = '.docx';
      final uri = Uri.parse(widget.filePath);
      print('downloadAndSaveFile: Sending HEAD request to $uri');
      final response = await http.head(uri);

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        print('downloadAndSaveFile: Content-Type: $contentType');
        if (contentType != null) {
          if (contentType.contains('pdf')) {
            fileExtension = '.pdf';
          } else if (contentType.contains('epub')) {
            fileExtension = '.epub';
          } else if (contentType.contains('msword') ||
              contentType.contains('docx')) {
            fileExtension = '.docx';
          }
        }

        final filePath =
            '${tempDir.path}/${widget.bookTitle.replaceAll(" ", "_")}$fileExtension';
        print('downloadAndSaveFile: Downloading to $filePath');
        final responseBody = await http.get(uri);

        if (responseBody.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(responseBody.bodyBytes);

          setState(() {
            _localFilePath = filePath;
            _isLoading = false;
          });

          if (fileExtension == '.epub' && mounted) {
            print('downloadAndSaveFile: EPUB detected, showing dialog');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showReaderChoiceDialog(context);
            });
          }
        } else {
          throw Exception('Failed to download file');
        }
      } else {
        throw Exception('Failed to get file content type');
      }
    } catch (e) {
      print('downloadAndSaveFile: Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading file: $e')));
      }
    }
  }

  void _loadLocalFile(String filePath) {
    print('loadLocalFile: Loading local file: $filePath');
    setState(() {
      _localFilePath = filePath;
      _isLoading = false;
    });

    if (filePath.endsWith('.epub') && mounted) {
      print('loadLocalFile: EPUB detected, showing dialog');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showReaderChoiceDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('build: isLoading: $_isLoading, localFilePath: $_localFilePath');
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }
    if (_localFilePath == null) {
      return const Center(child: Text('Failed to load file'));
    }
    return _getFileReaderScreen();
  }

  Widget _getFileReaderScreen() {
    print(
        'getFileReaderScreen: File path: $_localFilePath, Reader: $_selectedEpubReader');
    if (_localFilePath!.endsWith('.pdf')) {
      return PdfReaderScreen(
        filePath: _localFilePath!,
        bookTitle: widget.bookTitle,
        bookId: widget.bookId,
      );
    } else if (_localFilePath!.endsWith('.epub')) {
      if (_selectedEpubReader == 'default') {
        return EpubReaderScreen(
          filePath: _localFilePath!,
          bookTitle: widget.bookTitle,
          bookId: widget.bookId,
        );
      } else if (_selectedEpubReader == 'alternate') {
        return EpubReaderScreen2(
          filePath: _localFilePath!,
          bookTitle: widget.bookTitle,
          bookId: widget.bookId.toString(),
        );
      } else {
        return EpubReaderScreen(
          filePath: _localFilePath!,
          bookTitle: widget.bookTitle,
          bookId: widget.bookId,
        );
      }
    } else if (_localFilePath!.endsWith('.docx')) {
      return DocxReaderScreen(
        filePath: _localFilePath!,
        bookTitle: widget.bookTitle,
        bookId: widget.bookId,
      );
    } else {
      return const Center(child: Text('Unsupported file format'));
    }
  }

  Future<void> _showReaderChoiceDialog(BuildContext context) async {
    print('showReaderChoiceDialog: Displaying dialog');
    final choice = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose a Reader'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.book),
                title: const Text('Default Epub Reader'),
                onTap: () {
                  print('Dialog: Default reader selected');
                  Navigator.pop(context, 'default');
                },
              ),
              ListTile(
                leading: const Icon(Icons.chrome_reader_mode),
                title: const Text('Alternate Epub Reader'),
                onTap: () {
                  print('Dialog: Alternate reader selected');
                  Navigator.pop(context, 'alternate');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('Dialog: Cancel pressed');
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (choice != null && mounted) {
      print('showReaderChoiceDialog: Choice made: $choice');
      setState(() {
        _selectedEpubReader = choice;
      });
    } else {
      print('showReaderChoiceDialog: No choice made or widget unmounted');
    }
  }
}
