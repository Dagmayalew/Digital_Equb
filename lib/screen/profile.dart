import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifier/user_notifier.dart'; // Ensure this path is correct

class ProfileScreen extends StatelessWidget {
  // The user data will now be fetched from UserNotifier,
  // so we no longer need to pass it via the constructor.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access user data from UserNotifier
    final userNotifier = Provider.of<UserNotifier>(context);
    final user = userNotifier.user ?? {}; // Get the user map, default to empty if null

    final String userName = user['name'] ?? 'Guest';
    final String userEmail = user['email'] ?? 'No email provided';
    final String userPhone = user['phone'] ?? 'No phone provided';
    // You could also add other fields like 'bio', 'address', etc., if they exist in your user map.
    // For example: final String userBio = user['bio'] ?? 'Tell us about yourself!';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        // Potentially add settings or edit profile icon here
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.edit),
        //     tooltip: 'Edit Profile',
        //     onPressed: () {
        //       // Navigate to an edit profile screen
        //       ScaffoldMessenger.of(context).showSnackBar(
        //         const SnackBar(content: Text('Edit Profile (Not implemented)')),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture Section
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              // You can use NetworkImage or AssetImage here if you have profile pictures
              // backgroundImage: NetworkImage('URL_TO_PROFILE_PIC'),
            ),
            const SizedBox(height: 20),

            // User Name
            Text(
              userName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Divider for visual separation
            Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),

            // User Details Section
            _buildProfileInfoRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: userEmail,
            ),
            const SizedBox(height: 15),
            _buildProfileInfoRow(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: userPhone,
            ),
            // Add more rows for other profile details if available
            // const SizedBox(height: 15),
            // _buildProfileInfoRow(
            //   context,
            //   icon: Icons.info_outline,
            //   label: 'Bio',
            //   value: userBio,
            // ),
            const SizedBox(height: 40),

            // Example of an action button (can be customized or removed)
            // ElevatedButton.icon(
            //   onPressed: () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Settings (Not implemented)')),
            //     );
            //   },
            //   icon: const Icon(Icons.settings),
            //   label: const Text('Account Settings'),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            //     textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //     backgroundColor: Theme.of(context).colorScheme.secondary,
            //     foregroundColor: Theme.of(context).colorScheme.onSecondary,
            //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build a consistent info row
  Widget _buildProfileInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2), // Subtle background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}