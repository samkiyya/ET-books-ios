import 'dart:io';
import 'package:bookreader/screens/book_reader_screens/epub_fontsize_controller.dart';
import 'package:bookreader/screens/book_reader_screens/epub_chapter_drawer.dart';
import 'package:bookreader/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EpubReaderScreen2 extends StatefulWidget {
  final String filePath;
  final String bookTitle;
  final String bookId; // Unique identifier for the book

  const EpubReaderScreen2({
    super.key,
    required this.filePath,
    required this.bookTitle,
    required this.bookId,
  });

  @override
  State<EpubReaderScreen2> createState() => _EpubReaderScreen2State();
}

class _EpubReaderScreen2State extends State<EpubReaderScreen2> {
  final epubController = EpubController();
  bool isLoading = true;
  double _progress = 0.0;
  String _currentCfi = '';
  double _fontSize = 16;
  String _currentTheme = 'day';
  UniqueKey _epubViewerKey = UniqueKey();
  bool _showControls = true;

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
    double? savedFontSize = prefs.getDouble('fontSize_${widget.bookId}');
    if (savedFontSize != null) {
      setState(() {
        _fontSize = savedFontSize;
      });
    }

    String? savedTheme = prefs.getString('theme_${widget.bookId}');
    if (savedTheme != null && _themes.containsKey(savedTheme)) {
      setState(() {
        _currentTheme = savedTheme;
      });
    }

    String? savedCfi = prefs.getString('cfi_${widget.bookId}');
    double? savedProgress = prefs.getDouble('progress_${widget.bookId}');
    if (savedCfi != null && savedCfi.isNotEmpty) {
      setState(() {
        _currentCfi = savedCfi;
        _progress = savedProgress ?? 0.0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await epubController.display(cfi: _currentCfi);
        } catch (e) {
          print('Failed to restore CFI: $e');
          if (savedProgress != null) {
            epubController.toProgressPercentage(savedProgress);
          }
        }
      });
    } else if (savedProgress != null) {
      epubController.toProgressPercentage(savedProgress);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize_${widget.bookId}', _fontSize);
    await prefs.setString('theme_${widget.bookId}', _currentTheme);
    if (_currentCfi.isNotEmpty) {
      await prefs.setString('cfi_${widget.bookId}', _currentCfi);
    }
    await prefs.setDouble('progress_${widget.bookId}', _progress);
  }

  @override
  void dispose() {
    _savePreferences();
    super.dispose();
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
                            if (_currentCfi.isNotEmpty) {
                              epubController.addHighlight(cfi: _currentCfi);
                            }
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
                      if (_currentCfi.isNotEmpty) {
                        try {
                          await epubController.display(cfi: _currentCfi);
                        } catch (e) {
                          print('Failed to restore CFI: $e');
                          if (_progress > 0.0) {
                            epubController.toProgressPercentage(_progress);
                          }
                        }
                      }
                    },
                    onRelocated: (EpubLocation location) {
                      setState(() {
                        _progress = location.progress;
                        _currentCfi = location.startCfi.isNotEmpty
                            ? location.startCfi
                            : '';
                      });
                      if (_currentCfi.isNotEmpty) {
                        _savePreferences();
                      }
                    },
                    onAnnotationClicked: (cfi) {
                      print("Annotation clicked: $cfi");
                    },
                    onTextSelected: (epubTextSelection) {
                      setState(() {
                        _currentCfi = epubTextSelection.selectionCfi;
                      });
                      print("Text selected: $_currentCfi");
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
                        behavior: HitTestBehavior.translucent,
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
      _savePreferences();
    });
  }

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
                      _savePreferences();
                      epubController.setManager(
                          manager: EpubManager.continuous);
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
}
