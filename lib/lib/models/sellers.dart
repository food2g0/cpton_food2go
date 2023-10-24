class Sellers{
  String? sellersName;
  String? sellersUID;
  String? sellersAddress;
  String? sellersImageUrl;

  Sellers( {
    this.sellersName,
    this.sellersUID,
    this.sellersAddress,
    this.sellersImageUrl,
});

  Sellers.fromJson(Map<String, dynamic> json)
  {
    sellersUID = json["sellersUID"];
    sellersImageUrl = json["sellersImageUrl"];
    sellersName = json["sellersName"];
    sellersAddress = json["sellersAddress"];
  }

  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["sellersUID"] = sellersUID;
    data["sellersName"] = sellersName;
    data["address"] = sellersAddress;
    data["sellersImageUrl"] = sellersImageUrl;
    return data;
  }



}