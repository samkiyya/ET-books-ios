import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';

class EpubReaderScreen extends StatefulWidget {
  final String filePath;
  final String bookTitle;

  const EpubReaderScreen({
    super.key,
    required this.filePath,
    required this.bookTitle,
  });

  @override
  _EpubReaderScreenState createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  final epubController = EpubController();
  bool isLoading = true;
  double progress = 0.0;
  var textSelectionCfi = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: ChapterDrawer(controller: epubController),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.bookTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
            ),
            Expanded(
              child: Stack(
                children: [
                  EpubViewer(
                    epubSource: EpubSource.fromFile(File(widget.filePath)),
                    epubController: epubController,
                    displaySettings: EpubDisplaySettings(
                      flow: EpubFlow.paginated,
                      useSnapAnimationAndroid: false,
                      snap: true,
                      allowScriptedContent: true,
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
                    },
                    onRelocated: (value) {
                      setState(() {
                        progress = value.progress;
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
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChapterDrawer extends StatelessWidget {
  final EpubController controller;

  const ChapterDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<List<EpubChapter>>(
        future: Future.value(
            controller.getChapters()), // Fix the Future type mismatch
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chapters = snapshot.data!;
          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return ListTile(
                title: Text(chapter.title),
                onTap: () {
                  controller.display(cfi: chapter.href);
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      ),
    );
  }
}
