import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Required for min function

// Define the PayoutHistoryEntry class
class PayoutHistoryEntry {
  final String recipientName;
  final DateTime cycleDate;
  final double amount;

  PayoutHistoryEntry({
    required this.recipientName,
    required this.cycleDate,
    required this.amount,
  });
}


// Assume your EqubMember class is defined similar to this:
class EqubMember {
  final String id;
  final String name;
  bool hasPaidForCurrentCycle;
  final List<DateTime> paymentHistory;

  EqubMember({
    required this.id,
    required this.name,
    this.hasPaidForCurrentCycle = false,
    List<DateTime>? paymentHistory,
  }) : paymentHistory = paymentHistory ?? [];
}

class Equb {
  final String id;
  final String name;
  final String description;
  final double contributionAmount;
  final String frequency;
  final int numberOfMembers;
  final DateTime startDate;
  final int durationInMonths;
  DateTime nextPaymentDate;
  String equbPaymentStatus; // Only 'Paid' or 'Pending'
  final List<EqubMember> members;
  int currentPayoutRecipientIndex;
  // 🔥 NEW: List to store payout history
  final List<PayoutHistoryEntry> payoutHistory;

  Equb({
    required this.id,
    required this.name,
    required this.description,
    required this.contributionAmount,
    required this.frequency,
    required this.numberOfMembers,
    required this.startDate,
    required this.nextPaymentDate,
    this.equbPaymentStatus = 'Pending',
    required this.members,
    this.currentPayoutRecipientIndex = 0,
    // 🔥 Initialize payoutHistory in the constructor
    List<PayoutHistoryEntry>? payoutHistory,
    required this.durationInMonths, // Ensure this is also required
  }) : payoutHistory = payoutHistory ?? []; // Initialize as an empty list if null


  factory Equb.fromMap(Map<String, dynamic> data) {
    DateTime parsedStartDate;
    try {
      parsedStartDate = DateFormat('MMMM dd,yyyy').parse(data['startDate']);
    } catch (e) {
      parsedStartDate = DateTime.now();
      print('Error parsing startDate: $e');
    }

    DateTime parsedNextPaymentDate;
    try {
      parsedNextPaymentDate = DateFormat('MMMM dd,yyyy').parse(data['nextPaymentDate']);
    } catch (e) {
      parsedNextPaymentDate = DateTime.now();
      print('Error parsing nextPaymentDate: $e');
    }

    // In a real application, 'members' and 'payoutHistory' would likely come from 'data' as well.
    // This is a placeholder for demonstration purposes.
    List<EqubMember> generatedMembers = List.generate(
      data['numberOfMembers'] ?? 0,
          (index) => EqubMember(
        id: 'member_${data['id']}_${index + 1}',
        name: 'Member ${index + 1}',
        hasPaidForCurrentCycle: false,
      ),
    );

    // 🔥 Add dummy payout history for demonstration purposes if not present in data
    List<PayoutHistoryEntry> dummyPayoutHistory = [];
    if (data['payoutHistory'] != null) {
      // Assuming payoutHistory in data is a List<Map<String, dynamic>>
      for (var entryMap in data['payoutHistory']) {
        dummyPayoutHistory.add(PayoutHistoryEntry(
          recipientName: entryMap['recipientName'],
          cycleDate: DateFormat('MMMM dd,yyyy').parse(entryMap['cycleDate']),
          amount: (entryMap['amount'] as num).toDouble(),
        ));
      }
    } else {
      // Create some fake history for demonstration on new Equbs
      // This part will only run if data['payoutHistory'] is null
      final now = DateTime.now();
      if (data['numberOfMembers'] > 0) {
        // Simulate a few past payouts for older Equbs
        for (int i = 1; i <= 2 && i <= data['numberOfMembers']; i++) {
          dummyPayoutHistory.add(PayoutHistoryEntry(
            recipientName: 'Member ${data['numberOfMembers'] - i + 1}', // Fake recipients
            cycleDate: now.subtract(Duration(days: 30 * i)), // A month ago, two months ago etc.
            amount: (data['numberOfMembers'] as int) * (data['contributionAmount'] as num).toDouble(),
          ));
        }
      }
    }


    return Equb(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Untitled Equb',
      description: data['description'] ?? 'No description available.',
      contributionAmount: (data['contributionAmount'] as num?)?.toDouble() ?? 0.0,
      frequency: data['frequency'] ?? 'Not specified',
      numberOfMembers: data['numberOfMembers'] ?? 0,
      startDate: parsedStartDate,
      durationInMonths: data['durationInMonths'] ?? 0,
      nextPaymentDate: parsedNextPaymentDate,
      equbPaymentStatus: (data['paymentStatus'] == 'Paid') ? 'Paid' : 'Pending',
      members: generatedMembers,
      payoutHistory: dummyPayoutHistory, // Pass the parsed or generated history
    );
  }

  Color getPaymentStatusColor() {
    switch (equbPaymentStatus) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void calculateNextPaymentDate() {
    int originalDay = startDate.day;

    switch (frequency.toLowerCase()) {
      case 'daily':
        nextPaymentDate = nextPaymentDate.add(const Duration(days: 1));
        break;
      case 'weekly':
        nextPaymentDate = nextPaymentDate.add(const Duration(days: 7));
        break;
      case 'bi-weekly':
        nextPaymentDate = nextPaymentDate.add(const Duration(days: 14));
        break;
      case 'monthly':
        int newMonth = nextPaymentDate.month + 1;
        int newYear = nextPaymentDate.year;

        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        }

        final int lastDayOfNextMonth = DateTime(newYear, newMonth + 1, 0).day;
        int targetDay = min(originalDay, lastDayOfNextMonth);

        nextPaymentDate = DateTime(newYear, newMonth, targetDay);
        break;
      default:
        int newMonth = nextPaymentDate.month + 1;
        int newYear = nextPaymentDate.year;
        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        }
        final int lastDayOfNextMonth = DateTime(newYear, newMonth + 1, 0).day;
        int targetDay = min(originalDay, lastDayOfNextMonth);
        nextPaymentDate = DateTime(newYear, newMonth, targetDay);
        break;
    }
  }

  bool allMembersPaidForCurrentCycle() {
    return members.every((member) => member.hasPaidForCurrentCycle);
  }

  void rotatePayoutRecipient() {
    currentPayoutRecipientIndex = (currentPayoutRecipientIndex + 1) % members.length;
    for (var member in members) {
      member.hasPaidForCurrentCycle = false;
    }
    equbPaymentStatus = 'Pending';
  }
}