import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/bottom_bar_item_model.dart';
import 'package:book_mobile/models/order_model.dart';
import 'package:book_mobile/providers/content_access_provider.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:book_mobile/providers/review_provider.dart';
import 'package:book_mobile/screens/author_screen.dart';
import 'package:book_mobile/screens/book_reader_screen.dart';
import 'package:book_mobile/screens/buy_book_screen.dart';
import 'package:book_mobile/screens/home_screen.dart';
import 'package:book_mobile/screens/review_screen.dart';
import 'package:book_mobile/screens/view_order_status_screen.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar_controller.dart';
import 'package:book_mobile/widgets/animated_rating_button.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 3);

  final List<String> _routes = [
    '/announcements',
    '/subscription-tier',
    '/home',
    '/self',
    '/authors',
  ];
  void _navigateToScreen(BuildContext context, int index) {
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailScreen(book: widget.book),
        ),
      );
    } else if (index >= 0 && index < _routes.length) {
      Navigator.pushNamed(context, _routes[index]);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
    setState(() {
      _controller.jumpTo(index);
    });
  }

  final List<BottomBarItem> _bottomBarItems = [
    BottomBarItem(
      activeItem: Icon(Icons.announcement, color: AppColors.color1),
      inActiveItem: Icon(Icons.announcement_outlined, color: AppColors.color2),
      itemLabel: 'Announcements',
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
    // BottomBarItem(
    //   activeItem: Icon(Icons.person, color: AppColors.color1),
    //   inActiveItem: Icon(Icons.person_outline, color: AppColors.color2),
    //   itemLabel: 'Profile',
    // ),
    BottomBarItem(
      inActiveItem: Icon(Icons.library_books, color: AppColors.color1),
      activeItem: Icon(Icons.book_outlined, color: AppColors.color2),
      itemLabel: 'ebook Detail',
    )
  ];

  Future<Map<String, dynamic>?> fetchOrderForCurrentUser() async {
    final statusProvider =
        Provider.of<OrderStatusProvider>(context, listen: false);

    try {
      await statusProvider.fetchOrders();
      final Order order = statusProvider.orders.firstWhere(
        (order) => order.orderBook['id'] == widget.book['id'],
        orElse: () => Order(
          id: -1, // Default ID for a non-existent order
          price: '0',
          bankName: '',
          type: '',
          transactionNumber: '',
          status: '',
          createdAt: DateTime.now(),
          orderBook: {},
          orderUser: {},
        ),
      );

      if (order.id != -1) {
        return {
          "orderId": order.id,
          "bookId": order.orderBook['id'],
          "status": order.status,
        };
      }
    } catch (e) {
      debugPrint('Error fetching order: $e');
    }

    return null;
  }

  void _handleButtonPress(BuildContext context) async {
    final currentBookId = widget.book['id'];
    final order = await fetchOrderForCurrentUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    final accessProvider = Provider.of<AccessProvider>(context, listen: false);
    if (userId == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Log in to continue'),
          content: Text('Please log in to continue to buy this book.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    await accessProvider.fetchSubscriptionStatus(userId);
    final bool? isSubscribed = accessProvider.hasReachedLimitAndApproved;

    if (order != null) {
      final orderedBookId = order['bookId'];

      if (order['status'] == 'PENDING' && orderedBookId == currentBookId) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderStatusScreen()),
          );
        }
      } else if ((order['status'] == 'APPROVED' &&
              orderedBookId == currentBookId) ||
          isSubscribed == true) {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookReaderScreen(
                  bookId: widget.book['id'],
                  filePath: '${Network.baseUrl}/${widget.book['pdfFilePath']}',
                  bookTitle: widget.book['title']),
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyBookScreen(book: widget.book),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final accessProvider = Provider.of<AccessProvider>(
      context,
    );
    // final reviewProvider = Provider.of<ReviewProvider>(context);

    final isSubscribed = accessProvider.hasReachedLimitAndApproved;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.book['title'],
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.color6,
              )),
          centerTitle: true,
          foregroundColor: AppColors.color2,
          backgroundColor: AppColors.color1,
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.color2,
                    AppColors.color1,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: height * 0.009),
                  Center(
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          '${Network.baseUrl}/${widget.book['imageFilePath']}',
                          height: height * 0.22,
                          width: width * 0.7,
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
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: Card(
                      color: AppColors.color1,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(width * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Title: ${widget.book['title']}",
                              style: TextStyle(
                                fontSize: width * 0.06,
                                fontWeight: FontWeight.bold,
                                color: AppColors.color3,
                              ),
                            ),
                            SizedBox(height: height * 0.01),

                            // _buildDetailRow("Author", widget.book['author']),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    print(
                                        'Author id: ${widget.book['author_id']}');

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AuthorScreen(
                                          authorId: (widget.book['author_id']
                                              .toString()),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'By: ${widget.book['author']}',
                                    style: TextStyle(
                                        color:
                                            AppColors.color3.withOpacity(0.7)),
                                  ),
                                ),
                              ],
                            ),

                            _buildDetailRow("Publication Year",
                                widget.book['publicationYear']),
                            _buildDetailRow(
                                "Language", widget.book['language']),
                            _buildDetailRow("Pages", widget.book['pages']),
                            _buildDetailRow(
                                "Price", "${widget.book['price']} ETB"),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildDetailRow(
                                    "⭐ ",
                                    "${widget.book['rating']}",
                                  ),
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStateProperty.all(
                                          AppColors.color2),
                                      elevation: WidgetStateProperty.all(5),
                                      shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      )),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BookReviewsScreen(
                                                  bookId: widget.book['id'],
                                                  book:widget.book,),
                                                  
                                        ),
                                      );
                                    },
                                    child: Tooltip(
                                      message:
                                          "View Reviews", // Hint text when hovered or long-pressed
                                      child: _buildDetailRow(
                                        "${widget.book['rateCount']}",
                                        " reviews",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            _buildDetailRow("Status", widget.book['status']),
                            _buildDetailRow(
                                "Description", widget.book['description']),

                            AnimatedRatingButton(
                              bookId: widget.book['id'],
                              initialRating: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: fetchOrderForCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.color3),
                            ),
                          ); // Show loading
                        } else if (snapshot.hasError) {
                          return const Text('Error loading data');
                        } else {
                          final order = snapshot.data;
                          final buttonText = _determineButtonText(order,
                              isSubscribed: isSubscribed ?? false);
                          return CustomButton(
                            text: buttonText,
                            onPressed: () => _handleButtonPress(context),
                            backgroundColor: AppColors.color2,
                            borderColor: AppColors.color3,
                            textStyle: AppTextStyles.buttonText,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return AnimatedNotchBottomBar(
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
      ),
    );
  }

  String _determineButtonText(Map<String, dynamic>? order,
      {required bool isSubscribed}) {
    if (order != null) {
      if (order['status'] == 'PENDING') {
        return 'Check Order Status';
      } else if (order['status'] == 'APPROVED' || isSubscribed == true) {
        return 'Read Book';
      }
    }
    return 'BUY';
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.color3,
            ),
          ),
          Expanded(
            child: Text(
              value != null && value.toString().isNotEmpty
                  ? value.toString()
                  : "N/A ETB",
              style: const TextStyle(
                color: AppColors.color3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
