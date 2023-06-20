import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class NotificationController extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final userId = ''.obs;
  final user$Id = ''.obs;
  final notiList = [].obs;

  Future<void> getAllNotifications(userGroup, userID) async {
    try {
      change(null, status: RxStatus.loading());

      var accountObject = await account.get();
      userId.value = accountObject.$id;
      var notificationList = [];
      // for news notification
      for (var i = 0; i < userGroup.length; i++) {
        var each = userGroup[i];
        await database.listDocuments(
          databaseId: Constants.databseId,
          collectionId: Constants.notificationId,
          queries: [
            Query.search("userGroups", each),
            Query.equal("status", "sent"),
            Query.equal("type", "news"),
            Query.orderDesc("\$createdAt"),
          ],
        ).then((response) {
          notificationList.addAll(response.documents);
        });
      }
      // For request notification
      await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.notificationId,
        queries: [
          Query.equal("status", "sent"),
          Query.equal("creator", userID),
          Query.equal("type", "request"),
          Query.orderDesc("\$createdAt"),
        ],
      ).then((response) {
        notificationList.addAll(response.documents);
      });
      notiList.value = notificationList;
      notiList.refresh();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  Future<void> getUserId() async {
    try {
      var accountObject = await account.get();
      userId.value = accountObject.$id;
      var userDetail = await database.getDocument(
        databaseId: Constants.databseId,
        collectionId: Constants.userId,
        documentId: accountObject.$id,
      );
      user$Id.value = userDetail.$id.toString();
    } catch (e) {
      debugPrint('error ${e.toString()}');
      Get.toNamed('/login');
    }
  }
}
