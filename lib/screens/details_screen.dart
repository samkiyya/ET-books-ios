import 'package:flutter/material.dart';

class BookDetailScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(book['imageFilePath']),
            SizedBox(height: 8),
            Text("Title: ${book['title']}", style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text("Author: ${book['author']}"),
            SizedBox(height: 8),
            Text("Description: ${book['description']}"),
            SizedBox(height: 8),
            Text("Publication Year: ${book['publicationYear']}"),
            SizedBox(height: 8),
            Text("Language: ${book['language']}"),
            SizedBox(height: 8),
            Text("Price: ${book['price']}"),
            SizedBox(height: 8),
            Text("Rating: ${book['rating']} (${book['rateCount']} reviews)"),
            SizedBox(height: 8),
            Text("Pages: ${book['pages']}"),
            SizedBox(height: 8),
            Text("Status: ${book['status']}"),
            // Add any additional fields here
          ],
        ),
      ),
    );
  }
}
