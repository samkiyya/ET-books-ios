import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/screens/audo_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/widgets/animated_search_field.dart';

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
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.03),
              // Filter Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFilterButton(
                      context, "Search By Title", 'bookTitle', width, height),
                  SizedBox(width: width * 0.03),
                  _buildFilterButton(
                      context, "Search By Episode", 'episode', width, height),
                ],
              ),
              SizedBox(height: height * 0.03),
              // List of Audio Books
              homeProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : homeProvider.hasError
                      ? const Center(
                          child: Text("An error occurred. Please try again."),
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
                                        AudioDetailScreen(audioBook: book),
                                  ),
                                ),
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: height * 0.01),
                                  color: AppColors.color5,
                                  child: ListTile(
                                    leading: _buildBookImage(
                                        '${Network.baseUrl}/${book['imageFilePath']}'),
                                    title: Text(
                                      book['title'] ?? "Unknown Title",
                                      style: AppTextStyles.bodyText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Author: ${book['author'] ?? 'Unknown'}",
                                          style: AppTextStyles.bodyText,
                                        ),
                                        Text(
                                          "Price: ${book['audio_price'] ?? 'Free'} ETB",
                                          style: AppTextStyles.bodyText,
                                        ),
                                        Text(
                                          "Episodes: ${book['audioCount'] ?? '0'}",
                                          style: AppTextStyles.bodyText,
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

  Widget _buildBookImage(String? imageUrl) {
    return imageUrl != null && imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.audiotrack,
                color: Colors.grey,
              );
            },
          )
        : const Icon(
            Icons.audiotrack,
            color: AppColors.color3,
            size: 50,
          );
  }

  Widget _buildFilterButton(BuildContext context, String label, String type,
      double width, double height) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.color1, AppColors.color2],
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
              horizontal: width * 0.04, vertical: height * 0.015),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.buttonText
              .copyWith(color: AppColors.color6, fontSize: width * 0.04),
        ),
      ),
    );
  }
}
