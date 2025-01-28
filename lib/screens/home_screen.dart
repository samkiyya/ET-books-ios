import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/screens/all_book_screen.dart';
import 'package:book_mobile/screens/audo_detail_screen.dart';
import 'package:book_mobile/screens/book_details_screen.dart';
import 'package:book_mobile/screens/custom_bottom_navigation_bar.dart';
import 'package:book_mobile/widgets/book_sharing_modal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/screens/custom_drawer_screen.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _iconAnimationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Fetch data via the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        homeProvider.fetchAllData();
      }
    });
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final homeProvider = Provider.of<HomeProvider>(context);

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu, size: width * 0.12),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Define breakpoints for responsiveness
                final double width = constraints.maxWidth;
                final bool isSmallScreen = width < 600;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 16.0,
                    vertical: isSmallScreen ? 6.0 : 12.0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() => _isSearching = false);
                      }
                      setState(() => _isSearching = true);
                      homeProvider.fetchSearchAndRecommendations(value);
                    },
                    onSubmitted: (value) {
                      if (value.isEmpty) {
                        setState(() => _isSearching = false);
                      }
                      setState(() => _isSearching = true);
                      homeProvider.fetchSearchAndRecommendations(value);
                    },
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.color1,
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      hintStyle: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      filled: true,
                      fillColor: AppColors.color2,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(isSmallScreen ? 8 : 12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 8.0 : 10.0,
                        horizontal: isSmallScreen ? 10.0 : 16.0,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        iconSize: isSmallScreen ? 20 : 24,
                        onPressed: () {
                          final query = _searchController.text.trim();
                          if (query.isNotEmpty) {
                            setState(() => _isSearching = true);
                            homeProvider.fetchSearchAndRecommendations(query);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, size: width * 0.09),
              onPressed: () {
                context.push('/notification');
              },
            ),
            Container(
              height: height * 0.08,
              width: width * 0.1,
              decoration: const BoxDecoration(
                color: AppColors.color2,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.person,
                    size: width * 0.09,
                  ),
                  onPressed: () {
                    context.push('/profile');
                  },
                ),
              ),
            ),
          ],
        ),
        drawer: SizedBox(
          width: width * .65,
          child: CustomDrawer(
            iconAnimationController: _iconAnimationController,
            onItemSelected: (label) {},
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(initialIndex: 2),
        body: homeProvider.isLoading
            ? const Center(
                child: LoadingWidget(),
              )
            : homeProvider.hasError
                ? const Center(
                    child: Text("An error occurred. Please try again."),
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(width * 0.0074),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Conditionally display Trending Books
                              if (homeProvider.trendingBooks.isNotEmpty) ...[
                                Text(
                                  "Trending Books",
                                  style: TextStyle(
                                      fontSize: width * 0.05,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.color3),
                                ),
                                SizedBox(height: height * 0.02),
                                SizedBox(
                                  height: height * 0.23,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        homeProvider.trendingBooks.length,
                                    itemBuilder: (context, index) {
                                      final book =
                                          homeProvider.trendingBooks[index];
                                      return GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BookDetailScreen(book: book),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              bottom: height * 0.003),
                                          child: Card(
                                            margin: EdgeInsets.symmetric(
                                                vertical: height * 0.009,
                                                horizontal: width * 0.03),
                                            elevation: 8,
                                            shadowColor: AppColors.color4,
                                            color: AppColors.color5,
                                            child: SizedBox(
                                              width: width * 0.3,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.network(
                                                    '${Network.baseUrl}/${book['imageFilePath']}',
                                                    fit: BoxFit.cover,
                                                    height: height * 0.08,
                                                    width: width * 0.2,
                                                    errorBuilder:
                                                        (BuildContext context,
                                                            Object error,
                                                            StackTrace?
                                                                stackTrace) {
                                                      return Icon(
                                                        Icons
                                                            .broken_image, // Alternative icon
                                                        size: width * 0.2,
                                                        color: Colors.grey,
                                                      );
                                                    },
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                        width * 0.0074),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          book['title'] ??
                                                              "No title available",
                                                          style: AppTextStyles
                                                              .heading2
                                                              .copyWith(
                                                                  color: AppColors
                                                                      .color3,
                                                                  fontSize:
                                                                      width *
                                                                          0.047),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        SizedBox(
                                                            height: height *
                                                                0.0045),
                                                        Text(
                                                          "By: ${book['author'] ?? "N/A"}",
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .color3
                                                                  .withOpacity(
                                                                      0.7)),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          "Price: ${book['price'] ?? 'N/A'} ETB",
                                                          style: const TextStyle(
                                                              color: AppColors
                                                                  .color2),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: height * 0.02),
                              ],

                              // All Books Section
                              Text(
                                "All Books",
                                style: TextStyle(
                                    fontSize: width * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.color3),
                              ),
                              SizedBox(height: height * 0.0045),
                              Container(
                                height: homeProvider.trendingBooks.isEmpty
                                    ? height *
                                        0.5 // Take the space of trending books
                                    : height * 0.3, // Normal height
                                color: AppColors.color1,
                                child: SingleChildScrollView(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: homeProvider.allBooks.length,
                                    itemBuilder: (context, index) {
                                      final book = homeProvider.allBooks[index];
                                      return GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BookDetailScreen(book: book),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: width * 0.03,
                                              right: width * 0.03,
                                              top: height * 0.003,
                                              bottom: height * 0.003),
                                          child: Card(
                                            color: AppColors.color5,
                                            margin: EdgeInsets.symmetric(
                                                vertical: height * 0.009,
                                                horizontal: width * 0.03),
                                            elevation: 8,
                                            shadowColor: AppColors.color4,
                                            child: ListTile(
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.network(
                                                  '${Network.baseUrl}/${book['imageFilePath']}',
                                                  width: width * 0.2,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object error,
                                                      StackTrace? stackTrace) {
                                                    return Icon(
                                                      Icons
                                                          .broken_image, // Alternative icon
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
                                                    style: AppTextStyles
                                                        .heading2
                                                        .copyWith(
                                                            color: AppColors
                                                                .color3,
                                                            fontSize:
                                                                width * 0.045),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'By: ${book['author']}',
                                                    style: TextStyle(
                                                        color: AppColors.color3
                                                            .withOpacity(0.7)),
                                                  ),
                                                  Text(
                                                    "Price: ${book['price']} ETB",
                                                    style: const TextStyle(
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
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AllBooksScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text("More",
                                      style:
                                          TextStyle(color: AppColors.color3)),
                                ),
                              ),
                              SizedBox(height: height * 0.01),

                              SingleChildScrollView(
                                child: SizedBox(
                                  height: height * 0.3,
                                  child: Card(
                                    color: AppColors.color2,
                                    child: Padding(
                                      padding: EdgeInsets.all(width * 0.02),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Section Header
                                          Text(
                                            "Audio Books",
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.color3,
                                            ),
                                          ),
                                          SizedBox(
                                              height: height *
                                                  0.01), // Space below header

                                          // Horizontal List of Audio Books
                                          Expanded(
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: homeProvider
                                                  .audioBooks.length,
                                              itemBuilder: (context, index) {
                                                final audioBook = homeProvider
                                                    .audioBooks[index];

                                                return GestureDetector(
                                                  onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          AudioDetailScreen(
                                                        audioBook: audioBook,
                                                      ),
                                                    ),
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        Card(
                                                          color: AppColors
                                                              .color3
                                                              .withValues(
                                                                  alpha: 0.65),
                                                          margin: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      width *
                                                                          0.02),
                                                          child: Container(
                                                            width: width * 0.3,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    width *
                                                                        0.02),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Audio Book Image
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  child: Image
                                                                      .network(
                                                                    '${Network.baseUrl}/${audioBook['imageFilePath']}',
                                                                    height:
                                                                        height *
                                                                            0.07,
                                                                    width: double
                                                                        .infinity,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorBuilder:
                                                                        (context,
                                                                            error,
                                                                            stackTrace) {
                                                                      return Icon(
                                                                        Icons
                                                                            .audiotrack,
                                                                        size: height *
                                                                            0.07,
                                                                        color: Colors
                                                                            .grey,
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.01),

                                                                // Audio Book Title
                                                                Text(
                                                                  audioBook[
                                                                          'title'] ??
                                                                      "No Title",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        width *
                                                                            0.035,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.005),

                                                                // Audio Book Author
                                                                Text(
                                                                  'By: ${audioBook['author'] ?? "Unknown Author"}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        width *
                                                                            0.03,
                                                                    color: AppColors
                                                                        .color4,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.005),

                                                                // Audio Book Author
                                                                Text(
                                                                  '${audioBook['audio_price'] ?? "N/A"} ETB',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        width *
                                                                            0.04,
                                                                    color: AppColors
                                                                        .color4,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                    height:
                                                                        height *
                                                                            0.005),

                                                                // Audio Book Author
                                                                Text(
                                                                  '${audioBook['audioCount'] ?? "N/A"} ${audioBook['audioCount'] > 1 ? "Episodes" : "Episode"}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        width *
                                                                            0.03,
                                                                    color: AppColors
                                                                        .color4,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Search Results Overlay
                      if (_isSearching)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Search Results',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white),
                                        onPressed: () {
                                          setState(() => _isSearching = false);
                                          _searchController.clear();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount:
                                        homeProvider.searchResults.length,
                                    itemBuilder: (context, index) {
                                      final book =
                                          homeProvider.searchResults[index];
                                      return Card(
                                        color: AppColors.color2,
                                        elevation: 8,
                                        margin: EdgeInsets.symmetric(
                                            vertical: height * 0.009,
                                            horizontal: width * 0.03),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: width * 0.03,
                                              vertical: height * 0.007),
                                          title: Text(
                                            book['title'],
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            book['description'],
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                          onTap: () {
                                            setState(
                                                () => _isSearching = false);
                                            _searchController.clear();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    BookDetailScreen(
                                                        book: book),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
