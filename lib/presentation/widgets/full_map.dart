import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:oss/constants/constants.dart';

class FullMap extends StatefulWidget {
  final String? lat;
  final String? lng;
  final String? label;
  const FullMap(
      {super.key, required this.lat, required this.lng, required this.label});

  @override
  State createState() => FullMapState();
}

class FullMapState extends State<FullMap> {
  MapboxMap? mapboxMap;
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapWidget(
        key: const ValueKey("mapWidget"),
        resourceOptions:
            ResourceOptions(accessToken: Constants.mapBoxAccessToken),
        cameraOptions: CameraOptions(
          center: Point(
              coordinates: Position(
            double.parse(widget.lng!),
            double.parse(widget.lat!),
          )).toJson(),
          zoom: 15.0,
        ),
        styleUri: MapboxStyles.MAPBOX_STREETS,
        textureView: true,
        onMapCreated: _onMapCreated,
        onStyleLoadedListener: _onStyleLoadedCallback,
        onCameraChangeListener: _onCameraChangeListener,
        onMapIdleListener: _onMapIdleListener,
        onMapLoadedListener: _onMapLoadedListener,
        onMapLoadErrorListener: _onMapLoadingErrorListener,
        onRenderFrameStartedListener: _onRenderFrameStartedListener,
        onRenderFrameFinishedListener: _onRenderFrameFinishedListener,
        onSourceAddedListener: _onSourceAddedListener,
        onSourceDataLoadedListener: _onSourceDataLoadedListener,
        onSourceRemovedListener: _onSourceRemovedListener,
        onStyleDataLoadedListener: _onStyleDataLoadedListener,
        onStyleImageMissingListener: _onStyleImageMissingListener,
        onStyleImageUnusedListener: _onStyleImageUnusedListener,
      ),
    );
  }

  void createOneAnnotation(Uint8List list) {
    pointAnnotationManager
        ?.create(PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
              double.parse(widget.lng!),
              double.parse(widget.lat!),
            )).toJson(),
            textField: widget.label ?? "ที่ตั้ง ตำบล",
            textOffset: [0.0, -3.0],
            textColor: const Color.fromRGBO(244, 67, 54, 1).value,
            iconSize: 2,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            image: list))
        .then((value) => pointAnnotation = value);
  }

  _eventObserver(Event event) {
    print("Receive event, type: ${event.type}, data: ${event.data}");
  }

  _onCameraChangeListener(CameraChangedEventData data) {
    print("CameraChangedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.subscribe(_eventObserver, [
      MapEvents.STYLE_LOADED,
      MapEvents.MAP_LOADED,
      MapEvents.MAP_IDLE,
    ]);

    mapboxMap.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      final ByteData bytes = await rootBundle.load('assets/images/appeal.png');
      final Uint8List list = bytes.buffer.asUint8List();
      createOneAnnotation(list);
    });
  }

  _onMapIdleListener(MapIdleEventData data) {
    print("MapIdleEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onMapLoadedListener(MapLoadedEventData data) {
    print("MapLoadedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onMapLoadingErrorListener(MapLoadingErrorEventData data) {
    print("MapLoadingErrorEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onRenderFrameFinishedListener(RenderFrameFinishedEventData data) {
    print(
        "RenderFrameFinishedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onRenderFrameStartedListener(RenderFrameStartedEventData data) {
    print(
        "RenderFrameStartedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onSourceAddedListener(SourceAddedEventData data) {
    print("SourceAddedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onSourceDataLoadedListener(SourceDataLoadedEventData data) {
    print("SourceDataLoadedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onSourceRemovedListener(SourceRemovedEventData data) {
    print("SourceRemovedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onStyleDataLoadedListener(StyleDataLoadedEventData data) {
    print("StyleDataLoadedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onStyleImageMissingListener(StyleImageMissingEventData data) {
    print("StyleImageMissingEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onStyleImageUnusedListener(StyleImageUnusedEventData data) {
    print("StyleImageUnusedEventData: begin: ${data.begin}, end: ${data.end}");
  }

  _onStyleLoadedCallback(StyleLoadedEventData data) {
    print('style loaded');
  }
}
