import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/order_model.dart';
import 'package:book_mobile/providers/content_access_provider.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:book_mobile/screens/author_screen.dart';
import 'package:book_mobile/screens/book_reader_screen.dart';
import 'package:book_mobile/screens/buy_book_screen.dart';
import 'package:book_mobile/screens/review_screen.dart';
import 'package:book_mobile/screens/view_order_status_screen.dart';
import 'package:book_mobile/widgets/animated_rating_button.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_mobile/services/device_info.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  String? deviceName;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  Map<String, dynamic> _deviceData = {};
  String _getDeviceType(BuildContext context) {
    return _deviceInfoService.detectDeviceType(context);
  }

  @override
  void initState() {
    super.initState();
    _getDeviceInfo();
    _fetchSubscriptionStatus();
  }

  Future<void> _getDeviceInfo() async {
    final deviceData = await _deviceInfoService.getDeviceData();
    setState(() {
      _deviceData = deviceData;
    });
    String brand = _deviceData['brand'] ?? 'Unknown';
    String board = _deviceData['board'] ?? 'Unknown';
    String model = _deviceData['model'] ?? 'Unknown';
    String deviceId = _deviceData['id'] ?? 'Unknown';
    String deviceType = _getDeviceType(context);
    deviceName =
        "Brand: $brand Board: $board Model: $model deviceId: $deviceId DeviceType: $deviceType";
    // print('device information is: $deviceName');
  }

  Future<Map<String, dynamic>?> fetchOrderForCurrentUser() async {
    final statusProvider =
        Provider.of<OrderStatusProvider>(context, listen: false);

    try {
      await statusProvider.fetchOrders(deviceName);
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
      // debugPrint('Error fetching order: $e');
    }

    return null;
  }

Future<void> _fetchSubscriptionStatus() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('userId');
  if (userId != null) {
    final accessProvider = Provider.of<AccessProvider>(context, listen: false);
    await accessProvider.fetchSubscriptionStatus(userId, "books");
    if (context.mounted) {
      setState(() {}); // Trigger a rebuild after fetching the subscription status
    }
  }
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

    await accessProvider.fetchSubscriptionStatus(userId,"books");
    if (context.mounted) {
    setState(() {});  // This ensures the UI rebuilds after fetching the subscription status
  }
    final bool isSubscribed = accessProvider.hasReachedLimitAndApproved;

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
          isSubscribed ) {
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
      context
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
                          fit: BoxFit.contain,
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
                                    // print(
                                    //     'Author id: ${widget.book['author_id']}');

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
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'By: ',
                                          style: TextStyle(
                                              color: AppColors.color3
                                                  .withOpacity(0.7)),
                                        ),
                                        TextSpan(
                                          text: '${widget.book['author']}',
                                          style: TextStyle(
                                            color: AppColors.color3
                                                .withOpacity(0.9),
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                            book: widget.book,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Tooltip(
                                      message: "View Reviews",
                                      child: _buildDetailRow(
                                        "${widget.book['rateCount']}",
                                        " reviews",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                              isSubscribed: isSubscribed );
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
                  SizedBox(height: height * 0.03),
                ],
              ),
            ),
          ],
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
