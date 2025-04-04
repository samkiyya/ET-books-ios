import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/screens/audo_detail_screen.dart';
import 'package:bookreader/widgets/book_sharing_modal.dart';
import 'package:bookreader/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/providers/home_provider.dart';
import 'package:bookreader/widgets/animated_search_field.dart';

class AllAudioScreen extends StatefulWidget {
  const AllAudioScreen({super.key});

  @override
  State<AllAudioScreen> createState() => _AllAudioScreenState();
}

class _AllAudioScreenState extends State<AllAudioScreen> {
  String _searchQuery = '';
  String _filterType = 'bookTitle';

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    // Filter books based on search query and filter type
    var filteredBooks = homeProvider.audioBooks.where((book) {
      if (_filterType == 'bookTitle') {
        return book['title']!
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      } else if (_filterType == 'episode') {
        return book['audios'] != null &&
            (book['audios'] as List).any((audio) =>
                audio['episode'] != null &&
                audio['episode']
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()));
      }
      return false;
    }).toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "All Audio Books",
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
        ),
        body: filteredBooks.isEmpty
            ? Center(
                child: Text(
                  "No Audio book available.",
                  style: TextStyle(
                      color: AppColors.color3,
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold),
                ),
              )
            : Padding(
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
                            customHint: _filterType == 'bookTitle'
                                ? 'search by title'
                                : "Search by episode",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.03),
                    // Filter Buttons
                    Padding(
                      padding: EdgeInsets.only(
                          left: width * 0.03, right: width * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFilterButton(context, "Search By Title",
                              'bookTitle', width, height),
                          SizedBox(width: width * 0.03),
                          _buildFilterButton(context, "Search By Episode",
                              'episode', width, height),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    // List of Audio Books
                    homeProvider.isLoading
                        ? const Center(
                            child: LoadingWidget(),
                          )
                        : homeProvider.hasError
                            ? const Center(
                                child: Text(
                                  "An error occurred. Please try again.",
                                  style: TextStyle(color: AppColors.color3),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: filteredBooks.length,
                                  itemBuilder: (context, index) {
                                    final book = filteredBooks[index];
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AudioDetailScreen(
                                                  audioBook: book),
                                        ),
                                      ),
                                      child: Card(
                                        margin: EdgeInsets.symmetric(
                                            vertical: height * 0.01),
                                        color: AppColors.color5,
                                        child: ListTile(
                                          leading: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.network(
                                              '${Network.baseUrl}/${book['imageFilePath']}',
                                              width: width * 0.2,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                return Icon(
                                                  Icons.broken_image,
                                                  size: width * 0.2,
                                                  color: Colors.grey,
                                                );
                                              },
                                            ),
                                          ),
                                          title: Text(
                                            book['title'] ?? "Unknown Title",
                                            style: AppTextStyles.heading2
                                                .copyWith(
                                                    color: AppColors.color3,
                                                    fontSize: width * 0.045),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Author: ${book['author'] ?? 'Unknown'}",
                                                style: AppTextStyles.bodyText
                                                    .copyWith(
                                                        color: AppColors.color3
                                                            .withOpacity(0.8)),
                                              ),
                                              Text(
                                                "Episodes: ${book['audioCount'] ?? '0'}",
                                                style: AppTextStyles.bodyText
                                                    .copyWith(
                                                        color: AppColors.color3
                                                            .withOpacity(0.8)),
                                              ),
                                              Text(
                                                "Price: ${book['audio_price'] ?? 'Free'} ETB",
                                                style: AppTextStyles.bodyText
                                                    .copyWith(
                                                        color:
                                                            AppColors.color2),
                                              ),
                                            ],
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.share,
                                                color: AppColors.color3),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (_) =>
                                                    BookSharingModal(
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
