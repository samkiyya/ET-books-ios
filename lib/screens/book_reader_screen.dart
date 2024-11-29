import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class BookReaderScreen extends StatefulWidget {
  final String pdfPath; // URL of the PDF book
  final String bookTitle;

  const BookReaderScreen({
    super.key,
    required this.pdfPath,
    required this.bookTitle,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  String? _localFilePath;
  bool _isLoading = true;
  late SharedPreferences _prefs;
  String _theme = 'light';
  bool _isAppBarVisible = true;
  bool _isBottomNavVisible = true;
  late PdfViewerController _pdfViewerController;
  String _scrollDirection = 'vertical';
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPreferences();
    _downloadOrLoadPdf();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = _prefs.getString('theme') ?? 'light';
      _scrollDirection = _prefs.getString('scrollDirection') ?? 'vertical';
    });
  }

  void _savePreferences() {
    _prefs.setString('theme', _theme);
    _prefs.setString('scrollDirection', _scrollDirection);
  }

  // Method to check if the pdfPath is local or a network URL and handle accordingly
  Future<void> _downloadOrLoadPdf() async {
    if (widget.pdfPath.startsWith('http://') ||
        widget.pdfPath.startsWith('https://')) {
      // If URL is a network URL, download the PDF
      await _downloadAndSavePdf();
    } else {
      // If it's a local path, just load the PDF
      _loadLocalPdf(widget.pdfPath);
    }
  }

  // Download and save the PDF from the network
  Future<void> _downloadAndSavePdf() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${widget.bookTitle.replaceAll(" ", "_")}.pdf';

      final response = await http.get(Uri.parse(widget.pdfPath));

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

  // Load the local PDF
  void _loadLocalPdf(String filePath) {
    setState(() {
      _localFilePath = filePath;
      _isLoading = false;
    });
  }

  Color _getOverlayColor() {
    switch (_theme) {
      case 'dark':
        return Colors.black.withOpacity(0.5); // Semi-transparent dark overlay
      case 'sepia':
        return const Color(0xFF704214).withOpacity(0.3); // Sepia overlay
      default:
        return Colors.transparent; // No overlay for light theme
    }
  }

  Color _getTextColor() {
    return _theme == 'dark' ? Colors.white : Colors.black;
  }

  void _toggleAppBarVisibility() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
      _isBottomNavVisible = !_isBottomNavVisible;
      print(
          '_isAppBarVisible: $_isAppBarVisible, _isBottomNavVisible: $_isBottomNavVisible');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Theme(
        data: ThemeData(
          brightness: _theme == 'dark' ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: _getOverlayColor(),
          appBar: _isAppBarVisible
              ? AppBar(
                  title: Text(widget.bookTitle),
                  actions: <Widget>[
                    IconButton(
                        onPressed: () {
                          if (_pdfViewerController.zoomLevel > 1) {
                            _pdfViewerController.zoomLevel =
                                _pdfViewerController.zoomLevel - 0.5;
                          }
                        },
                        icon: const Icon(Icons.zoom_out)),
                    IconButton(
                      onPressed: () {
                        double newZoomLevel =
                            _pdfViewerController.zoomLevel + 0.5;
                        if (newZoomLevel <= 4) {
                          _pdfViewerController.zoomLevel = newZoomLevel;
                        }
                      },
                      icon: const Icon(Icons.zoom_in),
                    ),
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
                            } else if (value == 'Vertical Scroll') {
                              _scrollDirection = 'vertical';
                            } else if (value == 'Horizontal Scroll') {
                              _scrollDirection = 'horizontal';
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
                          const PopupMenuItem(
                              value: 'Vertical Scroll',
                              child: Text('Vertical Scroll')),
                          const PopupMenuItem(
                              value: 'Horizontal Scroll',
                              child: Text('Horizontal Scroll')),
                        ],
                      ),
                  ],
                )
              : null,
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _localFilePath == null
                  ? const Center(child: Text('Failed to load PDF'))
                  : Stack(
                      children: [
                        // PDF Viewer
                        SfPdfViewerTheme(
                          data: SfPdfViewerThemeData(
                            backgroundColor: _theme == 'dark'
                                ? Colors.black
                                : _theme == 'sepia'
                                    ? const Color(0xFFE6D4B4)
                                    : Colors.white,
                          ),
                          child: SfPdfViewer.file(
                            File(_localFilePath!),
                            controller: _pdfViewerController,
                            scrollDirection: _scrollDirection == 'vertical'
                                ? PdfScrollDirection.vertical
                                : PdfScrollDirection.horizontal,
                            key: _pdfViewerStateKey,
                            canShowPageLoadingIndicator: true,
                            onTap: (details) {
                              _toggleAppBarVisibility();
                            },
                          ),
                        ),

                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => print("Handle Tap event!!"),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: _isBottomNavVisible && !_isLoading
              ? BottomAppBar(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: _getTextColor()),
                              onPressed: () async {
                                _pdfViewerController.previousPage();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward,
                                  color: _getTextColor()),
                              onPressed: () async {
                                _pdfViewerController.nextPage();
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
      ),
    );
  }
}
