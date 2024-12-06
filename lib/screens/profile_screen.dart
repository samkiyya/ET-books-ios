import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:book_mobile/providers/profile_provider.dart';
import 'package:book_mobile/screens/password_change_screen.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:flutter/material.dart';
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
        body: userProfile == null
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ) // Loading state
            : Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.0148148,
                    vertical: height * 0.0072072),
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
                              userProfile['imageFilePath'] ??
                                  'https://xsgames.co/randomusers/avatar.php?g=pixel',
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
                                height: height * 0.051,
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
                        '${userProfile['fname'] ?? 'No first name available'} ${userProfile['lname'] ?? 'No last name available'}',
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
                              vertical: height * 0.01),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Level
                              Column(
                                children: [
                                  Text(
                                    'Level',
                                    style: TextStyle(
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userProfile['levelUser']?['name'] ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: width * 0.045,
                                    ),
                                  ),
                                ],
                              ),
                              VerticalDivider(
                                color: Colors.black26,
                                thickness: 1,
                                width: width * 0.03,
                              ),
                              // Subscription
                              Column(
                                children: [
                                  Text(
                                    'Subscription',
                                    style: TextStyle(
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userProfile['subscription']?['name'] ?? 'Free'}',
                                    style: TextStyle(fontSize: width * 0.045),
                                  ),
                                ],
                              ),
                              VerticalDivider(
                                color: Colors.black26,
                                thickness: 1,
                                width: width * 0.045,
                              ),
                              // Followers
                              Column(
                                children: [
                                  Text(
                                    'Followers',
                                    style: TextStyle(
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userProfile['followerCount']?.toInt() ?? 0}',
                                    style: TextStyle(fontSize: width * 0.045),
                                  ),
                                ],
                              ),
                              VerticalDivider(
                                color: Colors.black26,
                                thickness: 1,
                                width: width * 0.045,
                              ),
                              // Following
                              Column(
                                children: [
                                  Text(
                                    'Following',
                                    style: TextStyle(
                                        fontSize: width * 0.045,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userProfile['followingCount']?.toInt() ?? 0}',
                                    style: TextStyle(fontSize: width * 0.045),
                                  ),
                                ],
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
}
