import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/author_provider.dart';
import 'package:book_mobile/screens/custom_bottom_navigation_bar.dart';
import 'package:book_mobile/widgets/authors_card.dart';
import 'package:book_mobile/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  bool isDataFetched = false;
final Map<String, bool> _loadingStates = {};
  // Fetch authors inside initState
  @override
  void initState() {
    super.initState();
    // Fetch authors when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authorProvider =
          Provider.of<AuthorProvider>(context, listen: false);
      authorProvider.fetchAuthors().then((_) {
        setState(() {
          isDataFetched = true; // Set flag to true once data is fetched
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    final authorProvider = Provider.of<AuthorProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Authors', style: AppTextStyles.heading2),
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          centerTitle: true,
        ),
        bottomNavigationBar: CustomNavigationBar(initialIndex: 3),
        body: !isDataFetched
            ? const Center(
                child: LoadingWidget(),
              ) // Show loading while fetching
            : authorProvider.authors.isEmpty
                ? const Center(
                    child: Text(
                      'No authors found.',
                      style: AppTextStyles.bodyText,
                    ),
                  ) // No authors found
                : RefreshIndicator(
                    onRefresh: () => authorProvider.fetchAuthors(),
                    child: ListView.builder(
                      itemCount: authorProvider.authors.length,
                      itemBuilder: (context, index) {
                        final author = authorProvider.authors[index];
                                        final isAuthorLoading = _loadingStates[author.id.toString()] ?? false;

                        return Column(
                          children: [
                            AuthorCard(
                              author: author,
                            ),
                            Center(
                              child: ElevatedButton(
                                onPressed: isAuthorLoading
                                    ? null
                                    : () {
                                        // Disable button while updating follow status
                                        setState(() {
                                          _loadingStates[author.id.toString()] = true;
                                        });
                                        authorProvider
                                            .toggleFollowAuthors(
                                                author.id.toString())
                                            .then((_) {
                                          setState(() {
                                            // Enable the button once the action is completed
                                            _loadingStates[author.id.toString()] = false;
                                          });
                                        });
                                      },
                                child: isAuthorLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text(
                                        author.isFollowing
                                            ? 'Unfollow'
                                            : 'Follow',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: width*0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
