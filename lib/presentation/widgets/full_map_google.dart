import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_location_picker/map_location_picker.dart';

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
      .buffer
      .asUint8List();
}

class FullGoogleMap extends State<MapGoogle> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  void addCustomIcon() async {
    final Uint8List iconData =
        await getBytesFromAsset('assets/images/appeal.png', 100);
    setState(() {
      markerIcon = BitmapDescriptor.fromBytes(iconData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.satellite,
        initialCameraPosition: CameraPosition(
          target: LatLng(double.parse(widget.lat!), double.parse(widget.lng!)),
          zoom: 18,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationButtonEnabled: false,
        markers: {
          Marker(
            markerId: const MarkerId("appealLocation"),
            position:
                LatLng(double.parse(widget.lat!), double.parse(widget.lng!)),
            icon: markerIcon,
          ),
        },
      ),
    );
  }

  @override
  void initState() {
    addCustomIcon();
    super.initState();
  }
}

class MapGoogle extends StatefulWidget {
  final String? lat;
  final String? lng;
  final String? label;
  const MapGoogle(
      {super.key, required this.lat, required this.lng, required this.label});

  @override
  State<MapGoogle> createState() => FullGoogleMap();
}
