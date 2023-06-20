import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/controllers/pois_controller.dart';

import '../../utils/map_utils.dart';

// ignore: must_be_immutable
class Destinations extends StatefulWidget {
  final String type;
  const Destinations({super.key, required this.type});

  @override
  State<Destinations> createState() => _DestinationsState();
}

class _DestinationsState extends State<Destinations> {
  // ignore: non_constant_identifier_names
  final PoisController _poisConroller = Get.put(PoisController());
  final errorMessageController = TextEditingController();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return _poisConroller.obx(
      (state) {
        RxList? data;
        if (widget.type == "food") {
          data = _poisConroller.foodList;
        }
        if (widget.type == "shopping") {
          data = _poisConroller.shoppingList;
        }
        if (widget.type == "factory") {
          data = _poisConroller.factoryList;
        }
        if (widget.type == "tourist") {
          data = _poisConroller.touristList;
        }
        if (widget.type == "hotel") {
          data = _poisConroller.hotelList;
        }

        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                kToolbarHeight,
            child: data!.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: data.length,
                    itemBuilder: (ctx, i) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: <Widget>[
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.green[300],
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      jsonDecode(
                                          data![i].data["images"][0])["url"],
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: 5,
                                  right: 5,
                                  child: FloatingActionButton(
                                    heroTag: 'navi_2',
                                    mini: true,
                                    onPressed: () {
                                      MapUtils.openMap(
                                          double.parse(jsonDecode(data![i]
                                              .data!["coordinates"])[1]),
                                          double.parse(jsonDecode(data[i]
                                              .data!["coordinates"])[0]));
                                    },
                                    child: Transform.rotate(
                                      angle: 45 * math.pi / 180,
                                      child: const Icon(
                                        Icons.navigation,
                                      ),
                                    ),
                                  ))
                            ]),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data[i]?.data["name"],
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 25,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      data[i].data["rating"].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const Text(
                              '~ 1.6 kilometers',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(child: Text('No Data')),
          ),
        );
      },
      onLoading: const Center(child: CircularProgressIndicator()),
    );
  }
}
