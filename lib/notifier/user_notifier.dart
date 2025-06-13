import 'package:flutter/material.dart';
import '../models/equb.dart'; // Ensure your Equb and EqubMember models are correctly defined

class UserNotifier with ChangeNotifier {
  Map<String, dynamic>? _user;
  List<Equb> _joinedEqubs = []; // Now stores Equb objects for strong typing

  Map<String, dynamic>? get user => _user;
  List<Equb> get joinedEqubs => _joinedEqubs;

  void setUser(Map<String, dynamic> newUser) {
    _user = newUser;
    notifyListeners();
  }

  /// Finds a joined Equb by its ID from the global list.
  Equb? findJoinedEqub(String equbId) {
    try {
      return _joinedEqubs.firstWhere((equb) => equb.id == equbId);
    } catch (e) {
      // If Equb is not found, return null
      return null;
    }
  }

  /// Gets the currently logged-in user's EqubMember object for a specific Equb.
  /// If the user is not found as a member within that Equb, a simulated member is added.
  EqubMember? getLoggedInUserMemberForEqub(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null || _user == null) {
      return null;
    }

    final loggedInUserId = _user!['id'];
    try {
      return equb.members.firstWhere((member) => member.id == loggedInUserId);
    } catch (e) {
      // If the loggedInUserId doesn't match any existing member in the Equb,
      // create a specific member for the logged-in user and add it to the Equb's members.
      // In a real application, this user would likely be part of the initial Equb data.
      final newUserMember = EqubMember(id: loggedInUserId, name: 'You (Logged In)');
      equb.members.add(newUserMember);
      return newUserMember;
    }
  }

  /// Adds a new Equb to the joined list.
  /// It also calls _updateEqubAndMemberStatuses to ensure the initial status is set.
  void joinEqub(Equb equbToAdd) {
    final exists = _joinedEqubs.any((e) => e.id == equbToAdd.id);
    if (!exists) {
      _joinedEqubs.add(equbToAdd);
      _updateEqubAndMemberStatuses(equbToAdd.id); // Update status immediately upon joining
      notifyListeners();
    }
  }

  /// Removes a joined Equb from the list.
  void removeJoinedEqub(String equbId) {
    _joinedEqubs.removeWhere((e) => e.id == equbId);
    notifyListeners();
  }

  /// Updates the payment status for a specific member within an Equb.
  void updateMemberPaymentStatus(String equbId, String memberId, bool hasPaid) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    final member = equb.members.firstWhere((m) => m.id == memberId, orElse: () => EqubMember(id: '', name: ''));
    if (member.id.isNotEmpty && member.hasPaidForCurrentCycle != hasPaid) {
      member.hasPaidForCurrentCycle = hasPaid;
      if (hasPaid) {
        member.paymentHistory.add(DateTime.now());
      }
      _updateEqubAndMemberStatuses(equbId); // Recalculate global status for the Equb
      notifyListeners();
    }
  }

  /// Simulates other members' payments for an Equb.
  /// In a real application, this would typically come from a backend or real-time updates.
  void simulateOtherMembersPayments(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    for (var member in equb.members) {
      if (member.id != (_user?['id'] ?? '') && !member.hasPaidForCurrentCycle) {
        // Simulate a payment for other members
        final randomPaid = DateTime.now().millisecondsSinceEpoch % (member.id.hashCode % 5 + 2) == 0;
        if (randomPaid) {
          member.hasPaidForCurrentCycle = true;
          member.paymentHistory.add(DateTime.now());
        }
      }
    }
    _updateEqubAndMemberStatuses(equbId); // Update overall status after simulation
    notifyListeners();
  }

  /// Resets all members' payment status to 'Pending' for a specific Equb.
  /// This is typically called at the beginning of a new cycle.
  void resetAllMemberPaymentsForEqub(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    for (var member in equb.members) {
      member.hasPaidForCurrentCycle = false;
    }
    _updateEqubAndMemberStatuses(equbId); // Update overall status
    notifyListeners();
  }


  /// Handles the logic for completing an Equb cycle (payout, rotation, next payment date).
  /// This will also reset all member payment statuses to false.
  void processEqubCycleCompletion(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    equb.rotatePayoutRecipient(); // This method within Equb should also reset all member statuses
    equb.calculateNextPaymentDate(); // Advance the next payment date for the new cycle
    _updateEqubAndMemberStatuses(equbId); // Update global status for the Equb
    notifyListeners();
  }

  /// Checks if the currently logged-in user has paid for the current cycle of a specific Equb.
  bool hasCurrentUserPaidForEqub(String equbId) {
    final currentUserMember = getLoggedInUserMemberForEqub(equbId);
    return currentUserMember?.hasPaidForCurrentCycle ?? false;
  }

  /// Gets the payment history of the currently logged-in user for a specific Equb.
  List<DateTime> getCurrentUserPaymentHistoryForEqub(String equbId) {
    final currentUserMember = getLoggedInUserMemberForEqub(equbId);
    return currentUserMember?.paymentHistory ?? [];
  }

  /// Updates the overall Equb payment status (Paid, Pending, Overdue) based on members' statuses.
  /// This is a private helper method called internally when member payments change.
  void _updateEqubAndMemberStatuses(String equbId) {
    final equb = findJoinedEqub(equbId);
    if (equb == null) return;

    int paidCount = equb.members.where((m) => m.hasPaidForCurrentCycle).length;
    int total = equb.numberOfMembers;

    if (paidCount == total) {
      equb.equbPaymentStatus = 'Paid';
    } else if (paidCount >= total ~/ 2) {
      equb.equbPaymentStatus = 'Pending';
    }
    // notifyListeners is called by the public methods that invoke this helper.
  }

  /// Clears user data and joined Equbs upon logout.
  void logout() {
    _user = null;
    _joinedEqubs.clear();
    notifyListeners();
  }
}