import 'dart:io';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/constants/payment_methods.dart';
import 'package:book_mobile/providers/purchase_order_provider.dart';
import 'package:book_mobile/providers/user_activity_provider.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:book_mobile/widgets/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_mobile/services/device_info.dart';

class BuyBookScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BuyBookScreen({super.key, required this.book});

  @override
  State<BuyBookScreen> createState() => _BuyBookScreenState();
}

class _BuyBookScreenState extends State<BuyBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _transactionController = TextEditingController();
  File? _receiptImage;
  String selectedBank = '';
  String _selectedType = 'PDF';

  late final List<String> bankLists = PaymentMethods.banks;

  String? _validateField(String key, String value) {
    if (value.isEmpty) {
      return 'Please enter your $key';
    }

    return null; // No errors
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
    //print('device information is: $deviceName');
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<PurchaseOrderProvider>(context);
    final UserActivityTracker tracker = UserActivityTracker();

    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(width * 0.03),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: height * 0.02),
                // Book title
                Center(
                  child: Text("Buy Your Book",
                      style: AppTextStyles.heading2
                          .copyWith(color: AppColors.color2)),
                ),

                SizedBox(height: height * 0.04),
                Card(
                  color: AppColors.color2,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.03),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image on the left
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            '${Network.baseUrl}/${widget.book['imageFilePath']}',
                            height: height * 0.13,
                            width: width * 0.25,
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
                        SizedBox(
                            width:
                                width * 0.09), // Space between image and text
                        // Text on the right
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book['title'],
                                style: AppTextStyles.heading2,
                              ),
                              SizedBox(
                                  height: height *
                                      0.0045), // Space between title and rating
                              Text(
                                '${widget.book['rating']} ⭐ | ${widget.book['sold']} peoples bought',
                                style: AppTextStyles.bodyText,
                              ),
                              SizedBox(height: height * 0.0045),
                              Text(
                                'Price: ETB ${widget.book['price']}',
                                style: AppTextStyles.bodyText,
                              ),
                              SizedBox(height: height * 0.0045),
                              Text(
                                  'Publication Year ${widget.book['publicationYear']}',
                                  style: AppTextStyles.bodyText),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Stack(
                  children: [
                    Opacity(
                      opacity: orderProvider.isLoading ? 0.5 : 1,
                      child: Form(
                        key: _formKey,
                        child: Card(
                          color: Colors.transparent, // Transparent card color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5, // Adds subtle shadow for depth
                          child: Padding(
                            padding: EdgeInsets.all(width * 0.0148),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Transaction Number
                                CustomTextField(
                                  label: 'Transaction Number',
                                  controller: _transactionController,
                                  labelText: "Enter Transaction Number",
                                  hintColor: AppColors.color4,
                                  fillColor: AppColors.color3,
                                  validator: (value) => _validateField(
                                      'Transaction Number', value!),
                                ),
                                SizedBox(height: height * 0.0045),

                                CoustomSearchableDropdown(
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedBank = value!;
                                    });
                                  },
                                  data: bankLists,
                                  hintText: 'Select Bank Name',
                                ),
                                SizedBox(height: height * 0.02),

                                // Row for Image Upload
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () async {
                                          await orderProvider.pickImage();
                                          setState(() {
                                            _receiptImage = orderProvider
                                                .receiptImage; // Sync with provider
                                          });
                                        },
                                        icon: const Icon(Icons.image,
                                            color: AppColors.color3),
                                        label: Text(
                                          _receiptImage == null
                                              ? 'Upload Receipt Image'
                                              : 'Change Image',
                                          style:
                                              AppTextStyles.buttonText.copyWith(
                                            color: AppColors.color3,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: width * 0.03),

                                    // Display Image or Placeholder
                                    Flexible(
                                      child: orderProvider.receiptImage == null
                                          ? const Text(
                                              'No receipt image selected',
                                              style: TextStyle(
                                                  color: AppColors.color3),
                                            )
                                          : orderProvider.isImage
                                              ? Image.file(
                                                  orderProvider.receiptImage!,
                                                  fit: BoxFit.cover,
                                                  height: height * 0.09,
                                                )
                                              : Row(
                                                  children: [
                                                    Icon(
                                                        Icons.insert_drive_file,
                                                        size: 40,
                                                        color: Colors
                                                            .white), // File icon
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                          orderProvider
                                                              .receiptImage!
                                                              .path
                                                              .split('/')
                                                              .last, // Displaying just the filename
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ],
                                                ),
                                    ),
                                  ],
                                ),
                                if (_receiptImage == null)
                                  const Text(
                                    'Please upload a receipt image.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                // Dropdown for Book Type
                                SizedBox(height: height * 0.03),
                                widget.book['hasAudioBook']
                                    ? Text(
                                        'Select Book Type',
                                        style: AppTextStyles.bodyText,
                                      )
                                    : SizedBox.shrink(),
                                widget.book['hasAudioBook']
                                    ? DropdownButtonFormField<String>(
                                        value: _selectedType,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'audio',
                                            child: Text('AudioBook'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'PDF',
                                            child: Text('E-Book'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Both',
                                            child: Text('Both'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedType = value!;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          filled: true,
                                          fillColor: AppColors.color2,
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),

                orderProvider.isLoading || orderProvider.isUploading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : CustomButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          if (_receiptImage == null) {
                            // Show an error message under the image upload section
                            return;
                          }
                          await _getDeviceInfo();

                          await orderProvider.purchaseBook(
                            id: widget.book['id'].toString(),
                            transactionNumber: _transactionController.text,
                            bankName: selectedBank,
                            // bookType: widget.book['type'].toString(),
                            bookType: _selectedType,
                            deviceInfo: deviceName!,
                            context: context,
                          );

                          final actionDetails = {
                            "bookId": widget.book['id'].toString(),
                            "title": widget.book['title'].toString(),
                            "price": widget.book['price'].toString(),
                          };
                          SharedPreferences pref =
                              await SharedPreferences.getInstance();
                          int? userId =
                              int.tryParse(pref.getString('userId').toString());
                          await tracker.trackUserActivity(
                            userId: userId!,
                            actionType: "BOOK_PURCHASE",
                            actionDetails: actionDetails,
                          );

                          if (context.mounted) {
                            orderProvider.showResponseDialog(
                              context,
                              orderProvider.errorMessage.isNotEmpty
                                  ? orderProvider.errorMessage
                                  : orderProvider.successMessage,
                              "Close",
                              orderProvider.errorMessage.isEmpty,
                            );
                          }
                        },
                        text: 'Submit Order',
                        textStyle: AppTextStyles.buttonText,
                        backgroundColor: AppColors.color2,
                        borderColor: AppColors.color3,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
