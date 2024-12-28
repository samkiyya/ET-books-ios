import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/author_provider.dart';
import 'package:book_mobile/widgets/authors_card.dart';
import 'package:book_mobile/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthorsScreen extends StatelessWidget {
  const AuthorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authorProvider = Provider.of<AuthorProvider>(context, listen: false);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Authors', style: AppTextStyles.heading2),
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: authorProvider.fetchAuthors(), // Call fetchAuthors once
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingWidget());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (authorProvider.authors.isEmpty) {
              return const Center(child: Text('No authors found.'));
            }

            return ListView.builder(
              itemCount: authorProvider.authors.length,
              itemBuilder: (context, index) {
                final author = authorProvider.authors[index];
                return AuthorCard(author: author);
              },
            );
          },
        ),
      ),
    );
  }
}
