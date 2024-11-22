import 'package:book_mobile/constants/styles.dart';
import 'package:book_mobile/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  final AnimationController? iconAnimationController;
  final Function(String)? onItemSelected;

  const CustomDrawer(
      {super.key, this.iconAnimationController, this.onItemSelected});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final List<Map<String, dynamic>> drawerItems = [
    {'label': 'Audio Book', 'icon': Icons.library_music},
    {'label': 'Downloaded', 'icon': Icons.download},
    {'label': 'My Books', 'icon': Icons.book},
    {'label': 'Notification', 'icon': Icons.notifications},
    {'label': 'Subscribe', 'icon': Icons.subscriptions},
    {'label': 'Author', 'icon': Icons.person},
    {'label': 'Share App', 'icon': Icons.share},
    {'label': 'Share Code', 'icon': Icons.code},
    {'label': 'Settings', 'icon': Icons.settings},
    {'label': 'Contact Us', 'icon': Icons.contact_mail},
    {'label': 'Enable 2FA', 'icon': Icons.security},
    {'label': 'Logout', 'icon': Icons.logout},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      backgroundColor: AppColors.color3, // Set background to AppColors.color3
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App Bar with Logo on Left and Hamburger Icon on Right
          _buildAppBar(),

          Divider(height: 1, color: AppColors.color5.withOpacity(0.6)),

          // Drawer List Items
          Expanded(
            child: ListView.builder(
              itemCount: drawerItems.length,
              itemBuilder: (context, index) {
                final item = drawerItems[index];
                return ListTile(
                  leading: Icon(item['icon'],
                      color: AppColors.color1), // Icon with default text color
                  title: Text(
                    item['label'],
                    style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.color1), // Use bodyText style
                  ),
                  onTap: () => _onItemSelected(item['label'], authProvider),
                );
              },
            ),
          ),

          Divider(height: 1, color: AppColors.color5.withOpacity(0.6)),
          Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),
    );
  }

  // App Bar with Logo and Hamburger Icon
  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.book,
            size: 40,
            color: AppColors.color1, // Set color to default text color
          ),
          IconButton(
            icon: const Icon(Icons.close,
                size: 40,
                color: AppColors.color2), // Icon color to default text color
            onPressed: () {
              // Toggle the drawer when menu icon is pressed
              Scaffold.of(context).closeDrawer();
            },
          ),
        ],
      ),
    );
  }

  // Handle item selection from the drawer
  void _onItemSelected(String label, AuthProvider authProvider) {
    switch (label) {
      case 'Enable 2FA':
        _enable2FA(context);
        break;
      case 'Logout':
        _logout(context);
        break;
      default:
        widget.onItemSelected?.call(label);
    }
  }

  // Enable 2FA logic
  void _enable2FA(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context);
    try {
      await authProvider.toggle2FA();
      // Toggling 2FA
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('2FA Enabled Successfully!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  // Logout logic
  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.logout();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
      }
      // Logout
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
