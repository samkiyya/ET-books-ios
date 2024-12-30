import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/order_model.dart';
import 'package:book_mobile/providers/content_access_provider.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:book_mobile/screens/author_screen.dart';
import 'package:book_mobile/screens/book_reader_screen.dart';
import 'package:book_mobile/screens/buy_book_screen.dart';
import 'package:book_mobile/screens/home_screen.dart';
import 'package:book_mobile/screens/view_order_status_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_nav_bar.dart';
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
  int _currentIndex = 0;

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/filter-book');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
    }
    setState(() {
      _currentIndex = index;
    });
  }

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
                            _buildDetailRow(
                                "Price", "${widget.book['price']} ETB"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildDetailRow(
                                    "⭐ ",
                                    "${widget.book['rating']}  (${widget.book['rateCount']} reviews)",
                                  ),
                                ),
                                const VerticalDivider(
                                  width: 1,
                                  thickness: 1,
                                ),
                                Expanded(
                                  child: _buildDetailRow(
                                      "Pages", widget.book['pages']),
                                )
                              ],
                            ),
                            _buildDetailRow("Status", widget.book['status']),
                            _buildDetailRow(
                                "Description", widget.book['description']),
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
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => _navigateToScreen(context, index),
        ),
      ),
    );
  }

  String _determineButtonText(Map<String, dynamic>? order,
      {bool? isSubscribed}) {
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
