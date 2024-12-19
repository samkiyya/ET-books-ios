import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:book_mobile/widgets/custom_text_field.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  // final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  void _launchURL(String url) async {
    final Uri? uri = Uri.tryParse(url); // Safely parse the string into a Uri
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us',
            style: AppTextStyles.heading2.copyWith(color: AppColors.color6)),
        centerTitle: true,
        foregroundColor: AppColors.color6,
        backgroundColor: AppColors.color1,
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.09),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Information',
                style: AppTextStyles.bodyText
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: height * 0.01),
              const ListTile(
                leading: Icon(Icons.location_on, color: Colors.red),
                title: Text('Wollo sefer B242, Addis Ababa, Ethipia',
                    style: AppTextStyles.bodyText),
              ),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title:
                    const Text('+123 456 7890', style: AppTextStyles.bodyText),
                onTap: () => _launchURL('tel:+1234567890'),
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text('support@example.com',
                    style: AppTextStyles.bodyText),
                onTap: () => _launchURL('mailto:support@example.com'),
              ),
              const SizedBox(height: 20),
              Text(
                'Send Us a Message',
                style: AppTextStyles.bodyText
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                labelText: 'Name',
                controller: _nameController,
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                labelText: 'Email',
                controller: _emailController,
                validator: (value) =>
                    value!.isEmpty ? 'email is required' : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                labelText: 'subject',
                controller: _subjectController,
                validator: (value) =>
                    value!.isEmpty ? 'subject is required' : null,
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: 5,
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message sent!')),
                  );
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Follow Us',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook),
                    onPressed: () => _launchURL('https://facebook.com'),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.twitter),
                    onPressed: () => _launchURL('https://twitter.com'),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.instagram),
                    onPressed: () => _launchURL('https://instagram.com'),
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
