import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:oss/presentation/controllers/message_controller.dart';

import '../../data/services/appwrite_service.dart';
import '../controllers/doc_type_controller.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key});

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  // ignore: non_constant_identifier_names
  final DocTypesController docTypesController = Get.put(
    DocTypesController(),
  );

  final MessageConroller _messageConroller = Get.put(MessageConroller());
  List<String> allRequestListPage = [];
  String? unitId = Get.arguments[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('คำขอทั้งหมด')),
      body: SafeArea(
        child: docTypesController.obx(
          (state) {
            var data = [];
            // filter if have arguments
            debugPrint('${docTypesController.docTyesGroupList}');
            if (unitId != "") {
              data = docTypesController.docTyesGroupList
                  .where((i) => i["unit_id"] == unitId)
                  .toList();
            } else {
              data = docTypesController.docTyesGroupList;
            }

            debugPrint('data request ${data.toString()}');

            if (data.isEmpty) {
              return const Center(
                child: Text('ไม่มีเอกสาร'),
              );
            }
            return GroupedListView<dynamic, String>(
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
                    // check if flow of current Request exist
                    var docExist = await AppwriteService()
                        .checkDocMasterName(element["link"]);
                    if (docExist == null) {
                      Get.snackbar(
                        "ข้อผิดพลาด",
                        "ไม่มีเวิร์กโฟลว์ ของเอกสาร",
                        colorText: Colors.white,
                        icon: const Icon(Icons.cancel),
                        snackPosition: SnackPosition.TOP,
                      );
                    } else {
                      Get.toNamed('/${element["link"]}-form');
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
            );
          },
          onLoading: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  void checkLogin() async {
    await _messageConroller.getUserId();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }
}
