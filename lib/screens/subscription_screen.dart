import 'package:book_mobile/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:book_mobile/providers/subscription_provider.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';

class SubscriptionOrderScreen extends StatefulWidget {
  final Map<String, dynamic> tier;

  const SubscriptionOrderScreen({super.key, required this.tier});

  @override
  State<SubscriptionOrderScreen> createState() =>
      _SubscriptionOrderScreenState();
}

class _SubscriptionOrderScreenState extends State<SubscriptionOrderScreen> {
  final _bankNameController = TextEditingController();
  final Map<String, String> _validationErrors = {};

  // Validate form inputs and return true if valid
  bool _validateInputs() {
    _validationErrors.clear();
    if (_bankNameController.text.trim().isEmpty) {
      _validationErrors['bankName'] = 'Bank Name is required.';
    }
    if (context.read<SubscriptionProvider>().startDate == null) {
      _validationErrors['startDate'] = 'Please select a start date.';
    }
    if (context.read<SubscriptionProvider>().receiptImage == null) {
      _validationErrors['receiptImage'] = 'Receipt image is required.';
    }

    setState(() {}); // Update UI with validation errors
    return _validationErrors.isEmpty;
  }

  // Show dialog with a custom message
  void _showDialog(String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isSuccess ? 'Success' : 'Error',
            style: AppTextStyles.heading2),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        content: Text(message, style: AppTextStyles.bodyText),
        icon: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: Colors.white,
          size: 50,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isSuccess) {
                Navigator.of(context).pop(); // Go back to the previous screen
              }
            },
            child: Text('OK',
                style: AppTextStyles.buttonText.copyWith(
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.color1,
          title: Text('You are subscribing to: ${widget.tier['tier_name']}',
              style: AppTextStyles.heading2),
        ),
        body: Consumer<SubscriptionProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card containing main content
                    Card(
                      color: AppColors.color1,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Price: ${provider.subscriptionType == 'yearly' ? 'ETB ${widget.tier['annual_price']}' : 'ETB ${widget.tier['monthly_price']}'} / ${provider.subscriptionType}',
                              style: AppTextStyles.bodyText,
                            ),
                            const SizedBox(height: 16),

                            // Bank Name Field
                            CustomTextField(
                              label: 'Bank Name',
                              controller: _bankNameController,
                              hintText: "Enter Bank Name",
                            ),
                            if (_validationErrors.containsKey('bankName'))
                              Text(
                                _validationErrors['bankName']!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            const SizedBox(height: 16),
                            const Text('Select subscription type',
                                style: AppTextStyles.bodyText),

                            // Subscription Type Dropdown
                            DropdownButton<String>(
                              value: provider.subscriptionType,
                              onChanged: (value) {
                                if (value != null) {
                                  provider.subscriptionType = value;
                                }
                              },
                              dropdownColor: AppColors.color5,
                              style: const TextStyle(color: AppColors.color3),
                              items: ['monthly', 'yearly']
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        type.toUpperCase(),
                                        style: const TextStyle(
                                            color: AppColors.color3),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 25),

                            // Start Date Picker
                            GestureDetector(
                              onTap: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      provider.startDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (selectedDate != null) {
                                  provider.startDate = selectedDate;
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Select Start Date',
                                  labelStyle:
                                      TextStyle(color: AppColors.color3),
                                  filled: true,
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: AppColors.color3,
                                  ),
                                  fillColor: AppColors.color5,
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  provider.startDate == null
                                      ? 'Select Start Date'
                                      : provider.startDate!
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0],
                                  style: AppTextStyles.bodyText,
                                ),
                              ),
                            ),
                            if (_validationErrors.containsKey('startDate'))
                              Text(
                                _validationErrors['startDate']!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            const SizedBox(height: 16),

                            // Show Calculated End Date
                            Text(
                              provider.endDate == null
                                  ? 'End Date will be: Not calculated'
                                  : 'End Date: ${DateFormat('yyyy-MM-dd').format(provider.endDate!)}',
                              style: AppTextStyles.bodyText,
                            ),
                            const SizedBox(height: 16),

                            // Receipt Image Picker
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: provider.pickReceiptImage,
                                    icon: const Icon(Icons.image,
                                        color: AppColors.color3),
                                    label: Text(
                                      provider.receiptImage == null
                                          ? 'Pick Receipt Image'
                                          : 'Change Image',
                                      style: AppTextStyles.buttonText.copyWith(
                                        color: AppColors.color3,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Display Image or Placeholder
                                Flexible(
                                  child: provider.receiptImage == null
                                      ? const Text(
                                          'No receipt image selected',
                                          style: TextStyle(
                                              color: AppColors.color3),
                                        )
                                      : Image.file(
                                          provider.receiptImage!,
                                          fit: BoxFit.cover,
                                          height: 100,
                                        ),
                                ),
                              ],
                            ),
                            if (_validationErrors.containsKey('receiptImage'))
                              Text(
                                _validationErrors['receiptImage']!,
                                style: const TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Submit Button Outside Card
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.color2,
                          ),
                          onPressed: () async {
                            if (!_validateInputs()) {
                              return; // Validation failed
                            }

                            await provider.createSubscriptionOrder(
                              tierId: widget.tier['id'].toString(),
                              bankName: _bankNameController.text.trim(),
                              context: context,
                            );

                            final isSuccess = provider.errorMessage.isEmpty;
                            final message = isSuccess
                                ? provider.successMessage
                                : provider.errorMessage;

                            _showDialog(message, isSuccess);
                          },
                          child: provider.isUploading
                              ? const CircularProgressIndicator()
                              : const Text('Submit Order',
                                  style: AppTextStyles.buttonText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
