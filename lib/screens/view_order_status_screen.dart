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
    final orderProvider =
        Provider.of<OrderStatusProvider>(context, listen: false);
    orderProvider.fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderStatusProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Order Status'),
        ),
        body: orderProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderProvider.errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      orderProvider.errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
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
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text(
                                'Order ID: ${order.id}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
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
                                        const SizedBox(height: 8),
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
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
