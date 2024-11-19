import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/screens/all_book_screen.dart';
import 'package:book_mobile/screens/details_screen.dart';
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
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: AppColors.color1,
        foregroundColor: AppColors.color6,
      ),
      drawer: SizedBox(
        width: 250,
        child: CustomDrawer(
          iconAnimationController: _iconAnimationController,
          onItemSelected: (label) {},
        ),
      ),
      body: homeProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : homeProvider.hasError
              ? const Center(
                  child: Text("An error occurred. Please try again."),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trending Books
                        const Text(
                          "Trending Books",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color3),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: homeProvider.trendingBooks.length,
                            itemBuilder: (context, index) {
                              final book = homeProvider.trendingBooks[index];
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
                                    width: 100,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          '${Network.baseUrl}/${book['imageFilePath']}',
                                          fit: BoxFit.cover,
                                          height: 100,
                                          width: 150,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  book['title'] ??
                                                      "No title available",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                "Price: ${book['price'] ?? 'N/A'}",
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
                        const SizedBox(height: 20),

                        // All Books
                        const Text(
                          "All Books",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color3),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 200,
                          color: AppColors.color1,
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: homeProvider.allBooks.length,
                              // itemCount: homeProvider.allBooks.length,
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
                                            style: const TextStyle(
                                                color: AppColors.color2),
                                          ),
                                          Text(
                                            book['title'],
                                            style: const TextStyle(
                                                color: AppColors.color2),
                                          ),
                                          Text(
                                            "Price: ${book['price']}",
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
                                  builder: (context) => const AllBooksScreen(),
                                ),
                              );
                            },
                            child: const Text("More",
                                style: TextStyle(color: AppColors.color3)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Audio Books
                        const Text(
                          "Audio Books",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color3),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          child: SizedBox(
                            height: 150,
                            child: Card(
                              color: AppColors.color2,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 6, right: 5, top: 10, bottom: 8),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: homeProvider.audioBooks.length,
                                  itemBuilder: (context, index) {
                                    final audioBook =
                                        homeProvider.audioBooks[index];
                                    print('Audio book in ui: $audioBook');

                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BookDetailScreen(book: audioBook),
                                        ),
                                      ),
                                      child: Card(
                                        child: Container(
                                          width: 150,
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Image.network(
                                              //   '${Network.baseUrl}/${audioBook['imageFilePath']}',
                                              //   fit: BoxFit.cover,
                                              //   height: 100,
                                              //   width: 150,
                                              // ),
                                              Text(
                                                  audioBook['bookTitle'] ??
                                                      "No title",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(audioBook['episode']),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
