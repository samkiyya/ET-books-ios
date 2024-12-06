import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final orderProvider =
            Provider.of<OrderStatusProvider>(context, listen: false);
        orderProvider.fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final orderProvider = Provider.of<OrderStatusProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Order Status',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.color6,
              )),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
        ),
        body: orderProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : orderProvider.errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      orderProvider.errorMessage,
                      style:
                          TextStyle(color: Colors.red, fontSize: width * 0.045),
                    ),
                  )
                : orderProvider.orders.isEmpty
                    ? const Center(child: Text('No orders found.'))
                    : ListView.builder(
                        itemCount: orderProvider.orders.length,
                        itemBuilder: (context, index) {
                          final order = orderProvider.orders[index];
                          return Card(
                            elevation: 5,
                            margin: EdgeInsets.symmetric(
                                vertical: height * 0.01,
                                horizontal: width * 0.025),
                            child: ListTile(
                              title: Text(
                                'Order ID: ${order.id}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.045),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status: ${order.status}'),
                                  Text(
                                    'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)}',
                                  ),
                                  Text('Price: ${order.price} ETB'),
                                  if (order.orderBook.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: height * 0.03),
                                        Text(
                                          'Book Title: ${order.orderBook['title']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                            'Author: ${order.orderBook['author']}'),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
        floatingActionButton: FloatingActionButton(
          onPressed: orderProvider.isLoading ? null : orderProvider.fetchOrders,
          child: orderProvider.isLoading
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
