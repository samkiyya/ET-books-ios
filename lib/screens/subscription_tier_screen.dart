import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/providers/subscription_tiers_provider.dart';
import 'package:bookreader/screens/custom_bottom_navigation_bar.dart';
import 'package:bookreader/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SubscriptionTierScreen extends StatefulWidget {
  const SubscriptionTierScreen({super.key});

  @override
  State<SubscriptionTierScreen> createState() => _SubscriptionTierScreenState();
}

class _SubscriptionTierScreenState extends State<SubscriptionTierScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<SubscriptionTiersProvider>(context, listen: false)
          .fetchAllTiers();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final provider = Provider.of<SubscriptionTiersProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          title: Text(
            'Available Subscription Tiers',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.color6,
            ),
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: CustomNavigationBar(initialIndex: 1),
        body: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (provider.hasError) {
              return Center(
                child: Text(
                  provider.errorMessage,
                  style: AppTextStyles.bodyText,
                ),
              );
            }

            if (provider.tiers.isEmpty) {
              return const Center(
                  child: Text('No subscription tiers available.'));
            }

            return ListView.builder(
              itemCount: provider.tiers.length,
              itemBuilder: (context, index) {
                final tier = provider.tiers[index];

                return Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.03,
                        right: width * 0.03,
                        top: height * 0.003,
                        bottom: height * 0.003),
                    child: Card(
                      margin: EdgeInsets.symmetric(
                          vertical: height * 0.01, horizontal: width * 0.04),
                      elevation: 8,
                      shadowColor: AppColors.color4,
                      color: AppColors.color5,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: width * 0.03, vertical: height * 0.007),
                        title: Text(tier['tier_name'] ?? 'Unknown Tier',
                            style: AppTextStyles.bodyText),
                        subtitle: Column(
                          children: [
                            SizedBox(height: height * 0.0045),
                            Text(
                              'Monthly price: ETB ${tier['monthly_price']}',
                              style: AppTextStyles.bodyText,
                            ),
                            SizedBox(height: height * 0.0045),
                            Text(
                              'Annual price: ETB ${tier['annual_price']}',
                              style: AppTextStyles.bodyText,
                            ),
                            SizedBox(height: height * 0.0045),
                            Text(
                              'Discount for yearly subscribers: ${tier['discount_percentage']}%',
                              style: TextStyle(
                                color: AppColors.color3.withValues(alpha: 0.8),
                              ),
                            ),
                            SizedBox(height: height * 0.0045),
                            ElevatedButton(
                              onPressed:
                                  (tier['subscription_status'] == 'current')||tier['subscription_status'] == 'downgrade'
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SubscriptionOrderScreen(
                                                      tier: tier),
                                            ),
                                          );
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
                                // tier['subscription_status'].toString().toUpperCase(),
                                tier['subscription_status'] == 'current'
                                    ? 'Current Plan'
                                    : tier['subscription_status'].toString(),
                                style: AppTextStyles.buttonText.copyWith(
                                  color: AppColors.color3,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ));
              },
            );
          },
        ),
      ),
    );
  }
}
