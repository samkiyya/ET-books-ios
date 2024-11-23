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
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userProfile = profileProvider.userProfile;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("My Profile")),
        body: userProfile == null
            ? const Center(child: CircularProgressIndicator()) // Loading state
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        userProfile['imageFilePath'] ?? 'default_image_url',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${userProfile['fname']} ${userProfile['lname']}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userProfile['bio'] ?? 'No bio available',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    // Additional profile info
                    Text(
                      'Email: ${userProfile['email']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Phone: ${userProfile['phone']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Country: ${userProfile['country']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'City: ${userProfile['city']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    // Subscription and Level Info
                    Row(
                      children: [
                        Text(
                          'Level: ${userProfile['levelUser']['name']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Subscription: ${userProfile['subscription']['name']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Followers and Following counts
                    Row(
                      children: [
                        Text(
                          'Followers: ${userProfile['followerCount']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Following: ${userProfile['followingCount']}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
