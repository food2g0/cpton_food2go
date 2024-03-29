import 'package:cloud_firestore/cloud_firestore.dart';

class Menus
{
  String? menuID;
  String? sellersUID;
  String? productsID;
  String? productTitle;
  String? productDescription;
  String? status;
  int? productPrice;
  int? productQuantity;
  Timestamp? publishedDate;
  String? thumbnailUrl;
  String? sellersImageUrl;
  String? sellersName;
  String? sellersAddress;
  String? menuTitle;
  String? Open;
  double? lat;
  double? lng;

 Menus
      ({
   this.lat,
   this.lng,
    this.menuID,
    this.menuTitle,
    this.sellersUID,
    this.productsID,
    this.productTitle,
    this.productDescription,
    this.status,
    this.productPrice,
    this.productQuantity,
    this.publishedDate,
    this.thumbnailUrl,
    this.sellersImageUrl,
    this.sellersName,
    this.sellersAddress,
   this.Open
  });

  Menus.fromJson(Map<String, dynamic> json)
  {
    menuID = json['menuID'];
    menuTitle = json['menuTitle'];
    sellersUID = json['sellersUID'];
    productsID = json['productsID'];
    productTitle= json['productTitle'];
    productDescription= json['productDescription'];
    status = json['status'];
    productPrice = json['productPrice'];
    productQuantity = json['productQuantity'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    sellersImageUrl = json['sellersImageUrl'];
    sellersName = json['sellersName'];
    sellersAddress = json['sellersAddress'];
    Open = json['open'];
    lat = json['lat'];
    lng = json['lng'];
  }


  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["menuID"] = menuID;
    data["lat"] = lat;
    data["lng"] = lng;
    data["menuTitle"] = menuTitle;
    data["sellerUID"] = sellersUID;
    data["productsID"] = productsID;
    data["productTitle"] = productTitle;
    data["productDescription"] = productDescription;
    data["productPrice"] = productPrice;
    data["productQuantity"] = productQuantity;
    data["publishedDate"] = publishedDate;
    data["thumbnailUrl"] = thumbnailUrl;
    data["status"] = status;
    data["sellersImageUrl"] = sellersImageUrl;
    data["sellersName"] = sellersName;
    data["sellersAddress"] = sellersAddress;
    data["open"] = Open;

    return data;
  }

}