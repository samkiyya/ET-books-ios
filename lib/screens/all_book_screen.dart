import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllBooksScreen extends StatefulWidget {
  const AllBooksScreen({super.key});

  @override
  State<AllBooksScreen> createState() => _AllBooksScreenState();
}

class _AllBooksScreenState extends State<AllBooksScreen> {
  String _searchQuery = '';
  String _filterType =
      'Book'; // Track if the user is filtering by Book or Author

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    // Filter the books based on the search query and selected filter type
    var filteredBooks = homeProvider.allBooks.where((book) {
      if (_filterType == 'Book') {
        return book['title']!
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      } else if (_filterType == 'Author') {
        return book['author']!
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Books"),
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Box
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: "Search",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter Buttons (Book / Author)
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterType = 'Book';
                        });
                      },
                      child: const Text("Books"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterType = 'Author';
                        });
                      },
                      child: const Text("Authors"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Scrollable Book List
            Expanded(
              child: ListView.builder(
                itemCount: filteredBooks.length,
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(book: book),
                      ),
                    ),
                    child: Card(
                      child: ListTile(
                        leading: Image.network(
                          '${Network.baseUrl}/${book['imageFilePath']}',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(book['title']),
                        subtitle: Text("Price: ${book['price']}"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
