import 'dart:convert';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:get/get.dart';

import '../controllers/vision_controller.dart';

class VisionPage extends StatefulWidget {
  const VisionPage({super.key});

  @override
  State<VisionPage> createState() => _VisionPageState();
}

class _VisionPageState extends State<VisionPage> {
  final VisionController visionController = Get.put(
    VisionController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลทั่วไปของ อบต.')),
      body: visionController.obx(
        (state) {
          return SafeArea(
            child: ListView.builder(
                itemCount: visionController.visionList.length,
                itemBuilder: (ctx, i) {
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Color(
                          (math.Random().nextDouble() * 0xFFFFFF).toInt(),
                        ).withOpacity(0.3),
                      ),
                      height: 130,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                20,
                              ),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: jsonDecode(visionController
                                  .visionList[i].data["image"])[0]["url"],
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Chip(
                                  elevation: 2,
                                  label: Text(
                                    visionController.visionList[i].data["type"],
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed("/vision-detail", arguments: [
                                      visionController.visionList[i].data
                                    ]);
                                  },
                                  child: Icon(
                                    Icons.open_in_new,
                                    color: Colors.grey[600],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          );
        },
        onLoading: Center(
            child: Column(
          children: const [
            ListTileShimmer(),
            ListTileShimmer(),
            ListTileShimmer(),
            ListTileShimmer(),
          ],
        )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
