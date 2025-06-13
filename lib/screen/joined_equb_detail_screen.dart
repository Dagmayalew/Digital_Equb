import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/equb.dart'; // Ensure this import is present
import '../notifier/user_notifier.dart';

class JoinedEqubDetailScreen extends StatefulWidget {
  final Equb equbData;

  const JoinedEqubDetailScreen({super.key, required this.equbData});

  @override
  State<JoinedEqubDetailScreen> createState() => _JoinedEqubDetailScreenState();
}

class _JoinedEqubDetailScreenState extends State<JoinedEqubDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Helper for showing snackbars
  void _showPaymentConfirmationSnackbar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- Payment Flow Methods ---

  Future<void> _handlePaymentFlow(UserNotifier userNotifier, Equb currentEqub, EqubMember currentUserMember) async {
    // Check if already paid
    if (currentUserMember.hasPaidForCurrentCycle) {
      _showPaymentConfirmationSnackbar(
        context,
        'You have already paid for this cycle!',
        backgroundColor: Colors.blue,
      );
      return;
    }

    final double requiredAmount = currentEqub.contributionAmount;
    final double? userBalance = (userNotifier.user?['balance'] as num?)?.toDouble();

    if (userBalance == null || userBalance < requiredAmount) {
      _showPaymentConfirmationSnackbar(
        context,
        'Insufficient balance! You need ${requiredAmount.toStringAsFixed(2)} Birr to pay.',
        backgroundColor: Colors.red,
      );
      return;
    }

    // 1. Show Agreement Policy
    final bool? agreementAccepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Payment Agreement Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'By proceeding with this payment, you acknowledge and agree to the following terms for the "${currentEqub.name}" Equb:',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 15),
              _buildPolicyPoint('1. All payments are final and non-refundable.', Icons.gavel_outlined),
              _buildPolicyPoint('2. Contributions are due strictly by the next payment date.', Icons.access_time),
              _buildPolicyPoint('3. Failure to pay may result in penalties or exclusion as per Equb rules.', Icons.warning_amber_outlined),
              _buildPolicyPoint('4. Your payment will be securely recorded and shared with all Equb members.', Icons.verified_user_outlined),
              _buildPolicyPoint('5. You understand the current payout recipient and your position in the queue.', Icons.queue_play_next),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Accept & Continue'),
          ),
        ],
      ),
    );

    if (agreementAccepted == true) {
      // 2. Show Payment Confirmation if agreement accepted
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Confirm Your Contribution',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'You are confirming a payment of ${currentEqub.contributionAmount.toStringAsFixed(2)} Birr for the "${currentEqub.name}" Equb. This action cannot be undone. Are you sure?',
            style: Theme.of(ctx).textTheme.bodyLarge,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final bool deductionSuccess = userNotifier.deductUserBalance(requiredAmount);

        if (deductionSuccess) {
          _processPayment(userNotifier, currentEqub.id, currentUserMember.id);
        } else {
          _showPaymentConfirmationSnackbar(
            context,
            'Payment failed: Balance became insufficient during processing. Please deposit more funds.',
            backgroundColor: Colors.red,
          );
        }
      } else {
        _showPaymentConfirmationSnackbar(
          context,
          'Payment process cancelled.',
          backgroundColor: Colors.redAccent,
        );
      }
    } else {
      _showPaymentConfirmationSnackbar(
        context,
        'Agreement declined. Payment not processed.',
        backgroundColor: Colors.orangeAccent,
      );
    }
  }

  void _processPayment(UserNotifier userNotifier, String equbId, String currentUserMemberId) {
    userNotifier.updateMemberPaymentStatus(equbId, currentUserMemberId, true);
    _showPaymentConfirmationSnackbar(context, 'Payment recorded successfully!');

    userNotifier.simulateOtherMembersPayments(equbId);

    final updatedEqub = userNotifier.findJoinedEqub(equbId);
    if (updatedEqub != null && updatedEqub.allMembersPaidForCurrentCycle()) {
      _showPayoutNotification(userNotifier, updatedEqub);
      userNotifier.processEqubCycleCompletion(equbId);
    }
  }

  void _showPayoutNotification(UserNotifier userNotifier, Equb currentEqub) {
    final recipient = currentEqub.members[currentEqub.currentPayoutRecipientIndex];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Payout Cycle Complete!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        content: Text.rich(
          TextSpan(
            text: '${recipient.name} is the lucky recipient for this cycle\'s payout of ',
            children: [
              TextSpan(
                text: '${NumberFormat.currency(locale: 'en_US', symbol: 'Birr').format(currentEqub.numberOfMembers * currentEqub.contributionAmount)}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const TextSpan(text: '!\n\n'),
              const TextSpan(
                  text: 'A new cycle has begun, and all members\' contributions are reset to "Pending".',
                  style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Great!'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserNotifier>(
      builder: (context, userNotifier, child) {
        final Equb? currentEqub = userNotifier.findJoinedEqub(widget.equbData.id);
        final EqubMember? currentUserMember = userNotifier.getLoggedInUserMemberForEqub(
          widget.equbData.id,
        );

        if (currentEqub == null || currentUserMember == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Equb Detail')),
            body: const Center(child: Text('Equb or user data not found.')),
          );
        }

        final String name = currentEqub.name;
        final String description = currentEqub.description;
        final String contributionAmount = currentEqub.contributionAmount.toStringAsFixed(2);
        final String frequency = currentEqub.frequency;
        final String numberOfMembers = currentEqub.numberOfMembers.toString();
        final String startDate = DateFormat('MMMM dd,yyyy').format(currentEqub.startDate);
        final String durationInMonths = currentEqub.durationInMonths.toString();
        final String nextPaymentDate = DateFormat('MMMM dd,yyyy').format(currentEqub.nextPaymentDate);
        final String equbPaymentStatus = currentEqub.equbPaymentStatus;
        final String currentRecipientName = currentEqub.members.isEmpty
            ? 'N/A'
            : currentEqub.members[currentEqub.currentPayoutRecipientIndex].name;

        // Calculate the total payout amount
        final double totalPayoutAmount = currentEqub.numberOfMembers * currentEqub.contributionAmount;
        final String formattedTotalPayoutAmount = NumberFormat.currency(locale: 'en_US', symbol: 'Birr').format(totalPayoutAmount);

        final List<PayoutHistoryEntry> payoutHistory = currentEqub.payoutHistory;


        return Scaffold(
          appBar: AppBar(
            title: Text(name),
            centerTitle: true,
            elevation: 4,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
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
                    _buildDetailRow(context, Icons.attach_money, 'Contribution', '$contributionAmount Birr'),
                    _buildDetailRow(context, Icons.event_repeat, 'Frequency', frequency),
                    _buildDetailRow(context, Icons.group, 'Members', numberOfMembers),
                    // 🔥 NEW: Display total payout amount
                    _buildDetailRow(
                      context,
                      Icons.trending_up, // Or a suitable icon like Icons.savings
                      'Total Payout when You Win',
                      formattedTotalPayoutAmount,
                      valueColor: Colors.green[700], // Highlight the win amount
                    ),
                    _buildDetailRow(context, Icons.calendar_today, 'Start Date', startDate),
                    _buildDetailRow(context, Icons.timelapse, 'Duration', '$durationInMonths months'),
                    _buildDetailRow(context, Icons.next_plan, 'Next Payment', nextPaymentDate),
                    _buildDetailRow(
                      context,
                      Icons.credit_card,
                      'Equb Status',
                      equbPaymentStatus,
                      valueColor: currentEqub.getPaymentStatusColor(),
                    ),
                    _buildDetailRow(context, Icons.person, 'Current Recipient', currentRecipientName),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: Text(
                      currentUserMember.hasPaidForCurrentCycle ? "You Paid (Current Cycle)" : "Pay Contribution",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      backgroundColor: currentUserMember.hasPaidForCurrentCycle
                          ? Colors.grey[400]
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: currentUserMember.hasPaidForCurrentCycle
                          ? Colors.grey[700]
                          : Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: currentUserMember.hasPaidForCurrentCycle
                        ? null
                        : () => _handlePaymentFlow(userNotifier, currentEqub, currentUserMember),
                  ),
                ),
                const SizedBox(height: 30),
                _buildDetailSectionTitle(context, 'Individual Contributions', Icons.person_pin),
                const SizedBox(height: 10),
                _buildDetailCard(
                  context,
                  currentEqub.members.map((member) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            member.name + (member.id == currentUserMember.id ? ' (You)' : ''),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: member.id == currentUserMember.id ? FontWeight.bold : FontWeight.normal,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: member.hasPaidForCurrentCycle ? Colors.green[100] : Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            member.hasPaidForCurrentCycle ? 'Paid' : 'Pending',
                            style: TextStyle(
                              fontSize: 14,
                              color: member.hasPaidForCurrentCycle ? Colors.green[700] : Colors.orange[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 30),
                _buildDetailSectionTitle(context, 'Payout History', Icons.history),
                const SizedBox(height: 10),
                if (payoutHistory.isEmpty)
                  _buildDetailCard(
                    context,
                    [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'No past payouts yet. Be the first to contribute!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  )
                else
                  _buildDetailCard(
                    context,
                    payoutHistory.reversed.map((entry) => Padding( // Display in reverse chronological order
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recipient: ${entry.recipientName}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date: ${DateFormat('MMM dd, yyyy').format(entry.cycleDate)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${NumberFormat.currency(locale: 'en_US', symbol: 'Birr').format(entry.amount)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          if (payoutHistory.indexOf(entry) < payoutHistory.length -1) // Add a divider if not the last item
                            Divider(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5), height: 15),
                        ],
                      ),
                    )).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Helper Widgets for UX ---

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