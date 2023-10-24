

import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapsUtil
{
  MapsUtil._();

  static Future<void> openMapWithPosition(double latitude, double longitude) async {
    String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      print("Could not open the map. Please check your device settings.");
    }
  }


  static Future<void> openMapWithAddress(String fullAddress) async
  {
    String query = Uri.encodeComponent(fullAddress);
    String googleMapUrl = "https://www.google.com/maps/search/?api=1&query=$query";

    if (await canLaunch(googleMapUrl))
    {
      await launch(googleMapUrl);
    }
    else
    {
      throw "Could not open the map.";
    }
  }
  }
