import 'package:bookreader/constants/payment_methods.dart';
import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/providers/user_activity_provider.dart';
import 'package:bookreader/widgets/custom_button.dart';
import 'package:bookreader/widgets/custom_text_field.dart';
import 'package:bookreader/widgets/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bookreader/providers/subscription_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionOrderScreen extends StatefulWidget {
  final Map<String, dynamic> tier;

  const SubscriptionOrderScreen({super.key, required this.tier});

  @override
  State<SubscriptionOrderScreen> createState() =>
      _SubscriptionOrderScreenState();
}

class _SubscriptionOrderScreenState extends State<SubscriptionOrderScreen> {
  final _transactionController = TextEditingController();
  String selectedBank = '';
  bool isBuying = true;

  late final List<String> bankLists = PaymentMethods.banks;
  // final int benefitLimitRemaining = 0;
  final Map<String, String> _validationErrors = {};
  final UserActivityTracker _tracker = UserActivityTracker();

  // Validate form inputs and return true if valid
  bool _validateInputs() {
    _validationErrors.clear();
    if (selectedBank.isEmpty || selectedBank == '') {
      _validationErrors['bankName'] = 'Bank Name is required.';
    }
    if (_transactionController.text.trim().isEmpty) {
      _validationErrors['transactionNumber'] =
          'transaction number is required.';
    }
    if (context.read<SubscriptionProvider>().startDate == null) {
      _validationErrors['startDate'] = 'Please select a start date.';
    }
    if (context.read<SubscriptionProvider>().receiptFile == null) {
      _validationErrors['receiptFile'] = 'Receipt image is required.';
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
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.color1,
            foregroundColor: AppColors.color6,
            title: Text(
              'You are subscribing to: ${widget.tier['tier_name']}',
              style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isBuying = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.color3,
                        backgroundColor: AppColors.color2, // Text color
                        elevation: 10, // Shadow effect
                        padding: EdgeInsets.symmetric(
                            vertical: height * 0.00585585,
                            horizontal: width * 0.024074),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30), // Rounded corners for 3D effect
                        ),
                        shadowColor: AppColors.color3.withOpacity(
                            0.6), // Custom shadow color for realism
                      ),
                      child: Text(
                        'benefits',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.color3,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isBuying = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.color3,
                        backgroundColor: AppColors.color2, // Text color
                        elevation: 10, // Shadow effect
                        padding: EdgeInsets.symmetric(
                            vertical: height * 0.00585585,
                            horizontal: width * 0.024074),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              30), // Rounded corners for 3D effect
                        ),
                        shadowColor: AppColors.color3.withOpacity(
                            0.6), // Custom shadow color for realism
                      ),
                      child: Text(
                        'Subscribe',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.color3,
                        ),
                      ),
                    ),
                  ],
                ),
                isBuying
                    ? (Consumer<SubscriptionProvider>(
                        builder: (context, provider, child) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: width * 0.02,
                                vertical: height * 0.01),
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.02,
                                          vertical: height * 0.01),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: height * 0.03),
                                          SizedBox(height: height * 0.03),
                                          Text(
                                            'Price: ${provider.subscriptionType == 'yearly' ? 'ETB ${widget.tier['annual_price']}' : 'ETB ${widget.tier['monthly_price']}'} / ${provider.subscriptionType}',
                                            style: AppTextStyles.bodyText,
                                          ),
                                          SizedBox(height: height * 0.003),
                                          CustomTextField(
                                            label: 'Transaction Number',
                                            controller: _transactionController,
                                            hintText:
                                                "Enter Transaction Number",
                                            fillColor: AppColors.color3,
                                          ),
                                          if (_validationErrors
                                              .containsKey('transactionNumber'))
                                            Text(
                                              _validationErrors[
                                                  'transactionNumber']!,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                          SizedBox(height: height * 0.03),
                                          // Bank Name Field
                                          CoustomSearchableDropdown(
                                            onChanged: (String? value) {
                                              setState(() {
                                                selectedBank = value!;
                                              });
                                            },
                                            data: bankLists,
                                            hintText: 'Select Bank Name',
                                          ),

                                          if (_validationErrors
                                              .containsKey('bankName'))
                                            Text(
                                              _validationErrors['bankName']!,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                          SizedBox(height: height * 0.03),
                                          const Text('Select subscription type',
                                              style: AppTextStyles.bodyText),

                                          // Subscription Type Dropdown
                                          DropdownButton<String>(
                                            value: provider.subscriptionType,
                                            onChanged: (value) {
                                              if (value != null) {
                                                provider.subscriptionType =
                                                    value;
                                              }
                                            },
                                            dropdownColor: AppColors.color5,
                                            style: const TextStyle(
                                                color: AppColors.color3),
                                            items: ['monthly', 'yearly']
                                                .map(
                                                  (type) => DropdownMenuItem(
                                                    value: type,
                                                    child: Text(
                                                      type.toUpperCase(),
                                                      style: const TextStyle(
                                                          color:
                                                              AppColors.color3),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                          SizedBox(height: height * 0.03),

                                          // Start Date Picker
                                          GestureDetector(
                                            onTap: () async {
                                              final selectedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    provider.startDate ??
                                                        DateTime.now(),
                                                firstDate: DateTime.now().subtract(const Duration(days:1)),
                                                lastDate: DateTime(2100),
                                              );
                                              if (selectedDate != null) {
                                                provider.startDate =
                                                    selectedDate;
                                              }
                                            },
                                            child: InputDecorator(
                                              decoration: const InputDecoration(
                                                labelText: 'Select Start Date',
                                                labelStyle: TextStyle(
                                                    color: AppColors.color3),
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
                                          if (_validationErrors
                                              .containsKey('startDate'))
                                            Text(
                                              _validationErrors['startDate']!,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                          SizedBox(height: height * 0.03),

                                          // Show Calculated End Date
                                          Text(
                                            provider.endDate == null
                                                ? 'End Date will be: Not calculated'
                                                : 'End Date: ${DateFormat('yyyy-MM-dd').format(provider.endDate!)}',
                                            style: AppTextStyles.bodyText,
                                          ),
                                          SizedBox(height: height * 0.03),

                                          // Receipt Image Picker
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton.icon(
                                                  onPressed:
                                                      provider.pickReceiptFile,
                                                  icon: const Icon(Icons.image,
                                                      color: AppColors.color3),
                                                  label: Text(
                                                    provider.receiptFile == null
                                                        ? 'Pick Receipt Image'
                                                        : 'Change Image',
                                                    style: AppTextStyles
                                                        .buttonText
                                                        .copyWith(
                                                      color: AppColors.color3,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: width * 0.03),
                                              // Display Image or Placeholder
                                              Flexible(
                                                child: provider.receiptFile ==
                                                        null
                                                    ? const Text(
                                                        'No receipt image selected',
                                                        style: TextStyle(
                                                            color: AppColors
                                                                .color3),
                                                      )
                                                    : provider.isImage
                                                        ? Image.file(
                                                            provider
                                                                .receiptFile!,
                                                            fit: BoxFit.contain,
                                                            height:
                                                                height * 0.09,
                                                          )
                                                        : Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .insert_drive_file,
                                                                  size: 40,
                                                                  color: Colors
                                                                      .white), // File icon
                                                              SizedBox(
                                                                  width: 8),
                                                              Expanded(
                                                                child: Text(
                                                                    provider
                                                                        .receiptFile!
                                                                        .path
                                                                        .split(
                                                                            '/')
                                                                        .last, // Displaying just the filename
                                                                    overflow:
                                                                        TextOverflow
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
                                          if (_validationErrors
                                              .containsKey('receiptFile'))
                                            Text(
                                              _validationErrors['receiptFile']!,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: height * 0.0072072),

                                  provider.isUploading
                                      ? Center(
                                          child:
                                              const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : CustomButton(
                                          backgroundColor: AppColors.color2,
                                          borderColor: AppColors.color3,
                                          textStyle: AppTextStyles.buttonText,
                                          text: 'Submit Order',
                                          onPressed: () async {
                                            if (!_validateInputs()) {
                                              return; // Validation failed
                                            }

                                            await provider
                                                .createSubscriptionOrder(
                                              tierId:
                                                  widget.tier['id'].toString(),
                                              bankName: selectedBank,
                                              transactionNumber:
                                                  _transactionController.text,
                                              benefitLimitRemain: widget
                                                      .tier['benefit_limit'] ??
                                                  0,
                                              subscriptionType:
                                                  provider.subscriptionType,
                                              context: context,
                                            );
                                            final actionDetails = {
                                              "subscriptionType":
                                                  provider.subscriptionType,
                                              "amount": provider
                                                          .subscriptionType ==
                                                      'yearly'
                                                  ? widget.tier['annual_price']
                                                  : widget
                                                      .tier['monthly_price'],
                                              "startDate": provider.startDate!
                                                  .toIso8601String(),
                                              "endDate": provider.endDate!
                                                  .toIso8601String(),
                                              "tierId":
                                                  widget.tier['id'].toString(),
                                            };
                                            SharedPreferences pref =
                                                await SharedPreferences
                                                    .getInstance();
                                            int? userId = int.tryParse(pref
                                                .getString('userId')
                                                .toString());

                                            final isSuccess =
                                                provider.errorMessage.isEmpty;

                                            if (isSuccess) {
                                              await _tracker.trackUserActivity(
                                                userId: userId!,
                                                actionType: "SUBSCRIPTION",
                                                actionDetails: actionDetails,
                                              );
                                            }

                                            final message = isSuccess
                                                ? provider.successMessage
                                                : provider.errorMessage;

                                            _showDialog(message, isSuccess);
                                          },
                                        ),
                                ],
                              ),
                            ),
                          );
                        },
                      ))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Divider(),
                          const Text(
                            "Contents and Benefits:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(
                            widget.tier['content_type'].length,
                            (i) {
                              final content = widget.tier['content_type'][i];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: height * 0.01,
                                    horizontal: width * 0.04),
                                elevation: 8,
                                shadowColor: AppColors.color4,
                                color: AppColors.color5,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: ListTile(
                                    leading: Icon(
                                        content['type'] == 'books'
                                            ? Icons.book
                                            : content['type'] == 'periodicals'
                                                ? Icons.spatial_audio_off
                                                : Icons.audio_file_outlined,
                                        color: Colors.white,
                                        size: 30),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: width * 0.03,
                                        vertical: height * 0.007),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          content['type'],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          "${content['benefit_limit']} ${content['type']}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ],
            ),
          )),
    );
  }
}
