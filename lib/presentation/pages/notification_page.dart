import 'package:animate_do/animate_do.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_shimmer/flutter_shimmer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:oss/presentation/controllers/message_controller.dart';
import 'package:oss/presentation/controllers/notification_controller.dart';
import 'package:oss/presentation/widgets/empty_widget.dart';

import '../../data/services/appwrite_service.dart';

const storage = FlutterSecureStorage();

class NotificationsPage extends StatefulWidget {
  final Function clearNotification;
  const NotificationsPage({super.key, required this.clearNotification});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController _notificationConroller =
      Get.put(NotificationController());
  final MessageConroller _messageConroller = Get.put(MessageConroller());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _pullRefresh,
      child: _notificationConroller.obx(
        (state) => _notificationConroller.notiList.isEmpty
            ? const EmptyWidget()
            : FadeInDown(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: List.generate(
                    _notificationConroller.notiList.length,
                    (index) => renderItem(index),
                  ),
                ),
              ),
        onLoading: const Center(child: ProfilePageShimmer()),
      ),
    );
  }

  void checkLogin() async {
    await _messageConroller.getUserId();
    debugPrint('mesaage data ${_messageConroller.accountData["data"]}');
    await _notificationConroller.getAllNotifications(
      _messageConroller.accountData["data"]["group"],
      _messageConroller.user$Id,
    );
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
    widget.clearNotification();
  }

  renderItem(int index) {
    var data = _notificationConroller.notiList[index].data;
    debugPrint('print ${data["source"].toString()}');

    return GestureDetector(
      onTap: () async {
        // TODO link to actual data instead, add easy loading
        if (_notificationConroller.notiList[index].data["type"] == "news") {
          var newData = await AppwriteService()
              .getNews(_notificationConroller.notiList[index].data["source"]);
          Get.toNamed("/news-detail", arguments: [newData?.data]);
          return;
        }
        if (_notificationConroller.notiList[index].data["type"] == "request") {
          Document? newData;
          if (_notificationConroller.notiList[index].data["type"] ==
              "request") {
            try {
              newData = await AppwriteService().getRequest(
                  _notificationConroller.notiList[index].data["source"]);
              Get.toNamed("/request-detail", arguments: [newData?.data]);
              return;
            } catch (e) {
              Get.snackbar(
                "ข้อผิดพลาด",
                "ไม่พบรายละเอียด",
                duration: const Duration(seconds: 1),
                colorText: Colors.white,
                icon: const Icon(Icons.cancel_outlined),
                snackPosition: SnackPosition.TOP,
              );
              return;
            }
          }
        }
        Get.snackbar(
          "ข้อผิดพลาด",
          "ไม่พบข้อมูลการแจ้งเตือน",
          colorText: Colors.white,
          icon: const Icon(Icons.cancel_rounded),
          duration: const Duration(seconds: 1),
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 1),
              color: Colors.black12,
              blurRadius: 1,
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 300.0),
                            child: Text(
                              data["title"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          // Container(
                          //   constraints: const BoxConstraints(maxWidth: 300.0),
                          //   child: Text(
                          //     data["subTitle"],
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          // ),
                        ],
                      ),
                      _notificationConroller.notiList[index].data["type"] ==
                              "news"
                          ? const Icon(
                              Icons.newspaper,
                              color: Colors.white,
                            )
                          : (_notificationConroller
                                      .notiList[index].data["type"] ==
                                  "request"
                              ? const Icon(
                                  Icons.list_alt_rounded,
                                  color: Colors.white,
                                )
                              : Container()),
                    ],
                  ),
                  Expanded(child: Container()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.yMd('th')
                            .add_jm()
                            .format(DateTime.parse(data["subTitle"]).toLocal()),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
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
    );
  }

  Future<void> _pullRefresh() async {
    await _notificationConroller.getAllNotifications(
      _messageConroller.accountData["data"]["group"],
      _messageConroller.user$Id,
    );
  }
}
