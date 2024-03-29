class Address
{
  String? name;
  String? phoneNumber;
  String? flatNumber;
  String? paymentMode;
  String? postalCode;
  String? city;
  String? state;
  String? fullAddress;
  double? lat;
  double? lng;

  Address({
    this.postalCode,
   this.name,
    this.paymentMode,
    this.phoneNumber,
    this.flatNumber,
    this.city,
    this.state,
    this.fullAddress,
    this.lat,
    this.lng,
});

  Address.fromJson(Map<String, dynamic> json)
  {
    name = json['name'];
    paymentMode = json['paymentMode'];
    phoneNumber = json['phoneNumber'];
    flatNumber = json['flatNumber'];
    city = json['city'];
    state = json['state'];
    fullAddress = json['fullAddress'];
    postalCode = json['postalCode'];
    lat = json['lat'];
    lng = json['lng'];

  }



  Map<String, dynamic> toJson()
  {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['paymentMode'] = paymentMode;
    data['phoneNumber'] = phoneNumber;
    data['flatNumber'] = flatNumber;
    data['city'] = city;
    data['state'] = state;
    data['fullAddress'] = fullAddress;
    data['postalCode'] = postalCode;
    data['lat'] = lat;
    data['lng'] = lng;

    return data;

  }

}