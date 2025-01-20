import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/constants/constants.dart';
import 'package:book_mobile/providers/profile_provider.dart';
import 'package:book_mobile/providers/update_profile_provider.dart';
import 'package:book_mobile/widgets/custom_button.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final phoneController = TextEditingController();
  final bioController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  String? formattedDate;
  bool isLoading = true; // To track profile loading state
  String profileUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  void _pickAndUploadImage(UpdateProfileProvider provider) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await provider.updateProfileImage(pickedFile.path);

      if (provider.errorMessage.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
        // Refresh profile image
        setState(() {
          _fetchUserProfile();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage)),
        );
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.loadToken();
    await profileProvider.fetchUserProfile();
    if (profileProvider.userProfile != null) {
      // Pre-fill controllers with user data
      final profile = profileProvider.userProfile!;
      fnameController.text = profile['fname'] ?? '';
      lnameController.text = profile['lname'] ?? '';
      phoneController.text = profile['phone'] ?? '';
      bioController.text = profile['bio'] ?? '';
      cityController.text = profile['city'] ?? '';
      countryController.text = profile['country'] ?? '';
      profileUrl = '${Network.baseUrl}/${profile['imageFilePath']}';
      // Safely parse createdAt
      if (profile['createdAt'] != null) {
        final DateTime joinedOn = DateTime.parse(profile['createdAt']);

        formattedDate = DateFormat('MMM d, yyyy').format(joinedOn);
        print('User joined on: $joinedOn');
      } else {
        print('createdAt is null');
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'Edit your Profile',
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6),
          ),
          centerTitle: true,
        ),
        body: Consumer<UpdateProfileProvider>(
          builder: (context, provider, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.04),
              child: Column(
                children: [
                  // Profile Picture with Edit Icon
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: width * 0.2,
                        backgroundImage: NetworkImage(
                          profileUrl,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            final provider = Provider.of<UpdateProfileProvider>(
                                context,
                                listen: false);
                            _pickAndUploadImage(provider);
                          },
                          child: Container(
                            width: width * 0.1,
                            height: height * 0.051,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: provider.isLoading
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: provider.uploadProgress,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                      Text(
                                        '${(provider.uploadProgress * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: width * 0.03,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : Icon(
                                    Icons.camera_alt,
                                    color: AppColors.color3,
                                    size: width * 0.09,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.03),

                  // Form Fields
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                      child: Form(
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: fnameController,
                              labelText: 'First Name',
                              prefixIcon: Icons.person,
                            ),
                            SizedBox(height: height * 0.0036),
                            CustomTextField(
                              controller: lnameController,
                              labelText: 'Last Name',
                              prefixIcon: Icons.person,
                            ),
                            SizedBox(height: height * 0.0036),
                            CustomTextField(
                              controller: phoneController,
                              labelText: 'Phone Number',
                              prefixIcon: Icons.phone,
                            ),
                            SizedBox(height: height * 0.0036),
                            CustomTextField(
                              controller: bioController,
                              labelText: 'Bio',
                              prefixIcon: Icons.info,
                            ),
                            SizedBox(height: height * 0.0036),
                            CustomTextField(
                              controller: cityController,
                              labelText: 'City',
                              prefixIcon: Icons.location_city,
                            ),
                            SizedBox(height: height * 0.0036),
                            CustomTextField(
                              controller: countryController,
                              labelText: 'Country',
                              prefixIcon: Icons.flag,
                            ),
                            SizedBox(height: height * 0.0036),
                            provider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white)),
                                  )
                                : CustomButton(
                                    backgroundColor: AppColors.color2,
                                    borderColor: AppColors.color3,
                                    text: 'Save Changes',
                                    onPressed: () async {
                                      // Trigger profile update
                                      await provider.updateProfile(
                                        fname: fnameController.text.isNotEmpty
                                            ? fnameController.text
                                            : '',
                                        lname: lnameController.text.isNotEmpty
                                            ? lnameController.text
                                            : '',
                                        phone: phoneController.text.isNotEmpty
                                            ? phoneController.text
                                            : '',
                                        bio: bioController.text.isNotEmpty
                                            ? bioController.text
                                            : '',
                                        city: cityController.text.isNotEmpty
                                            ? cityController.text
                                            : '',
                                        country:
                                            countryController.text.isNotEmpty
                                                ? countryController.text
                                                : '',
                                      );
                                      if (!provider.isLoading &&
                                          provider.errorMessage.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Profile updated successfully!')),
                                        );
                                        _fetchUserProfile();
                                        Navigator.of(context).pop();
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
                                    textStyle: AppTextStyles.buttonText,
                                  ),
                            SizedBox(height: height * 0.01351),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Joined on: $formattedDate',
                                  style: AppTextStyles.bodyText
                                      .copyWith(fontSize: width * 0.035),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    // Trigger account deletion
                                    await provider.deleteAccount();
                                    if (!provider.isLoading &&
                                        provider.errorMessage.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Account deleted successfully!')),
                                      );
                                      context.go('/signup');
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
                                        AppColors.color6, // Text color
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
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
