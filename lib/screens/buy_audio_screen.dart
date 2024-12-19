import 'dart:io';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/purchase_order_provider.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuyAudioScreen extends StatefulWidget {
  final Map<String, dynamic> audioBook;
  const BuyAudioScreen({super.key, required this.audioBook});

  @override
  State<BuyAudioScreen> createState() => _BuyAudioScreenState();
}

class _BuyAudioScreenState extends State<BuyAudioScreen> {
  final _formKey = GlobalKey<FormState>();

  final _transactionController = TextEditingController();
  final _bankNameController = TextEditingController();
  File? _receiptImage;
  String _selectedType = 'AudioBook'; // Default selection

  String? _validateField(String key, String value) {
    if (value.isEmpty) {
      return 'Please enter your $key';
    }
    return null; // No errors
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<PurchaseOrderProvider>(context);
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
                Center(
                  child: Text(
                    "Buy Your AudioBook",
                    style: AppTextStyles.heading2
                        .copyWith(color: AppColors.color2),
                  ),
                ),
                SizedBox(height: height * 0.04),
                // Book details card
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
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            '${Network.baseUrl}/${widget.audioBook['imageFilePath']}',
                            height: height * 0.13,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                size: width * 0.2,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: width * 0.09),
                        // Book details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.audioBook['title'],
                                style: AppTextStyles.heading2,
                              ),
                              SizedBox(height: height * 0.0045),
                              Text(
                                '${widget.audioBook['rating']} ⭐ | ${widget.audioBook['sold']} bought',
                                style: AppTextStyles.bodyText,
                              ),
                              SizedBox(height: height * 0.0045),
                              Text(
                                'Price: ETB ${widget.audioBook['price']}',
                                style: AppTextStyles.bodyText,
                              ),
                              SizedBox(height: height * 0.0045),
                              Text(
                                'Publication Year: ${widget.audioBook['publicationYear']}',
                                style: AppTextStyles.bodyText,
                              ),
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
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
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
                                  validator: (value) => _validateField(
                                      'Transaction Number', value!),
                                ),
                                SizedBox(height: height * 0.0045),

                                // Bank Name
                                CustomTextField(
                                  label: 'Bank Name',
                                  controller: _bankNameController,
                                  hintText: "Enter Bank Name",
                                  validator: (value) =>
                                      _validateField('Bank Name', value!),
                                ),
                                SizedBox(height: height * 0.02),

                                // Receipt Image
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
                                    Flexible(
                                      child: orderProvider.receiptImage == null
                                          ? const Text(
                                              'No receipt image selected',
                                              style: TextStyle(
                                                  color: AppColors.color3),
                                            )
                                          : Image.file(
                                              orderProvider.receiptImage!,
                                              fit: BoxFit.cover,
                                              height: height * 0.09,
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
                                const Text(
                                  'Select Book Type',
                                  style: AppTextStyles.bodyText,
                                ),
                                DropdownButtonFormField<String>(
                                  value: _selectedType,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'AudioBook',
                                      child: Text('AudioBook'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'PDF',
                                      child: Text('PDF'),
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
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.color2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),

                // Submit Button
                orderProvider.isLoading || orderProvider.isUploading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : CustomButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate() ||
                              _receiptImage == null) {
                            return;
                          }

                          await orderProvider.purchaseBook(
                            id: widget.audioBook['id'].toString(),
                            transactionNumber: _transactionController.text,
                            bankName: _bankNameController.text,
                            bookType: _selectedType, // Selected type
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
