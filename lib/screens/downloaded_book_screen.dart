import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/services/book_service.dart';
import 'package:flutter/material.dart';

class DownloadedBooksScreen extends StatelessWidget {
  const DownloadedBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Downloaded Books'),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: BookService.getDownloadedBooks(),
          builder: (context, snapshot) {
            final books = snapshot.data ?? [];
            print('downloaded book detail: $books');
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(book['title'], style: AppTextStyles.bodyText),
                  onTap: () async {
                    await BookService.openBook(
                        context, book['id'], book['title']);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
