// lib/services/fake_payment_service.dart
import 'dart:math';

/// A service to simulate payment processing.
class FakePaymentService {
  /// Simulates a deposit transaction.
  /// Returns `true` for success, `false` for failure.
  ///
  /// For demonstration:
  /// - Deposits of amount < 10.0 always fail.
  /// - Other deposits have a 80% chance of success.
  Future<bool> processDeposit(double amount) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (amount < 10.0) {
      print('FakePaymentService: Deposit of $amount Birr failed (amount too low).');
      return false; // Simulate failure for small amounts
    }

    // Simulate random success/failure for other amounts
    final random = Random();
    final bool success = random.nextDouble() > 0.2; // 80% chance of success

    if (success) {
      print('FakePaymentService: Deposit of $amount Birr succeeded.');
      return true;
    } else {
      print('FakePaymentService: Deposit of $amount Birr failed (simulated network error).');
      return false;
    }
  }
}