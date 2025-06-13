// lib/screens/profile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fake_payment_service.dart';
import '../notifier/user_notifier.dart'; // Ensure this path is correct

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper widget to build a consistent info row
  Widget _buildProfileInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
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

  // 🔥 NEW: Method to show deposit dialog
  Future<void> _showDepositDialog(BuildContext context) async {
    final TextEditingController amountController = TextEditingController();
    final FakePaymentService paymentService = FakePaymentService();
    final UserNotifier userNotifier = Provider.of<UserNotifier>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Deposit Funds'),
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
                  validator: (value) {
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
                  'Note: This is a simulated payment service. Amounts less than 10 Birr will fail.',
                  style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                amountController.dispose();
              },
            ),
            ElevatedButton(
              child: const Text('Deposit'),
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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing deposit...'), backgroundColor: Colors.orange, duration: Duration(seconds: 3)),
                );

                // Simulate payment
                final bool success = await paymentService.processDeposit(depositAmount);

                if (success) {
                  userNotifier.updateUserBalance(depositAmount); // Update global balance
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deposit of ${depositAmount.toStringAsFixed(2)} Birr successful!'), backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deposit of ${depositAmount.toStringAsFixed(2)} Birr failed. Try again.'), backgroundColor: Colors.red),
                  );
                }
              },
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
    final String userBalance = (user['balance'] ?? 0.0).toStringAsFixed(2);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Deposit Funds',
            onPressed: () => _showDepositDialog(context), // 🔥 NEW: Deposit button in AppBar
          ),
          const SizedBox(width: 8),
          // Optionally add settings or edit profile icon here
        ],
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
            const SizedBox(height: 15),
            _buildProfileInfoRow(
              context,
              icon: Icons.account_balance_wallet_outlined,
              label: 'Balance',
              value: '$userBalance Birr',
            ),
            const SizedBox(height: 40),

            // You can move the deposit button here if you prefer it in the body
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: () => _showDepositDialog(context),
            //     icon: const Icon(Icons.add_circle_outline),
            //     label: const Text('Deposit Funds'),
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 15),
            //       textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //       backgroundColor: Theme.of(context).colorScheme.secondary,
            //       foregroundColor: Theme.of(context).colorScheme.onSecondary,
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}