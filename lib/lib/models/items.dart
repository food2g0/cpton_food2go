import 'package:cloud_firestore/cloud_firestore.dart';

class Items {
  final String productsID;
  final String menuID;
  final String sellersUID;
  final String productDescription;
  final String productTitle;
  final int productPrice;
  final int productQuantity;
  final String thumbnailUrl;
  final List<Map<String, dynamic>> variations; // Updated field for variations
  final Timestamp timestamp;

  Items({
    required this.timestamp,
    required this.productsID,
    required this.menuID,
    required this.sellersUID,
    required this.productDescription,
    required this.productTitle,
    required this.productPrice,
    required this.productQuantity,
    required this.thumbnailUrl,
    required this.variations, // Updated constructor to include variations
  });

  Items copyWith({
    String? productsID,
    String? menuID,
    String? sellersUID,
    String? productDescription,
    String? productTitle,
    int? productPrice,
    int? productQuantity,
    String? thumbnailUrl,
    List<Map<String, dynamic>>? variations, // Updated copyWith to include variations
  }) {
    return Items(
      timestamp: timestamp,
      productsID: productsID ?? this.productsID,
      menuID: menuID ?? this.menuID,
      sellersUID: sellersUID ?? this.sellersUID,
      productDescription: productDescription ?? this.productDescription,
      productTitle: productTitle ?? this.productTitle,
      productPrice: productPrice ?? this.productPrice,
      productQuantity: productQuantity ?? this.productQuantity,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      variations: variations ?? this.variations, // Updated copyWith to include variations
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variation': variations,
      'productsID': productsID,
      'menuID': menuID,
      'sellersUID': sellersUID,
      'productDescription': productDescription,
      'productTitle': productTitle,
      'productPrice': productPrice,
      'productQuantity': productQuantity,
      'thumbnailUrl': thumbnailUrl,
      'variations': variations, // Updated toJson to include variations
    };
  }

  factory Items.fromJson(Map<String, dynamic> json) {
    return Items(
      timestamp: json['timestamp'] ?? Timestamp.now(), // Use the appropriate default value
      productsID: json['productsID'] ?? '',
      menuID: json['menuID'] ?? '',
      sellersUID: json['sellersUID'] ?? '',
      productDescription: json['productDescription'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productPrice: json['productPrice'] ?? 0,
      productQuantity: json['productQuantity'] ?? 0,
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      variations: List<Map<String, dynamic>>.from(json['variations'] ?? []), // Updated fromJson to parse variations
    );
  }
}
