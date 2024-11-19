import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/screens/buy_book_screen.dart';
import 'package:book_mobile/screens/home_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_nav_bar.dart';
import 'package:flutter/material.dart';

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
        // HomeScreen
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
      // case 1:
      //   // LastReadScreen
      //   Navigator.push(context, MaterialPageRoute(builder: (context) => LastReadScreen()));
      //   break;
      // case 2:
      //   // ProfileScreen
      //   Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
      //   break;
      default:
        // Default to HomeScreen
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
        break;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['title']),
      ),
      body: Stack(
        children: [
          // Background gradient
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
          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Image Card
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
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Details Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: AppColors.color1,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Title: ${widget.book['title']}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.color3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildDetailRow("Author", widget.book['author']),
                          _buildDetailRow("Publication Year",
                              widget.book['publicationYear']),
                          _buildDetailRow("Language", widget.book['language']),
                          _buildDetailRow("Price", widget.book['price']),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: _buildDetailRow(
                                  "Rating",
                                  "${widget.book['rating']} (${widget.book['rateCount']} reviews)",
                                ),
                              ),
                              const VerticalDivider(
                                width: 20,
                                thickness: 8,
                                color: Colors.white, // You can adjust the color
                              ),
                              const Expanded(
                                child: Text('|'),
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
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: CustomButton(
                    text: 'BUY',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BuyBookScreen(
                                  book: widget.book, key: UniqueKey())));
                    },
                    backgroundColor: AppColors.color2,
                    borderColor: Colors.transparent,
                    textStyle: AppTextStyles.buttonText,
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
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}
