// lib/screen/equb_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/equb.dart'; // Import your Equb model
import '../notifier/user_notifier.dart';
import 'joined_equb_detail_screen.dart'; // Import the joined detail screen

class EqubDetailScreen extends StatefulWidget {
  // It's currently expecting a Map<String, dynamic> from EqubListScreen
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Equb Details"),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
            const SizedBox(height: 25),
            Divider(
              color: Theme.of(context).colorScheme.outlineVariant,
              thickness: 1.5,
            ),
            const SizedBox(height: 20),
            _buildDetailSectionTitle(context, 'Equb Details', Icons.info_outline),
            const SizedBox(height: 10),
            _buildDetailCard(
              context,
              [
                _buildDetailRow(context, Icons.attach_money, 'Contribution', '${currentEqub.contributionAmount} Birr'),
                _buildDetailRow(context, Icons.event_repeat, 'Frequency', currentEqub.frequency),
                _buildDetailRow(context, Icons.group, 'Members', '${currentEqub.numberOfMembers}'),
                _buildDetailRow(context, Icons.calendar_today, 'Start Date', DateFormat('MMMM dd, yyyy').format(currentEqub.startDate)),
                _buildDetailRow(context, Icons.timelapse, 'Duration', '${currentEqub.durationInMonths} months'),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(isJoined ? Icons.check_circle_outline : Icons.group_add),
                label: Text(isJoined ? "Already Joined" : "Join Equb"),
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
                onPressed: isJoined // Disable if already joined
                    ? null
                    : () {
                  // Call the joinEqub method from UserNotifier
                  userNotifier.joinEqub(currentEqub);

                  // Optionally show a confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You have joined ${currentEqub.name}!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Navigate to the JoinedEqubDetailScreen after joining
                  // Pass the actual Equb object, as JoinedEqubDetailScreen now expects it
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
            _buildDetailSectionTitle(context, 'How it works', Icons.policy),
            const SizedBox(height: 10),
            _buildDetailCard(
              context,
              [
                _buildPolicyPoint('Each member contributes the agreed amount at the set frequency.', Icons.money),
                _buildPolicyPoint('One member receives the total payout in each cycle.', Icons.person_add),
                _buildPolicyPoint('The payout recipient rotates among members each cycle.', Icons.sync),
                _buildPolicyPoint('All members are expected to pay their contributions on time.', Icons.timer),
                _buildPolicyPoint('Payment status is tracked for transparency.', Icons.track_changes),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets (No changes needed unless you want to style them) ---

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