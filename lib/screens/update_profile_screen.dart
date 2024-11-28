import 'package:book_mobile/providers/update_profile_provider.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fnameController = TextEditingController();
    final lnameController = TextEditingController();
    final phoneController = TextEditingController();
    final bioController = TextEditingController();
    final cityController = TextEditingController();
    final countryController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'Edit Profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: Consumer<UpdateProfileProvider>(
          builder: (context, provider, child) {
            return FutureBuilder<String?>(
              future: _getTokenFromSharedPreferences(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Authentication error. Please log in.'));
                }

                final token = snapshot.data!;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Profile Picture with Edit Icon
                        Stack(
                          children: [
                            const SizedBox(
                              width: 120,
                              height: 120,
                              child: ClipOval(
                                child: Icon(Icons.person),
                                //Image.asset(
                                //'assets/images/profile.png', // Replace with your image path
                                // fit: BoxFit.cover,
                                // ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // Add your image picker logic here
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Form Fields
                        Form(
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: fnameController,
                                labelText: 'Full Name',
                                prefixIcon: Icons.person,
                              ),
                              const SizedBox(height: 8),

                              CustomTextField(
                                controller: lnameController,
                                labelText: 'Last Name',
                                prefixIcon: Icons.person,
                              ),

                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: phoneController,
                                labelText: 'Phone Number',
                                prefixIcon: Icons.phone,
                              ),

                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: bioController,
                                labelText: 'Bio',
                                prefixIcon: Icons.info,
                              ),

                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: cityController,
                                labelText: 'City',
                                prefixIcon: Icons.location_city,
                              ),

                              const SizedBox(height: 8),
                              CustomTextField(
                                controller: countryController,
                                labelText: 'Country',
                                prefixIcon: Icons.flag,
                              ),

                              const SizedBox(height: 30),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Trigger profile update
                                    await provider.updateProfile(
                                      token: token,
                                      fname: fnameController.text,
                                      lname: lnameController.text,
                                      phone: phoneController.text,
                                      bio: bioController.text,
                                      city: cityController.text,
                                      country: countryController.text,
                                    );
                                    if (!provider.isLoading &&
                                        provider.errorMessage.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Profile updated successfully!')),
                                      );
                                    } else if (provider
                                        .errorMessage.isNotEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text(provider.errorMessage)),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    shape: const StadiumBorder(),
                                  ),
                                  child: provider.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text('Save Changes'),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Created Date and Delete Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Joined on: Jan 1, 2022',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Trigger account deletion
                                      await provider.deleteAccount(
                                          token: token);
                                      if (!provider.isLoading &&
                                          provider.errorMessage.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Account deleted successfully!')),
                                        );
                                      } else if (provider
                                          .errorMessage.isNotEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text(provider.errorMessage)),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      backgroundColor:
                                          Colors.red.withOpacity(0.1),
                                      elevation: 0,
                                      shape: const StadiumBorder(),
                                    ),
                                    child: const Text('Delete Account'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Helper function to get the token from SharedPreferences
  Future<String?> _getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }
}
