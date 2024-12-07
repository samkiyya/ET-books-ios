// import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/screens/audo_detail_screen.dart';
import 'package:book_mobile/widgets/animated_search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    // Filter the books based on the search query and selected filter type
    var filteredBooks = homeProvider.audioBooks.where((book) {
      if (_filterType == 'bookTitle') {
        return book['bookTitle']!
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      } else if (_filterType == 'episode') {
        return book['episode']!
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
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
                            _filterType = 'bookTitle';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .transparent, // Make background transparent to use gradient
                          shadowColor:
                              Colors.transparent, // Disable default shadow
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                              vertical: height * 0.01), // Button size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Search By bookTitle",
                          style: AppTextStyles.buttonText.copyWith(
                              color: AppColors.color3, fontSize: width * 0.04),
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
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
                            _filterType = 'episode';
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                              vertical: height * 0.01),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Search By episode",
                          style: AppTextStyles.buttonText.copyWith(
                              color: AppColors.color3, fontSize: width * 0.04),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.03),
              // Scrollable Book List
              homeProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
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
                                  color: AppColors.color1,
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.audio_file,
                                      color: AppColors.color3,
                                      size: width * 0.13,
                                    ),
                                    //Image.network(
                                    //   '${Network.baseUrl}/${book['imageFilePath']}',
                                    //   width: 50,
                                    //   height: 50,
                                    //   fit: BoxFit.cover,
                                    // ),
                                    title: Column(
                                      children: [
                                        Text(
                                          book['bookTitle'],
                                          style: const TextStyle(
                                              color: AppColors.color2),
                                        ),
                                        Text(
                                          book['episode'],
                                          style: const TextStyle(
                                              color: AppColors.color2),
                                        ),
                                        // Text(
                                        //   "Price: ${book['price']} ETB",
                                        //   style: const TextStyle(
                                        //       color: AppColors.color3),
                                        // ),
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
