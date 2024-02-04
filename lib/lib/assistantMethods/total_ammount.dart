import 'package:flutter/cupertino.dart';

class TotalAmount extends ChangeNotifier {
  double _totalAmount = 0;
  double get tAmount => _totalAmount;

  void displayTotalAmount(double number) {
    _totalAmount = number;
    notifyListeners(); // Notify listeners immediately without delay
  }
}
