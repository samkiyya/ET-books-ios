import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/models/bottom_bar_item_model.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:book_mobile/providers/profile_provider.dart';
import 'package:book_mobile/screens/password_change_screen.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar.dart';
import 'package:book_mobile/widgets/animated_notch_bottom_bar/notch_bottom_bar_controller.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
 final NotchBottomBarController _controller =
      NotchBottomBarController(index: 4); // Default to "home"

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
      Navigator.pushNamed(
        context,
'/home'      );
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
    // Fetch the profile data on page load
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.loadToken();
    await profileProvider.fetchUserProfile();
  }

  void _showLogoutDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logged out successfully')),
                    );
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${error.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userProfile = profileProvider.userProfile;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.color3),
          ),
          title: Text(
            "My Profile",
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: AppColors.color3),
              color: AppColors.color3,
              tooltip: 'Logout',
            ),
          ],
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
        body: userProfile == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ) // Loading state
            : Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03, vertical: height * 0.01),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: width * 0.2,
                            backgroundImage: NetworkImage(
                              userProfile['imageFilePath'] != null
                                  ? '${Network.baseUrl}/${userProfile['imageFilePath']}'
                                  : 'https://xsgames.co/randomusers/avatar.php?g=pixel',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to Edit Profile Screen
                                Navigator.pushNamed(context, '/edit-profile');
                              },
                              child: Container(
                                width: width * 0.1,
                                height: height * 0.05,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Icon(
                                  Icons.edit,
                                  color: AppColors.color3,
                                  size: width * 0.07,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.03),
                      Text(
                        '${userProfile['fname'] ?? ''} ${userProfile['lname'] ?? ''}',
                        style: AppTextStyles.heading2,
                      ),
                      SizedBox(height: height * 0.01),
                      Text(
                        'Bio: ${userProfile['bio'] ?? 'No bio available'}',
                        style: AppTextStyles.bodyText,
                      ),
                      SizedBox(height: height * 0.01),
                      // Additional profile info
                      Text(
                        'Email: ${userProfile['email'] ?? 'No Email'}',
                        style: AppTextStyles.bodyText,
                      ),
                      SizedBox(height: height * 0.01),

                      Text(
                        'Phone: ${userProfile['phone'] ?? 'No Phone'}',
                        style: AppTextStyles.bodyText,
                      ),
                      SizedBox(height: height * 0.01),

                      Text(
                        'Country: ${userProfile['country'] ?? 'Unknown'}',
                        style: AppTextStyles.bodyText,
                      ),
                      SizedBox(height: height * 0.01),

                      Text(
                        'City: ${userProfile['city'] ?? 'Unknown'}',
                        style: AppTextStyles.bodyText,
                      ),
                      SizedBox(height: height * 0.03),
                      // Card for Level, Subscription, Followers and Following
                      Card(
  color: AppColors.color2, // Custom card color
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 5,
  child: Padding(
    padding: EdgeInsets.symmetric(
      horizontal: width * 0.02,
      vertical: height * 0.01,
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: width * 0.02, // Horizontal spacing between elements
          runSpacing: height * 0.01, // Vertical spacing between rows
          children: [
            // Level Column
            _buildColumn(
              title: 'Level',
              value: '${userProfile['levelUser']?['name'] ?? 'Unknown'}',
              showDivider: true,
              width:width
            ),
            // Subscription Column
            _buildColumn(
              title: 'Subscription',
              value: '${userProfile['subscription']?['name'] ?? 'Free'}',
              showDivider: true,
              width:width
            ),
            // Followers or Following Column
            userProfile['role'] == "AUTHOR"
                ? _buildColumn(
                    title: 'Followers',
                    value: '${userProfile['followerCount']?.toInt() ?? 0}',
                    showDivider: false,
                    width:width
                  )
                : _buildColumn(
                    title: 'Following',
                    value: '${userProfile['followingCount']?.toInt() ?? 0}',
                    showDivider: false,
                    width:width
                  ),
          ],
        );
      },
    ),
  ),
),


                      SizedBox(height: height * 0.03),
                      CustomButton(
                          text: 'Change Password',
                          backgroundColor: AppColors.color2,
                          borderColor: AppColors.color3,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const PasswordChangeFormScreen()));
                          },
                          textStyle: AppTextStyles.buttonText),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  // Helper function to build the individual column with optional divider
Widget _buildColumn({
  required String title,
  required String value,
  required bool showDivider,
  required double width,
}) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: width * 0.045,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        value,
        style: TextStyle(fontSize: width * 0.045),
      ),
      if (showDivider)
        VerticalDivider(
          color: Colors.black26,
          thickness: 1,
          width: width * 0.03,
        ),
    ],
  );
}

}
