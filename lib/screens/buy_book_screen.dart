import 'dart:io';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/purchase_order_provider.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyBookScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BuyBookScreen({super.key, required this.book});

  @override
  State<BuyBookScreen> createState() => _BuyBookScreenState();
}

class _BuyBookScreenState extends State<BuyBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _transactionController = TextEditingController();
  final _bankNameController = TextEditingController();
  File? _receiptImage;

  String? _selectedBookType; // For dropdown selection

  @override
  void initState() {
    super.initState();
    _selectedBookType = widget.book['bookType'];
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
                Text("Buy Your Book",
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
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                                ),
                                const SizedBox(height: 10),

                                // Bank Name
                                CustomTextField(
                                  label: 'Bank Name',
                                  controller: _bankNameController,
                                  hintText: "Enter Bank Name",
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Required'
                                          : null,
                                ),
                                const SizedBox(height: 10),

                                // Row for Image Upload
                                Row(
                                  children: [
                                    TextButton.icon(
                                      onPressed: () async {
                                        await orderProvider.pickImage();
                                        setState(() {
                                          _receiptImage = orderProvider
                                              .receiptImage; // Sync with provider
                                        });
                                      },
                                      icon: const Icon(Icons.image),
                                      label: Text(
                                        _receiptImage == null
                                            ? 'Upload Receipt Image'
                                            : 'Change Image',
                                        style: AppTextStyles.buttonText,
                                      ),
                                    ),

                                    const SizedBox(width: 20),

                                    // Display Image or Placeholder
                                    Flexible(
                                        child:
                                            orderProvider.receiptImage == null
                                                ? const Text(
                                                    'No receipt image selected')
                                                : Image.file(
                                                    orderProvider.receiptImage!,
                                                    fit: BoxFit.cover,
                                                    height: 100)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // Dropdown for Book Type
                                DropdownButton<String>(
                                  hint: const Text("Select Book Type"),
                                  value: _selectedBookType,
                                  items: const [
                                    DropdownMenuItem(
                                        value: "audio", child: Text("Audio")),
                                    DropdownMenuItem(
                                        value: "pdf", child: Text("PDF")),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedBookType = value;
                                    });
                                  },
                                ),
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
                              if (!_formKey.currentState!.validate() ||
                                  orderProvider.receiptImage == null) {
                                orderProvider.showResponseDialog(
                                  context,
                                  "Please complete all fields and upload a receipt image.",
                                  "OK",
                                  false,
                                );
                                return;
                              }

                              await orderProvider.purchaseBook(
                                id: widget.book['id'].toString(),
                                transactionNumber: _transactionController.text,
                                bankName: _bankNameController.text,
                                bookType: _selectedBookType ?? '',
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

                      // if (context.mounted) {
                      //   ScaffoldMessenger.of(context).showSnackBar(
                      //     SnackBar(
                      //         content: Text(provider.responseMessage)),
                      //   );
                      // }

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
