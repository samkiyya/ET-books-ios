import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/models/order_model.dart';
import 'package:bookreader/providers/content_access_provider.dart';
import 'package:flutter/material.dart';

import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/widgets/custom_button.dart';
import 'package:bookreader/screens/buy_audio_screen.dart';
import 'package:bookreader/screens/book_reader_screen.dart';
import 'package:bookreader/screens/audio_player_screen.dart';
import 'package:bookreader/screens/view_order_status_screen.dart';
import 'package:bookreader/providers/order_status_provider.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/services/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioDetailScreen extends StatefulWidget {
  final Map<String, dynamic> audioBook;

  const AudioDetailScreen({super.key, required this.audioBook});

  @override
  State<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends State<AudioDetailScreen> {
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

      // Ensure orders list is not empty before calling firstWhere
      if (statusProvider.orders.isNotEmpty) {
        final order = statusProvider.orders.firstWhere(
          (order) => order.orderBook['id'] == widget.audioBook['id'],
          orElse: () => Order(
            id: -1, // Default ID for a non-existent order
            price: '0',
            bankName: '',
            type: '',
            transactionNumber: '',
            status: '',
            createdAt: DateTime.now(),
            orderBook: {}, // Ensure this is an empty Map
            orderUser: {}, // Ensure this is an empty Map
          ),
        );

        if (order.id != -1 && order.orderBook.isNotEmpty) {
          return {
            "orderId": order.id,
            "audioBookId": order.orderBook['id'],
            "status": order.status,
            "type": order.type, // "audio", "pdf", or "both"
          };
        }
      }
    } catch (e) {
      // debugPrint('Error fetching order: $e');
    }

    return null;
  }

   Future<bool> _fetchSubscriptionStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    if (userId != null) {
      final accessProvider =
          Provider.of<AccessProvider>(context, listen: false);
      await accessProvider.fetchSubscriptionStatus(userId, 'audio_books',widget.audioBook['id']);
      print(
          "isSubscribed value in fetch substat: ${accessProvider.hasReachedLimitAndApproved}");
      return accessProvider.hasReachedLimitAndApproved;
    }
    return false;
  }


  void _handleButtonPress(BuildContext context) async {
    final currentBookId = widget.audioBook['id'];
    final order = await fetchOrderForCurrentUser();
    final isSubscribed = await _fetchSubscriptionStatus();
    print("isSubscribed value in handle button press: ${isSubscribed}");
SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
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

 if (context.mounted) {
      setState(
          () {}); // This ensures the UI rebuilds after fetching the subscription status
    }
    if (order != null) {
      final orderedBookId = order['bookId'];
      if ((order['status'] == 'PENDING' && orderedBookId == currentBookId)&&!isSubscribed) {
        // Redirect to Order Status Screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderStatusScreen()),
          );
        }
      } else if ((order['status'] == 'APPROVED' &&
              orderedBookId == currentBookId) ||
          isSubscribed ) {
        final type = isSubscribed?'audio':order['type'];

        if (type == 'audio') {
          // Redirect to Audio Player Screen
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AudioPlayerScreen(
                  audioBook: widget.audioBook,
                ),
              ),
            );
          }
        } else if (type == 'both') {
          // Show both "Play" and "Read" buttons
          _showBothButtons(context);
        } else {
          // Redirect to BuyAudioScreen if type is null or invalid
          _redirectToBuyAudioScreen(context);
        }
      }
    } else if(isSubscribed){
      if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AudioPlayerScreen(
                  audioBook: widget.audioBook,
                ),
              ),
            );
          }
    }
    
     else {
      // Redirect to BuyAudioScreen if no order exists
      _redirectToBuyAudioScreen(context);
    }
  }

  void _redirectToBuyAudioScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyAudioScreen(audioBook: widget.audioBook),
      ),
    );
  }

  void _showBothButtons(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                text: 'Play Audio',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioPlayerScreen(
                        audioBook: widget.audioBook,
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.color2,
                borderColor: AppColors.color3,
                textStyle: AppTextStyles.buttonText,
              ),
              const SizedBox(height: 16.0),
              CustomButton(
                text: 'Read PDF',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookReaderScreen(
                        bookId: widget.audioBook['id'],
                        filePath:
                            '${Network.baseUrl}/${widget.audioBook['pdfFilePath']}',
                        bookTitle: widget.audioBook['title'],
                      ),
                    ),
                  );
                },
                backgroundColor: AppColors.color1,
                borderColor: AppColors.color3,
                textStyle: AppTextStyles.buttonText,
              ),
            ],
          ),
        );
      },
    );
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
                  : "N/A",
              style: const TextStyle(
                color: AppColors.color3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final accessProvider = Provider.of<AccessProvider>(context);
    // final reviewProvider = Provider.of<ReviewProvider>(context);

    final isSubscribed = accessProvider.hasReachedLimitAndApproved;
    print('isSubscribed: $isSubscribed');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.audioBook['title'],
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
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
              child: Padding(
                padding: EdgeInsets.all(width * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            '${Network.baseUrl}/${widget.audioBook['imageFilePath']}',
                            width: width * 0.8,
                            height: width * 0.4,
                            fit: BoxFit.contain,
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                size: width * 0.2,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    // Audio Book Details Card
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
                                "Title: ${widget.audioBook['title']}",
                                style: TextStyle(
                                  fontSize: width * 0.06,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.color3,
                                ),
                              ),
                              SizedBox(height: height * 0.01),
                              _buildDetailRow(
                                  "Author", widget.audioBook['author']),
                              _buildDetailRow("Publication Year",
                                  widget.audioBook['publicationYear']),
                              _buildDetailRow(
                                  "Language", widget.audioBook['language']),
                              _buildDetailRow(
                                  "Price", "${widget.audioBook['price']} ETB"),
                              _buildDetailRow("Number of Episodes",
                                  widget.audioBook['audioCount']),
                              _buildDetailRow("Description",
                                  widget.audioBook['description']),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                      child: Consumer<AccessProvider>(
                      builder: (context, accessProvider, child){
final isSubscribed =
                            accessProvider.hasReachedLimitAndApproved;
                        print("isSubscribed value in Consumer: $isSubscribed");

                        return FutureBuilder<Map<String, dynamic>?>(
                        future: fetchOrderForCurrentUser(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.color3),
                            ));
                          } else if (snapshot.hasError) {
                            return const Text('Error loading data');
                          } else {
                            final order = snapshot.data;
                            final buttonText = _determineButtonText(order,
                                isSubscribed: isSubscribed);
                            return CustomButton(
                              text: buttonText,
                              onPressed: () => _handleButtonPress(context),
                              backgroundColor: AppColors.color2,
                              borderColor: AppColors.color3,
                              textStyle: AppTextStyles.buttonText,
                            );
                          }
                        },
                      );}),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _determineButtonText(Map<String, dynamic>? order,
      {required bool isSubscribed}) {
        if(isSubscribed){
          return 'Play Audio';
        }
    if (order != null) {
      if (order['status'] == 'PENDING') {
        return 'Check Order Status';
      } else if (order['status'] == 'APPROVED') {
        final type = order['type'];
        if (type == 'audio') {
          return 'Play Audio';
        } else if (type == 'pdf') {
          return 'Read PDF';
        } else if (type == 'both') {
          return 'Choose Action';
        }
      }
    }
    return 'BUY';
  }
}
