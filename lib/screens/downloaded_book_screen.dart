// import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/services/book_service.dart';
import 'package:bookreader/services/file_services.dart';
import 'package:bookreader/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DownloadedBooksScreen extends StatefulWidget {
  const DownloadedBooksScreen({super.key});

  @override
  State<DownloadedBooksScreen> createState() => _DownloadedBooksScreenState();
}

class _DownloadedBooksScreenState extends State<DownloadedBooksScreen> {
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final books = await BookService.getDownloadedBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading books: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBook(int bookId, String bookName) async {
    final deleted = await FileService.deleteBook(bookId, bookName);
    if (deleted) {
      setState(() {
        _books.removeWhere((book) => book['id'] == bookId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully.')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete the book.')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, int bookId, String bookTitle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $bookTitle'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteBook(bookId, bookTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Downloaded Books',
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodyText,
                    ),
                  )
                : _books.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No downloaded books available.',
                              style: AppTextStyles.bodyText,
                            ),
                            CustomButton(
                              onPressed: () {
                                context.go('/my-books');
                              },
                              text: 'Go to your Books',
                              borderColor: AppColors.color3,
                              textStyle: AppTextStyles.buttonText.copyWith(
                                color: AppColors.color3,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _books.length,
                        itemBuilder: (context, index) {
                          final book = _books[index];
                          return Padding(
                            padding: EdgeInsets.only(
                                left: width * 0.03,
                                right: width * 0.03,
                                top: height * 0.003,
                                bottom: height * 0.003),
                            child: Card(
                              margin: EdgeInsets.symmetric(
                                  vertical: height * 0.009,
                                  horizontal: width * 0.03),
                              elevation: 8,
                              shadowColor: AppColors.color4,
                              color: AppColors.color5,
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: width * 0.03,
                                    vertical: height * 0.007),
                                leading: Icon(Icons.book,
                                    color: AppColors.color1,
                                    size: width * 0.07),
                                title: Text(book['title'],
                                    style: AppTextStyles.bodyText),
                                onTap: () async {
                                  await BookService.openBook(
                                    context,
                                    book['id'],
                                    book['title'],
                                    book['extension'],
                                  );
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(
                                      context,
                                      book['id'],
                                      book['title'],
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
