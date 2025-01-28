import 'package:flutter/material.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/bottom_bar_item_model.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar_controller.dart';
import 'package:go_router/go_router.dart';

class CustomNavigationBar extends StatelessWidget {
  final int initialIndex;

  CustomNavigationBar({super.key, required this.initialIndex})
      : assert(initialIndex >= 0 && initialIndex < _routes.length,
            'Invalid initial index');

  static final List<String> _routes = [
    '/announcements',
    '/subscription-tier',
    '/home',
    // '/authors',
    '/profile',
  ];

  final List<BottomBarItem> _bottomBarItems = [
    BottomBarItem(
      activeItem: Icon(Icons.announcement, color: AppColors.color1),
      inActiveItem: Icon(Icons.announcement_outlined, color: AppColors.color2),
      itemLabel: 'News',
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
    // BottomBarItem(
    //   activeItem: Icon(Icons.people, color: AppColors.color1),
    //   inActiveItem: Icon(Icons.person_outline, color: AppColors.color2),
    //   itemLabel: 'Authors',
    // ),
    BottomBarItem(
      activeItem: Icon(Icons.person, color: AppColors.color1),
      inActiveItem: Icon(Icons.person_outline, color: AppColors.color2),
      itemLabel: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final NotchBottomBarController controller =
        NotchBottomBarController(index: initialIndex);

    void navigateToScreen(BuildContext context, int index) {
      if (index >= 0 && index < _routes.length) {
        context.push(_routes[index]);
      } else {
        context.go('/home');
      }
      controller.jumpTo(index);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return AnimatedNotchBottomBar(
          notchBottomBarController: controller,
          onTap: (index) => navigateToScreen(context, index),
          bottomBarItems: _bottomBarItems,
          showShadow: true,
          showLabel: true,
          itemLabelStyle: const TextStyle(color: Colors.black, fontSize: 12),
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
    );
  }
}
