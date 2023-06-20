import 'dart:convert';
import 'dart:math' as math;

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/controllers/unit_controller.dart';

import '../../constants/constants.dart';
import '../../data/services/appwrite_service.dart';
import '../controllers/message_controller.dart';

const storage = FlutterSecureStorage();

class UnitSelectionPage extends StatefulWidget {
  const UnitSelectionPage({super.key});

  @override
  State<UnitSelectionPage> createState() => _UnitSelectionPageState();
}

class _UnitSelectionPageState extends State<UnitSelectionPage> {
  final UnitController unitController = Get.put(
    UnitController(),
  );
  final MessageConroller _messageConroller = Get.put(MessageConroller());
  var messageData = {};
  RealtimeSubscription? _subscription;

  @override
  Widget build(BuildContext context) {
    return unitController.obx(
      (state) {
        debugPrint(
            'image url ${jsonDecode(unitController.unitList[0].data["image"])[0]["url"]}');
        return SafeArea(
          child: ListView.builder(
              itemCount: unitController.unitList.length,
              itemBuilder: (ctx, i) {
                return GestureDetector(
                  onTap: () {
                    Get.toNamed('/chat', arguments: [
                      unitController.unitList[i].data["name_t"],
                      unitController.unitList[i].data["\$id"]
                    ]);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Color(
                        (math.Random().nextDouble() * 0xFFFFFF).toInt(),
                      ).withOpacity(0.5),
                    ),
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                          imageUrl: jsonDecode(
                                  unitController.unitList[i].data["image"])[0]
                              ["url"],
                        ),
                        (messageData[unitController.unitList[i].data["\$id"]] !=
                                    null &&
                                messageData[unitController
                                        .unitList[i].data["\$id"]] !=
                                    0)
                            ? Badge(
                                label: Text(
                                  messageData[unitController
                                          .unitList[i].data["\$id"]]
                                      .toString(),
                                ),
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300.0),
                                  child: Chip(
                                    elevation: 2,
                                    label: Text(
                                      'chit·chat ${unitController.unitList[i].data["name_t"]}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 300.0),
                                child: Chip(
                                  elevation: 2,
                                  label: Text(
                                    'chit·chat ${unitController.unitList[i].data["name_t"]}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              }),
        );
      },
      onLoading: const Center(child: VideoShimmer()),
    );
  }

  void checkLogin() async {
    await _messageConroller.getUserId();
    setState(() {
      messageData = _messageConroller.unreadMessage;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription!.close();
  }

  @override
  void initState() {
    super.initState();
    checkLogin();

    final realtime = Realtime(Appwrite.instance.client);
    _subscription = realtime.subscribe([
      'databases.${Constants.databseId}.collections.${Constants.userId}.documents'
    ]);

    _subscription!.stream.listen((response) async {
      // Callback will be executed on changes for documents A and all files.
      String? userID = await storage.read(key: 'userID');
      if (response.payload["\$id"] == userID!) {
        checkLogin();
      }
      // do query to update massage
    });
  }
}
