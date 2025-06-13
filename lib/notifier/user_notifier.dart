import 'package:flutter/material.dart';
import '../models/equb.dart'; // Ensure your Equb and EqubMember models are correctly defined

class UserNotifier with ChangeNotifier {
  Map<String, dynamic>? _user;
  List<Equb> _joinedEqubs = [];

  Map<String, dynamic>? get user => _user;
  List<Equb> get joinedEqubs => _joinedEqubs;

  void setUser(Map<String, dynamic> newUser) {
    _user = newUser;
    notifyListeners();
  }

  void updateUserBalance(double amount) {
    if (_user != null && _user!.containsKey('balance')) {
      _user!['balance'] = (_user!['balance'] as num) + amount;
      notifyListeners();
    } else if (_user != null) {
      _user!['balance'] = amount;
      notifyListeners();
    }
  }

  bool deductUserBalance(double amount) {
    if (_user != null && _user!.containsKey('balance')) {
      double currentBalance = (_user!['balance'] as num).toDouble();
      if (currentBalance >= amount) {
        _user!['balance'] = currentBalance - amount;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Equb? findJoinedEqub(String equbId) {
    try {
      return _joinedEqubs.firstWhere((equb) => equb.id == equbId);
    } catch (e) {
      return null;
    }
  }

  EqubMember? getLoggedInUserMemberForEqub(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null || _user == null) {
      return null;
    }

    final loggedInUserId = _user!['id'];
    try {
      return equb.members.firstWhere((member) => member.id == loggedInUserId);
    } catch (e) {
      final newUserMember = EqubMember(id: loggedInUserId, name: 'You (Logged In)');
      equb.members.add(newUserMember);
      return newUserMember;
    }
  }

  void joinEqub(Equb equbToAdd) {
    final exists = _joinedEqubs.any((e) => e.id == equbToAdd.id);
    if (!exists) {
      _joinedEqubs.add(equbToAdd);
      _updateEqubAndMemberStatuses(equbToAdd.id);
      notifyListeners();
    }
  }

  void removeJoinedEqub(String equbId) {
    _joinedEqubs.removeWhere((e) => e.id == equbId);
    notifyListeners();
  }

  void updateMemberPaymentStatus(String equbId, String memberId, bool hasPaid) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    final member = equb.members.firstWhere((m) => m.id == memberId, orElse: () => EqubMember(id: '', name: ''));
    if (member.id.isNotEmpty && member.hasPaidForCurrentCycle != hasPaid) {
      member.hasPaidForCurrentCycle = hasPaid;
      if (hasPaid) {
        member.paymentHistory.add(DateTime.now());
      }
      _updateEqubAndMemberStatuses(equbId);
      notifyListeners();
    }
  }

  void simulateOtherMembersPayments(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    for (var member in equb.members) {
      if (member.id != (_user?['id'] ?? '') && !member.hasPaidForCurrentCycle) {
        final randomPaid = DateTime.now().millisecondsSinceEpoch % (member.id.hashCode % 5 + 2) == 0;
        if (randomPaid) {
          member.hasPaidForCurrentCycle = true;
          member.paymentHistory.add(DateTime.now());
        }
      }
    }
    _updateEqubAndMemberStatuses(equbId);
    notifyListeners();
  }

  void resetAllMemberPaymentsForEqub(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    for (var member in equb.members) {
      member.hasPaidForCurrentCycle = false;
    }
    _updateEqubAndMemberStatuses(equbId);
    notifyListeners();
  }

  /// Handles the logic for completing an Equb cycle (payout, rotation, next payment date).
  /// This will also reset all member payment statuses to false.
  void processEqubCycleCompletion(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    // Get the current recipient before rotating for history recording
    final currentRecipient = equb.members[equb.currentPayoutRecipientIndex];
    final payoutAmount = equb.numberOfMembers * equb.contributionAmount;

    // 🔥 NEW: Add an entry to payout history
    equb.payoutHistory.add(PayoutHistoryEntry(
      recipientName: currentRecipient.name,
      cycleDate: DateTime.now(), // Use current date as the cycle completion date
      amount: payoutAmount,
    ));

    // Then perform rotation and date calculation
    equb.rotatePayoutRecipient();
    equb.calculateNextPaymentDate();
    resetAllMemberPaymentsForEqub(equbId);

    _updateEqubAndMemberStatuses(equbId);
    notifyListeners();
  }

  bool hasCurrentUserPaidForEqub(String equbId) {
    final currentUserMember = getLoggedInUserMemberForEqub(equbId);
    return currentUserMember?.hasPaidForCurrentCycle ?? false;
  }

  List<DateTime> getCurrentUserPaymentHistoryForEqub(String equbId) {
    final currentUserMember = getLoggedInUserMemberForEqub(equbId);
    return currentUserMember?.paymentHistory ?? [];
  }

  void _updateEqubAndMemberStatuses(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    int paidCount = equb.members.where((m) => m.hasPaidForCurrentCycle).length;
    int total = equb.numberOfMembers;

    if (paidCount == total) {
      equb.equbPaymentStatus = 'Paid';
    } else {
      equb.equbPaymentStatus = 'Pending';
    }
  }

  void logout() {
    _user = null;
    _joinedEqubs.clear();
    notifyListeners();
  }
}