import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oss/constants/constants.dart';

import '../../data/services/appwrite_service.dart';

class ConfigController extends GetxController with StateMixin {
  final Account account = Account(Appwrite.instance.client);
  final Databases database = Databases(Appwrite.instance.client);
  final configList = [].obs;

  Future<void> getAllConfig() async {
    try {
      change(null, status: RxStatus.loading());

      var allConfigList = await database.listDocuments(
        databaseId: Constants.databseId,
        collectionId: Constants.configId,
      ); // add group ID filter
      // debugPrint(allConfigList.documents[0].data.toString());
      configList.value = allConfigList.documents;
      configList.refresh();

      // if done, change status to success
      change(null, status: RxStatus.success());
    } catch (e) {
      debugPrint('error ${e.toString()}');
      // Get.toNamed('/login');
    }
  }

  @override
  void onInit() {
    getAllConfig();
    super.onInit();
  }
}
