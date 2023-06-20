import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class AppealListController extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final allAppealList = [];
  final appealList = [].obs;

  Future<void> getAllAppeals() async {
    try {
      change(null, status: RxStatus.loading());
      appealList.clear();
      var allAppeals = await database.listDocuments(
          databaseId: Constants.databseId,
          collectionId: Constants.appealCategoryId,
          queries: [Query.equal("show", true)]);
      // add group ID filter
      for (var e in allAppeals.documents) {
        allAppealList.add({...e.data});
      }
      appealList.value = allAppealList;
      appealList.refresh();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllAppeals();
    super.onInit();
  }
}
