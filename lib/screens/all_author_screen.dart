import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/bottom_bar_item_model.dart';
import 'package:book_mobile/providers/author_provider.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar_controller.dart';
import 'package:book_mobile/widgets/authors_card.dart';
import 'package:book_mobile/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AuthorsScreen extends StatefulWidget {
  const AuthorsScreen({super.key});

  @override
  State<AuthorsScreen> createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 3);

  // Default to "home"
  final List<String> _routes = [
    '/announcements',
    '/subscription-tier',
    '/home',
    '/authors',
    '/profile',
  ];

  void _navigateToScreen(BuildContext context, int index) {
    if (index >= 0 && index < _routes.length) {
      context.push(_routes[index]);
    } else {
      context.go('/home');
    }
    setState(() {
      _controller.jumpTo(index);
    });
  }

  final List<BottomBarItem> _bottomBarItems = [
    BottomBarItem(
      activeItem: Icon(Icons.announcement, color: AppColors.color1),
      inActiveItem: Icon(Icons.announcement_outlined, color: AppColors.color2),
      itemLabel: 'News',
    ),
    BottomBarItem(
      activeItem: Icon(Icons.subscriptions, color: AppColors.color1),
      inActiveItem: Icon(Icons.subscriptions_outlined, color: AppColors.color2),
      itemLabel: 'Subscribe',
    ),
    BottomBarItem(
      activeItem: Icon(Icons.home, color: AppColors.color1),
      inActiveItem: Icon(Icons.home_outlined, color: AppColors.color2),
      itemLabel: 'Home',
    ),
    BottomBarItem(
      activeItem: Icon(
        Icons.people,
        color: AppColors.color1,
      ),
      inActiveItem: Icon(Icons.person_outline, color: AppColors.color2),
      itemLabel: 'Authors',
    ),
    BottomBarItem(
      activeItem: Icon(Icons.person, color: AppColors.color1),
      inActiveItem: Icon(Icons.person_outline, color: AppColors.color2),
      itemLabel: 'Profile',
    ),
  ];
  bool isDataFetched = false;

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
    double height = AppSizes.screenHeight(context);
    final authorProvider = Provider.of<AuthorProvider>(context);
    final isLoading = authorProvider.isLoading;
    final author = authorProvider.author;
    final errorMessage = authorProvider.errorMessage;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Authors', style: AppTextStyles.heading2),
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          centerTitle: true,
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return AnimatedNotchBottomBar(
              // color:AppColors.color5,
              notchBottomBarController: _controller,
              onTap: (index) => _navigateToScreen(context, index),
              bottomBarItems: _bottomBarItems,
              showShadow: true,
              showLabel: true,
              itemLabelStyle: TextStyle(color: Colors.black, fontSize: 12),
              showBlurBottomBar: true,
              blurOpacity: 0.6,
              blurFilterX: 10.0,
              blurFilterY: 10.0,
              kIconSize: 30,
              kBottomRadius: 10,
              showTopRadius: true,
              showBottomRadius: true,
              topMargin: 15,
              durationInMilliSeconds: 300,
              bottomBarHeight: 70,
              elevation: 8,
            );
          },
        ),
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
                        return Column(
                          children: [
                            AuthorCard(
                              author: author,
                            ),
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
                                            .toggleFollow(author.id.toString())
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
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
