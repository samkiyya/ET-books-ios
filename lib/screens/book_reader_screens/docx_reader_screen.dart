import 'package:flutter/material.dart';
import 'package:docx_viewer/docx_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocxReaderScreen extends StatefulWidget {
  final int bookId;
  final String filePath;
  final String bookTitle;

  const DocxReaderScreen(
      {super.key,
      required this.filePath,
      required this.bookTitle,
      required this.bookId});

  @override
  State<DocxReaderScreen> createState() => _DocxReaderScreenState();
}

class _DocxReaderScreenState extends State<DocxReaderScreen> {
  late SharedPreferences _prefs;
  String _theme = 'light';
  double _zoomLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = _prefs.getString('theme') ?? 'light';
    });
  }

  void _savePreferences() {
    _prefs.setString('theme', _theme);
  }

  Color _getBackgroundColor() {
    switch (_theme) {
      case 'dark':
        return Colors.black;
      case 'sepia':
        return const Color(0xFFE6D4B4);
      default:
        return Colors.white;
    }
  }

  Color _getTextColor() {
    return _theme == 'dark' ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getTextColor(),
        title: Text(
          widget.bookTitle,
        ),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                if (_zoomLevel < 2.0) {
                  _zoomLevel += 0.2;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                if (_zoomLevel > 1) {
                  _zoomLevel -= 0.2;
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        color: _getBackgroundColor(),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Transform.scale(
            scale: _zoomLevel,
            alignment: Alignment.center,
            child: DocxView(
              filePath: widget.filePath,
              fontSize: 16 * _zoomLevel.toInt(),
            ),
          ),
        ),
      ),
    );
  }
}
