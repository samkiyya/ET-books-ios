import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/screens/all_book_screen.dart';
import 'package:book_mobile/screens/audo_detail_screen.dart';
import 'package:book_mobile/screens/book_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/screens/custom_drawer_screen.dart';
import 'package:book_mobile/providers/home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _iconAnimationController;

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
          title: Text(
            "Home",
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.color6,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, size: width * 0.09),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
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
                    Navigator.pushNamed(context, '/profile');
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
        body: homeProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : homeProvider.hasError
                ? const Center(
                    child: Text("An error occurred. Please try again."),
                  )
                : SingleChildScrollView(
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
                              height: height * 0.2,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: homeProvider.trendingBooks.length,
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
                                    child: Card(
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
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  width * 0.0074),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    book['title'] ??
                                                        "No title available",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "Price: ${book['price'] ?? 'N/A'} ETB",
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
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
                                physics: const NeverScrollableScrollPhysics(),
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
                                    child: Card(
                                      color: AppColors.color1,
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.network(
                                            '${Network.baseUrl}/${book['imageFilePath']}',
                                            width: width * 0.2,
                                            fit: BoxFit.cover,
                                            errorBuilder: (BuildContext context,
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
                                              book['author'],
                                              style: const TextStyle(
                                                  color: AppColors.color2),
                                            ),
                                            Text(
                                              book['title'],
                                              style: const TextStyle(
                                                  color: AppColors.color2),
                                            ),
                                            Text(
                                              "Price: ${book['price']} ETB",
                                              style: const TextStyle(
                                                  color: AppColors.color3),
                                            ),
                                          ],
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
                                  style: TextStyle(color: AppColors.color3)),
                            ),
                          ),
                          SizedBox(height: height * 0.01),

                          SingleChildScrollView(
                            child: SizedBox(
                              height: height *
                                  0.25, // Total height for the entire card
                              child: Card(
                                color: AppColors.color2,
                                child: Padding(
                                  padding: EdgeInsets.all(width * 0.0074),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Audio Books Section Header
                                      Text(
                                        "Audio Books",
                                        style: TextStyle(
                                          fontSize: width * 0.06,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.color3,
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),

                                      // Horizontal List of Audio Books
                                      Expanded(
                                        // Ensures ListView takes up remaining space
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              homeProvider.audioBooks.length,
                                          itemBuilder: (context, index) {
                                            final audioBook =
                                                homeProvider.audioBooks[index];

                                            return GestureDetector(
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AudioDetailScreen(
                                                          audioBook: audioBook),
                                                ),
                                              ),
                                              child: Card(
                                                child: Container(
                                                  width: width * 0.3,
                                                  padding: EdgeInsets.all(
                                                      width * 0.03),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Audio Book Title
                                                      Expanded(
                                                        child: Text(
                                                          audioBook[
                                                                  'bookTitle'] ??
                                                              "No title",
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),

                                                      // Audio Book Episode
                                                      Flexible(
                                                        child: Text(audioBook[
                                                            'episode']),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
