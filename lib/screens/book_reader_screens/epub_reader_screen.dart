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

  @override
  void initState() {
    super.initState();
    _readerFuture = _openEpubReader();
    final userActivityProvider =
        Provider.of<UserActivityProvider>(context, listen: false);
    userActivityProvider.startTracking(widget.bookId);
  }

  @override
  void dispose() {
    // Stop tracking when the user leaves the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userActivityProvider =
            Provider.of<UserActivityProvider>(context, listen: false);
        userActivityProvider.stopTracking(widget.bookId);
      }
    });
    super.dispose();
  }

  // Increment pages read when user progresses in the book
  void _incrementPagesRead() {
    final userActivityProvider =
        Provider.of<UserActivityProvider>(context, listen: false);
    userActivityProvider.incrementPagesRead();
  }

  Future<void> _openEpubReader() async {
    print('Initializing CosmosEpub...');

    // Initialize CosmosEpub if not already initialized
    // bool initialized = await CosmosEpub.initialize();
    // if (!initialized) {
    //   throw Exception('Failed to initialize CosmosEpub');
    // }
    print('Fetching book progress...');

    // Load the book progress
    BookProgressModel? bookProgress =
        CosmosEpub.getBookProgress(widget.bookTitle.toString());
    int starterChapter = bookProgress.currentChapterIndex ?? 0;
    bookProgress.currentPageIndex ?? 0;
    print('Opening asset book...');

    // Open the EPUB file
    await CosmosEpub.openLocalBook(
      localPath: widget.filePath,
      context: context,
      bookId: widget.bookTitle.toString(),
      starterChapter: starterChapter >= 0
          ? starterChapter
          : bookProgress.currentChapterIndex ?? 0,
      onPageFlip: (int currentPage, int totalPages) {
        CosmosEpub.setCurrentPageIndex(
            widget.bookTitle.toString(), currentPage);
        CosmosEpub.setCurrentChapterIndex(
            widget.bookTitle.toString(), bookProgress.currentChapterIndex ?? 0);

        print(currentPage);
        _incrementPagesRead();
      },
      onLastPage: (int lastPageIndex) {
        CustomToast.showToast(
            'You have reached the end of the book. Thank you for reading!');
        Snack('You have reached the end of the book. Thank you for reading!',
            context, Colors.black);
        print('We arrived to the last widget');
      },
    );

    //  lateFuture() {
    // setState(() {
    //   _readerFuture = _openEpubReader(context);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _readerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CupertinoActivityIndicator(
              radius: 15,
              color: Colors.black, // Adjust the radius as needed
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
