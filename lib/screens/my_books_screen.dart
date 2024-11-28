import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:book_mobile/services/book_service.dart';
import 'package:provider/provider.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _isLoading = true; // State to track loading status

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final orderProvider =
        Provider.of<OrderStatusProvider>(context, listen: false);
    await orderProvider.fetchOrders(); // Fetch orders asynchronously
    setState(() {
      _isLoading = false; // Set loading to false when fetch is complete
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderStatusProvider>(context);

    // Filter only approved orders
    final approvedOrders = orderProvider.orders
        .where((order) => order.status == 'APPROVED')
        .toList();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Available Books'),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_done),
              onPressed: () {
                Navigator.pushNamed(context, '/downloaded');
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : approvedOrders.isEmpty
                ? const Center(child: Text('No approved books available.'))
                : ListView.builder(
                    itemCount: approvedOrders.length,
                    itemBuilder: (context, index) {
                      final order = approvedOrders[index];
                      final book =
                          order.orderBook; // Extract book details from order
                      return ListTile(
                        leading: Image.network(
                            "${Network.baseUrl}/${book['imageFilePath']}"),
                        title: Text(book['title'],
                            style: AppTextStyles.bodyText), // Book title
                        trailing: FutureBuilder<bool>(
                          future: BookService.isBookDownloaded(order.id),
                          builder: (context, snapshot) {
                            final isDownloaded = snapshot.data ?? false;
                            return isDownloaded
                                ? IconButton(
                                    icon: const Icon(Icons.read_more,
                                        color: AppColors.color3),
                                    onPressed: () async {
                                      await BookService.openBook(
                                          context, order.id, book['title']);
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.download,
                                        color: AppColors.color3),
                                    onPressed: () async {
                                      await BookService.downloadBook(
                                          order.id,
                                          "${Network.baseUrl}/${book['pdfFilePath']}",
                                          context);
                                      setState(() {});
                                    },
                                  );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
