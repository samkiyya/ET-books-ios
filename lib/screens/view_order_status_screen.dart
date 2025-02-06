import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/order_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/services/device_info.dart';

class OrderStatusScreen extends StatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  @override
  void initState() {
    super.initState();
    getUserDeviceInfo();
    
  }

  Future<void> getUserDeviceInfo() async {
    await _getDeviceInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final orderProvider =
            Provider.of<OrderStatusProvider>(context, listen: false);
         orderProvider.fetchOrders(deviceName);
      }
    });

//     final orderProvider =Provider.of<OrderStatusProvider>(context, listen: false);
//     await orderProvider.fetchOrders(deviceName);
//     // setState(() {
//     //   _isLoading = false;
//     // });
  }

  String? deviceName;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();
  Map<String, dynamic> _deviceData = {};
  String _getDeviceType(BuildContext context) {
    return _deviceInfoService.detectDeviceType(context);
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
    print('device information is: $deviceName');
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
                                'Order No: ${order.orderNumber}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.035),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Your Order Status: ${order.status}'),
                                  Text(
                                    'Order Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.createdAt)}',
                                  ),
                                  Text(
                                      'Ordered Book Price: ${order.price} ETB'),
                                  if (order.orderBook.isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: height * 0.02),
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
          onPressed: orderProvider.isLoading
              ? null
              : () => orderProvider.fetchOrders(deviceName),
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
