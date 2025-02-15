import 'dart:io';
import 'package:book_mobile/screens/book_reader_screens/epub_chapter_drawer.dart';
import 'package:book_mobile/screens/book_reader_screens/epub_fontsize_controller.dart';
import 'package:book_mobile/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EpubReaderScreen extends StatefulWidget {
  final String filePath;
  final String bookTitle;

  const EpubReaderScreen({
    super.key,
    required this.filePath,
    required this.bookTitle,
  });

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  final epubController = EpubController();
  bool isLoading = true;
  double _progress = 0.0;
  var textSelectionCfi = '';
  double _fontSize = 16;
  String _currentTheme = 'day';
  UniqueKey _epubViewerKey = UniqueKey();
  double _savedPosition = 0.0;
  bool _showControls = true;

  // Define theme colors
  final Map<String, EpubTheme> _themes = {
    'day': EpubTheme.light(),
    'night': EpubTheme.dark(),
    'sepia': EpubTheme.custom(
      backgroundColor: const Color(0xFFF4ECD8),
      foregroundColor: Colors.black,
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load font size preference
    double? savedFontSize = prefs.getDouble('fontSize');

    if (savedFontSize != null) {
      setState(() {
        _fontSize = savedFontSize;
      });
    }

    // Load theme preference
    String? savedTheme = prefs.getString('theme');
    if (savedTheme != null && _themes.containsKey(savedTheme)) {
      setState(() {
        _currentTheme = savedTheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ChapterDrawer(controller: epubController),
      appBar: _showControls
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.bookTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.palette),
                  onPressed: _showThemePicker,
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            
            Expanded(
              child: Stack(
                children: [
                  EpubViewer(
                    key: _epubViewerKey,
                    epubSource: EpubSource.fromFile(File(widget.filePath)),
                    epubController: epubController,
                    displaySettings: EpubDisplaySettings(
                      flow: EpubFlow.paginated,
                      useSnapAnimationAndroid: false,
                      snap: true,
                      allowScriptedContent: true,
                      theme: _themes[_currentTheme],
                      fontSize: _fontSize.toInt(),
                      spread: EpubSpread.always,
                    ),
                    selectionContextMenu: ContextMenu(
                      menuItems: [
                        ContextMenuItem(
                          title: "Highlight",
                          id: 1,
                          action: () async {
                            epubController.addHighlight(cfi: textSelectionCfi);
                          },
                        ),
                      ],
                      settings: ContextMenuSettings(
                          hideDefaultSystemContextMenuItems: true),
                    ),
                    onChaptersLoaded: (chapters) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                    onEpubLoaded: () async {
                      print('Epub loaded');
                      _themes[_currentTheme] = _themes[_currentTheme]!;
                      _progress = _savedPosition;
                    },
                    onRelocated: (value) {
                      setState(() {
                        _progress = value.progress;
                        _savedPosition = value.progress;
                      });
                    },
                    onAnnotationClicked: (cfi) {
                      print("Annotation clicked: $cfi");
                    },
                    onTextSelected: (epubTextSelection) {
                      print("Text selected: ${epubTextSelection.selectionCfi}");
                    },
                  ),
                  Visibility(
                    visible: isLoading,
                    child: const Center(
                      child: LoadingWidget(),
                    ),
                  ),
                  if (!isLoading)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior
                            .translucent, // Allow taps to pass through
                        onTap: () {
                          setState(() {
                            _showControls = !_showControls;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
           LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  void _handleFontSizeChange(double newSize) {
    setState(() {
      _fontSize = newSize;
    });
    epubController.setFontSize(fontSize: newSize).then((_) {
      _saveFontSizePreference(newSize);
    });
  }

  Future<void> _saveFontSizePreference(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize.toDouble());
  }

  final EpubManager _epubManager = EpubManager.continuous;

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Theme',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._themes.keys.map((themeKey) {
                return ListTile(
                  title: Text(
                    themeKey.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      color: _currentTheme == themeKey
                          ? Theme.of(context).primaryColor
                          : Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _currentTheme = themeKey;
                      _epubViewerKey = UniqueKey();
                      _saveThemePreference(themeKey);
                      epubController.setManager(manager: _epubManager);
                    });
                    Navigator.pop(context);
                  },
                );
              }),
              ControlsSection(
                fontSize: _fontSize,
                onFontSizeChange: _handleFontSizeChange,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveThemePreference(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
  }
}