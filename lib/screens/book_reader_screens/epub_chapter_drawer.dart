import 'package:bookreader/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_epub_viewer/flutter_epub_viewer.dart';

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
            return const Center(child: LoadingWidget());
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
