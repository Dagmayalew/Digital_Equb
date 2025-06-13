import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../fake_payment_service.dart';
import '../notifier/user_notifier.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});


  Widget _buildProfileInfoRow(BuildContext context, {required IconData icon, required String label, required String value, Color? valueColor}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8), // Add vertical margin for spacing
      elevation: 2, // Subtle elevation
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
                      color: valueColor ?? Theme.of(context).colorScheme.onSurface, // Apply custom color if provided
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show deposit dialog (minor text adjustments for clarity)
  Future<void> _showDepositDialog(BuildContext context) async {
    final TextEditingController amountController = TextEditingController();
    final FakePaymentService paymentService = FakePaymentService();
    final UserNotifier userNotifier = Provider.of<UserNotifier>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // User can tap outside to close now
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Deposit Funds',
            style: TextStyle(fontWeight: FontWeight.bold), // Bold title
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (Birr)',
                    hintText: 'e.g., 100.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  validator: (value) { // Basic validation
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount.';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number.';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be positive.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Text(
                  'Note: This is a simulated payment. Deposits less than 10 Birr will fail.',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.redAccent), // Highlight note
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                amountController.dispose();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary, // Apply primary theme color
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () async {
                final String amountText = amountController.text;
                final double? depositAmount = double.tryParse(amountText);

                if (depositAmount == null || depositAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid positive amount.'), backgroundColor: Colors.red),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop(); // Close dialog immediately
                amountController.dispose();

                // Show processing snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Processing deposit of ${depositAmount.toStringAsFixed(2)} Birr...'), backgroundColor: Colors.blue, duration: const Duration(seconds: 2)),
                );

                // Simulate payment
                final bool success = await paymentService.processDeposit(depositAmount);

                if (success) {
                  userNotifier.updateUserBalance(depositAmount); // Update global balance
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deposit successful! Your new balance is ${NumberFormat.currency(locale: 'en_US', symbol: 'Birr').format(userNotifier.user?['balance'] ?? 0.0)}.'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deposit failed. Please try again with an amount of 10 Birr or more.'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Deposit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access user data from UserNotifier
    final userNotifier = Provider.of<UserNotifier>(context);
    final user = userNotifier.user ?? {};

    final String userName = user['name'] ?? 'Guest';
    final String userEmail = user['email'] ?? 'No email provided';
    final String userPhone = user['phone'] ?? 'No phone provided';
    final String userBalance = NumberFormat.currency(locale: 'en_US', symbol: 'Birr').format(userNotifier.user?['balance'] ?? 0.0); // Formatted balance

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
        // Moved deposit button to body for better visibility and context
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture and Name Section
            Container(
              padding: const EdgeInsets.all(20), // Padding around the avatar and name
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05), // Light background for the section
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Equb Member', // A generic role/status
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // User Details Section
            Align( // Align the details section title to the left
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            _buildProfileInfoRow(
              context,
              icon: Icons.email_outlined,
              label: 'Email Address', // More descriptive label
              value: userEmail,
            ),
            _buildProfileInfoRow(
              context,
              icon: Icons.phone_outlined,
              label: 'Phone Number', // More descriptive label
              value: userPhone,
            ),
            _buildProfileInfoRow(
              context,
              icon: Icons.account_balance_wallet_outlined,
              label: 'Current Balance', // More descriptive label
              value: userBalance,
              valueColor: Theme.of(context).colorScheme.primary, // Highlight balance
            ),
            const SizedBox(height: 40),

            // Deposit Funds Button (prominently placed at the bottom)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showDepositDialog(context),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Deposit Funds'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18), // Larger button
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                  elevation: 5, // Add elevation
                ),
              ),
            ),
            const SizedBox(height: 20), // Spacing at the bottom
          ],
        ),
      ),
    );
  }
}