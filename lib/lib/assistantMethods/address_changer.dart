import 'package:flutter/cupertino.dart';

class AddressChanger extends ChangeNotifier
{
  int _counter = 0;
  int get count => _counter;

  displayResult(dynamic newValue)
  {
    _counter = newValue;
    notifyListeners();
  }
}

class SelectedAddress with ChangeNotifier {
  int? selectedAddressIndex;

  void selectAddress(int index) {
    selectedAddressIndex = index;
    notifyListeners();
  }
}
