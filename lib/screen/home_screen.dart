import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

import '../notifier/user_notifier.dart';
import 'joined_equb_detail_screen.dart';
import 'login_screen.dart';
import '../models/equb.dart'; // Import the Equb model

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    Provider.of<UserNotifier>(context, listen: false).logout();
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  // Helper for showing a temporary deposit dialog
  void _showDepositDialog(BuildContext context, UserNotifier userNotifier) {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deposit Funds'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (Birr)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                userNotifier.updateUserBalance(amount);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${amount.toStringAsFixed(2)} Birr deposited successfully!')),
                );
                Navigator.of(ctx).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount.')),
                );
              }
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>( // Use Consumer to rebuild only parts that depend on userNotifier
      builder: (context, userNotifier, child) {
        final joinedEqubs = userNotifier.joinedEqubs;
        final user = userNotifier.user ?? {};
        final double userBalance = (user['balance'] as num?)?.toDouble() ?? 0.0;
        final String formattedBalance = NumberFormat.currency(locale: 'en_US', symbol: 'Birr').format(userBalance);


        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 4,
            actions: [
              Tooltip(
                message: "Logout",
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () => _logout(context),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.waving_hand,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Hello, ${user['name'] ?? 'Equb Member'}",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 🔥 NEW: User Balance Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Theme.of(context).colorScheme.tertiaryContainer, // A light, complementary color
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Balance',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onTertiaryContainer.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              formattedBalance,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showDepositDialog(context, userNotifier),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Deposit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Your Joined Equbs",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Divider(
                  height: 20,
                  thickness: 1.5, // Slightly thinner for better aesthetics
                  color: Colors.grey,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: joinedEqubs.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "You haven't joined any Equbs yet.",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  )
                      : ListView.builder(
                    itemCount: joinedEqubs.length,
                    itemBuilder: (context, index) {
                      final equb = joinedEqubs[index];
                      final String name = equb.name;
                      final String amount = equb.contributionAmount.toStringAsFixed(2); // Format amount
                      final String frequency = equb.frequency;
                      final String status = equb.equbPaymentStatus;

                      Color statusColor = equb.getPaymentStatusColor();
                      IconData statusIcon = status == 'Paid' ? Icons.check_circle : Icons.pending; // Icons for status

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => JoinedEqubDetailScreen(equbData: equb),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.savings,
                                    size: 30,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "$amount Birr • $frequency",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row( // 🔥 NEW: Row for icon and text status
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(statusIcon, size: 14, color: statusColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}