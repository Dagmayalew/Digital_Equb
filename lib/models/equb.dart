import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  Equb({
    required this.id,
    required this.name,
    required this.description,
    required this.contributionAmount,
    required this.frequency,
    required this.numberOfMembers,
    required this.startDate,
    required this.durationInMonths,
    required this.nextPaymentDate,
    this.equbPaymentStatus = 'Pending',
    required this.members,
    this.currentPayoutRecipientIndex = 0,
  });

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

    List<EqubMember> generatedMembers = List.generate(
      data['numberOfMembers'] ?? 0,
          (index) => EqubMember(
        id: 'member_${data['id']}_${index + 1}',
        name: 'Member ${index + 1}',
        hasPaidForCurrentCycle: false,
      ),
    );

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
    if (frequency == 'ወራዊ') {
      nextPaymentDate = DateTime(nextPaymentDate.year, nextPaymentDate.month + 1, nextPaymentDate.day);
      if (nextPaymentDate.day != startDate.day) {
        int targetDay = startDate.day;
        int newMonth = nextPaymentDate.month;
        int newYear = nextPaymentDate.year;
        while (true) {
          try {
            nextPaymentDate = DateTime(newYear, newMonth, targetDay);
            break;
          } catch (e) {
            targetDay--;
            if (targetDay <= 0) {
              nextPaymentDate = DateTime(newYear, newMonth + 1, 0);
              break;
            }
          }
        }
      }
    } else if (frequency == 'ሳምንታዊ') {
      nextPaymentDate = nextPaymentDate.add(const Duration(days: 7));
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
