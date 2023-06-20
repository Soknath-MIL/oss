import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:oss/presentation/controllers/appeal_list_controller.dart';
import 'package:oss/presentation/controllers/message_controller.dart';

import '../../data/services/appwrite_service.dart';

class AppealList extends StatefulWidget {
  const AppealList({super.key});

  @override
  State<AppealList> createState() => _AppealListState();
}

class _AppealListState extends State<AppealList> {
  // ignore: non_constant_identifier_names
  final AppealListController _AppealListController = Get.put(
    AppealListController(),
  );

  final MessageConroller _messageConroller = Get.put(MessageConroller());
  var data = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _AppealListController.obx(
        (state) {
          data = _AppealListController.appealList;
          debugPrint('data length ${data.length.toString()}');
          return FadeInDown(
            child: RefreshIndicator(
              onRefresh: _pullRefresh,
              child: GroupedListView<dynamic, String>(
                elements: data,
                groupBy: (element) => element['group'],
                groupComparator: (value1, value2) => value2.compareTo(value1),
                itemComparator: (item1, item2) =>
                    item1['name'].compareTo(item2['name']),
                order: GroupedListOrder.DESC,
                useStickyGroupSeparators: true,
                groupSeparatorBuilder: (String value) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    value,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                itemBuilder: (c, element) {
                  return GestureDetector(
                    onTap: () async {
                      // check if flow of current appeal exist
                      var docExist = await AppwriteService()
                          .checkDocMaster(element["\$id"]);

                      debugPrint(
                          'docExist ${docExist?.documents[0].data.toString()}');
                      if (docExist == null) {
                        Get.snackbar(
                          "ข้อผิดพลาด",
                          "ไม่มีเวิร์กโฟลว์ ของเอกสาร",
                          colorText: Colors.white,
                          icon: const Icon(Icons.cancel),
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      } else {
                        Get.toNamed("/appeal-request", arguments: [
                          docExist.documents[0].data["\$id"],
                          element["\$id"],
                          element["name_t"],
                          docExist.documents[0].data["docOwner"],
                        ]);
                        return;
                      }
                    },
                    child: Card(
                      elevation: 0,
                      child: SizedBox(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 4.0,
                          ),
                          dense: true,
                          leading: element["icon"] != null
                              ? Container(
                                  padding: const EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    child: CachedNetworkImage(
                                      imageUrl: jsonDecode(element["icon"])[0]
                                          ["url"],
                                      width: 30,
                                    ),
                                  ))
                              : const Icon(Icons.info),
                          title: Text(element['name']),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        onLoading: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  void checkLogin() async {
    await _messageConroller.getUserId();
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> _pullRefresh() async {
    setState(() {
      data = [];
    });
    await _AppealListController.getAllAppeals();
  }
}
