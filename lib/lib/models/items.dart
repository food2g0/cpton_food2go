import 'package:cloud_firestore/cloud_firestore.dart';

class Items
{

  String? productsID;
  String? sellersUID;
  String? productTitle;
  String? productDescription;
  String? status;
  int? productPrice;
  int? productQuantity;
  Timestamp? publishedDate;
  String? thumbnailUrl;


  Items
  ({
    this.sellersUID,
    this.productsID,
    this.productTitle,
    this.productDescription,
    this.status,
    this.productPrice,
    this.productQuantity,
    this.publishedDate,
    this.thumbnailUrl,

});

  Items.fromJson(Map<String, dynamic> json)
  {

    productsID = json['productsID'];
    sellersUID = json['sellersUID'];
    productTitle= json['productTitle'];
    productDescription= json['productDescription'];
    status = json['status'];
    productPrice = json['productPrice'];
    productQuantity = json['productQuantity'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];

  }


  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data["productsID"] = this.productsID;
    data["sellersUID"] = this.sellersUID;
    data["productTitle"] = this.productTitle;
    data["productDescription"] = this.productDescription;
    data["productPrice"] = this.productPrice;
    data["productQuantity"] = this.productQuantity;
    data["publishedDate"] = this.publishedDate;
    data["thumbnailUrl"] = this.thumbnailUrl;
    data["status"] = this.status;


    return data;
  }

}