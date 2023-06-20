import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:oss/constants/constants.dart';
import 'package:oss/presentation/controllers/pois_controller.dart';

import '../../utils/map_utils.dart';

class AnnotationClickListener extends OnPointAnnotationClickListener {
  Function navigate;
  AnnotationClickListener(this.navigate);

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    print("onAnnotationClick, id: ${annotation.id}");
    navigate(int.parse(annotation.id));
  }
}

class MapViewPage extends StatefulWidget {
  const MapViewPage({Key? key}) : super(key: key);

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage>
    with TickerProviderStateMixin {
  final PoisController poisController = Get.put(PoisController());

  final pageController = PageController();
  int selectedIndex = 0;
  var currentLocation = Constants.tambonLocation;
  String searchValue = '';
  PointAnnotation? pointAnnotation;
  PointAnnotationManager? pointAnnotationManager;

  MapboxMap? mapboxMap;

  @override
  Widget build(BuildContext context) {
    return poisController.obx(
      (state) {
        // create suggestions list
        List<String> suggestions = [];
        for (var element in poisController.poisList) {
          suggestions.add(
            element.data["name"],
          );
        }
        return Scaffold(
          appBar: EasySearchBar(
            iconTheme: const IconThemeData(
              color: Colors.white, //change your color here
            ),
            title: const Text(
              'แนะนำสถานที่',
              style: TextStyle(color: Colors.white),
            ),
            onSearch: (value) => setState(() => searchValue = value),
            suggestions: suggestions,
            onSuggestionTap: (data) {
              debugPrint("data $data");
              // navigate map
              navigate(suggestions.indexOf(data));
            },
          ),
          body: Stack(
            children: [
              MapWidget(
                key: const ValueKey("mapWidget"),
                resourceOptions:
                    ResourceOptions(accessToken: Constants.mapBoxAccessToken),
                cameraOptions: CameraOptions(
                  center: Point(
                      coordinates: Position(
                    Constants.tambonLocation.longitude,
                    Constants.tambonLocation.latitude,
                  )).toJson(),
                  zoom: 15.0,
                ),
                styleUri: MapboxStyles.MAPBOX_STREETS,
                textureView: true,
                onMapCreated: _onMapCreated,
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 2,
                height: MediaQuery.of(context).size.height * 0.2,
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (value) {
                    selectedIndex = value;
                    currentLocation = LatLng(
                        double.parse(jsonDecode(poisController
                            .poisList[value].data["coordinates"])[1]),
                        double.parse(jsonDecode(poisController
                            .poisList[value].data["coordinates"])[0]));
                    _animatedMapMove(currentLocation, 12);
                    setState(() {});
                  },
                  itemCount: poisController.poisList.length,
                  itemBuilder: (_, index) {
                    final item = poisController.poisList[index].data;
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.grey[900],
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        scrollDirection: Axis.horizontal,
                                        itemCount: item["rating"],
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Icon(
                                            Icons.star,
                                            color: Colors.green[500],
                                          );
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/${item["type"]}.png',
                                                width: 30,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                item["name"] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.map,
                                                color: Colors.green,
                                              ),
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              Text(
                                                item["address"] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Stack(
                                  alignment: AlignmentDirectional.topEnd,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: jsonDecode(
                                                  item["images"][0])["url"] ??
                                              '',
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                    ),
                                    FloatingActionButton(
                                      heroTag: 'navi_3',
                                      mini: true,
                                      onPressed: () {
                                        MapUtils.openMap(
                                            double.parse(jsonDecode(
                                                item!["coordinates"])[1]),
                                            double.parse(jsonDecode(
                                                item!["coordinates"])[0]));
                                      },
                                      child: Transform.rotate(
                                        angle: 45 * math.pi / 180,
                                        child: const Icon(
                                          Icons.navigation,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
      onLoading: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  void navigate(int i) {
    pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    selectedIndex = i;
    currentLocation = LatLng(
        double.parse(
            jsonDecode(poisController.poisList[i].data["coordinates"])[1]),
        double.parse(
            jsonDecode(poisController.poisList[i].data["coordinates"])[0]));
    _animatedMapMove(currentLocation, 12);
    setState(() {});
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    mapboxMap?.easeTo(
        CameraOptions(
            center: Point(
                coordinates: Position(
              destLocation.longitude,
              destLocation.latitude,
            )).toJson(),
            zoom: 15,
            bearing: 0,
            pitch: 3),
        MapAnimationOptions(duration: 2000, startDelay: 0));
  }

  _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    mapboxMap.annotations.createPointAnnotationManager().then((value) async {
      pointAnnotationManager = value;
      final ByteData bytes = await rootBundle.load(
        'assets/icons/map-mark.png',
      );
      final Uint8List list = bytes.buffer.asUint8List();
      var options = <PointAnnotationOptions>[];
      for (var i = 0; i < poisController.poisList.length; i++) {
        var data = poisController.poisList[i].data;
        options.add(
          PointAnnotationOptions(
            geometry: Point(
                coordinates: Position(
              double.parse(jsonDecode(data["coordinates"])[0]),
              double.parse(jsonDecode(data["coordinates"])[1]),
            )).toJson(),
            textField: data["name"],
            textOffset: [0.0, -2.0],
            textColor: const Color.fromRGBO(244, 67, 54, 1).value,
            iconSize: 1,
            iconOffset: [0.0, -5.0],
            symbolSortKey: 10,
            image: list,
          ),
        );
      }
      pointAnnotationManager?.createMulti(options);
      pointAnnotationManager?.addOnPointAnnotationClickListener(
          AnnotationClickListener(navigate));
    });
  }
}
