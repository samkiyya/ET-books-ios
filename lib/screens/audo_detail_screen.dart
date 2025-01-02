import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/bottom_bar_item_model.dart';
import 'package:book_mobile/models/order_model.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar_controller.dart';
import 'package:flutter/material.dart';

import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/screens/buy_audio_screen.dart';
import 'package:book_mobile/screens/book_reader_screen.dart';
import 'package:book_mobile/screens/audio_player_screen.dart';
import 'package:book_mobile/screens/view_order_status_screen.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:provider/provider.dart';

class AudioDetailScreen extends StatefulWidget {
  final Map<String, dynamic> audioBook;

  const AudioDetailScreen({super.key, required this.audioBook});

  @override
  State<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends State<AudioDetailScreen> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 3); // Default to "home"

  final List<String> _routes = [
    '/announcements',
    '/subscription-tier',
    '/home',
    '/self'
    '/authors',
  ];
  void _navigateToScreen(BuildContext context, int index) {
     if (index == 3) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AudioDetailScreen(audioBook: widget.audioBook),
      ),
    );
  } else if (index >= 0 && index < _routes.length) {
      Navigator.pushNamed(context, _routes[index]);
    }
     else {
      Navigator.pushNamed(context, '/home');
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
      activeItem: Icon(Icons.audio_file, color: AppColors.color1),
      inActiveItem: Icon(Icons.audio_file_outlined, color: AppColors.color2),
      itemLabel: 'Self',
    ),
  ];
  Future<Map<String, dynamic>?> fetchOrderForCurrentUser() async {
    final statusProvider =
        Provider.of<OrderStatusProvider>(context, listen: false);

    try {
      await statusProvider.fetchOrders();
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
          orderBook: {},
          orderUser: {},
        ),
      );

      if (order.id != -1) {
        return {
          "orderId": order.id,
          "audioBookId": order.orderBook['id'],
          "status": order.status,
          "type": order.type, // "audio", "pdf", or "both"
        };
      }
    } catch (e) {
      debugPrint('Error fetching order: $e');
    }

    return null;
  }

  void _handleButtonPress(BuildContext context) async {
    final order = await fetchOrderForCurrentUser();

    if (order != null) {
      if (order['status'] == 'PENDING') {
        // Redirect to Order Status Screen
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrderStatusScreen()),
          );
        }
      } else if (order['status'] == 'APPROVED') {
        final type = order['type'];

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
        }
        // else if (type == 'pdf') {
        //   // Redirect to Book Reader Screen
        //   if (context.mounted) {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => BookReaderScreen(
        //           pdfPath:
        //               '${Network.baseUrl}/${widget.audioBook['pdfFilePath']}',
        //           bookTitle: widget.audioBook['title'],
        //         ),
        //       ),
        //     );
        //   }
        // }
        else if (type == 'both') {
          // Show both "Play" and "Read" buttons
          _showBothButtons(context);
        } else {
          // Redirect to BuyAudioScreen if type is null or invalid
          _redirectToBuyAudioScreen(context);
        }
      }
    } else {
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
                            fit: BoxFit.cover,
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
                      child: FutureBuilder<Map<String, dynamic>?>(
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
                            final buttonText = _determineButtonText(order);
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

  String _determineButtonText(Map<String, dynamic>? order) {
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
