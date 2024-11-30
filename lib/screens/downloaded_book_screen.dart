// import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/services/book_service.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class DownloadedBooksScreen extends StatelessWidget {
  const DownloadedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // double width = AppSizes.screenWidth(context);
    // double height = AppSizes.screenHeight(context);
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
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: BookService.getDownloadedBooks(),
          builder: (context, snapshot) {
            // Handle loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }
            // Handle error state
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading books: ${snapshot.error}',
                  style: AppTextStyles.bodyText,
                ),
              );
            }
            final books = snapshot.data ?? [];
            if (books.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No downloaded books available.',
                      style: AppTextStyles.bodyText,
                    ),
                    CustomButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/my-books');
                      },
                      text: 'Go to your Books',
                      borderColor: AppColors.color3,
                      textStyle: AppTextStyles.buttonText.copyWith(
                        color: AppColors.color3,
                      ),
                    ),
                  ],
                ),
              );
            }
            print('downloaded book detail: $books');
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  color: AppColors.color1,
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text(book['title'], style: AppTextStyles.bodyText),
                    onTap: () async {
                      await BookService.openBook(
                          context, book['id'], book['title']);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
