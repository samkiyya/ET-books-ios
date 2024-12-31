import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/screens/author_screen.dart';
import 'package:book_mobile/screens/book_details_screen.dart';
import 'package:book_mobile/widgets/animated_search_field.dart';
import 'package:book_mobile/widgets/book_sharing_modal.dart';
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
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

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
          title: Text(
            "All Books",
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
        ),
        body: Padding(
          padding: EdgeInsets.all(width * 0.03),
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
                      customHint: _filterType == 'Book'
                          ? "Search by Title ..."
                          : "Search by author ...",
                    ),
                  ),
                  // Filter Buttons (Book / Author)
                ],
              ),
              SizedBox(height: height * 0.03),
              Padding(
                padding:
                    EdgeInsets.only(left: width * 0.03, right: width * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFilterButton(
                        context, "Search By Title", 'Book', width, height),
                    SizedBox(width: width * 0.03),
                    _buildFilterButton(
                        context, "Search By Author", 'Author', width, height),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),
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
                        color: AppColors.color5,
                        elevation: 8,
                        margin: EdgeInsets.symmetric(
                            vertical: height * 0.009, horizontal: width * 0.03),
                        shadowColor: AppColors.color4,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: width * 0.03,
                              vertical: height * 0.007),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              '${Network.baseUrl}/${book['imageFilePath']}',
                              width: width * 0.2,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Icon(
                                  Icons.broken_image, // Alternative icon
                                  size: width * 0.2,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                          title: Column(
                            children: [
                              Text(
                                book['title'],
                                style: AppTextStyles.heading2.copyWith(
                                    color: AppColors.color3,
                                    fontSize: width * 0.047),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'By: ${book['author']}',
                                style: TextStyle(
                                    color: AppColors.color3.withOpacity(0.7)),
                              ),
                              Text(
                                "Price: ${book['price']} ETB",
                                style: const TextStyle(color: AppColors.color2),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.share,
                                color: AppColors.color3),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => BookSharingModal(
                                  book: book,
                                  appDownloadLink:
                                      "${Network.appPlayStoreUrl}${Network.appPackageName}",
                                ),
                              );
                            },
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

  Widget _buildFilterButton(BuildContext context, String label, String type,
      double width, double height) {
    bool isActive = _filterType == type;

    return Container(
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [AppColors.color3, AppColors.color3],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [AppColors.color6, AppColors.color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _filterType = type;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.02, vertical: height * 0.01),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonText.copyWith(
              color: isActive ? AppColors.color4 : AppColors.color1,
              fontSize:
                  width * 0.038), // Change text color based on active state
        ),
      ),
    );
  }
}
