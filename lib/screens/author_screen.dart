import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/screens/book_details_screen.dart';
import 'package:book_mobile/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/providers/author_provider.dart';

class AuthorScreen extends StatefulWidget {
  final String authorId;

  const AuthorScreen({super.key, required this.authorId});

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  bool isDataFetched = false;

  @override
  void initState() {
    super.initState();
    // Fetch data once the screen is loaded and after navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authorProvider =
          Provider.of<AuthorProvider>(context, listen: false);

      // Trigger data fetch only once after the screen is loaded
      authorProvider.fetchAuthorById(widget.authorId).then((_) {
        setState(() {
          isDataFetched = true; // Set flag to true once data is fetched
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final authorProvider = Provider.of<AuthorProvider>(context);
    final author = authorProvider.author;
    final errorMessage = authorProvider.errorMessage;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Author Details', style: AppTextStyles.heading1),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color2,
        ),
        body: !isDataFetched
            ? const Center(
                child: LoadingWidget(),) // Only show when data is not fetched
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(errorMessage,
                        style: const TextStyle(color: Colors.red)))
                : author == null
                    ? const Center(child: Text('Failed to load author details'))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Profile Section
                              Column(
                                children: [
                                  // Profile Picture
                                  Center(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(width * 0.2),
                                      child: Image.network(
                                        author['image'] != null
                                            ? '${Network.baseUrl}/${author['image']}'
                                            : 'https://xsgames.co/randomusers/avatar.php?g=pixel',
                                        width: width * 0.4,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object error,
                                            StackTrace? stackTrace) {
                                          return Icon(
                                            Icons
                                                .broken_image, // Alternative icon
                                            size: width * 0.4,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16), // Correct spacing
                                  // Author Info
                                  Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          author['name'],
                                          style: AppTextStyles.heading2,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          author['bio'] ??
                                              'No biography available.',
                                          style: AppTextStyles.bodyText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Books Section with Glass Effect
                              if (author['books'] != null &&
                                  author['books'].isNotEmpty) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    backgroundBlendMode: BlendMode.overlay,
                                  ),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Glassmorphism "Some of My Books" Text
                                      Text(
                                        'Some of My Books',
                                        style: AppTextStyles.heading2.copyWith(
                                          color: AppColors.color3,
                                          fontWeight: FontWeight.bold,
                                          fontSize: width * 0.05,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: height*0.25,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: author['books'].length,
                                          itemBuilder: (context, index) {
                                            final book = author['books'][index];
                                            return AnimatedOpacity(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              opacity:
                                                  1.0, // Adjust opacity while scrolling
                                              child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookDetailScreen(
                                                            book: book),
                                                  ),
                                                ),
                                                child: Card(
                                                  margin: const EdgeInsets.only(
                                                      right: 16),
                                                  child: SizedBox(
                                                    width: width*0.35,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          book['image'] != null
                                                              ? Image.network(
                                                                  '${Network.baseUrl}/${book['image']}',
                                                                  height: 100,
                                                                  width: 120,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              :  Icon(
                                                                  Icons.book,
                                                                  size: width*0.27,
                                                                  color: AppColors
                                                                      .color1,
                                                                ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            book['title'],
                                                            style: AppTextStyles
                                                                .bodyText
                                                                .copyWith(
                                                                    color: AppColors
                                                                        .color4,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          const SizedBox(
                                                              height: 4),
                                                          Text(
                                                            'ETB ${book['price']}',
                                                            style:
                                                                const TextStyle(
                                                              color: AppColors
                                                                  .color4,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Text(
                                                            'Published: ${book['publicationYear']}',
                                                            style: AppTextStyles
                                                                .bodyText
                                                                .copyWith(
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
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),

                              // Stats Section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    '${author['books'].length} Books',
                                    style: AppTextStyles.bodyText,
                                  ),
                                  Text(
                                    '${author['followerCount'] ?? 'No'} Followers',
                                    style: AppTextStyles.bodyText,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Follow Button
                              Center(
                                child: ElevatedButton(
                                  onPressed: authorProvider.isLoading
                                      ? null
                                      : () {
                                          // Disable button while updating follow status
                                          setState(() {
                                            authorProvider.isLoading = true;
                                          });
                                          authorProvider
                                              .toggleFollow(widget.authorId)
                                              .then((_) {
                                            setState(() {
                                              // Enable the button once the action is completed
                                              authorProvider.isLoading = false;
                                            });
                                          });
                                        },
                                  child: authorProvider.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          authorProvider.isFollowing
                                              ? 'Unfollow'
                                              : 'Follow',
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
