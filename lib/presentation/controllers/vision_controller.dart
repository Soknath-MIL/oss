import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class VisionController extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final visionList = [].obs;

  Future<void> getAllVision() async {
    try {
      change(null, status: RxStatus.loading());

      var allVisionList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.tambonHistoryId,
      ); // add group ID filter
      // debugPrint(allVisionList.documents[0].data.toString());
      visionList.value = allVisionList.documents;
      visionList.refresh();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllVision();
    super.onInit();
  }
}
