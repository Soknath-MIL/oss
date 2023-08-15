import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:get/get.dart';
import 'package:oss/presentation/controllers/unit_controller.dart';

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
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      color: Color.fromRGBO(231, 231, 231, 1),
                    ),
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 48, // Image radius
                          backgroundImage: NetworkImage(jsonDecode(
                                  unitController.unitList[i].data["image"])[0]
                              ["url"]),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ชิทแชท',
                              style: TextStyle(fontSize: 16),
                            ),
                            (messageData[unitController
                                            .unitList[i].data["\$id"]] !=
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
                                        backgroundColor: const Color.fromRGBO(
                                            41, 153, 20, 1),
                                        elevation: 2,
                                        label: Text(
                                          '${unitController.unitList[i].data["name_t"]}',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
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
                                      backgroundColor: const Color.fromRGBO(
                                        41,
                                        153,
                                        20,
                                        1,
                                      ),
                                      elevation: 2,
                                      label: Text(
                                        '${unitController.unitList[i].data["name_t"]}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
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
    if (_subscription != null) {
      _subscription!.close();
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();

    // final realtime = Realtime(Appwrite.instance.client);
    // _subscription = realtime.subscribe([
    //   'databases.${Constants.databseId}.collections.${Constants.userId}.documents'
    // ]);

    // _subscription!.stream.listen((response) async {
    //   // Callback will be executed on changes for documents A and all files.
    //   String? userID = await storage.read(key: 'userID');
    //   if (response.payload["\$id"] == userID!) {
    //     checkLogin();
    //   }
    //   // do query to update massage
    // });
  }
}
