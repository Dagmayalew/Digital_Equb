// lib/screen/equb_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for NumberFormat
import 'package:provider/provider.dart';

import '../models/equb.dart'; // Import your Equb model
import '../notifier/user_notifier.dart';
import 'joined_equb_detail_screen.dart'; // Import the joined detail screen

class EqubDetailScreen extends StatefulWidget {
  final Map<String, dynamic> equbData;

  const EqubDetailScreen({super.key, required this.equbData});

  @override
  State<EqubDetailScreen> createState() => _EqubDetailScreenState();
}

class _EqubDetailScreenState extends State<EqubDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final userNotifier = Provider.of<UserNotifier>(context);

    // Create an Equb object from the passed map data
    final Equb currentEqub = Equb.fromMap(widget.equbData);

    // Check if the user has already joined this equb
    final bool isJoined = userNotifier.joinedEqubs.any((equb) => equb.id == currentEqub.id);

    final double totalPayoutAmount = currentEqub.numberOfMembers * currentEqub.contributionAmount;
    final String formattedTotalPayoutAmount = NumberFormat.currency(locale: 'en_US', symbol: 'Birr').format(totalPayoutAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Equb Details",
          style: TextStyle(fontWeight: FontWeight.bold), // Make app bar title bold
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Equb Name and Description Section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08), // Light background for this section
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentEqub.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentEqub.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Divider for visual separation
            Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              thickness: 1.5,
            ),
            const SizedBox(height: 20),

            // Equb Details Section
            _buildDetailSectionTitle(context, 'Equb Overview', Icons.info_outline), // More descriptive title
            const SizedBox(height: 10),
            _buildDetailCard(
              context,
              [
                _buildDetailRow(
                  context,
                  Icons.monetization_on_outlined, // Updated icon
                  'Contribution Amount', // More descriptive label
                  '${currentEqub.contributionAmount.toStringAsFixed(2)} Birr',
                  valueColor: Theme.of(context).colorScheme.tertiary, // Highlight contribution
                ),
                _buildDetailRow(
                  context,
                  Icons.trending_up,
                  'Total Payout (When you win)',
                  formattedTotalPayoutAmount,
                  valueColor: Colors.green[700], // Highlight the potential winning amount
                ),
                _buildDetailRow(context, Icons.event_repeat, 'Payment Frequency', currentEqub.frequency), // More descriptive label
                _buildDetailRow(context, Icons.group, 'Number of Members', '${currentEqub.numberOfMembers}'),
                _buildDetailRow(
                    context,
                    Icons.calendar_month_outlined, // Updated icon
                    'Start Date',
                    DateFormat('MMMM dd, yyyy').format(currentEqub.startDate)
                ),
                _buildDetailRow(context, Icons.timelapse, 'Total Duration', '${currentEqub.durationInMonths} months'),
              ],
            ),
            const SizedBox(height: 40),

            // Join Equb Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(isJoined ? Icons.check_circle_outline : Icons.group_add),
                label: Text(isJoined ? "You've Already Joined!" : "Join This Equb"), // More friendly label
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  backgroundColor: isJoined
                      ? Colors.grey[400] // Grey if already joined
                      : Theme.of(context).colorScheme.primary, // Primary color for join button
                  foregroundColor: isJoined
                      ? Colors.grey[700]
                      : Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                onPressed: isJoined
                    ? null // Disable button if already joined
                    : () {
                  userNotifier.joinEqub(currentEqub);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 You have successfully joined ${currentEqub.name}!'), // More celebratory message
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating, // Make it float
                    ),
                  );

                  // Navigate to the JoinedEqubDetailScreen and remove this screen from stack
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinedEqubDetailScreen(equbData: currentEqub),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // How It Works Section
            _buildDetailSectionTitle(context, 'How Equb Works', Icons.help_outline), // More descriptive title
            const SizedBox(height: 10),
            _buildDetailCard(
              context,
              [
                _buildPolicyPoint('Each member contributes the agreed amount at the set frequency.', Icons.money),
                _buildPolicyPoint('One lucky member receives the full payout in each cycle.', Icons.emoji_events_outlined), // Updated icon
                _buildPolicyPoint('The payout recipient rotates fairly among all members.', Icons.rotate_right_outlined), // Updated icon
                _buildPolicyPoint('Timely payments ensure smooth operation for everyone.', Icons.check_circle_outline), // Updated icon
                _buildPolicyPoint('Your payment status is transparently tracked within the Equb.', Icons.track_changes),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDetailSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDetailCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyPoint(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}