import 'dart:io';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/purchase_order_provider.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class BuyBookScreen extends StatefulWidget {
  final Map<String, dynamic> book;

  const BuyBookScreen({super.key, required this.book});

  @override
  State<BuyBookScreen> createState() => _BuyBookScreenState();
}

class _BuyBookScreenState extends State<BuyBookScreen> {
  final _transactionController = TextEditingController();
  final _bankNameController = TextEditingController();
  File? _receiptImage;
  final _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PurchaseOrderProvider>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Book title
              Text("Buy Your Book",
                  style:
                      AppTextStyles.heading1.copyWith(color: AppColors.color2)),

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
                      const SizedBox(width: 30), // Space between image and text
                      // Text on the right
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Walk into the Shadow",
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
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // Transparent color
                    ),
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
                            ),
                            const SizedBox(height: 10),

                            // Bank Name
                            CustomTextField(
                              label: 'Bank Name',
                              controller: _bankNameController,
                              labelText: "Enter Bank Name",
                            ),
                            const SizedBox(height: 10),

                            // Row for Image Upload
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.zero, // Square shape
                                    ),
                                    backgroundColor: AppColors.color6,
                                  ),
                                  child: Text(
                                    _receiptImage == null
                                        ? 'Upload Receipt Image'
                                        : 'Change Image',
                                    style: AppTextStyles.buttonText,
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // Display Image or Placeholder
                                Flexible(
                                  child: _receiptImage != null
                                      ? Image.file(
                                          _receiptImage!,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        )
                                      : const Text(
                                          'No image selected',
                                          style: AppTextStyles.bodyText,
                                        ),
                                ),
                              ],
                            ),
                          ],
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
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            if (_transactionController.text.isEmpty ||
                                _bankNameController.text.isEmpty ||
                                _receiptImage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("All fields are required")),
                              );
                              return;
                            }
                            await provider.purchaseBook(
                              id: widget.book['id'],
                              transactionNumber: _transactionController.text,
                              bankName: _bankNameController.text,
                              receiptImage: _receiptImage!.path,
                              token:
                                  "your_user_token", // Replace with real token
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.responseMessage)),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.color2,
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Submit", style: AppTextStyles.buttonText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
