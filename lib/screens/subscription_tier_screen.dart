import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/bottom_bar_item_model.dart';
import 'package:book_mobile/providers/subscription_tiers_provider.dart';
import 'package:book_mobile/screens/subscription_screen.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscriptionTierScreen extends StatefulWidget {
  const SubscriptionTierScreen({super.key});

  @override
  State<SubscriptionTierScreen> createState() => _SubscriptionTierScreenState();
}

class _SubscriptionTierScreenState extends State<SubscriptionTierScreen> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 1); // Default to "home"

  final List<String> _routes = [
    '/announcements',
    '/subscription-tier',
    '/home',
    '/authors',
    '/profile',
  ];
  void _navigateToScreen(BuildContext context, int index) {
    if (index >= 0 && index < _routes.length) {
      Navigator.pushNamed(context, _routes[index]);
    } else {
      Navigator.pushNamed(context, '/home');
    }
    setState(() {
      _controller.jumpTo(index);
    });
  }

  final List<BottomBarItem> _bottomBarItems = [
    BottomBarItem(
      activeItem: Icon(Icons.announcement, color: AppColors.color1),
      inActiveItem: Icon(Icons.announcement_outlined, color: AppColors.color2),
      itemLabel: 'Announcements',
    ),
    BottomBarItem(
      activeItem: Icon(Icons.subscriptions, color: AppColors.color1),
      inActiveItem: Icon(Icons.subscriptions_outlined, color: AppColors.color2),
      itemLabel: 'Subscribe',
    ),
    BottomBarItem(
      activeItem: Icon(Icons.home, color: AppColors.color1),
      inActiveItem: Icon(Icons.home_outlined, color: AppColors.color2),
      itemLabel: 'Home',
    ),
    BottomBarItem(
      activeItem: Icon(
        Icons.people,
        color: AppColors.color1,
      ),
      inActiveItem: Icon(Icons.person_outline, color: AppColors.color2),
      itemLabel: 'Authors',
    ),
    BottomBarItem(
      activeItem: Icon(Icons.person, color: AppColors.color1),
      inActiveItem: Icon(Icons.person_outline, color: AppColors.color2),
      itemLabel: 'Profile',
    ),
  ];
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
        bottomNavigationBar: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return AnimatedNotchBottomBar(
              notchBottomBarController: _controller,
              onTap: (index) => _navigateToScreen(context, index),
              bottomBarItems: _bottomBarItems,
              showShadow: true,
              showLabel: true,
              itemLabelStyle: TextStyle(color: Colors.black, fontSize: 12),
              showBlurBottomBar: true,
              blurOpacity: 0.6,
              blurFilterX: 10.0,
              blurFilterY: 10.0,
              kIconSize: 30,
              kBottomRadius: 10,
              showTopRadius: true,
              showBottomRadius: true,
              topMargin: 15,
              durationInMilliSeconds: 300,
              bottomBarHeight: 70,
              elevation: 8,
            );
          },
        ),
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
                            SizedBox(height: height * 0.0045045),
                            Text(
                              'Monthly price: ETB ${tier['monthly_price']}',
                              style: AppTextStyles.bodyText,
                            ),
                            SizedBox(height: height * 0.0045045),
                            Text(
                              'Annual price: ETB ${tier['annual_price']}',
                              style: AppTextStyles.bodyText,
                            ),
                          ],
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
                        )),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
