import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/screens/book_details_screen.dart';
import 'package:book_mobile/widgets/animated_search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllBooksScreen extends StatefulWidget {
  const AllBooksScreen({super.key});

  @override
  State<AllBooksScreen> createState() => _AllBooksScreenState();
}

class _AllBooksScreenState extends State<AllBooksScreen> {
  String _searchQuery = '';
  String _filterType = 'Book';

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

    return SafeArea(
      child: Scaffold(
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
                    child: AnimatedSearchTextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  // Filter Buttons (Book / Author)
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.color1,
                          AppColors.color2
                        ], // Gradient colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.color5
                              .withOpacity(0.5), // Shadow for 3D effect
                          offset: const Offset(3, 3), // Position of shadow
                          blurRadius: 6, // Blur for soft edges
                        ),
                        BoxShadow(
                          color: AppColors.color3
                              .withOpacity(0.5), // Light shadow for highlight
                          offset: const Offset(-2, -2),
                          blurRadius: 4,
                        ),
                      ],
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterType = 'Book';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .transparent, // Make background transparent to use gradient
                        shadowColor:
                            Colors.transparent, // Disable default shadow
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12), // Button size
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Search By Books",
                        style: AppTextStyles.buttonText
                            .copyWith(color: AppColors.color3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Second Button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.color2,
                          AppColors.color1,
                        ], // Gradient colors
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.color5
                              .withOpacity(0.5), // Shadow for 3D effect
                          offset: const Offset(3, 3),
                          blurRadius: 6,
                        ),
                        BoxShadow(
                          color: AppColors.color5
                              .withOpacity(0.5), // Light shadow for highlight
                          offset: const Offset(-2, -2),
                          blurRadius: 4,
                        ),
                      ],
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterType = 'Author';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Search By Authors",
                        style: AppTextStyles.buttonText
                            .copyWith(color: AppColors.color3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                        color: AppColors.color1,
                        child: ListTile(
                          leading: Image.network(
                            '${Network.baseUrl}/${book['imageFilePath']}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Column(
                            children: [
                              Text(
                                book['author'],
                                style: const TextStyle(color: AppColors.color2),
                              ),
                              Text(
                                book['title'],
                                style: const TextStyle(color: AppColors.color2),
                              ),
                              Text(
                                "Price: ${book['price']} ETB",
                                style: const TextStyle(color: AppColors.color3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
