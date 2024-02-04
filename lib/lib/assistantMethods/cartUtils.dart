class CartHelper {
  static double calculateTotalAmount(double productPrice, int quantity, {double shippingFee = 0}) {
    double subTotalAmount = (productPrice * quantity) + shippingFee;
    return subTotalAmount;
  }

  static double calculateSubTotalAmount(double productPrice, int quantity) {
    double totalAmount = productPrice * quantity;
    return totalAmount;
  }
}
