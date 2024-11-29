import 'dart:io';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/purchase_order_provider.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyAudioScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BuyAudioScreen({super.key, required this.book});

  @override
  State<BuyAudioScreen> createState() => _BuyAudioScreenState();
}

class _BuyAudioScreenState extends State<BuyAudioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _transactionController = TextEditingController();
  final _bankNameController = TextEditingController();
  File? _receiptImage;

  String? _validateField(String key, String value) {
    if (value.isEmpty) {
      return 'Please enter your $key';
    }

    return null; // No errors
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<PurchaseOrderProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Book title
                Text("Buy Your Audio Book",
                    style: AppTextStyles.heading1
                        .copyWith(color: AppColors.color2)),

                const SizedBox(height: 20),
                Card(
                  color: AppColors.color2,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image on the left
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            '${Network.baseUrl}/${widget.book['imageFilePath']}',
                            height: 150,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                            width: 30), // Space between image and text
                        // Text on the right
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.book['title'],
                                style: AppTextStyles.heading2,
                              ),
                              const SizedBox(
                                  height: 10), // Space between title and rating
                              Text(
                                '${widget.book['rating']} ⭐ | ${widget.book['sold']} peoples bought',
                                style: AppTextStyles.bodyText,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Price: ETB ${widget.book['price']}',
                                style: AppTextStyles.bodyText,
                              ),
                              const SizedBox(height: 10),
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
                const SizedBox(height: 20),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Transaction Number
                                CustomTextField(
                                  label: 'Transaction Number',
                                  controller: _transactionController,
                                  labelText: "Enter Transaction Number",
                                  validator: (value) => _validateField(
                                      'Transaction Number', value!),
                                ),
                                const SizedBox(height: 10),

                                // Bank Name
                                CustomTextField(
                                  label: 'Bank Name',
                                  controller: _bankNameController,
                                  hintText: "Enter Bank Name",
                                  validator: (value) =>
                                      _validateField('Bank Name', value!),
                                ),
                                const SizedBox(height: 10),

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

                                    const SizedBox(width: 20),

                                    // Display Image or Placeholder
                                    Flexible(
                                        child: orderProvider.receiptImage ==
                                                null
                                            ? const Text(
                                                'No receipt image selected',
                                                style: TextStyle(
                                                    color: AppColors.color3),
                                              )
                                            : Image.file(
                                                orderProvider.receiptImage!,
                                                fit: BoxFit.cover,
                                                height: 100)),
                                  ],
                                ),
                                if (_receiptImage == null)
                                  const Text(
                                    'Please upload a receipt image.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                // Dropdown for Book Type
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: orderProvider.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              if (_receiptImage == null) {
                                // Show an error message under the image upload section
                                return;
                              }

                              await orderProvider.purchaseBook(
                                id: widget.book['id'].toString(),
                                transactionNumber: _transactionController.text,
                                bankName: _bankNameController.text,
                                bookType: widget.book['type'].toString(),
                                context: context,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.color2,
                      ),
                      child: orderProvider.isLoading ||
                              orderProvider.isUploading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Submit Order',
                              style: AppTextStyles.buttonText),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
