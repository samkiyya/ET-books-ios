import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/subscription_tiers_provider.dart';
import 'package:book_mobile/screens/subscription_screen.dart';
import 'package:flutter/material.dart';
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
    final provider = Provider.of<SubscriptionTiersProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.color1,
          title: const Text('Available Subscription Tiers',
              style: AppTextStyles.heading2),
        ),
        body: Builder(
          builder: (context) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.hasError) {
              return Center(child: Text(provider.errorMessage));
            }

            if (provider.tiers.isEmpty) {
              return const Center(
                  child: Text('No subscription tiers available.'));
            }

            return ListView.builder(
              itemCount: provider.tiers.length,
              itemBuilder: (context, index) {
                final tier = provider.tiers[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.8),
                  color: AppColors.color1,
                  child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      title: Text(tier['tier_name'] ?? 'Unknown Tier',
                          style: AppTextStyles.bodyText),
                      subtitle: Text(
                        'Monthly price: \$${tier['monthly_price']}, \nAnnual price: \$${tier['annual_price']}',
                        style: AppTextStyles.bodyText,
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SubscriptionOrderScreen(tier: tier),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.color3,
                          backgroundColor: AppColors.color2, // Text color
                          elevation: 10, // Shadow effect
                          padding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 26),
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
                      )),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
