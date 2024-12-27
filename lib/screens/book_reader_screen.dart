import 'package:book_mobile/screens/book_reader_screens/docx_reader_screen.dart';
import 'package:book_mobile/screens/book_reader_screens/epub_reader_screen.dart';
import 'package:book_mobile/screens/book_reader_screens/pdf_reader_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class BookReaderScreen extends StatefulWidget {
  final int bookId;
  final String filePath;
  final String bookTitle;

  const BookReaderScreen(
      {super.key,
      required this.filePath,
      required this.bookTitle,
      required this.bookId});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  String? _localFilePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadOrLoadFile();
  }

  Future<void> _downloadOrLoadFile() async {
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

      // Get the file extension from the URL or set a default if none exists
      String fileExtension =
          '.docx'; // Default extension, you can change this based on expected default
      final uri = Uri.parse(widget.filePath);
      final response =
          await http.head(uri); // Send a HEAD request to get headers

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];

        // Check the content type and assign the proper file extension
        if (contentType != null) {
          if (contentType.contains('pdf')) {
            fileExtension = '.pdf';
          } else if (contentType.contains('epub')) {
            fileExtension = '.epub';
          } else if (contentType.contains('msword') ||
              contentType.contains('docx')) {
            fileExtension = '.docx';
          }
        } else {
          print(' 🤣🤣🤣🤣 Failed to get file content type');
        }

        // Now, use the correct file extension
        final filePath =
            '${tempDir.path}/${widget.bookTitle.replaceAll(" ", "_")}$fileExtension';

        // Download the file
        final responseBody = await http.get(uri);

        if (responseBody.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(responseBody.bodyBytes);

          setState(() {
            _localFilePath = filePath;
            print('🤣🤣🤣 _localFilePath: $_localFilePath');
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to download file');
        }
      } else {
        throw Exception('Failed to get file content type');
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading file: $e')));
      }
    }
  }

  void _loadLocalFile(String filePath) {
    setState(() {
      _localFilePath = filePath;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _localFilePath == null
            ? const Center(child: Text('Failed to load file'))
            : _getFileReaderScreen();
  }

  Widget _getFileReaderScreen() {
    if (_localFilePath!.endsWith('.pdf')) {
      return PdfReaderScreen(
          filePath: _localFilePath!,
          bookTitle: widget.bookTitle,
          bookId: widget.bookId);
    } else if (_localFilePath!.endsWith('.epub')) {
      return EpubReaderScreen(
          filePath: _localFilePath!, bookTitle: widget.bookTitle);
    } else if (_localFilePath!.endsWith('.docx')) {
      return DocxReaderScreen(
          filePath: _localFilePath!,
          bookTitle: widget.bookTitle,
          bookId: widget.bookId);
    } else {
      return const Center(child: Text('Unsupported file format'));
    }
  }
}
