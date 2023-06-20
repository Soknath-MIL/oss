import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      Get.snackbar(
        'Redirect Error',
        'No navigation app found',
        colorText: Colors.white,
        backgroundColor: Colors.redAccent,
        icon: const Icon(Icons.error),
      );
      throw 'Could not open the map.';
    }
  }
}
