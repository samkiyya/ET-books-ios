import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/home_provider.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:book_mobile/screens/audio_episodes_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:book_mobile/services/book_service.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _isLoading = true;
  String _selectedCategory = 'PDF';
  final Map<int, double> _downloadProgress = {};
  final Set<int> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final orderProvider =
        Provider.of<OrderStatusProvider>(context, listen: false);
    await orderProvider.fetchOrders();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final orderProvider = Provider.of<OrderStatusProvider>(context);
    final audioBookProvider = Provider.of<HomeProvider>(context);

    // Filter orders based on the selected category
    final filteredOrders = orderProvider.orders.where((order) {
      final isApproved = order.status.toUpperCase() == 'APPROVED';
      // print('is approved: $isApproved');
      if (_selectedCategory == 'PDF') {
        return (isApproved && order.type.toLowerCase() == 'pdf') ||
            (isApproved && order.type.toLowerCase() == 'both');
      } else if (_selectedCategory == 'Audio') {
        return (isApproved && (order.type.toLowerCase() == 'audio'||order.type.toLowerCase()=='audiobook')) ||
            (isApproved && order.type.toLowerCase() == 'both');
      }
      return false;
    }).toList();
    print('filteredOrders: $filteredOrders');

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Available Books',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.color6,
            ),
          ),
          centerTitle: true,
          foregroundColor: AppColors.color6,
          backgroundColor: AppColors.color1,
          actions: [
            IconButton(
              icon: const Icon(Icons.download_done),
              onPressed: () {
                context.push('/downloaded');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Buttons to switch categories
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'PDF';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory == 'PDF'
                          ? AppColors.color3
                          : AppColors.color2,
                    ),
                    child: const Text('PDF Books'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'Audio';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory == 'Audio'
                          ? AppColors.color3
                          : AppColors.color2,
                    ),
                    child: const Text('Audio Books'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.color3),
                      ),
                    )
                  : filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No approved orders found.',
                              style: AppTextStyles.bodyText,
                            ),
                            SizedBox(height: height * 0.01081),
                            CustomButton(
                              onPressed: () {
                                context.push('/allEbook');
                              },
                              text: 'Go to Books',
                              textStyle: AppTextStyles.buttonText.copyWith(
                                color: AppColors.color3,
                              ),
                              borderColor: AppColors.color3,
                            ),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            final book = order.orderBook;

                            return Padding(
                              padding: EdgeInsets.only(
                                  left: width * 0.03,
                                  right: width * 0.03,
                                  top: height * 0.003,
                                  bottom: height * 0.003),
                              child: Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: height * 0.009,
                                    horizontal: width * 0.03),
                                elevation: 8,
                                shadowColor: AppColors.color4,
                                color: AppColors.color5,
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: width * 0.03,
                                      vertical: height * 0.007),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      "${Network.baseUrl}/${book['imageFilePath']}",
                                      width: width * 0.2,
                                      fit: BoxFit.cover,
                                      errorBuilder: (BuildContext context,
                                          Object error,
                                          StackTrace? stackTrace) {
                                        return Icon(
                                          Icons.broken_image,
                                          size: width * 0.2,
                                          color: Colors.grey,
                                        );
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    book['title'],
                                    style: AppTextStyles.bodyText,
                                  ),
                                  trailing: _downloadingIds.contains(book['id'])
                                      ? SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              CircularProgressIndicator(
                                                value: _downloadProgress[
                                                    book['id']],
                                                valueColor:
                                                    const AlwaysStoppedAnimation(
                                                        AppColors.color3),
                                              ),
                                              Text(
                                                "${(_downloadProgress[book['id']]! * 100).toInt()}%",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.color3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : _selectedCategory == 'PDF'
                                          ? FutureBuilder<bool>(
                                              future:
                                                  BookService.isBookDownloaded(
                                                      book['id'],
                                                      book['title']),
                                              builder: (context, snapshot) {
                                                final isDownloaded =
                                                    snapshot.data ?? false;
                                                return isDownloaded
                                                    ? IconButton(
                                                        icon: const Icon(
                                                          Icons.read_more,
                                                          color:
                                                              AppColors.color3,
                                                        ),
                                                        onPressed: () async {
                                                          final down = await BookService
                                                              .getFileExtension(
                                                                  '${Network.baseUrl}/${book['pdfFilePath']}');
                                                          await BookService
                                                              .openBook(
                                                                  context,
                                                                  book['id'],
                                                                  book['title'],
                                                                  down);
                                                        },
                                                      )
                                                    : IconButton(
                                                        icon: const Icon(
                                                          Icons.download,
                                                          color:
                                                              AppColors.color3,
                                                        ),
                                                        onPressed: () async {
                                                          setState(() {
                                                            _downloadingIds.add(
                                                                book['id']);
                                                            _downloadProgress[
                                                                    book[
                                                                        'id']] =
                                                                0.0;
                                                          });
                                                          await BookService
                                                              .downloadAndOpenBook(
                                                            book['id'],
                                                            "${Network.baseUrl}/${book['pdfFilePath']}",
                                                            book['title'],
                                                            context,
                                                            (progress) {
                                                              setState(() {
                                                                _downloadProgress[
                                                                        book[
                                                                            'id']] =
                                                                    progress;
                                                              });
                                                            },
                                                          );
                                                          setState(() {
                                                            _downloadingIds
                                                                .remove(
                                                                    book['id']);
                                                          });
                                                        },
                                                      );
                                              },
                                            )
                                          : IconButton(
                                              icon: const Icon(
                                                Icons.audio_file,
                                                color: AppColors.color3,
                                              ),
                                              onPressed: () {
                                                final audioBook =
                                                    audioBookProvider.audioBooks
                                                        .firstWhere(
                                                  (audioBook) =>
                                                      audioBook['id'] ==
                                                      book['id'],
                                                  orElse: () => null,
                                                );

                                                if (audioBook == null) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Audio book not found."),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                print('Audio Book: $audioBook');
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        AudioEpisodeScreen(
                                                            audioBook:
                                                                audioBook),
                                                  ),
                                                );
                                              },
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
    );
  }
}
