import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:book_mobile/providers/profile_provider.dart';
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
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userProfile = profileProvider.userProfile;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.color1,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.color3),
          ),
          title: const Text(
            "My Profile",
            style: AppTextStyles.heading2,
          ),
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
            ? const Center(child: CircularProgressIndicator()) // Loading state
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Picture
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: AppColors.color3,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text(
                        '${userProfile['fname'] ?? 'No first name available'} ${userProfile['lname'] ?? 'No last name available'}',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userProfile['bio'] ?? 'No bio available',
                        style: AppTextStyles.bodyText,
                      ),
                      const SizedBox(height: 20),
                      // Additional profile info
                      Text(
                        'Email: ${userProfile['email'] ?? 'No Email'}',
                        style: AppTextStyles.bodyText,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'Phone: ${userProfile['phone'] ?? 'No Phone'}',
                        style: AppTextStyles.bodyText,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'Country: ${userProfile['country'] ?? 'Unknown'}',
                        style: AppTextStyles.bodyText,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        'City: ${userProfile['city'] ?? 'Unknown'}',
                        style: AppTextStyles.bodyText,
                      ),
                      const SizedBox(height: 20),
                      // Card for Level, Subscription, Followers and Following
                      Card(
                        color: AppColors.color2, // Custom card color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Level
                              Column(
                                children: [
                                  const Text(
                                    'Level',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userProfile['levelUser']?['name'] ?? 'Unknown'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const VerticalDivider(
                                color: Colors.black26,
                                thickness: 1,
                                width: 20,
                              ),
                              // Subscription
                              Column(
                                children: [
                                  const Text(
                                    'Subscription',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userProfile['subscription']?['name'] ?? 'Free'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const VerticalDivider(
                                color: Colors.black26,
                                thickness: 1,
                                width: 20,
                              ),
                              // Followers
                              Column(
                                children: [
                                  const Text(
                                    'Followers',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userProfile['followerCount']?.toInt() ?? 0}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const VerticalDivider(
                                color: Colors.black26,
                                thickness: 1,
                                width: 20,
                              ),
                              // Following
                              Column(
                                children: [
                                  const Text(
                                    'Following',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userProfile['followingCount']?.toInt() ?? 0}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
