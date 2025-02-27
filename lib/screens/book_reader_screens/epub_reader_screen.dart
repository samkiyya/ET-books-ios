import 'package:bookreader/widgets/loading_widget.dart';
import 'package:cosmos_epub/Model/book_progress_model.dart';
import 'package:cosmos_epub/cosmos_epub.dart';
import 'package:cosmos_epub/Helpers/custom_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/providers/user_interaction_provider.dart';

class EpubReaderScreen extends StatefulWidget {
  final String filePath;
  final String bookTitle;
  final int bookId;

  const EpubReaderScreen({
    super.key,
    required this.filePath,
    required this.bookTitle,
    required this.bookId,
  });

  @override
  State<EpubReaderScreen> createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  late Future<void> _readerFuture;
  int startChapterIndex = 0;
  late UserActivityProvider _userActivityProvider;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _userActivityProvider = Provider.of<UserActivityProvider>(context, listen: false);
      _userActivityProvider.startTracking(widget.bookId);

      // Delay execution to avoid calling setState() during build
      _readerFuture = Future.microtask(() => _openEpubReader());
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _userActivityProvider.stopTracking(widget.bookId);
    super.dispose();
  }

  // Increment pages read when user progresses in the book
  void _incrementPagesRead() {
    if (!mounted) return;
    _userActivityProvider.incrementPagesRead();
  }

  Future<void> _openEpubReader() async {
    try {
      print('Initializing CosmosEpub...');
      print('Fetching book progress...');

      // Fetch book progress
      BookProgressModel? bookProgress = CosmosEpub.getBookProgress(widget.bookTitle);

      int startPageIndex = 0;
        startChapterIndex = bookProgress.currentChapterIndex ?? 0;
        startPageIndex = bookProgress.currentPageIndex ?? 0;

        await CosmosEpub.setCurrentPageIndex(widget.bookTitle, startPageIndex);
        await CosmosEpub.setCurrentChapterIndex(widget.bookTitle, startChapterIndex);
      

      print('Opening local EPUB book...');
      await CosmosEpub.openLocalBook(
        localPath: widget.filePath,
        context: context,
        bookId: widget.bookTitle,
        starterChapter: startChapterIndex >= 0 ? startChapterIndex : 0,
        onPageFlip: (int currentPage, int totalPages) {
          CosmosEpub.setCurrentPageIndex(widget.bookTitle, currentPage);
          CosmosEpub.setCurrentChapterIndex(widget.bookTitle, startChapterIndex);
          _incrementPagesRead();
        },
        onLastPage: (int lastPageIndex) {
          CustomToast.showToast('You have reached the end of the book. Thank you for reading!');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('You have reached the end of the book. Thank you for reading!')),
          // );
        },
      );
    } catch (e) {
      print('Error opening EPUB: $e');
      throw Exception('Failed to open EPUB: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _readerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(radius: 15, color: Colors.black),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading the EPUB file: ${snapshot.error}'),
            );
          } else {
            return const Center(child: LoadingWidget());
          }
        },
      ),
    );
  }
}
