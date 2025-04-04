import 'dart:convert';

import 'package:bookreader/constants/constants.dart';
import 'package:bookreader/constants/size.dart';
import 'package:bookreader/constants/styles.dart';
import 'package:bookreader/screens/custom_bottom_navigation_bar.dart';
import 'package:bookreader/providers/auth_provider.dart';
import 'package:bookreader/providers/profile_provider.dart';
import 'package:bookreader/screens/password_change_screen.dart';
import 'package:bookreader/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the profile data on page load
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.fetchUserProfile();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error fetching profile: ${error.toString()}')),
        );
      }
    }
  }

String formatDate(String? expirationDate) {
  if (expirationDate == null || expirationDate.isEmpty) {
    return 'Expired';
  }

  try {
    // Parse the ISO 8601 date string into a DateTime object
    DateTime parsedDate = DateTime.parse(expirationDate);

    // Get the current date and time
    DateTime currentDate = DateTime.now();

    // Check if the expiration date is in the past
    if (parsedDate.isBefore(currentDate)) {
      return 'Expired';
    }

    // Format the DateTime object using a custom format
    String formattedDate = DateFormat('MMMM dd, yyyy h:mm a').format(parsedDate);
    return formattedDate;
  } catch (e) {
    // In case of an error (invalid date), return 'Expired'
    return 'Expired';
  }
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
                    context.go(
                      '/login',
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
    final followerCount = profileProvider.followerCount;
    final followingCount = profileProvider.followingCount;
    Map<String, dynamic> subLimitsLeft = {};
    try {
      if (userProfile?['subLimitsLeft'] != null &&
          userProfile?['subLimitsLeft'] is String) {
        subLimitsLeft = jsonDecode(userProfile?['subLimitsLeft']);
      } else if (userProfile?['subLimitsLeft'] is Map<String, dynamic>) {
        subLimitsLeft = userProfile?['subLimitsLeft'];
      } else {
        subLimitsLeft = {};
      }
    } catch (e) {
      print('Error decoding subLimitsLeft: $e');
    }

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
        bottomNavigationBar: CustomNavigationBar(initialIndex: 3),
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
                                context.push('/edit-profile');
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
                      SizedBox(height: height * 0.01),
                      Text(
                        'your point: ${userProfile['point'] ?? '0'} ${userProfile['point'] != 0 ? 'points' : 'point'}',
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
                                spacing: width *
                                    0.02, // Horizontal spacing between elements
                                runSpacing: height *
                                    0.01, // Vertical spacing between rows
                                children: [
                                  // Level Column
                                  _buildColumn(
                                      title: 'Level',
                                      value:
                                          '${userProfile['level']?['level_name'] ?? 'Unknown'}',
                                      showDivider: true,
                                      width: width),
                                  // Subscription Column
                                  _buildColumn(
                                      title: 'Subscription',
                                      value:
                                          '${userProfile['subscription']?['tier_name'] ?? 'Free'}',
                                      showDivider: true,
                                      width: width),
                                  // Followers or Following Column
                                  userProfile['role'] == "AUTHOR"
                                      ? _buildColumn(
                                          title: 'Followers',
                                          value: '${followerCount ?? 0}',
                                          showDivider: false,
                                          width: width)
                                      : _buildColumn(
                                          title: 'Following',
                                          value: '${followingCount ?? 0}',
                                          showDivider: false,
                                          width: width),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Card(
                        color: AppColors.color2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.04,
                            vertical: height * 0.02,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subscription benefits Left',
                                style: AppTextStyles.heading2
                                    .copyWith(fontWeight: FontWeight.bold,fontSize: width*0.05),
                              ),
                              SizedBox(height: height * 0.01),
                              Text(
                                'Books: ${subLimitsLeft['books'] ?? 0}',
                                style: AppTextStyles.bodyText,
                              ),
                              Text(
                                'Audio Books: ${subLimitsLeft['audio_books'] ?? 0}',
                                style: AppTextStyles.bodyText,
                              ),
                              Text(
                                'Periodicals: ${subLimitsLeft['periodicals'] ?? 0}',
                                style: AppTextStyles.bodyText,
                              ),
                              Text('expiration Date: ${formatDate(userProfile['expirationDate']) ?? 'expired'}',
                                  style: AppTextStyles.bodyText,

                                  ),
                            ],
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
