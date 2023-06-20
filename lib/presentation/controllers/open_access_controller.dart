import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class OpenAccessController extends GetxController {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final openAccessList = [].obs;

  Future<void> getAllOpenAccess() async {
    try {
      var allOpenAccessList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.openAccessId,
      ); // add group ID filter
      // debugPrint('journal ${allOpenAccessList.documents[0].data.toString()}');
      openAccessList.value = allOpenAccessList.documents;
      openAccessList.refresh();
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllOpenAccess();
    super.onInit();
  }
}
