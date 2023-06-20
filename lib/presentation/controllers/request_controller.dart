import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class RequestController extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final reqList = [].obs;
  final userId = ''.obs;

  Future<void> getAllRequest() async {
    try {
      change(null, status: RxStatus.loading());

      var accountObject = await account.get();
      userId.value = accountObject.$id;
      debugPrint(userId.toString());
      var requestList = await database.listDocuments(
          databaseId: Constants.databseId,
          collectionId: Constants.requestId,
          queries: [
            Query.equal('userId', userId.value),
            Query.orderDesc("\$createdAt")
          ]); // add group ID filter
      debugPrint('request ${requestList.documents.toString()}');
      reqList.value = requestList.documents;
      reqList.refresh();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }
}
